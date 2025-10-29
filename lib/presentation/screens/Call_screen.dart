import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_call_app/Business-Logic/call_provider.dart';
import 'package:video_call_app/presentation/screens/home_screen.dart';
import 'package:video_call_app/presentation/utils/appcolors.dart';
import 'package:video_call_app/presentation/widgets/call_bottom_controls.dart';
import 'package:video_call_app/presentation/widgets/call_header.dart';
import 'package:video_call_app/presentation/widgets/local_cam_preview.dart';
import 'package:video_call_app/presentation/widgets/remote_video_preview.dart';
import 'package:video_call_app/presentation/widgets/screen_share.dart';

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
  bool _hadRemoteUser = false;

  @override
  void initState() {
    super.initState();
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
          _provider = provider;

          if (_isInitializing) {
            return Scaffold(
              backgroundColor: colors.bgColor,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

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

          if (provider.remoteUid != null && !_hadRemoteUser) {
            _hadRemoteUser = true;
          }

          if (provider.remoteUid == null &&
              provider.localUserJoined &&
              _hadRemoteUser) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _showRemoteUserLeftDialog();
                _hadRemoteUser = false;
              }
            });
          }

          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              backgroundColor: colors.bgColor,
              body: Stack(
                children: [
                  Positioned.fill(
                    child: RemoteVideoWidget(
                      provider: provider,
                      meetingId: widget.meetingId,
                      remoteUsername: provider.remoteUsername,
                    ),
                  ),

                  TopSection(provider: provider, username: widget.username),

                  if (provider.isScreenSharing) ScreenSharingIndicator(),

                  LocalPreviewWidget(
                    provider: provider,
                    username: widget.username,
                  ),

                  BottomControls(
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
