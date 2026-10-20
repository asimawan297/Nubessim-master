import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nubesim/config/routes/nav_router.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/generated/assets.dart';
import 'package:nubesim/modules/my_esim/cubits/esim_details_cubit/esim_detail_cubit.dart';
import 'package:nubesim/modules/my_esim/cubits/esim_details_cubit/esim_detail_state.dart';
// import 'package:nubesim/modules/my_esim/models/all_esim_model.dart' as all_esim;
import 'package:nubesim/modules/my_esim/models/all_esim_model.dart';
import 'package:nubesim/modules/my_esim/models/esim_details_input.dart'
    as details_input;
import 'package:nubesim/modules/my_esim/pages/package_info.dart';
import 'package:nubesim/modules/my_esim/pages/view_instructions_screen.dart';
import 'package:nubesim/modules/shop/widgets/eSIM_package_tile.dart';
import 'package:nubesim/utils/display/display_utils.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';
import 'package:sizer/sizer.dart';

class EsimDetailScreen extends StatefulWidget {
  final EsimList selectedEsim;
  const EsimDetailScreen({super.key, required this.selectedEsim});

  @override
  State<EsimDetailScreen> createState() => _EsimDetailScreenState();
}

class _EsimDetailScreenState extends State<EsimDetailScreen> {
  @override
  void initState() {
    context.read<EsimDetailCubit>().fetchEsimDetails(
          input: details_input.EsimDetailsInput(
            orderNo: widget.selectedEsim.orderNo,
            esimTranNo: widget.selectedEsim.esimTranNo,
            iccid: widget.selectedEsim.iccid,
            pager: details_input.Pager(
              pageNum: 1,
              pageSize: 20,
            ),
          ),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Details",
          style: TextStyle(
              color: AppColors.textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocBuilder<EsimDetailCubit, EsimDetailState>(
            builder: (context, state) {
              // For testing
              int totalBytes =
                  widget.selectedEsim.totalVolume; // 1 GB (in bytes)
              int usedBytes = widget.selectedEsim.orderUsage; // 256 MB used
              String totalVolume = formatBytes(totalBytes);
              String orderUseage = formatBytes(usedBytes);
              String remainingVolume = formatBytes(totalBytes - usedBytes);
              double usagePercent = usedBytes / totalBytes;
              // debugger();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Card
                  Stack(
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
                            const Text(
                              "ICCID NUMBER",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            Divider(
                                color: Colors.white.withOpacity(.1),
                                thickness: 1.5),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  widget.selectedEsim.iccid,
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
                                        ClipboardData(
                                            text: widget.selectedEsim.iccid),
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
                            const SizedBox(height: 3),
                            const Text(
                              "Coverage",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            Divider(
                                color: Colors.white.withOpacity(.1),
                                thickness: 1.5),
                            const SizedBox(height: 3),
                            Text(
                              extractCountry(widget
                                  .selectedEsim.packageList.first.packageName),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            Divider(
                                color: Colors.white.withOpacity(.1),
                                thickness: 1.5),
                            const SizedBox(height: 3),
                            // const Text(
                            //   "APN",
                            //   style: TextStyle(
                            //       color: Colors.white70, fontSize: 12),
                            // ),
                            // Divider(
                            //     color: Colors.white.withOpacity(.1),
                            //     thickness: 1.5),
                            // const SizedBox(height: 3),
                            // Row(
                            //   children: [
                            //     Text(
                            //       widget.selectedEsim.apn,
                            //       style:
                            //           TextStyle(color: Colors.white, fontSize: 14),
                            //     ),
                            //         SizedBox(
                            //       width: 10,
                            //     ),
                            //     InkWell(
                            //         onTap: () async {
                            //           await Clipboard.setData(
                            //             ClipboardData(
                            //                 text: widget.selectedEsim.apn),
                            //           );
                            //           DisplayUtils.showSnackBar(context, "APN copied to clipboard", type: "success");

                            //         },
                            //         child: Icon(Icons.copy,
                            //             color: Colors.white, size: 18)),
                            //   ],
                            // ),
                            // Divider(
                            //     color: Colors.white.withOpacity(.1),
                            //     thickness: 1.5),
                            const SizedBox(height: 20),
                            GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                    ),
                                    builder: (context) {
                                      return SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.7,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 20,
                                            bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom +
                                                20,
                                          ),
                                          child: PackageInfoSheet(
                                              esimTranNo: widget
                                                  .selectedEsim.esimTranNo,
                                              createTime: widget.selectedEsim.activateTime ??
                                                  widget
                                                      .selectedEsim
                                                      .packageList
                                                      .first
                                                      .createTime,
                                              activateTime: widget.selectedEsim.activateTime ??
                                                  "",
                                              basicPlan: widget.selectedEsim.dataType == 2
                                                  ? "Unlimited"
                                                  : widget
                                                      .selectedEsim
                                                      .packageList
                                                      .first
                                                      .packageName,
                                              basicPlanSpeedTxt:
                                                  widget.selectedEsim.dataType == 2
                                                      ? "Unlimited / Max Speed ${formatBytes(widget.selectedEsim.packageList.first.volume)} / Day"
                                                      : widget
                                                          .selectedEsim
                                                          .packageList
                                                          .first
                                                          .packageName,
                                              basicPlanCreated: widget
                                                      .selectedEsim
                                                      .packageList
                                                      .first
                                                      .createTime ??
                                                  "",
                                              topupPlan: widget.selectedEsim.packageList.where((pkg) => pkg.packageCode?.startsWith('TOPUP') ?? false).toList() ?? []),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Center(
                                    child: Text(
                                      "SHOW MORE",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.white),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0, bottom: 10),
                        child: Image.asset(
                          "assets/images/SIM 1.png",
                          height: 60,
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Warning
                        Container(
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                            right: 0,
                            left: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xffFF668B).withOpacity(.7),
                                const Color(0xffCA2045),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Text
                                  Expanded(
                                    child: Text(
                                      "Caution: Your eSIM is non-transferable and can only be installed once. "
                                      "Once installed, it cannot be moved to another device. Deleting it will render it unusable.",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 50),

                                  // Asset Image (SVG/PNG)
                                ],
                              ),
                              Image.asset(
                                  "assets/images/warning.png", // put your asset image here
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.contain),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (widget.selectedEsim.esimStatus.toLowerCase() ==
                            "new")
                          Container(
                            padding: const EdgeInsets.only(
                              top: 10,
                              bottom: 10,
                              left: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xffFF668B).withOpacity(.7),
                                  const Color(0xffCA2045),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Text
                                    Expanded(
                                      child: Text(
                                        "Please note, you must activate your purchased eSIM by ${DateFormat("MMM dd, yyyy").format(DateTime.parse(widget.selectedEsim.expiredTime))}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 50),

                                    // Asset Image (SVG/PNG)
                                  ],
                                ),
                                Image.asset(
                                  "assets/images/warning.png", // put your asset image here
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 30),

                        Card(
                          color: AppColors.lightGrey,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              // Handle click
                              NavRouter.push(
                                  context,
                                  ViewInstructionsScreen(
                                      selectedEsim: widget.selectedEsim));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              child: Row(
                                children: [
                                  // Left Icon
                                  const Icon(Icons.file_download_outlined,
                                      size: 22, color: Colors.black),

                                  const SizedBox(width: 12),

                                  // Text
                                  const Expanded(
                                    child: Text(
                                      "eSIM Installation",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  // Right Icon
                                  const Icon(Icons.arrow_forward_ios,
                                      size: 16, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // eSIM Installation

                        const SizedBox(height: 30),

                        // Data usage
                        Card(
                          color: AppColors.lightGrey,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("DATA",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 5),
                                // Convert to double for progress value

                                Center(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CircularPercentIndicator(
                                        radius: 60.0,
                                        lineWidth: 10.0,
                                        percent: usagePercent.clamp(
                                            0.0, 1.0), // ensure between 0 and 1
                                        center: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              widget.selectedEsim.dataType == 2
                                                  ? "Unlimited"
                                                  : remainingVolume, // e.g., "80 MB"
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                            const Text(
                                              "Remaining",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        progressColor:
                                            Colors.blue, // used data color
                                        backgroundColor: Colors
                                            .grey[300]!, // remaining data color
                                        circularStrokeCap: CircularStrokeCap
                                            .round, // rounded edges
                                      ),
                                      const SizedBox(height: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "USED DATA",
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            orderUseage,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "TOTAL DATA",
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            widget.selectedEsim.dataType == 2
                                                ? "Unlimited"
                                                : totalVolume,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Packages
                        Card(
                          color: AppColors.lightGrey,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("MY PACKAGES",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: widget.selectedEsim.esimStatus ==
                                                "GOT_RESOURCE" ||
                                            widget.selectedEsim.esimStatus ==
                                                "IN_USE"
                                        ? Colors.green
                                        : Colors.orange[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    widget.selectedEsim.esimStatus == "IN_USE"
                                        ? "Active"
                                        : widget.selectedEsim.esimStatus ==
                                                "GOT_RESOURCE"
                                            ? "Installed"
                                            : "Not Active",
                                    style: TextStyle(
                                        color: widget.selectedEsim.esimStatus ==
                                                    "GOT_RESOURCE" ||
                                                widget.selectedEsim
                                                        .esimStatus ==
                                                    "IN_USE"
                                            ? Colors.black
                                            : Colors.orange,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(Assets.validityIcon,
                                                height: 2.h),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text("VALIDITY"),
                                          ],
                                        ),
                                        if (widget.selectedEsim.activateTime ==
                                            null)
                                          Text("- - - - - - - - -")
                                        else
                                          Text(
                                              getValidity(
                                                DateTime.parse(widget
                                                    .selectedEsim.activateTime),
                                                widget
                                                    .selectedEsim.durationUnit,
                                                widget
                                                    .selectedEsim.totalDuration,
                                              ),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(Assets.dataIcon,
                                                height: 3.h),
                                            SizedBox(width: 10),
                                            Text("DATA"),
                                          ],
                                        ),
                                        Text(
                                            widget.selectedEsim.dataType == 2
                                                ? "Unlimited"
                                                : totalVolume,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String getValidity(
      DateTime activateTime, String durationUnit, int totalDuration) {
    // 1. Calculate expiry date
    DateTime expiryDate;
    if (durationUnit.toUpperCase() == "DAY") {
      expiryDate = activateTime.add(Duration(days: totalDuration));
    } else if (durationUnit.toUpperCase() == "MONTH") {
      expiryDate = DateTime(activateTime.year,
          activateTime.month + totalDuration, activateTime.day);
    } else {
      expiryDate = activateTime; // fallback
    }

    // 2. Calculate remaining time
    Duration remaining = expiryDate.difference(DateTime.now());

    String leftText;
    if (remaining.inDays > 0) {
      leftText = "${remaining.inDays} Days left";
    } else if (remaining.inHours > 0) {
      leftText = "${remaining.inHours} Hours left";
    } else {
      leftText = "Expired";
    }

    // 3. Format expiry date (optional for display)
    String formattedExpiry = DateFormat("dd MMM yyyy").format(expiryDate);

    return "$formattedExpiry ($leftText)";
  }

  String formatBytes(int bytes) {
    const int kb = 1024;
    const int mb = 1024 * kb;
    const int gb = 1024 * mb;
    const int tb = 1024 * gb;

    if (bytes >= tb) {
      return "${(bytes / tb).toStringAsFixed(2)} TB";
    } else if (bytes >= gb) {
      return "${(bytes / gb).toStringAsFixed(2)} GB";
    } else if (bytes >= mb) {
      return "${(bytes / mb).toStringAsFixed(2)} MB";
    } else if (bytes >= kb) {
      return "${(bytes / kb).toStringAsFixed(2)} KB";
    } else {
      return "$bytes B";
    }
  }
}
