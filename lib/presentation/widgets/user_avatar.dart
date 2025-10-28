import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_call_app/presentation/utils/appcolors.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final int index;
  final double radius;

  const UserAvatar({
    super.key,
    required this.name,
    required this.index,
    this.radius = 24,
  });

  Color _getAvatarColor(int index) {
    final colors = [
      const Color(0xFFE57373),
      const Color(0xFF64B5F6),
      const Color(0xFF81C784),
      const Color(0xFFFFD54F),
      const Color(0xFFBA68C8),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();

    return CircleAvatar(
      radius: radius,
      backgroundColor: _getAvatarColor(index),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.poppins(
          color: colors.whiteColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
