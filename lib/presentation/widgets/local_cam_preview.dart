import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_call_app/Business-Logic/call_provider.dart';


class LocalPreviewWidget extends StatelessWidget {
  final CallProvider provider;
  final String username;

  const LocalPreviewWidget({required this.provider, required this.username});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 200, 
      child: Container(
        width: 100,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildPreview(),
      ),
    );
  }

  Widget _buildPreview() {
   
    if (provider.isCameraOff && !provider.isScreenSharing) {
      return Container(
        color: Colors.grey[800],
        child: Center(
          child: Text(
            username.isNotEmpty ? username[0].toUpperCase() : '?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

   
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
    }

  
    if (provider.localUserJoined) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: provider.engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    }

 
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      ),
    );
  }
}