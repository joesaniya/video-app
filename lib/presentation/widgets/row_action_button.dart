import 'package:flutter/material.dart';
import 'package:video_call_app/presentation/dialog_box/join_meeting_dialog.dart';
import 'package:video_call_app/presentation/screens/Call_screen.dart';
import 'package:video_call_app/presentation/widgets/action_button.dart';

class ActionButtonsRow extends StatelessWidget {
  final String username;
  const ActionButtonsRow({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        /*ActionButton(
          icon: Icons.video_call,
          label: 'New meeting',
          color: const Color(0xFF4A90E2),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MeetingJoinScreen()),
            );
          },
        ),*/
        ActionButton(
          icon: Icons.video_call,
          label: 'New meeting',
          color: const Color(0xFF4A90E2),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) =>  JoinMeetingDialog(username: username,),
            );/*.then((result) {
              if (result != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CallScreen(
                      username: username,
                      meetingId: 'test1',
                      onCallEnded: () {},
                    ),
                  ),
                );
              }
            });*/
          },
        ),
        ActionButton(
          icon: Icons.calendar_today,
          label: 'Join Meeting',
          color: const Color(0xFF8B5CF6),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CallScreen(
                  meetingId: 'test1',

                  username: username,
                  onCallEnded: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
        ),
        ActionButton(
          icon: Icons.upload_file,
          label: 'Files',
          color: const Color(0xFF4A90E2),
          onTap: () {
           
          },
        ),
        ActionButton(
          icon: Icons.screen_share,
          label: 'Share screen',
          color: const Color(0xFF6366F1),
          onTap: () {
           
          },
        ),
      ],
    );
  }
}
