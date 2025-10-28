import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_call_app/presentation/utils/appcolors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(color: AppColors().bgcolor_circle),
        hintStyle: GoogleFonts.poppins(color: AppColors().bgcolor_circle),
        errorStyle: GoogleFonts.poppins(color: Colors.red),
        filled: true,
        fillColor: AppColors().bgColor.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors().bgcolor_circle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors().bgcolor_circle,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
// import 'package:flutter/material.dart';

// class CustomTextField extends StatelessWidget {
//   final String label;
//   final String hintText;
//   final TextEditingController controller;
//   final IconData icon;
//   final String? Function(String?)? validator;

//   const CustomTextField({
//     Key? key,
//     required this.label,
//     required this.hintText,
//     required this.controller,
//     required this.icon,
//     this.validator,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: const TextStyle(color: Colors.white70, fontSize: 14)),
//         const SizedBox(height: 10),
//         Container(
//           decoration: BoxDecoration(
//             color: const Color(0xFF3D4F6B),
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: TextFormField(
//             controller: controller,
//             validator: validator,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               prefixIcon: Icon(icon, color: Colors.white54),
//               hintText: hintText,
//               hintStyle: const TextStyle(color: Colors.white38),
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.all(20),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
