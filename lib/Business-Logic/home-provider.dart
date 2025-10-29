// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:video_call_app/Business-Logic/local_storage.dart';
// import 'package:video_call_app/data-provider/dio-client.dart';
// import 'package:video_call_app/models/user_model.dart';

// class HomeProvider extends ChangeNotifier {
//   UserModel? _currentUser;
//   List<UserModel> _otherUsers = [];
//   List<UserModel> _filteredUsers = [];
//   bool _isLoading = false;
//   String _searchQuery = '';
//   bool _isOffline = false;
//   UserModel? get currentUser => _currentUser;
//   List<UserModel> get otherUsers =>
//       _searchQuery.isEmpty ? _otherUsers : _filteredUsers;
//   bool get isLoading => _isLoading;
//   String get searchQuery => _searchQuery;
//   bool get isOffline => _isOffline;

//   final String _apiUrl =
//       "https://68ff815be02b16d1753e4119.mockapi.io/users/UsersData";

//   final DioClient _dioClient = DioClient();
//   Future<void> loadData() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       // ✅ Load cached data first (for instant display)
//       final cachedUsers = await LocalStorageService.getCachedUsers();
//       if (cachedUsers.isNotEmpty) {
//         _otherUsers = cachedUsers;
//         notifyListeners();
//       }

//       final loggedUser = await LocalStorageService.getUserData();
//       _currentUser = loggedUser;

//       // ✅ Try fetching fresh data from API
//       final response = await _dioClient.performCall(
//         requestType: RequestType.get,
//         url: _apiUrl,
//       );

//       if (response != null && response.statusCode == 200) {
//         final List<dynamic> data = response.data is String
//             ? jsonDecode(response.data)
//             : response.data;

//         final allUsers = data.map((e) => UserModel.fromJson(e)).toList();

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

//         // ✅ Save to cache after successful fetch
//         await LocalStorageService.saveCachedUsers(_otherUsers);
//         _isOffline = false;
//       } else {
//         _isOffline = true;
//         log('⚠️ Using cached users due to fetch error.');
//       }

//       if (_searchQuery.isNotEmpty) {
//         _filterUsers(_searchQuery);
//       }
//     } catch (e, s) {
//       _isOffline = true;
//       log('❌ Error loading data: $e');
//       log('Stack: $s');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> loadData1() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final loggedUser = await LocalStorageService.getUserData();
//       _currentUser = loggedUser;

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

//         if (_searchQuery.isNotEmpty) {
//           _filterUsers(_searchQuery);
//         }

//         log(' Loaded ${_otherUsers.length} other users');
//       } else {
//         log(' Failed to fetch users. Status: ${response?.statusCode}');
//       }
//     } catch (e, s) {
//       log(' Error loading data: $e');
//       log('Stack: $s');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void searchUsers(String query) {
//     _searchQuery = query;
//     _filterUsers(query);
//     notifyListeners();
//   }

//   void _filterUsers(String query) {
//     if (query.isEmpty) {
//       _filteredUsers = [];
//       return;
//     }

//     final lowerQuery = query.toLowerCase().trim();
//     _filteredUsers = _otherUsers.where((user) {
//       final name = user.name?.toLowerCase() ?? '';
//       final email = user.email.toLowerCase();

//       return name.contains(lowerQuery) || email.contains(lowerQuery);
//     }).toList();
//   }

//   void clearSearch() {
//     _searchQuery = '';
//     _filteredUsers = [];
//     notifyListeners();
//   }
// }

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:video_call_app/Business-Logic/local_storage.dart';
import 'package:video_call_app/data-provider/dio-client.dart';
import 'package:video_call_app/models/user_model.dart';

class HomeProvider extends ChangeNotifier {
  UserModel? _currentUser;
  List<UserModel> _otherUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = false;
  bool _isOffline = false;
  String _searchQuery = '';

  UserModel? get currentUser => _currentUser;
  List<UserModel> get otherUsers =>
      _searchQuery.isEmpty ? _otherUsers : _filteredUsers;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String get searchQuery => _searchQuery;

  final String _apiUrl =
      "https://68ff815be02b16d1753e4119.mockapi.io/users/UsersData";
  final DioClient _dioClient = DioClient();

  BuildContext? _context; // ✅ keep reference for snackbar

  HomeProvider({BuildContext? context}) {
    _context = context;
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _monitorNetworkStatus();
  }

  late final Connectivity _connectivity;
  late final Stream<List<ConnectivityResult>> _connectivityStream;

  void _monitorNetworkStatus() {
    _connectivityStream.listen((List<ConnectivityResult> results) async {
      final result = results.first;

      if (result != ConnectivityResult.none && _isOffline) {
        log('🌐 Internet reconnected → refreshing data...');
        _showSnackBar("✅ Internet reconnected — refreshing data...");
        await loadData();
      } else if (result == ConnectivityResult.none) {
        _isOffline = true;
        _showSnackBar("⚠️ You are offline");
        notifyListeners();
      }
    });
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // ✅ Load cached data first (instant display)
      final cachedUsers = await LocalStorageService.getCachedUsers();
      if (cachedUsers.isNotEmpty) {
        _otherUsers = cachedUsers;
        notifyListeners();
      }

      final loggedUser = await LocalStorageService.getUserData();
      _currentUser = loggedUser;

      // ✅ Try API
      final response = await _dioClient.performCall(
        requestType: RequestType.get,
        url: _apiUrl,
      );

      if (response != null && response.statusCode == 200) {
        final List<dynamic> data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final allUsers = data.map((e) => UserModel.fromJson(e)).toList();

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

        // ✅ Cache users
        await LocalStorageService.saveCachedUsers(_otherUsers);
        _isOffline = false;
      } else {
        _isOffline = true;
        log('⚠️ Using cached users (network fetch failed).');
      }

      if (_searchQuery.isNotEmpty) {
        _filterUsers(_searchQuery);
      }
    } catch (e, s) {
      _isOffline = true;
      log('❌ Error loading data: $e');
      log('Stack: $s');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _showSnackBar(String message) {
    if (_context == null) return;
    final messenger = ScaffoldMessenger.maybeOf(_context!);
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
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
}
