

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_call_app/Business-Logic/home-provider.dart';
import 'package:video_call_app/presentation/screens/Call_screen.dart';
import 'package:video_call_app/presentation/screens/home_screen.dart';
import 'package:video_call_app/presentation/screens/profile_screen.dart';
import 'package:video_call_app/presentation/widgets/custom_bottom_navbar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 1; 
  String? _activeMeetingId; 

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
      _activeMeetingId = null; 
    });
  }

  void _startCall(String meetingId) {
    setState(() {
      _selectedIndex = 1; 
      _activeMeetingId = meetingId;
    });
  }

  void _onItemTapped(int index) {
   
    if (_activeMeetingId != null && _selectedIndex == 1) {
     
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          titleTextStyle: GoogleFonts.poppins(),
          contentTextStyle: GoogleFonts.poppins(),
          
          title:  Text('End Call?',),
          content: const Text('Are you sure you want to end the call?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',),
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

     
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }

    
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
