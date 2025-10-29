import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_call_app/Business-Logic/home-provider.dart';
import 'package:video_call_app/presentation/utils/appcolors.dart';
import 'package:video_call_app/presentation/widgets/custom_search_button.dart';
import 'package:video_call_app/presentation/widgets/row_action_button.dart';

class HomeHeader extends StatelessWidget {
  final String title;
  final VoidCallback onLogout;

  const HomeHeader({super.key, required this.title, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final Name = Provider.of<HomeProvider>(
      context,
      listen: false,
    ).currentUser!.name;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar with Title and Logout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: colors.whiteColor,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color: colors.lightTextColor,
                  size: 22,
                ),
                onPressed: onLogout,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search Bar
          CustomSearchBar(
            hintText: 'Search users...',
            onChanged: (query) {
              homeProvider.searchUsers(query);
            },
          ),
          // CustomSearchBar(),
          const SizedBox(height: 20),

          // Action Buttons Row
          ActionButtonsRow(username: Name),
          const SizedBox(height: 25),

          // Today Label
          Text(
            "Today",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.lightTextColor,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
