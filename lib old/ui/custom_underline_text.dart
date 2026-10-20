import 'package:flutter/material.dart';

class CustomUnderlineText extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color underlineColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double underlineThickness;
  final double underlineSpacing;

  const CustomUnderlineText({
    super.key,
    required this.text,
    this.textColor = Colors.black,
    this.underlineColor = Colors.black,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.underlineThickness = 2,
    this.underlineSpacing = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.values.firstWhere(
              (fw) => fw.index == fontWeight,
              orElse: () => FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: underlineSpacing), // space between text and underline
        Container(
          height: underlineThickness,
          color: underlineColor,
          width: double.infinity,
        ),
      ],
    );
  }
}
