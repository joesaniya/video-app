import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_call_app/presentation/screens/Call_screen.dart';

import 'package:video_call_app/presentation/screens/welcome_screen.dart';

class SplashProvider extends ChangeNotifier {
  double _opacity = 0.0;
  bool _isVisible = false;

  double get opacity => _opacity;
  bool get isVisible => _isVisible;

  SplashProvider(BuildContext context) {
    _startAnimation(context);
  }

  void _startAnimation(BuildContext context) {
    _isVisible = true;
    _opacity = 1.0;
    notifyListeners();

    Timer(const Duration(seconds: 5), () async {
      await _checkLoginStatus(context);
    });
  }

  Future<void> _checkLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    final userData = prefs.getString('user_data');
    log('Stored UserData: $userData');

    if (userData != null) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userData);
        log('usermap: $userMap');
        if (userMap['email'] != null &&
            userMap['email'].toString().isNotEmpty) {
          // Check if context is still mounted before navigation
          if (!context.mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CallScreen(
                meetingId: 'test1',
                username: userMap['name'],
                onCallEnded: () {
                  // Empty callback - CallScreen handles its own navigation
                },
              ),
            ),
          );
          return;
        }
      } catch (e) {
        log("Error decoding user data: $e");
      }
    }

    // Check if context is still mounted before navigation
    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }
}
  /*Future<void> _checkLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    final userData = prefs.getString('user_data');
    log(' Stored UserData: $userData');

    if (userData != null) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userData);
        log('usermap:${userMap}');
        if (userMap['email'] != null &&
            userMap['email'].toString().isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CallScreen(
                meetingId: 'test1',
                // meetingId: _meetingIdController.text.trim(),
                username: userMap['name'],
                onCallEnded: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                },
              ),
            ),
          );
          return;
        }
      } catch (e) {
        log(" Error decoding user data: $e");
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }
}
*/