import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final bool isActive;
  final bool isEndButton;

  const ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.isActive = false,
    this.isEndButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    backgroundColor ??
                    (isActive
                        ? Colors.white.withOpacity(0.4)
                        : Colors.white.withOpacity(0.2)),
                border: isEndButton
                    ? null
                    : Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
