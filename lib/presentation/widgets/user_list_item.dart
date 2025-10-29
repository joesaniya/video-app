import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_call_app/presentation/utils/appcolors.dart';
import 'package:video_call_app/presentation/widgets/user_avatar.dart';

class UserListItem extends StatelessWidget {
  final dynamic user;
  final int index;

  const UserListItem({super.key, required this.user, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();

    final times = ['11:20 AM', '1:20 AM', '11:42 AM', '11:20 AM'];
    final messages = [
      'Hey there!',
      'Let\'s progress on that task',
      'IDK what ship is there to be',
      'Sure, I\'ll be there',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: UserAvatar(name: user.name, index: index),
        onTap: () {
          log('Selected user: ${user.email}');
          final channelName = user.email;
          if (channelName.isNotEmpty) {}
        },

        title: Text(
          user.name,
          style: GoogleFonts.poppins(
            color: colors.whiteColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            messages[index % messages.length],
            style: GoogleFonts.poppins(
              color: colors.lightTextColor,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Text(
          times[index % times.length],
          style: GoogleFonts.poppins(
            color: colors.lightTextColor,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
