import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/config/routes/nav_router.dart';
import 'package:nubesim/generated/assets.dart';
import 'package:nubesim/modules/base_view/page/base_view.dart';
import 'package:nubesim/modules/my_esim/pages/after_installation_topup_screen.dart';
import 'package:nubesim/modules/my_esim/pages/error_screen.dart';
import 'package:nubesim/modules/my_esim/pages/esim_detail_page.dart';
import 'package:nubesim/modules/my_esim/pages/no_topup_screen.dart';
import 'package:nubesim/modules/shop/cubits/data_package_cubit/data_package_cubit.dart';
import 'package:nubesim/modules/shop/pages/topUP_Package_view.dart';
import 'package:nubesim/modules/shop/widgets/eSIM_package_tile.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:nubesim/utils/helper_widgets.dart';
import '../../../utils/custom_loading_boxes.dart';
import '../models/all_esim_model.dart';

class ActiveEsimTab extends StatelessWidget {
  const ActiveEsimTab({super.key, required this.list});

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
                      Image.asset(Assets.imagesSIM),
                      Text(
                        "Get your eSim",
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 21.0,
                          color: Colors.black,
                          fontFamily: "Inter",
                        ),
                      ),
                      Text(
                        "Choose Your eSIM for multiple countries,\nregions, and destinations arround the world",
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.0,
                          color: Color(0xff606A71),
                          fontFamily: "Inter",
                        ),
                      ),
                      InkWell(
                        onTap: () {
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
                                "How To Get Your eSIM",
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontFamily: "Inter",
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 16.0,
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
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final model = list[index];
                // debugger();

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
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: EsimPackageTile(
                    dataType: model.dataType,
                    eSimStatus: model.esimStatus,
                    name: hasPackages
                        ? model.packageList.first.packageName
                        : model.iccid,
                    showBuyNow: false,
                    myEsims: true,
                    iccid: model.iccid,
                    package: null,
                    dataDisplayOverride: dataDisplay,
                    validityDisplayOverride: validityDisplay,
                    detailButton: () {
                      NavRouter.push(
                          context, EsimDetailScreen(selectedEsim: model));
                    },
                    topUpButton: () async {
                      if (model.supportTopUpType == 1) {
                        NavRouter.push(context, NoTopupScreen());
                      } else if (model.supportTopUpType == 2) {
                        if (model.activateTime == null) {
                          NavRouter.push(
                              context, AfterInstallationTopupScreen());
                        } else {
                          await context
                              .read<DataPackageCubit>()
                              .getAllTopUpPackages(
                                model.packageList.first.packageCode ?? "",
                              );

                          final topUpPackages = context
                              .read<DataPackageCubit>()
                              .state
                              .topUppackageList;
                          if (topUpPackages.isNotEmpty) {
                            NavRouter.push(
                                context,
                                TopupPackageScreen(
                                    iccid: model.iccid,
                                    name: hasPackages
                                        ? model.packageList.first.packageName
                                        : model.iccid,
                                    packageList: topUpPackages));
                          } else {
                            NavRouter.push(context, NoTopupScreen());
                          }
                        }
                      } else {
                        NavRouter.push(context, ErrorScreen());
                      }
                    },
                  ),
                );
              },
              itemCount: list.length,
            ),
    );
  }
}
