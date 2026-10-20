import 'dart:io';

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:nubesim/generated/assets.dart';
import 'package:nubesim/modules/base_view/page/base_view.dart';
import '../../../config/routes/nav_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final facebookAppEvents = FacebookAppEvents();
  @override
  void initState() {
    super.initState();

    // Logo fade-in animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    init();
    // Navigate after 3-5 seconds
    Future.delayed(const Duration(seconds: 4), () {
      NavRouter.pushReplacement(context, BaseScreen());
    });
  }

  Future<void> init({bool enable = true}) async {
    try {
      await facebookAppEvents.activateApp();

      await facebookAppEvents.logEvent(
        name: 'app_open',
        parameters: {
          'platform': Platform.isAndroid ? 'android' : 'ios',
        },
      );
      await analytics.setAnalyticsCollectionEnabled(enable);

      await analytics.logEvent(
        name: 'app_launch',
        parameters: <String, Object>{
          'platform': Platform.isAndroid ? "Android" : "iOS",
        },
      );
    } catch (e) {
      //
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // same as Figma background
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset(
            Assets.imagesLogo, // your Figma exported logo
            height: 200,
          ),
        ),
      ),
    );
  }
}
