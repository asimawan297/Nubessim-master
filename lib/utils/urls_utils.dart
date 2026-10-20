


import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

Future<void> openYouTubeVideo(String link) async {
  final url = Uri.parse(link);

  if (await canLaunchUrl(url)) {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication, // ✅ Open outside app
    );
  } else {
    throw 'Could not launch $url';
  }
}
Future<void> openStore() async {
  final String androidUrl = "https://play.google.com/store/apps/details?id=com.arham.nubes&pli=1";
  final String iosUrl = "https://apps.apple.com/app/6751854186?action=write-review";

  final Uri url = Uri.parse(Platform.isAndroid ? androidUrl : iosUrl);

  if (await canLaunchUrl(url)) {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw "Could not launch Store URL";
  }
}