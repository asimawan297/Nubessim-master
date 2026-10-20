import 'package:flutter/material.dart';
import 'package:nubesim/config/config.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/modules/base_view/page/base_view.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';

import '../../../utils/heights_and_widths.dart';

class VoiceTab extends StatefulWidget {
  const VoiceTab({super.key});

  @override
  State<VoiceTab> createState() => _VoiceTabState();
}

class _VoiceTabState extends State<VoiceTab> {
  final List<Map<String, String>> dialPadItems = [
    {"number": "1", "text": ""},
    {"number": "2", "text": "ABC"},
    {"number": "3", "text": "DEF"},
    {"number": "4", "text": "GHI"},
    {"number": "5", "text": "JKL"},
    {"number": "6", "text": "MNO"},
    {"number": "7", "text": "PQRS"},
    {"number": "8", "text": "TUV"},
    {"number": "9", "text": "WXYZ"},
    {"number": "*", "text": ""},
    {"number": "0", "text": "+"},
    {"number": "#", "text": ""},
  ];
void showComingSoonDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("🚀 Coming Soon"),
        content: const Text(
          "This feature will be available soon. Stay tuned!",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: (){
              NavRouter.pushTORoot(context, BaseScreen());
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          Text(
            "+1",
            style: context.textTheme.headlineLarge?.copyWith(
              fontSize: 40.0,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryColor,
            ),
          ),
          h1,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 38.0,
              childAspectRatio: 1.0,
            ),
            itemCount: dialPadItems.length,
            itemBuilder: (context, index) {
              final item = dialPadItems[index];
              return _dialerButton(
                dialNumber: item["number"]!,
                text: item["text"]!,
              );
            },
          ),
          h1,
          Center(
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Color(0xff00D465),
                borderRadius: BorderRadius.circular(80.0),
              ),
              padding: const EdgeInsets.all(12.0),
              alignment: Alignment.center,
              child: Icon(Icons.call, size: 45.0, color: Colors.white),
            ),
          ),
          // h2,
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(100.0),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              spacing: 6.0,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "0",
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: 18.0,
                    color: AppColors.logoColor2,
                  ),
                ),
                Text(
                  "minutes remaining",
                  style: context.textTheme.titleMedium?.copyWith(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialerButton({required String dialNumber, required String text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(90.0),
          ),
          padding: const EdgeInsets.all(12.0),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dialNumber,
                style: context.textTheme.headlineLarge?.copyWith(
                  fontSize: 32.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
              Text(
                text,
                style: context.textTheme.headlineLarge?.copyWith(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
