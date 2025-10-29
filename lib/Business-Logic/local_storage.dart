// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:video_call_app/models/user_model.dart';

// class LocalStorageService {
//   static const String _userKey = 'user_data';
//   static const String _allUsersKey = 'all_users';

//   static Future<void> saveUserData(UserModel user) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_userKey, jsonEncode(user.toJson()));
//   }

//   static Future<void> saveAllUsers(List<UserModel> users) async {
//     final prefs = await SharedPreferences.getInstance();
//     final List<Map<String, dynamic>> userList = users
//         .map((e) => e.toJson())
//         .toList();
//     await prefs.setString(_allUsersKey, jsonEncode(userList));
//   }

//   static Future<UserModel?> getUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final jsonData = prefs.getString(_userKey);
//     if (jsonData == null) return null;
//     return UserModel.fromJson(jsonDecode(jsonData));
//   }

//   static Future<List<UserModel>> getAllUsers() async {
//     final prefs = await SharedPreferences.getInstance();
//     final jsonString = prefs.getString(_allUsersKey);
//     if (jsonString == null) return [];
//     final List decoded = jsonDecode(jsonString);
//     return decoded.map((e) => UserModel.fromJson(e)).toList();
//   }

//   static Future<List<UserModel>> getAllUsers1() async {
//     final prefs = await SharedPreferences.getInstance();
//     final jsonData = prefs.getString(_allUsersKey);
//     if (jsonData == null) return [];
//     final List<dynamic> list = jsonDecode(jsonData);
//     return list.map((e) => UserModel.fromJson(e)).toList();
//   }

//   static Future<void> clearUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_userKey);
//   }
// }
// local_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_call_app/models/user_model.dart';

class LocalStorageService {
  static const String _userKey = 'user_data';
  static const String _allUsersKey = 'all_users';
  static const String _usernameKey = 'username';

  //  Save user (full data + username)
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_allUsersKey);
    List<UserModel> users = [];
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      users = decoded.map((e) => UserModel.fromJson(e)).toList();
    }

    final existingIndex = users.indexWhere((u) => u.email == user.email);
    if (existingIndex != -1) {
      users[existingIndex] = user;
    } else {
      users.add(user);
    }

    await prefs.setString(
      _allUsersKey,
      jsonEncode(users.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(_userKey, jsonEncode(user.toJson()));

    //  Save username separately
    await prefs.setString(_usernameKey, user.name);
  }

  static Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString(_userKey);
    if (jsonData == null) return null;
    return UserModel.fromJson(jsonDecode(jsonData));
  }

  //  Get stored username directly
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_usernameKey); 
  }
}


class LocalStorageService1 {
  static const String _userKey = 'user_data';
  static const String _allUsersKey = 'all_users';

  
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

  
    final jsonString = prefs.getString(_allUsersKey);
    List<UserModel> users = [];
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      users = decoded.map((e) => UserModel.fromJson(e)).toList();
    }


    final existingIndex = users.indexWhere((u) => u.email == user.email);
    if (existingIndex != -1) {
      users[existingIndex] = user;
    } else {
      users.add(user);
    }

    await prefs.setString(
      _allUsersKey,
      jsonEncode(users.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }


  static Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString(_userKey);
    if (jsonData == null) return null;
    return UserModel.fromJson(jsonDecode(jsonData));
  }



  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
 
  