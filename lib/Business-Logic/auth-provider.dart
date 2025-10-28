import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:video_call_app/Business-Logic/local_storage.dart';
import 'package:video_call_app/data-provider/dio-client.dart';
import 'package:video_call_app/models/user_model.dart';
import 'package:video_call_app/presentation/screens/login_screen.dart';

class AuthProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool isLoading = false;

 
  final lIemailControllerController = TextEditingController();
  final lIpasswordController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool agreeToTerms = false;

  final regformKey = GlobalKey<FormState>();
  final logInformKey = GlobalKey<FormState>();

  static const String baseUrl =
      "https://68ff815be02b16d1753e4119.mockapi.io/users/UsersData";

  
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 3) return 'Enter at least 3 characters';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirm password is required';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

   
  Future<Map<String, dynamic>> handleRegistration() async {
    if (!regformKey.currentState!.validate()) {
      return {'success': false, 'message': 'Please fill all fields correctly'};
    }

    try {
      final success = await registerUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (success != null) {
        // LocalStorageService.saveUserData(UserModel.fromJson(success));
        LocalStorageService.saveUser(UserModel.fromJson(success));
        clearRegistrationFields();
        return {'success': true, 'message': 'Registration successful 🎉'};
      } else {
        return {'success': false, 'message': 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
     
      final response = await _dioClient.performCall(
        requestType: RequestType.get,
        url: baseUrl,
      );

      if (response != null && response.statusCode == 200) {
        final List<dynamic> users = response.data;

      
        final existingUser = users.firstWhere(
          (u) => u['email'].toString().toLowerCase() == email.toLowerCase(),
          orElse: () => null,
        );

        if (existingUser != null) {
          isLoading = false;
          notifyListeners();
          log(" Duplicate email found: ${existingUser['email']}");
          return null; 
        }
      }

  
      final createResponse = await _dioClient.performCall(
        requestType: RequestType.post,
        url: baseUrl,
        data: {
          "name": name,
          "email": email,
          "password": password,
          "createdAt": DateTime.now().toIso8601String(),
        },
      );

      isLoading = false;
      notifyListeners();

      if (createResponse != null &&
          (createResponse.statusCode == 200 ||
              createResponse.statusCode == 201)) {
        log(" Registered new user: ${createResponse.data}");
        return createResponse.data;
      }
    } catch (e) {
      log(" Register error: $e");
    }

    isLoading = false;
    notifyListeners();
    return null;
  }

  
  Future<Map<String, dynamic>> handleLogin() async {
    if (!logInformKey.currentState!.validate()) {
      return {'success': false, 'message': 'Please fill all fields correctly'};
    }

    try {
      final user = await loginUser(
        email: lIemailControllerController.text.trim(),
        password: lIpasswordController.text.trim(),
      );

      if (user != null) {
        // await LocalStorageService.saveUserData(UserModel.fromJson(user));
await LocalStorageService.saveUser(UserModel.fromJson(user));
        clearLoginFields();
        return {'success': true, 'message': 'Login successful 🎉'};
      } else {
        return {'success': false, 'message': 'Invalid email or password'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Login failed. Please try again.'};
    }
  }

  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _dioClient.performCall(
        requestType: RequestType.get,
        url: baseUrl,
      );

      isLoading = false;
      notifyListeners();

      if (response != null && response.statusCode == 200) {
        final List<dynamic> users = response.data;
        final user = users.firstWhere(
          (u) => u['email'] == email && u['password'] == password,
          orElse: () => null,
        );

        if (user != null) {
          log(" Login success: $user");
          return user;
        }
      }
    } catch (e) {
      log(" Login error: $e");
    }

    isLoading = false;
    notifyListeners();
    return null;
  }


  Future<UserModel?> loadUserData() async {
    return await LocalStorageService.getUserData();
  }


  Future<void> logout(BuildContext context) async {
    await LocalStorageService.clearUserData();
    notifyListeners();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }


  void clearRegistrationFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    notifyListeners();
  }

  void clearLoginFields() {
    lIemailControllerController.clear();
    lIpasswordController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    lIemailControllerController.dispose();
    lIpasswordController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
