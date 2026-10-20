// ignore_for_file: must_be_immutable
import 'package:esim_compatibility/esim_compatibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nubesim/config/routes/nav_router.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/generated/assets.dart';
import 'package:nubesim/modules/authentication/widgets/auth_required_wrapper.dart';
import 'package:nubesim/modules/shop/cubits/currency_cubit/currency_cubit.dart';
import 'package:nubesim/modules/shop/pages/device_not_supported.dart';
import 'package:nubesim/modules/shop/pages/secure_checkout_screen.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:nubesim/utils/helper_widgets.dart';
import 'package:sizer/sizer.dart';
import '../model/all_data_packages_model.dart';
import '../widgets/eSIM_package_tile.dart';

class TopupPackageScreen extends StatefulWidget {
  const TopupPackageScreen({
    super.key,
    required this.name,
    required this.iccid,
    this.packageList,
  });

  final String name;
  final String iccid;
  final List<PackageList>? packageList;

  @override
  State<TopupPackageScreen> createState() => _TopupPackageScreentate();
}

class _TopupPackageScreentate extends State<TopupPackageScreen> {
  @override
  Widget build(BuildContext context) {
    final packages = widget.packageList ?? [];
    final quote = context.watch<CurrencyCubit>().state;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            extractCountry(widget.name),
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 19,
            ),
          ),
        ),
        body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: packages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              var package = packages[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xffFF668B).withOpacity(.7),
                      const Color(0xffCA2045),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      children: [
                        Container(
                          height: 17.w,
                          width: 17.w,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(Assets.imagesCardIcon),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          extractCountry(package.name),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _infoRow(
                      icon: Assets.svgCoverageIcon,
                      title: "COVERAGE",
                      value: extractCountry(package.name),
                    ),
                    _divider(),

                    _infoRow(
                      icon: Assets.svgDataTransferBoth,
                      title: "DATA",
                      value: "${formatBytesToGB(package.volume)} GB",
                    ),
                    _divider(),

                    _infoRow(
                      icon: Assets.svgCalendarIcon,
                      title: "VALIDITY",
                      value: "${package.duration} DAYS",
                    ),
                    _divider(),

                    _infoRow(
                      icon: Assets.svgPriceIcon,
                      title: "PRICE",
                      value:
                          quote.format(double.parse(calculateTotal(
                              package.retailPrice,
                              isUnlimited: package.dataType == 2))),
                    ),

                    const SizedBox(height: 24),

                    /// BUY BUTTON
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          if (AuthRequiredWrapper.isUserLoggedIn()) {
                            final isCompatible =
                                await EsimCompatibility.isEsimCompatible();

                            if (isCompatible) {
                              NavRouter.push(
                                  context,
                                  SecureCheckoutScreen(
                                    routeType: "TOP_UP",
                                    name: widget.name,
                                    iccid: widget.iccid,
                                    package: package,
                                  ));
                            } else {
                              final result = await NavRouter.push(
                                  context, DeviceNotSupported());
                              if (result != null && result == true) {
                                NavRouter.push(
                                    context,
                                    SecureCheckoutScreen(
                                      routeType: "TOP_UP",
                                      name: widget.name,
                                      iccid: widget.iccid,
                                      package: package,
                                    ));
                              }
                            }
                          } else {
                            AuthRequiredWrapper.showLoginDialog(
                              context,
                              message:
                                  "Please login to purchase this eSIM package",
                              isBottomBar: true,
                              checkoutName: widget.name,
                              checkoutPackage: package,
                              checkoutRouteType: 'TOP_UP',
                              checkoutIccid: widget.iccid,
                            );
                          }
                        },
                        child: Container(
                          width: 220,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            gradient: const LinearGradient(
                                colors: [Color(0xffFFE375), Color(0xffF9B400)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight),
                          ),
                          child: Center(
                            child: Text("Buy Now",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }));
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Divider(
        color: Colors.white.withOpacity(.3),
        thickness: 1,
      ),
    );
  }

  Widget _infoRow({
    required String icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        SvgPicture.asset(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
