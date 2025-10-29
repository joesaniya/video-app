import 'package:flutter/material.dart';
import 'package:video_call_app/Business-Logic/call_provider.dart';
import 'package:video_call_app/presentation/widgets/call_control_button.dart';

class BottomControls extends StatelessWidget {
  final CallProvider provider;
  final VoidCallback onEndCall;
  final VoidCallback onToggleScreenShare;

  const BottomControls({
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
          spacing: 16,
          runSpacing: 12,
          children: [
            ControlButton(
              icon: provider.isMuted ? Icons.mic_off : Icons.mic,
              label: 'Mute',
              onTap: provider.toggleMute,
              isActive: provider.isMuted,
            ),
            ControlButton(
              icon: provider.isCameraOff ? Icons.videocam_off : Icons.videocam,
              label: 'Camera',
              onTap: () async => await provider.toggleCamera(),
              isActive: provider.isCameraOff,
            ),
            ControlButton(
              icon: provider.isScreenSharing
                  ? Icons.stop_screen_share
                  : Icons.screen_share,
              label: 'Share',
              onTap: onToggleScreenShare,
              isActive: provider.isScreenSharing,
              backgroundColor: provider.isScreenSharing ? Colors.green : null,
            ),
            ControlButton(
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
