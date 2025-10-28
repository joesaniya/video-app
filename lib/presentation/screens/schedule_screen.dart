import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_call_app/presentation/utils/appcolors.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();
    return Scaffold(
      backgroundColor: colors.bgColor,
      body: Center(
        child: Text(
          'schedule',
          style: GoogleFonts.poppins(fontSize: 16, color: colors.whiteColor),
        ),
      ),
    );
  }
}
