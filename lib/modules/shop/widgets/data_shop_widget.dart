import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';

class DataShopWidget extends StatelessWidget {
  const DataShopWidget({super.key, this.iconPath, required this.name});

  final String? iconPath;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: Row(
        // spacing: 6.0,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconPath != null) ...[
            SvgPicture.asset(iconPath!, height: 15.0, color: Colors.black),
            SizedBox(width: 4.0),
          ],
          Text(
            name,
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.black,
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              fontFamily: "Inter",
            ),
          ),
          SizedBox(width: 4.0),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}
