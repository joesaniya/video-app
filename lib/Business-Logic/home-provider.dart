import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:video_call_app/Business-Logic/local_storage.dart';
import 'package:video_call_app/data-provider/dio-client.dart';
import 'package:video_call_app/models/user_model.dart';

class HomeProvider extends ChangeNotifier {
  UserModel? _currentUser;
  List<UserModel> _otherUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = false;
  String _searchQuery = ''; 

  UserModel? get currentUser => _currentUser;
  List<UserModel> get otherUsers =>
      _searchQuery.isEmpty ? _otherUsers : _filteredUsers;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  final String _apiUrl =
      "https://68ff815be02b16d1753e4119.mockapi.io/users/UsersData";

  final DioClient _dioClient = DioClient();

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
     
      final loggedUser = await LocalStorageService.getUserData();
      _currentUser = loggedUser;

   
      final response = await _dioClient.performCall(
        requestType: RequestType.get,
        url: _apiUrl,
      );

      if (response != null && response.statusCode == 200) {
        final List<dynamic> data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final allUsers = data.map((e) => UserModel.fromJson(e)).toList();

        log('All users:${allUsers.length}');
        if (loggedUser != null) {
          _otherUsers = allUsers
              .where(
                (user) =>
                    user.email.trim().toLowerCase() !=
                    loggedUser.email.trim().toLowerCase(),
              )
              .toList();
        } else {
          _otherUsers = allUsers;
        }

      
        if (_searchQuery.isNotEmpty) {
          _filterUsers(_searchQuery);
        }

        log(' Loaded ${_otherUsers.length} other users');
      } else {
        log(' Failed to fetch users. Status: ${response?.statusCode}');
      }
    } catch (e, s) {
      log(' Error loading data: $e');
      log('Stack: $s');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  void searchUsers(String query) {
    _searchQuery = query;
    _filterUsers(query);
    notifyListeners();
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      _filteredUsers = [];
      return;
    }

    final lowerQuery = query.toLowerCase().trim();
    _filteredUsers = _otherUsers.where((user) {
      final name = user.name?.toLowerCase() ?? '';
      final email = user.email.toLowerCase();

      return name.contains(lowerQuery) || email.contains(lowerQuery);
    }).toList();
  }

 
  void clearSearch() {
    _searchQuery = '';
    _filteredUsers = [];
    notifyListeners();
  }
} // import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:video_call_app/Business-Logic/local_storage.dart';
// import 'package:video_call_app/data-provider/dio-client.dart';
// import 'package:video_call_app/models/user_model.dart';

// class HomeProvider extends ChangeNotifier {
//   UserModel? _currentUser;
//   List<UserModel> _otherUsers = [];
//   bool _isLoading = false;

//   UserModel? get currentUser => _currentUser;
//   List<UserModel> get otherUsers => _otherUsers;
//   bool get isLoading => _isLoading;

//   final String _apiUrl =
//       "https://68ff815be02b16d1753e4119.mockapi.io/users/UsersData";

//   final DioClient _dioClient = DioClient();

//   Future<void> loadData() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       // ✅ Get current user from local storage
//       final loggedUser = await LocalStorageService.getUserData();
//       _currentUser = loggedUser;

//       // ✅ Fetch all users using DioClient
//       final response = await _dioClient.performCall(
//         requestType: RequestType.get,
//         url: _apiUrl,
//       );

//       if (response != null && response.statusCode == 200) {
//         final List<dynamic> data = response.data is String
//             ? jsonDecode(response.data)
//             : response.data;

//         final allUsers = data.map((e) => UserModel.fromJson(e)).toList();

//         log('All users:${allUsers.length}');
//         if (loggedUser != null) {
//           _otherUsers = allUsers
//               .where(
//                 (user) =>
//                     user.email.trim().toLowerCase() !=
//                     loggedUser.email.trim().toLowerCase(),
//               )
//               .toList();
//         } else {
//           _otherUsers = allUsers;
//         }

//         log('✅ Loaded ${_otherUsers.length} other users');
//       } else {
//         log('⚠️ Failed to fetch users. Status: ${response?.statusCode}');
//       }
//     } catch (e, s) {
//       log('❌ Error loading data: $e');
//       log('Stack: $s');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }
