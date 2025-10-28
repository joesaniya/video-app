

import 'package:flutter/material.dart';
import 'package:video_call_app/presentation/widgets/action_button.dart';

class ActionButtonsRow extends StatelessWidget {
  const ActionButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ActionButton(
          icon: Icons.video_call,
          label: 'New meeting',
          color: const Color(0xFF4A90E2),
          onTap: () {
            // Handle new meeting
          },
        ),
        ActionButton(
          icon: Icons.calendar_today,
          label: 'Schedule',
          color: const Color(0xFF8B5CF6),
          onTap: () {
            // Handle schedule
          },
        ),
        ActionButton(
          icon: Icons.upload_file,
          label: 'Files',
          color: const Color(0xFF4A90E2),
          onTap: () {
            // Handle files
          },
        ),
        ActionButton(
          icon: Icons.screen_share,
          label: 'Share screen',
          color: const Color(0xFF6366F1),
          onTap: () {
            // Handle share screen
          },
        ),
      ],
    );
  }
}

