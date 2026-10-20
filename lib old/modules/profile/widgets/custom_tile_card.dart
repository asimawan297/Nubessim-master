import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';

class CustomListTileCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final IconData trailingIcon;
  final double borderRadius;
  final double elevation;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const CustomListTileCard({
    super.key,
    required this.title,
    this.onTap,
    this.trailingIcon = Icons.chevron_right,
    this.borderRadius = 11.0,
    this.elevation = 5.0,
    this.backgroundColor = AppColors.white,
    this.iconColor = AppColors.black,
    this.textColor = AppColors.questionColorColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: elevation,
              spreadRadius: 1,
              offset: const Offset(2, 2),
            ),
          ],
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 14.0,
                    ),
              ),
              Icon(
                trailingIcon,
                color: iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
