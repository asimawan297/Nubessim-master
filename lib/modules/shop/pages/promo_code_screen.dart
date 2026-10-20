import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/core/auth_service/firestore_service.dart';
import 'package:nubesim/ui/primary_button.dart';
import 'package:nubesim/utils/display/display_utils.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';

class PromoCodeScreen extends StatefulWidget {
  const PromoCodeScreen({super.key});

  @override
  State<PromoCodeScreen> createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen> {
  final TextEditingController promoController = TextEditingController();
  final TextEditingController coinsController = TextEditingController();
  bool isLoading = false;

  void _applyPromoCode() async {
    final code = promoController.text.trim();
    if (code.isEmpty) {
      DisplayUtils.showToast(context, "Please enter a promo code.");
      return;
    }

    setState(() => isLoading = true);

    final result = await FireStoreService().validatePromoCode(code);

    setState(() => isLoading = false);

    if (result != null) {
      final data = result['data'] as Map<String, dynamic>;
      Navigator.pop(context, {
        'discountPercentage': double.tryParse(data['discount']) ?? 0.0,
        'appliedPromoCode': data['code'],
        'appliedPromoDocId': result['docId'],
        'promoChecked': true,
      });
    } else {
      DisplayUtils.showToast(context, "Invalid or expired promo code.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Promo Code/ Nubes Coins",
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textColor,
            fontSize: 19.0,
            fontFamily: "Inter",
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Use Promo Code",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: promoController,
                    decoration: InputDecoration(
                      hintText: "Promo Code",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PrimaryButton(
                  onPressed: isLoading ? () {} : _applyPromoCode,
                  title: 'Apply',
                  backgroundColor: AppColors.purpleColor,
                  titleColor: AppColors.white,
                  width: 100,
                  fontSize: 11,
                  shadowColor: AppColors.transparent,
                  borderRadius: 90,
                  vMargin: 0,
                  hMargin: 22,
                  height: 45,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Row(
            //   children: [
            //     Expanded(child: Divider(color: Colors.grey)),
            //     const Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 10),
            //       child: Text(
            //         "Or use Nubes Coins",
            //         style: TextStyle(color: Colors.grey),
            //       ),
            //     ),
            //     Expanded(child: Divider(color: Colors.grey)),
            //   ],
            // ),
            // const SizedBox(height: 20),
            // Text(
            //   "Redeem your Nubes coins",
            //   style: TextStyle(
            //     color: primaryColor,
            //     fontWeight: FontWeight.bold,
            //     fontSize: 16,
            //   ),
            // ),
            // const SizedBox(height: 10),
            // Row(
            //   children: [
            //     Expanded(
            //       child: TextField(
            //         controller: coinsController,
            //         decoration: InputDecoration(
            //           hintText: "Nubes Coins",
            //           filled: true,
            //           fillColor: Colors.grey[200],
            //           border: OutlineInputBorder(
            //             borderSide: BorderSide.none,
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 10),
            //     ElevatedButton(
            //       onPressed: () {
            //         // TODO: Apply coins logic
            //       },
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: primaryColor,
            //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //       ),
            //       child: const Text("Apply"),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 8),
            const Text(
              "You have total of \$ 0.00  Nubes Coins on your Wallet",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      "You don’t have enough Nubes Coins for this purchase. The minimum required amount is \$1.50",
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontSize: 11.0,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(Icons.info_outline, color: primaryColor, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
