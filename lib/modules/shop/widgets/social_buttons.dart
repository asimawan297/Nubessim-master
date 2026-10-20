import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons(
      {super.key, required this.name, required this.iconPath, this.onTap});

  final String name, iconPath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1.4),
          borderRadius: BorderRadius.circular(100.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 6.0,
          children: [
            SvgPicture.asset(iconPath, height: 24.0),
            Text(
              name,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
