import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/config/routes/nav_router.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/generated/assets.dart';
import 'package:nubesim/modules/my_esim/cubits/all_esims_cubit/all_esims_cubit.dart';
import 'package:nubesim/modules/my_esim/cubits/all_esims_cubit/all_esims_state.dart';
import 'package:nubesim/modules/my_esim/pages/esim_detail_page.dart';
import 'package:nubesim/modules/shop/widgets/eSIM_package_tile.dart';
import 'package:nubesim/ui/custom_appbar.dart';
import 'package:nubesim/ui/widgets/loading_indicator.dart';
import 'package:nubesim/utils/display/display_utils.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:nubesim/utils/heights_and_widths.dart';
import 'package:nubesim/utils/time_utils.dart';

import '../../my_esim/models/all_allocated_esim_input.dart';
import '../../my_esim/models/all_esim_model.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context
          .read<EsimCubit>()
          .fetchEsims(input: AllAllocatedEsimInput.initial());
    });
  }

  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (!_isFetched) {
  //     context.read<OrderHistoryCubit>().fetchOrderList(getUID());
  //     _isFetched = true;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Orders', titleColor: AppColors.black),
      body: BlocBuilder<EsimCubit, EsimState>(
        builder: (context, state) {
          if (state.status == EsimStatus.loading) {
            return LoadingIndicator();
          } else if (state.status == EsimStatus.error) {
            return Center(child: Text(state.message),);
            // return Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Text("Retry to Get eSim"),
            //       ],
            //     ),
            //     InkWell(
            //       onTap: () {
            //         context
            //             .read<EsimCubit>()
            //             .fetchEsims(input: AllAllocatedEsimInput.initial());
            //       },
            //       child: Container(
            //         margin: EdgeInsets.only(top: 40),
            //         decoration: BoxDecoration(
            //           gradient: LinearGradient(
            //             colors: [Color(0xffCD57B2), Color(0xff911B76)],
            //           ),
            //           borderRadius: BorderRadius.circular(100.0),
            //         ),
            //         padding: EdgeInsets.all(12.0),
            //         child: Row(
            //           mainAxisSize: MainAxisSize.min,
            //           spacing: 6.0,
            //           children: [
            //             Icon(
            //               Icons.help_outline,
            //               color: Colors.white,
            //               size: 24.0,
            //             ),
            //             Text(
            //               "Retry",
            //               style: context.textTheme.bodyMedium?.copyWith(
            //                 fontFamily: "Inter",
            //                 color: Colors.white,
            //                 fontSize: 12.0,
            //               ),
            //             ),
            //             Icon(
            //               Icons.chevron_right,
            //               color: Colors.white,
            //               size: 16.0,
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ],
            // );
          } else if (state.status == EsimStatus.success) {
            // 🔁 Your original "no data" UI
            return state.getTotalEsims().isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(Assets.imagesOrder),
                        h2,
                        SizedBox(
                          width: 220,
                          child: Text(
                            textAlign: TextAlign.center,
                            "You don't have any orders yet.",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 21.0,
                                ),
                          ),
                        ),
                        h1,
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 260,
                            child: Text(
                              textAlign: TextAlign.center,
                              "When you purchase an eSIM or top-up package, you will see your order details here",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: AppColors.greyColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14.0,
                                  ),
                            ),
                          ),
                        ),
                        h6,
                      ],
                    ),
                  )
                :

                // ✅ Show list of orders
                RefreshIndicator(
                    onRefresh: () async {
                      await context
                          .read<EsimCubit>()
                          .fetchEsims(input: AllAllocatedEsimInput.initial());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.getTotalEsims().length,
                      itemBuilder: (context, index) {
                        EsimList order = state.getTotalEsims()[index];

                        return InkWell(
                          onTap: () {
                            NavRouter.push(
                                context, EsimDetailScreen(selectedEsim: order));
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide.none,
                            ),
                            child: Theme(
                              data: Theme.of(context)
                                  .copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                // leading: CircleAvatar(
                                //     child: Image.network(order.)),
                                title: Text(
                                   extractCountry(order.packageList.first.packageName)
                                        ),
                                subtitle:
                                    Text("Order Number : ${order.orderNo}"),
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "IccID:".toUpperCase(),
                                            style: context.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.black,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    order.iccid,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: context
                                                        .textTheme.bodyMedium
                                                        ?.copyWith(
                                                      fontSize: 12,
                                                      color:
                                                          AppColors.greyColor,
                                                    ),
                                                  ),
                                                ),
                                                w1,
                                                InkWell(
                                                    onTap: () {
                                                      final trxId =
                                                          order.iccid;
                                                      if (trxId.isNotEmpty) {
                                                        Clipboard.setData(
                                                            ClipboardData(
                                                                text: trxId));

                                                        DisplayUtils
                                                            .showToast(
                                                                context,
                                                                "IccID copied",
                                                                );
                                                      }
                                                    },
                                                    child: Icon(Icons.copy,
                                                        size: 16,
                                                        color: AppColors
                                                            .greyColor)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Created Time:",
                                          style: context.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            "${dateTimeAccordingZone(order.packageList.first.createTime)}",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: context.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontSize: 12,
                                              color: AppColors.greyColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
          }
          return LoadingIndicator();
        },
      ),
    );
  }
}
