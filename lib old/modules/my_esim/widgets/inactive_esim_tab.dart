import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nubesim/config/routes/nav_router.dart';
import 'package:nubesim/modules/base_view/page/base_view.dart';
import 'package:nubesim/modules/shop/widgets/eSIM_package_tile.dart';
import 'package:nubesim/utils/display/display_utils.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:nubesim/utils/helper_widgets.dart';

import '../../../generated/assets.dart';
import '../../../utils/custom_loading_boxes.dart';
import '../models/all_esim_model.dart';

class InactiveEsimTab extends StatelessWidget {
  const InactiveEsimTab({super.key, required this.list});

  final List<EsimList> list;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 18.0),
      child: list.isEmpty
          ? ListView(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 12.0,
                    children: [
                      Image.asset(Assets.imagesESim),
                      Text(
                        "Get a eSIM",
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 21.0,
                          color: Colors.black,
                          fontFamily: "Inter",
                        ),
                      ),
                      Text(
                        "Buy your eSIM packages with Nubes.\nChoose from multiple countries and region\naround the world.",
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.0,
                          color: Color(0xff606A71),
                          fontFamily: "Inter",
                        ),
                      ),
                      InkWell(
                         onTap: (){
                          NavRouter.pushTORoot(context, BaseScreen());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xffCD57B2), Color(0xff911B76)],
                            ),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          padding: EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 6.0,
                            children: [
                              Icon(
                                Icons.help_outline,
                                color: Colors.white,
                                size: 24.0,
                              ),
                              Text(
                                "Find out how",
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontFamily: "Inter",
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 16.00,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                ColorBoxesWidget(),
              ],
            )
          : ListView.builder(
              itemBuilder: (context, index) {
                final model = list[index];
                final bool hasPackages = model.packageList.isNotEmpty;
                final String? dataDisplay = model.totalVolume > 0
                    ? formatBytes(model.totalVolume)
                    : (hasPackages
                        ? formatBytes(model.packageList.first.volume)
                        : null);
                final String? validityDisplay = model.totalDuration > 0
                    ? "${model.totalDuration} ${model.durationUnit}"
                    : (hasPackages
                        ? "${model.packageList.first.duration} Days"
                        : null);

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 24.0,
                  ),
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                Color(0xffFF668B).withOpacity(.7),
                                Color(0xffCA2045)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 25),
                            const Text(
                              "ICCID NUMBER",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            Divider(
                                color: Colors.white.withOpacity(.1),
                                thickness: 1.5),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  model.iccid,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                    onTap: () async {
                                      await Clipboard.setData(
                                        ClipboardData(text: model.iccid),
                                      );

                                      DisplayUtils.showSnackBar(
                                          context, "ICCID copied to clipboard",
                                          type: "success");
                                    },
                                    child: Icon(Icons.copy,
                                        color: Colors.white, size: 18)),
                              ],
                            ),
                            Divider(
                                color: Colors.white.withOpacity(.1),
                                thickness: 1.5),
                            const SizedBox(height: 8),
                            const Text(
                              "Coverage",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            Divider(
                                color: Colors.white.withOpacity(.1),
                                thickness: 1.5),
                            const SizedBox(height: 8),
                            Text(
                             extractCountry( model.packageList.first.packageName),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            Divider(
                                color: Colors.white.withOpacity(.1),
                                thickness: 1.5),
                            const SizedBox(height: 20),
                            Text(
                              "Status: ${model.esimStatus}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0, bottom: 10),
                        child: Image.asset(
                          "assets/images/simlogo.png",
                          height: 60,
                          width: 60,
                        ),
                      )
                    ],
                  ),
                );
              },
              itemCount: list.length,
            ),
    );
  }
}
