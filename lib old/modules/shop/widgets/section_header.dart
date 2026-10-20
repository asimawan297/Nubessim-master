import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const SectionHeader({
    super.key,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$title ($count)",
          style: context.textTheme.titleMedium?.copyWith(
            color: AppColors.black,
            fontFamily: "Inter",
            fontSize: 19.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
