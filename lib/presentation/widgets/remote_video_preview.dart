import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_call_app/Business-Logic/call_provider.dart';
import 'package:video_call_app/presentation/widgets/call_control_button.dart';


class RemoteVideoWidget extends StatelessWidget {
  final CallProvider provider;
  final String meetingId;
  final String remoteUsername;

  const RemoteVideoWidget({
    required this.provider,
    required this.meetingId,
    required this.remoteUsername,
  });

  @override
  Widget build(BuildContext context) {
  
    if (provider.remoteUid != null) {
      return Stack(
        children: [
        
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: provider.engine,
              canvas: VideoCanvas(uid: provider.remoteUid),
              connection: RtcConnection(channelId: meetingId),
            ),
          ),


          if (provider.remoteUid != null && provider.isRemoteCameraOff)
            Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  remoteUsername.isNotEmpty
                      ? remoteUsername[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    }

   
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
