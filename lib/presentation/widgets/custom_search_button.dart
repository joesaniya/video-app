import 'package:flutter/material.dart';
import 'package:video_call_app/presentation/utils/appcolors.dart';

class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String? hintText;

  const CustomSearchBar({super.key, this.onChanged, this.hintText});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();

    return Container(
      decoration: BoxDecoration(
        color: colors.searchBarColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(color: colors.whiteColor),
        decoration: InputDecoration(
          hintText: hintText ?? 'Search',
          hintStyle: TextStyle(
            color: colors.whiteColor.withOpacity(0.5),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colors.whiteColor.withOpacity(0.5),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
