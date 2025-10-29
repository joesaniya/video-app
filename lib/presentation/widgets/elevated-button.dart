
import 'package:flutter/material.dart';
import 'package:video_call_app/presentation/utils/appcolors.dart';

class ElevatedButtonWidget extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isLoading;

  const ElevatedButtonWidget({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        decoration: BoxDecoration(
          gradient: isLoading
              ? LinearGradient(
                  colors: [
                    AppColors().bgcolor_circle.withOpacity(0.5),
                    AppColors().bgcolor_circle.withOpacity(0.4),
                  ],
                )
              : AppColors().buttoncolorGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors().whiteColor,
                  ),
                )
              : Text(
                  title,
                  style: TextStyle(
                    color: AppColors().whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
