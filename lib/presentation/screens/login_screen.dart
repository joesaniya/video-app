import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_call_app/Business-Logic/auth-provider.dart';
import 'package:video_call_app/Business-Logic/local_storage.dart';
import 'package:video_call_app/presentation/screens/Call_screen.dart';
import 'package:video_call_app/presentation/screens/home_screen.dart';
import 'package:video_call_app/presentation/screens/register-screen.dart';
import 'package:video_call_app/presentation/utils/appcolors.dart';
import 'package:video_call_app/presentation/widgets/custom-textfield.dart';
import 'package:video_call_app/presentation/widgets/custom_password_field.dart';
import 'package:video_call_app/presentation/widgets/elevated-button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          body: Container(
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
                        'Login here',
                        style: GoogleFonts.poppins(
                          color: AppColors().bgcolor_circle,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'Welcome back! you\'ve been missed',
                      style: GoogleFonts.poppins(
                        color: AppColors().bgcolor_circle,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: authProvider.logInformKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              label: "Email",
                              hint: "Enter Email Address",
                              controller:
                                  authProvider.lIemailControllerController,
                              keyboardType: TextInputType.emailAddress,
                              validator: authProvider.validateEmail,
                            ),
                            const SizedBox(height: 20),
                            CustomPasswordField(
                              label: "Password",
                              hint: "Enter Password",
                              controller: authProvider.lIpasswordController,
                              validator: authProvider.validatePassword,
                            ),

                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.poppins(
                                  color: Colors.blueAccent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButtonWidget(
                                title: "Login",
                                isLoading: authProvider.isLoading,

                                onPressed: () async {
                                  final result = await authProvider
                                      .handleLogin();

                                  if (result['success']) {
                                    final username =
                                        await LocalStorageService.getUsername();
                                    log('Login user Name:$username');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.green,
                                        content: Text(
                                          result['message'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );

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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.redAccent,
                                        content: Text(
                                          result['message'],
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
                            text: "Register",
                            style: GoogleFonts.poppins(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
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
        );
      },
    );
  }
}
 