import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_call_app/Business-Logic/auth-provider.dart';
import 'package:video_call_app/presentation/utils/appcolors.dart';

class CustomPasswordField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isConfirmPassword;

  const CustomPasswordField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.isConfirmPassword = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final isObscured = isConfirmPassword
            ? auth.obscureConfirmPassword
            : auth.obscurePassword;

        return TextFormField(
          controller: controller,
          obscureText: isObscured,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            labelStyle: GoogleFonts.poppins(
              color: AppColors().bgcolor_circle,
            ),
            hintStyle: GoogleFonts.poppins(
              color: AppColors().bgcolor_circle,
            ),
            errorStyle: GoogleFonts.poppins(color: Colors.red),
            filled: true,
            fillColor: AppColors().bgColor.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors().bgcolor_circle,
              ),
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
            suffixIcon: IconButton(
              icon: Icon(
                isObscured ? Icons.visibility_off : Icons.visibility,
                color: AppColors().bgcolor_circle,
              ),
              onPressed: () {
                if (isConfirmPassword) {
                  authProvider.obscureConfirmPassword =
                      !authProvider.obscureConfirmPassword;
                } else {
                  authProvider.obscurePassword = !authProvider.obscurePassword;
                }
                authProvider.notifyListeners();
              },
            ),
          ),
        );
      },
    );
  }
}
// import 'package:flutter/material.dart';

// class CustomPasswordField extends StatelessWidget {
//   final String label;
//   final String hintText;
//   final TextEditingController controller;
//   final bool obscureText;
//   final VoidCallback toggle;
//   final String? Function(String?)? validator;

//   const CustomPasswordField({
//     Key? key,
//     required this.label,
//     required this.hintText,
//     required this.controller,
//     required this.obscureText,
//     required this.toggle,
//     this.validator,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(color: Colors.white70, fontSize: 14),
//         ),
//         const SizedBox(height: 10),
//         Container(
//           decoration: BoxDecoration(
//             color: const Color(0xFF3D4F6B),
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: TextFormField(
//             controller: controller,
//             obscureText: obscureText,
//             validator: validator,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
//               suffixIcon: IconButton(
//                 icon: Icon(
//                   obscureText ? Icons.visibility_off : Icons.visibility,
//                   color: Colors.white54,
//                 ),
//                 onPressed: toggle,
//               ),
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
