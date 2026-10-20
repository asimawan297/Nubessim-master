import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomCheckBox extends StatefulWidget {
  const CustomCheckBox({
    super.key,
    this.size = 18,
    required this.onChange,
    required this.value,
  });

  final bool value;
  final double? size;
  final Function(bool) onChange;

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  late bool _isChecked; // State to track checkbox status
  @override
  void initState() {
    super.initState();
    _isChecked = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isChecked = !_isChecked; // Toggle state on tap
        });
      },
      child: Container(
        width: widget.size, // Width of the checkbox
        height: widget.size, // Height of the checkbox
        decoration: BoxDecoration(
          color: _isChecked ? AppColors.primaryColor : Colors.transparent,
          // Background color of the checkbox
          borderRadius: BorderRadius.circular(4),
          // Rounded corners
          border: Border.all(
            color: AppColors.grey, // Border color
            width: 2,
          ),
        ),
        child: Icon(
          _isChecked ? Icons.check_outlined : Icons.clear,
          // Icon depending on checked state
          color: _isChecked ? AppColors.white : Colors.transparent,
          // Change icon color when checked
          size: 12,
          weight: 3.0,
        ),
      ),
    );
  }
}
