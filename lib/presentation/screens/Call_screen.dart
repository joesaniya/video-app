import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_call_app/Business-Logic/call_provider.dart';
import 'package:video_call_app/presentation/screens/home_screen.dart';
import 'package:video_call_app/presentation/utils/appcolors.dart';

class CallScreen extends StatefulWidget {
  final VoidCallback? onCallEnded;
  final String username;
  final String meetingId;

  const CallScreen({
    super.key,
    required this.onCallEnded,
    required this.username,
    required this.meetingId,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  CallProvider? _provider;
  bool _isInitializing = true;
  String? _initError;
  bool _hadRemoteUser = false; // Track if remote user was ever present

  @override
  void initState() {
    super.initState();
    // Schedule initialization after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCall();
    });
  }

  Future<void> _initializeCall() async {
    if (_provider == null) return;

    try {
      await _provider!.initialize();
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      log('Error initializing call: $e');
      if (mounted) {
        setState(() {
          _initError = e.toString();
          _isInitializing = false;
        });
        _showErrorDialog('Failed to initialize call: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleEndCall();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRemoteUserLeftDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Call Ended'),
        content: const Text('Guest has left the call'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _handleEndCall();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEndCall() async {
    if (_provider != null) {
      await _provider!.endCall();
    }
    widget.onCallEnded?.call();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      });
    }
  }

  Future<void> _handleToggleScreenShare() async {
    if (_provider == null) return;

    try {
      await _provider!.toggleScreenShare();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle screen sharing: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log('Name: ${widget.username}, Meeting ID: ${widget.meetingId}');
    final colors = AppColors();

    return ChangeNotifierProvider(
      create: (_) => CallProvider(),
      child: Consumer<CallProvider>(
        builder: (context, provider, child) {
          // Assign provider reference
          _provider = provider;

          if (_isInitializing) {
            return Scaffold(
              backgroundColor: colors.bgColor,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          // Show error if initialization failed
          if (_initError != null) {
            return Scaffold(
              backgroundColor: colors.bgColor,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to initialize call',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _initError!,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _handleEndCall,
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Track when remote user joins
          if (provider.remoteUid != null && !_hadRemoteUser) {
            _hadRemoteUser = true;
          }

          // Only show dialog if remote user LEFT (not if they never joined)
          if (provider.remoteUid == null &&
              provider.localUserJoined &&
              _hadRemoteUser) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _showRemoteUserLeftDialog();
                _hadRemoteUser = false; // Reset to prevent multiple dialogs
              }
            });
          }

          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              backgroundColor: colors.bgColor,
              body: Stack(
                children: [
                  // Remote video (full screen)
                  Positioned.fill(
                    child: _RemoteVideoWidget(
                      provider: provider,
                      meetingId: widget.meetingId,
                      username: widget.username,
                    ),
                  ),

                  // Top section
                  _TopSection(provider: provider, username: widget.username),

                  // Screen sharing indicator
                  if (provider.isScreenSharing) _ScreenSharingIndicator(),

                  // Bottom controls
                  _BottomControls(
                    provider: provider,
                    onEndCall: _handleEndCall,
                    onToggleScreenShare: _handleToggleScreenShare,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Top section widget
class _TopSection extends StatelessWidget {
  final CallProvider provider;
  final String username;

  const _TopSection({required this.provider, required this.username});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  provider.formatDuration(provider.callDuration),
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            _LocalPreviewWidget(provider: provider),
          ],
        ),
      ),
    );
  }
}

// Local preview widget
class _LocalPreviewWidget extends StatelessWidget {
  final CallProvider provider;

  const _LocalPreviewWidget({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildPreview(),
    );
  }

  Widget _buildPreview() {
    if (provider.isScreenSharing) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: provider.engine,
          canvas: const VideoCanvas(
            uid: 0,
            sourceType: VideoSourceType.videoSourceScreen,
          ),
        ),
      );
    } else if (provider.localUserJoined) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: provider.engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }
  }
}

// Screen sharing indicator
class _ScreenSharingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 140,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.screen_share, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              'Sharing Screen',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom controls widget
class _BottomControls extends StatelessWidget {
  final CallProvider provider;
  final VoidCallback onEndCall;
  final VoidCallback onToggleScreenShare;

  const _BottomControls({
    required this.provider,
    required this.onEndCall,
    required this.onToggleScreenShare,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 40,
          top: 40,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.4),
              Colors.transparent,
            ],
          ),
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: 8,
          runSpacing: 12,
          children: [
            _ControlButton(
              icon: provider.isMuted ? Icons.mic_off : Icons.mic,
              label: 'Mute',
              onTap: provider.toggleMute,
              isActive: provider.isMuted,
            ),
            _ControlButton(
              icon: provider.isCameraOff ? Icons.videocam_off : Icons.videocam,
              label: 'Camera',
              onTap: provider.toggleCamera,
              isActive: provider.isCameraOff,
            ),
            _ControlButton(
              icon: Icons.flip_camera_ios,
              label: 'Flip',
              onTap: provider.switchCamera,
            ),
            _ControlButton(
              icon: provider.isScreenSharing
                  ? Icons.stop_screen_share
                  : Icons.screen_share,
              label: 'Share',
              onTap: onToggleScreenShare,
              isActive: provider.isScreenSharing,
              backgroundColor: provider.isScreenSharing ? Colors.green : null,
            ),
            _ControlButton(
              icon: Icons.call_end,
              label: 'End',
              onTap: onEndCall,
              backgroundColor: const Color(0xFFFF4757),
              isEndButton: true,
            ),
          ],
        ),
      ),
    );
  }
}

// Control button widget
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final bool isActive;
  final bool isEndButton;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.isActive = false,
    this.isEndButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    backgroundColor ??
                    (isActive
                        ? Colors.white.withOpacity(0.4)
                        : Colors.white.withOpacity(0.2)),
                border: isEndButton
                    ? null
                    : Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Remote video widget
class _RemoteVideoWidget extends StatelessWidget {
  final CallProvider provider;
  final String meetingId;
  final String username;

  const _RemoteVideoWidget({
    required this.provider,
    required this.meetingId,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: provider.engine,
          canvas: VideoCanvas(uid: provider.remoteUid),
          connection: RtcConnection(channelId: meetingId),
        ),
      );
    } else {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 80,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Waiting for guest to join...',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}
