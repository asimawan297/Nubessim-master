import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';

class PaymentFailedInstruction extends StatefulWidget {
  const PaymentFailedInstruction({super.key});

  @override
  State<PaymentFailedInstruction> createState() =>
      _PaymentFailedInstructionState();
}

class _PaymentFailedInstructionState extends State<PaymentFailedInstruction> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Payment Failed",
          style: TextStyle(
           color: AppColors.textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Asset image
            Image.asset(
              "assets/images/payment_failed.png", // <-- replace with your asset path
              height: 180,
            ),
            const SizedBox(height: 25),

            // Title
            const Text(
              "Oops! Something didn’t go as planned",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle
            const Text(
              "We’re sorry an error has occurrend. This card has already been used with Nubes. Use another card to claim your free eSIM.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            // Show Supported Device Button

            // Purchase Anyway Button
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFCD57B2).withOpacity(.7),
                      Color(0xFF911B76).withOpacity(.9)
                    ], // gradient colors
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // important!
                    shadowColor: Colors.transparent, // removes button shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    // Purchase flow
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Back to checkout",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
