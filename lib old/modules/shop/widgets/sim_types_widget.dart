import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';

class SimTypesWidget extends StatelessWidget {
  const SimTypesWidget({
    super.key,
    required this.name,
    required this.selectedName,
    this.onSelect,
  });

  final String name;
  final String selectedName;
  final Function(String)? onSelect;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onSelect!(name);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: name.trim().toLowerCase() == selectedName.trim().toLowerCase()
              ? Color(0xffD0284D)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Center(
          child: Text(
            name,
            style: context.textTheme.titleMedium?.copyWith(
              fontFamily: "Inter",
              fontSize: 12.0,
              color:
                  name.trim().toLowerCase() == selectedName.trim().toLowerCase()
                      ? Colors.white
                      : AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
