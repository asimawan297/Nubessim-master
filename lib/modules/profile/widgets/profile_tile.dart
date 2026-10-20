import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';

class ProfileTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const ProfileTile({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          title: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: AppColors.black,
          ),
          onTap: onTap,
        ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: Colors.grey[300],
          indent: 20,
          endIndent: 20,
        ),
      ],
    );
  }
}
