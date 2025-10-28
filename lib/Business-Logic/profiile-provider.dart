import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:video_call_app/Business-Logic/local_storage.dart';
import 'package:video_call_app/data-provider/dio-client.dart';
import 'package:video_call_app/models/user_model.dart';

class ProfileProvider with ChangeNotifier {
  bool isLoading = true;
  UserModel? currentUser;
  int totalCalls = 0;
  int totalHours = 0;

  final DioClient _dioClient = DioClient();
  

  Future<void> loadUserData() async {
    isLoading = true;
    notifyListeners();

    try {
     
      final loggedUser = await LocalStorageService.getUserData();
      
      if (loggedUser != null) {
        currentUser = loggedUser;
        log(' Loaded user: ${currentUser?.name}');
        
       
        totalCalls = 24;
        totalHours = 12;
      } else {
        log(' No logged-in user found');
      }
    } catch (e, s) {
      log(' Error loading user data: $e');
      log('Stack: $s');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

 
 }

