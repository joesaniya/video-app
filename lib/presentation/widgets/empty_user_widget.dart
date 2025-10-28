
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_call_app/presentation/utils/appcolors.dart';

class EmptyUsersWidget extends StatelessWidget {
  const EmptyUsersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          "No other users found.",
          style: GoogleFonts.poppins(color: colors.lightTextColor),
        ),
      ),
    );
  }
}
