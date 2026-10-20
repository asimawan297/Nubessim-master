import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/ui/custom_appbar.dart';


class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Error',
        titleColor: AppColors.black,
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Image.asset("assets/images/cross.png"),
          SizedBox(height: 30,),
          Text("Oops! Something didn’t go as planned", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
          SizedBox(height: 20,),
          Text("Please note: This eSIM plan does not offer a top-up facility"),
        
        ],),
      ),
    );
  }
}