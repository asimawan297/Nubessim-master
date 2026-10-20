import 'dart:async';
import 'package:flutter/material.dart';

class ColorLoader extends StatefulWidget {
  const ColorLoader({super.key});

  @override
  _ColorLoaderState createState() => _ColorLoaderState();
}

class _ColorLoaderState extends State<ColorLoader>
    with SingleTickerProviderStateMixin {
  int activeIndex = 0;
  late Timer timer;

  final List<Color> colors = [
    Color(0xfaF9B400).withOpacity(.3),
    Color(0xfaF9B400).withOpacity(.4),
    Color(0xfaCA2045).withOpacity(.5),
    Color(0xfaCA2045).withOpacity(.6),
    Color(0xfa911B76).withOpacity(.7),
    Color(0xfa911B76).withOpacity(.1),
  ];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      setState(() {
        activeIndex = (activeIndex + 1) % colors.length;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(colors.length, (index) {
        return AnimatedOpacity(
          opacity: activeIndex == index ? 1.0 : 0.3,
          duration: const Duration(milliseconds: 300),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colors[index],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
