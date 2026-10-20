import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/generated/assets.dart';
import 'package:nubesim/ui/custom_appbar.dart';
import 'package:nubesim/ui/primary_button.dart';
import 'package:nubesim/utils/heights_and_widths.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Contact Us',
        titleColor: AppColors.textColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            h4,
            Image.asset(Assets.imagesContactUs),
            h2,
            Text(
              'We’re available 24/7 - you can use live chat ',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.questionColorColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.0,
                  ),
            ),
            h1,
            Text(
              'WhatsApp or Email to quickly reach out',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.questionColorColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.0,
                  ),
            ),
            // h4,
            // PrefixIconButton(
            //   onPressed: () {},
            //   title: 'Open Live Chat',
            //   prefixIconPath: Assets.svgChatLines,
            //   borderColor: AppColors.transparent,
            //   IconColor: AppColors.purpleColor,
            //   borderRadius: 8,
            //   backgroundColor: AppColors.white,
            //   fontSize: 14,
            //   prefixIconSize: 20,
            //   hPadding: 9,
            //   titleColor: AppColors.purpleColor,
            //   height: 45,
            // ),
            h2,
            PrefixIconButton(
              onPressed: () {
                openWhatsApp(phone: "17058812941", message: "Hello!");
              },
              title: 'Open WhatsApp',
              prefixIconPath: Assets.svgEmailLogo,
              borderColor: AppColors.transparent,
              borderRadius: 8,
              backgroundColor: AppColors.white,
              fontSize: 14,
              prefixIconSize: 20,
              hPadding: 9,
              titleColor: AppColors.purpleColor,
              height: 45,
              IconColor: AppColors.purpleColor,
            ),
            h2,
            PrefixIconButton(
              onPressed: () {
                openEmail("support@nubessim.com");
              },
              title: 'Open Email',
              prefixIconPath: Assets.svgWhatsAppLogo,
              borderColor: AppColors.transparent,
              borderRadius: 8,
              backgroundColor: AppColors.white,
              fontSize: 14,
              prefixIconSize: 20,
              hPadding: 9,
              titleColor: AppColors.purpleColor,
              height: 45,
              IconColor: AppColors.purpleColor,
            ),
          ],
        ),
      ),
    );
  }
}



Future<void> openWhatsApp({String? phone, String? message}) async {
    final url = phone != null
        ? Uri.parse(
            "https://wa.me/$phone?text=${Uri.encodeComponent(message ?? '')}")
        : Uri.parse("https://wa.me/");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch WhatsApp";
    }
  }

Future<void> openEmail(String email) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
    query: 'subject=${Uri.encodeComponent("Hello")}&body=${Uri.encodeComponent("How are you?")}',
  );

  try {
    await launchUrl(
      emailUri,
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    // debugPrint("❌ Could not open email app: $e");
  }
}
