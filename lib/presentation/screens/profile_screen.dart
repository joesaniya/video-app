import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_call_app/Business-Logic/auth-provider.dart';
import 'package:video_call_app/Business-Logic/profiile-provider.dart';
import 'package:video_call_app/presentation/utils/appcolors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider()..loadUserData(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: colors.bgColor,
      body: profileProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: colors.whiteColor))
          : SafeArea(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.cardColor,
                              border: Border.all(
                                color: colors.whiteColor.withOpacity(0.3),
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                profileProvider.currentUser!.name[0],
                                style: TextStyle(
                                  color: colors.whiteColor,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profileProvider.currentUser?.name ?? 'User Name',
                            style: TextStyle(
                              color: colors.whiteColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profileProvider.currentUser?.email ??
                                'user@example.com',
                            style: TextStyle(
                              color: colors.whiteColor.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              colors,
                              'Total Calls',
                              '${profileProvider.totalCalls}',
                              Icons.video_call,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              colors,
                              'Hours',
                              '${profileProvider.totalHours}h',
                              Icons.access_time,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          color: colors.whiteColor.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSettingItem(
                          colors,
                          Icons.person_outline,
                          'Edit Profile',
                          () =>
                              _showEditProfileDialog(context, profileProvider),
                        ),
                        _buildSettingItem(
                          colors,
                          Icons.notifications_outlined,
                          'Notifications',
                          () {},
                        ),
                        _buildSettingItem(
                          colors,
                          Icons.privacy_tip_outlined,
                          'Privacy',
                          () {},
                        ),
                        _buildSettingItem(
                          colors,
                          Icons.help_outline,
                          'Help & Support',
                          () {},
                        ),
                        _buildSettingItem(
                          colors,
                          Icons.info_outline,
                          'About',
                          () {},
                        ),
                        const SizedBox(height: 20),
                        _buildLogoutButton(
                          colors,
                          () => authProvider.logout(context),
                        ),
                        const SizedBox(height: 20),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
    AppColors colors,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: colors.whiteColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: colors.whiteColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: colors.whiteColor.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    AppColors colors,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.whiteColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: colors.whiteColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: colors.whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colors.whiteColor.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AppColors colors, VoidCallback onLogout) {
    return Material(
      color: Colors.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onLogout,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Colors.red, size: 22),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, ProfileProvider provider) {
    final colors = AppColors();
    final nameController = TextEditingController(
      text: provider.currentUser?.name,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Profile', style: TextStyle(color: colors.whiteColor)),
        content: TextField(
          controller: nameController,
          style: TextStyle(color: colors.whiteColor),
          decoration: InputDecoration(
            labelText: 'Name',
            labelStyle: TextStyle(color: colors.whiteColor.withOpacity(0.7)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.whiteColor.withOpacity(0.3)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.whiteColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.whiteColor.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: colors.whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
