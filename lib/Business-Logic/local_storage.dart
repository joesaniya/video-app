import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_call_app/models/user_model.dart';

class LocalStorageService {
  static const String _userKey = 'user_data';
  static const String _allUsersKey = 'all_users';
  static const String _usernameKey = 'username';
  static const String _cachedUsersKey = 'cached_users';

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
    await prefs.remove(_cachedUsersKey);
  }

  // ✅ Save cached user list for offline mode
  static Future<void> saveCachedUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final userListJson = jsonEncode(
      users.map((user) => user.toJson()).toList(),
    );
    await prefs.setString(_cachedUsersKey, userListJson);
  }

  // ✅ Retrieve cached users when offline
  static Future<List<UserModel>> getCachedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cachedUsersKey);
    if (cached == null) return [];
    final List<dynamic> decoded = jsonDecode(cached);
    return decoded.map((e) => UserModel.fromJson(e)).toList();
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
