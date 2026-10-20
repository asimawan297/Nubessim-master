import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/ui/custom_appbar.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:nubesim/utils/heights_and_widths.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'About Us',
       titleColor: AppColors.textColor
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Welcome to Nubes SIM – Your Gateway to Seamless Connectivity.',
                style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: 22, height: 1.6, fontWeight: FontWeight.w700)),
            h1,
            Text(
                'At Nubes SIM, we believe that staying connected should be simple, affordable, and borderless. That’s why we’ve created a next-generation eSIM solution that empowers travelers, digital nomads, and global citizens to access fast and reliable mobile data wherever they are in the world.',
                style: context.textTheme.bodyMedium
                    ?.copyWith(fontSize: 16, height: 1.6)),
            h1,
            Text(
                'Our mission is to make global connectivity effortless. With Nubes SIM, there’s no need to hunt for local SIM cards or pay high roaming charges. Just download, activate, and stay online — it’s that easy.',
                style: context.textTheme.bodyMedium
                    ?.copyWith(fontSize: 16, height: 1.6)),
            h2,
            Text('What We Offer:',
                style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: 18, height: 1.6, fontWeight: FontWeight.w500)),
            SizedBox(height: 12),
            BulletPoint(
              text: 'Instant eSIM activation in 180+ countries',
            ),
            BulletPoint(text: 'Affordable data plans tailored to your needs'),
            BulletPoint(text: '24/7 customer support'),
            BulletPoint(
                text: 'A user-friendly app to manage your data on the go'),
            h2,
            Text(
                'Stay connected worldwide with NubesSIM. Whether you’re traveling for business, vacation, or living abroad — we make it easy.',
                style: context.textTheme.bodyMedium
                    ?.copyWith(fontSize: 16, height: 1.6)),
            SizedBox(height: 12),
            Text('Stay connected, stay limitless. Nubes SIM.',
                style: context.textTheme.bodyMedium
                    ?.copyWith(fontSize: 16, height: 1.6)),
          ],
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(text,
                style: context.textTheme.bodyMedium
                    ?.copyWith(fontSize: 16, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
