import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_call_app/Business-Logic/join_meeting_provider.dart';
import 'package:video_call_app/presentation/screens/Call_screen.dart';
import 'package:video_call_app/presentation/screens/home_screen.dart';
import 'package:video_call_app/presentation/utils/appcolors.dart';

class JoinMeetingDialog extends StatelessWidget {
  final String username;
  const JoinMeetingDialog({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();

    return ChangeNotifierProvider(
      create: (_) => MeetingJoinProvider(),
      child: Consumer<MeetingJoinProvider>(
        builder: (context, provider, child) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: provider.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      'create meeting',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Username Input
                    TextFormField(
                      controller: provider.nameController,
                      enabled: !provider.isLoading,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Meeting ID Input
                    TextFormField(
                      controller: provider.meetingIdController,
                      enabled: !provider.isLoading,
                      decoration: InputDecoration(
                        hintText: 'Meeting ID',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter meeting ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Cancel Button
                        TextButton(
                          onPressed: provider.isLoading
                              ? null
                              : () {
                                  provider.resetForm();
                                  Navigator.of(context).pop();
                                },
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Join Meeting Button
                        TextButton(
                          onPressed: provider.isLoading
                              ? null
                              : () async {
                                  if (provider.formKey.currentState!
                                      .validate()) {
                                    final result = await provider.joinMeeting();

                                    if (result != null && context.mounted) {
                                      // Close dialog
                                      Navigator.of(context).pop();

                                      // Navigate to CallScreen using MaterialPageRoute
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => CallScreen(
                                            meetingId: username,
                                            username: 'test1',
                                            onCallEnded: () {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => HomeScreen(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'New meeting',
                                  style: GoogleFonts.poppins(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Bottom Links
                    Column(
                      children: [
                        Text(
                          'Join a Meeting',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start an Instant Meeting',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Passwords Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.key, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'create with id',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 12,
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
      ),
    );
  }
}
