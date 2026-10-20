import 'package:flutter/material.dart';
import 'package:nubesim/config/routes/nav_router.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/modules/profile/pages/about_app.dart';
import 'package:nubesim/modules/profile/pages/privacy_policy.dart';
import 'package:nubesim/modules/profile/pages/terms_and_conditions.dart';
import 'package:nubesim/modules/profile/widgets/custom_tile_card.dart';
import 'package:nubesim/ui/custom_appbar.dart';
import 'package:nubesim/utils/heights_and_widths.dart';

class MoreInfoPage extends StatelessWidget {
  const MoreInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'More Info',
        titleColor: AppColors.textColor,
      ),
      body: Container(
        height: 200,
        margin: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
        padding: const EdgeInsets.symmetric(vertical: 12),
        // decoration: BoxDecoration(
        //   color: AppColors.expansionTileBgColor,
        //   borderRadius: BorderRadius.circular(12),
        // ),
        child: Column(
          children: [
            CustomListTileCard(
              title: "About Nubes",
              onTap: () {
                NavRouter.pushFromRoot(context, AboutApp());
              },
            ),
            h1,
            CustomListTileCard(
              title: "Privacy Policy",
              onTap: () {
                NavRouter.pushFromRoot(context, PrivacyPolicy());
              },
            ),
            h1,
            CustomListTileCard(
              title: "Terms & Condition",
              onTap: () {
                NavRouter.pushFromRoot(context, TermsAndConditions());
              },
            ),
          ],
        ),
      ),
    );
  }
}
