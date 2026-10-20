import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class CustomButton extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const CustomButton({
    super.key,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Container(
          width: 80.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.0),
            color: const Color(0xffF6F6F6),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14.0,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 22.0,
                color: AppColors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
