

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_call_app/Business-Logic/home-provider.dart';
import 'package:video_call_app/presentation/screens/Call_screen.dart';
import 'package:video_call_app/presentation/screens/home_screen.dart';
import 'package:video_call_app/presentation/screens/profile_screen.dart';
import 'package:video_call_app/presentation/widgets/custom_bottom_navbar.dart';

// class MainNavigationScreen extends StatefulWidget {
//   const MainNavigationScreen({super.key});

//   @override
//   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// }

// class _MainNavigationScreenState extends State<MainNavigationScreen> {
//   int _selectedIndex = 1;

//   @override
//   void initState() {
//     super.initState();

//     Future.microtask(() {
//       final homeProvider = context.read<HomeProvider>();
//       homeProvider.loadData();
//     });
//   }

//   void _navigateToHome() {
//     log('calling home');
//     setState(() {
//       _selectedIndex = 1;
//     });
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final homeProvider = Provider.of<HomeProvider>(context);

//     if (homeProvider.isLoading && homeProvider.currentUser == null) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final username = homeProvider.currentUser?.name ?? 'Guest';

//     final List<Widget> screens = [
//       const HomeScreen(),
//       // MeetingJoinScreen(),
//       CallScreen(
//         onCallEnded: _navigateToHome,
//         username: username,
//         meetingId: 'test1',
//       ),
//       const ProfileScreen(),
//     ];

//     return Scaffold(
//       body: IndexedStack(index: _selectedIndex, children: screens),
//       bottomNavigationBar: CustomBottomNavBar(
//         selectedIndex: _selectedIndex,
//         onItemTapped: _onItemTapped,
//       ),
//     );
//   }
// }
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 1; // Start at home
  String? _activeMeetingId; // Track if there's an active call

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final homeProvider = context.read<HomeProvider>();
      homeProvider.loadData();
    });
  }

  void _navigateToHome() {
    setState(() {
      _selectedIndex = 0;
      _activeMeetingId = null; // Clear active meeting
    });
  }

  void _startCall(String meetingId) {
    setState(() {
      _selectedIndex = 1; // Switch to call tab
      _activeMeetingId = meetingId;
    });
  }

  void _onItemTapped(int index) {
    // Prevent switching away from call screen while in active call
    if (_activeMeetingId != null && _selectedIndex == 1) {
      // Show dialog to confirm leaving call
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('End Call?'),
          content: const Text('Are you sure you want to end the call?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToHome();
              },
              child: const Text('End Call'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);

    if (homeProvider.isLoading && homeProvider.currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final username = homeProvider.currentUser?.name ?? 'Guest';

    final List<Widget> screens = [
      HomeScreen(),
      CallScreen(
        onCallEnded: _navigateToHome,
        username: username,
        meetingId: 'test1',
      ),

      const ProfileScreen(),
    ];

    return WillPopScope(
      onWillPop: () async {
        // If on call screen, show confirmation
        if (_selectedIndex == 1 && _activeMeetingId != null) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('End Call?'),
              content: const Text('Are you sure you want to end the call?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('End Call'),
                ),
              ],
            ),
          );
          if (shouldExit == true) {
            _navigateToHome();
          }
          return false;
        }

        // If not on home screen, go to home
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }

        // Allow exit if on home screen
        return true;
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: screens),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
