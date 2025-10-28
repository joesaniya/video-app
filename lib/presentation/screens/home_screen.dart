import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_call_app/Business-Logic/auth-provider.dart';
import 'package:video_call_app/Business-Logic/home-provider.dart';
import 'package:video_call_app/presentation/utils/appcolors.dart';
import 'package:video_call_app/presentation/widgets/empty_user_widget.dart';
import 'package:video_call_app/presentation/widgets/home_header.dart';
import 'package:video_call_app/presentation/widgets/user_list_item.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider()..loadData(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView({super.key});

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Start animations when screen loads
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context);
    final colors = AppColors();

    return Scaffold(
      backgroundColor: colors.bgColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: homeProvider.isLoading
            ? Center(
                key: const ValueKey('loading'),
                child: CircularProgressIndicator(color: colors.whiteColor),
              )
            : homeProvider.currentUser == null
            ? FadeTransition(
                key: const ValueKey('no-user'),
                opacity: _fadeAnimation,
                child: Center(
                  child: Text(
                    "No user data found",
                    style: TextStyle(color: colors.whiteColor),
                  ),
                ),
              )
            : SafeArea(
                key: const ValueKey('content'),
                child: RefreshIndicator(
                  color: colors.whiteColor,
                  backgroundColor: colors.cardColor,
                  onRefresh: () async {
                    await homeProvider.loadData();
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Header Animation
                      SliverToBoxAdapter(
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: HomeHeader(
                              title: "Call and Meet",
                              onLogout: () => controller.logout(context),
                            ),
                          ),
                        ),
                      ),

                      // Users List with Staggered Animations
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        sliver: homeProvider.otherUsers.isEmpty
                            ? SliverToBoxAdapter(
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: EmptyUsersWidget(),
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final user = homeProvider.otherUsers[index];
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    delay: const Duration(milliseconds: 100),
                                    child: SlideAnimation(
                                      verticalOffset: 30.0,
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      child: FadeInAnimation(
                                        child: UserListItem(
                                          user: user,
                                          index: index,
                                        ),
                                      ),
                                    ),
                                  );
                                }, childCount: homeProvider.otherUsers.length),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:video_call_app/Business-Logic/auth-provider.dart';
// import 'package:video_call_app/Business-Logic/home-provider.dart';
// import 'package:video_call_app/presentation/utils/appcolors.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => HomeProvider()..loadData(),
//       child: const _HomeView(),
//     );
//   }
// }

// class _HomeView extends StatelessWidget {
//   const _HomeView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Provider.of<AuthProvider>(context, listen: false);
//     final homeProvider = Provider.of<HomeProvider>(context);

//     return Scaffold(
//       backgroundColor: AppColors().bgColor,
//       appBar: AppBar(
//         title: const Text("Home"),
//         backgroundColor: Colors.blueAccent,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout, color: Colors.white),
//             onPressed: () => controller.logout(context),
//           ),
//         ],
//       ),
//       body: homeProvider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : homeProvider.currentUser == null
//           ? const Center(
//               child: Text(
//                 "No user data found",
//                 style: TextStyle(color: Colors.white),
//               ),
//             )
//           : RefreshIndicator(
//               color: Colors.blueAccent,
//               backgroundColor: Colors.white,
//               onRefresh: () async {
//                 await homeProvider.loadData();
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Welcome, ${homeProvider.currentUser!.name} 👋",
//                       style: GoogleFonts.poppins(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "Email: ${homeProvider.currentUser!.email}",
//                       style: GoogleFonts.poppins(color: Colors.white70),
//                     ),
//                     const SizedBox(height: 25),
//                     Text(
//                       "Other Registered Users:",
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Expanded(
//                       child: homeProvider.otherUsers.isEmpty
//                           ? Center(
//                               child: Text(
//                                 "No other users found.",
//                                 style: GoogleFonts.poppins(
//                                   color: Colors.white70,
//                                 ),
//                               ),
//                             )
//                           : ListView.builder(
//                               physics:
//                                   const AlwaysScrollableScrollPhysics(), // ✅ ensures scroll
//                               itemCount: homeProvider.otherUsers.length,
//                               itemBuilder: (context, index) {
//                                 final user = homeProvider.otherUsers[index];
//                                 return Card(
//                                   color: Colors.white.withOpacity(0.1),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: ListTile(
//                                     leading: const Icon(
//                                       Icons.person,
//                                       color: Colors.white,
//                                     ),
//                                     title: Text(
//                                       user.name,
//                                       style: GoogleFonts.poppins(
//                                         color: Colors.white,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                     subtitle: Text(
//                                       user.email,
//                                       style: GoogleFonts.poppins(
//                                         color: Colors.white70,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }
