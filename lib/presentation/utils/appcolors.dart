import 'package:flutter/material.dart';

class AppColors {
  LinearGradient buttoncolorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B5CF1), Color(0xFF9E7BFF)],
  );
  Color whiteColor = Colors.white;
  Color bgColor = Color(0xFF2B3E5F);
  Color bgcolor_circle = Color(0xFF1E2B42);
  Color lightTextColor = Color(0xFF8B9CB8);
  LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2B3E5F), Color(0xFF8B9CB8)],
  );

  // Additional colors for the design
  Color cardColor = Color(0xFF3D5A6B);
  Color searchBarColor = Color(0xFF3D5A6B);
  Color navBarColor = Color(0xFF233947);
}
