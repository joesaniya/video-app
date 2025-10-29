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
                              username:
                                  homeProvider.currentUser?.name ?? 'Guest',
                              title: "Call and Meet",
                              onLogout: () => controller.logout(context),
                            ),
                          ),
                        ),
                      ),

                      // ✅ Offline banner
                      if (homeProvider.isOffline)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.wifi_off, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Offline Mode: Showing cached data',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Users List (existing)
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

                  /*  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Header Animation
                      SliverToBoxAdapter(
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: HomeHeader(
                              username: homeProvider.currentUser!.name,
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
                */
                ),
              ),
      ),
    );
  }
}
