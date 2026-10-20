import 'package:flutter/material.dart';
import 'package:nubesim/core/auth_service/firestore_service.dart';
import 'package:nubesim/utils/display/display_utils.dart';

class PromoCodeDialog {
  static Future<void> show(
    BuildContext context, {
    required Function(double discount, String code, String docId) onApplied,
  }) async {
    final TextEditingController promoController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Promo Code"),
          content: TextField(
            controller: promoController,
            decoration: const InputDecoration(hintText: "Enter your code"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final code = promoController.text.trim();
                final result = await FireStoreService().validatePromoCode(code);

                if (result != null) {
                  final data = result['data'] as Map<String, dynamic>;

                  final discount = double.tryParse(data['discount']) ?? 0.0;
                  final appliedCode = data['code'];
                  final docId = result['docId'];

                  // callback trigger karo
                  onApplied(discount, appliedCode, docId);

                  Navigator.pop(context);

                  DisplayUtils.showToast(
                    context,
                    "Promo applied: $appliedCode",
                  );
                } else {
                  DisplayUtils.showToast(
                    context,
                    "Invalid or expired promo code.",
                  );
                }
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
  }
}
