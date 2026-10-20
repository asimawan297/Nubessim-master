import 'package:flutter/material.dart';

class ColorBoxesWidget extends StatelessWidget {
  const ColorBoxesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen height to compute 1/3
    final screenHeight = MediaQuery.of(context).size.height;
    final mainContainerHeight = screenHeight / 3;

    // List of color hex codes
    final colors = [
      Color(0xFFF3E0A9),
      Color(0xFFF5DA91),
      Color(0xFFDD899C),
      Color(0xFFD9748A),
      Color(0xFFAE5B9B),
      Color(0xFF911B76),
    ];

    return Center(
      child: SizedBox(
        // height: mainContainerHeight,
        width: 200, // You can adjust this width as needed
        // color: Colors.grey[200], // Optional: background color for visibility
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: colors
              .map(
                (color) => Container(width: 10, height: 10, color: color),
              )
              .toList(),
        ),
      ),
    );
  }
}

class ColorBoxesWidget2 extends StatelessWidget {
  const ColorBoxesWidget2({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen height to compute 1/3
    final screenHeight = MediaQuery.of(context).size.height;
    final mainContainerHeight = screenHeight / 3;

    // List of color hex codes
    final colors = [
      Color(0xFFF1F3F2),
      Color(0xFFF1F3F2),
      Color(0xFFF1F3F2),
      Color(0xFFF1F3F2),
      Color(0xFFF1F3F2),
      Color(0xFFF1F3F2),
    ];

    return Center(
      child: SizedBox(
        width: 160, // You can adjust this width as needed
        // color: Colors.grey[200], // Optional: background color for visibility
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 8,
              height: 8,
              color: Colors.white.withOpacity(0.3),
            ),
            Container(
              width: 8,
              height: 8,
              color: Colors.white.withOpacity(0.4),
            ),
            Container(
              width: 8,
              height: 8,
              color: Colors.white.withOpacity(0.5),
            ),
            Container(
              width: 8,
              height: 8,
              color: Colors.white.withOpacity(0.6),
            ),
            Container(
              width: 8,
              height: 8,
              color: Colors.white.withOpacity(0.7),
            ),
            Container(width: 8, height: 8, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
