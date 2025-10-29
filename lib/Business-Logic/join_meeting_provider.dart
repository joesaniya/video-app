import 'package:flutter/material.dart';

class MeetingJoinProvider extends ChangeNotifier {
  final TextEditingController meetingIdController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  final formKey = GlobalKey<FormState>();

  Future<Map<String, String>?> joinMeeting() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call or processing delay
      await Future.delayed(const Duration(milliseconds: 800));

      _isLoading = false;
      notifyListeners();

      // Return sanitized data
      return {
        'meetingId': meetingIdController.text.trim(),
        'username': nameController.text.trim(),
      };
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Reset form to initial state
  void resetForm() {
    meetingIdController.clear();
    nameController.clear();
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    meetingIdController.dispose();
    nameController.dispose();
    super.dispose();
  }
}
