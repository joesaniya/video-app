import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_call_app/Business-Logic/auth-provider.dart';
import 'package:video_call_app/Business-Logic/local_storage.dart';
import 'package:video_call_app/presentation/screens/Call_screen.dart';
import 'package:video_call_app/presentation/screens/home_screen.dart';
import 'package:video_call_app/presentation/screens/login_screen.dart';
import 'package:video_call_app/presentation/utils/appcolors.dart';
import 'package:video_call_app/presentation/widgets/custom-textfield.dart';
import 'package:video_call_app/presentation/widgets/custom_password_field.dart';
import 'package:video_call_app/presentation/widgets/elevated-button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: AppColors().bgcolor_circle.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(125),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          'Create Account',
                          style: GoogleFonts.poppins(
                            color: AppColors().bgcolor_circle,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Create an account so you can start video calling',
                        style: GoogleFonts.poppins(
                          color: AppColors().bgcolor_circle,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: authProvider.regformKey,
                          child: Column(
                            children: [
                              CustomTextField(
                                label: "User Name",
                                hint: "Enter User Name",
                                controller: authProvider.nameController,
                                validator: authProvider.validateName,
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: "Email",
                                hint: "Enter Email Address",
                                controller: authProvider.emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: authProvider.validateEmail,
                              ),
                              const SizedBox(height: 20),
                              CustomPasswordField(
                                label: "Password",
                                hint: "Enter Password",
                                controller: authProvider.passwordController,
                                validator: authProvider.validatePassword,
                              ),

                              const SizedBox(height: 20),

                              CustomPasswordField(
                                label: "Confirm Password",
                                hint: "Re-enter Password",
                                controller:
                                    authProvider.confirmPasswordController,
                                validator: authProvider.validateConfirmPassword,
                                isConfirmPassword: true,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButtonWidget(
                                  title: "Register",
                                  isLoading: authProvider.isLoading,
                                  onPressed: () async {
                                    final result = await authProvider
                                        .handleRegistration();

                                    // ✅ Safe null checks
                                    final success =
                                        result != null &&
                                        result['success'] == true;
                                    final message =
                                        result?['message'] ??
                                        'Something went wrong';

                                    if (success) {
                                      final username =
                                          await LocalStorageService.getUsername();

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text(
                                            message,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );

                                      // ✅ Navigate safely after short delay
                                      Future.delayed(
                                        const Duration(seconds: 1),
                                        () {
                                          Navigator.of(
                                            context,
                                          ).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) => CallScreen(
                                                meetingId: 'test1',
                                                username: username!,
                                                onCallEnded: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          HomeScreen(),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            (Route<dynamic> route) => false,
                                          );
                                        },
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.redAccent,
                                          content: Text(
                                            message,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: GoogleFonts.poppins(
                            color: AppColors().bgcolor_circle,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: "Sign in",
                              style: GoogleFonts.poppins(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
