import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {


  @override
  void initState() {
    loadHelpSection();
    super.initState();
  }

  WebViewController? controller;

  loadHelpSection(){
    controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setNavigationDelegate(
    NavigationDelegate(
      onProgress: (int progress) {
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) {},
      onHttpError: (HttpResponseError error) {},
      onWebResourceError: (WebResourceError error) {},
    
    ),
  )
  ..loadRequest(Uri.parse('https://nubessim.com/faq'));
  }
  @override
  Widget build(BuildContext context) {
    // print('@@@@ initState DDD');
    return Scaffold(
      // appBar: const CustomAppBar(
      //   title: 'Help',
      //   titleColor: AppColors.black,
      //   showBackButton: false,
      // ),
      body: controller == null ? Center(child: CircularProgressIndicator()) : WebViewWidget(controller: controller!)
    );
  }
}
