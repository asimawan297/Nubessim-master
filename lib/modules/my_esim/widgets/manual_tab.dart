import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/modules/my_esim/models/all_esim_model.dart';
import 'package:nubesim/modules/my_esim/widgets/coverage_list.dart';
import 'package:nubesim/modules/my_esim/widgets/quick_install_tab.dart';
import 'package:nubesim/ui/primary_button.dart';
import 'package:nubesim/utils/display/display_utils.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:nubesim/utils/heights_and_widths.dart';
import 'package:nubesim/utils/sim_utils.dart';
import 'package:nubesim/utils/urls_utils.dart';

class ManualTab extends StatefulWidget {
  final EsimList selectedEsim;

  const ManualTab({super.key, required this.selectedEsim});

  @override
  State<ManualTab> createState() => _ManualTabState();
}

class _ManualTabState extends State<ManualTab> {
  bool hide = true;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Caution Banner
          hide && widget.selectedEsim.installationTime == null
              ? SizedBox()
              : Card(
                  color: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // Check Circle Icon
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 45,
                        ),
                        const SizedBox(width: 10),

                        // Message Text
                        const Expanded(
                          child: Text(
                            "Your eSIM successfully installed",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          h1,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
              gradient: LinearGradient(
                colors: [
                  const Color(0xffFF668B).withOpacity(.7),
                  const Color(0xffCA2045),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Caution: Your eSIM is non-transferable and can only be installed once. Once installed, it cannot be moved to another device. Deleting it will render it unusable.',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  "assets/images/warning.png", // put your asset image here
                  height: 50,
                  width: 50,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),

          h2,

          // LINK CODE Section
          // Container(
          //   width: double.infinity,
          //   padding: const EdgeInsets.all(16.0),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(color: Colors.grey.shade300),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         selectedEsim.shortUrl,
          //         textAlign: TextAlign.center,
          //         style: TextStyle(
          //           fontSize: 16,
          //           fontWeight: FontWeight.bold,
          //           color: Colors.black,
          //         ),
          //       ),
          //       const SizedBox(height: 12),
          //       Divider(
          //         color: Colors.grey.shade300,
          //         height: 1,
          //       ),
          //       const SizedBox(height: 12),
          //       Text(
          //         'Use the information provided to complete the QR Code installation and follow the guidelines below.',
          //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
          //               fontWeight: FontWeight.w700,
          //               color: AppColors.greyColor,
          //               fontSize: 12,
          //             ),
          //       ),
          //     ],
          //   ),
          // ),
          Platform.isAndroid
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,

                        borderRadius: BorderRadius.circular(12),
                        // border: Border.all(color: Colors.red.shade200),
                        // gradient: LinearGradient(
                        //   colors: [
                        //     const Color(0xffFF668B).withOpacity(.7),
                        //     const Color(0xffCA2045),
                        //   ],
                        //   begin: Alignment.centerLeft,
                        //   end: Alignment.centerRight,
                        // ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SM-DP+ ADDRESS
                            Text(
                              "SM-DP+ ADDRESS and Activation Code",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Expanded(
                            //       child: Text(
                            //         parseLpaString(widget.selectedEsim.ac)["smDpAddress"]!,
                            //         style: TextStyle(
                            //           color: Colors.white,
                            //           fontSize: 14,
                            //         ),
                            //       ),
                            //     ),
                            //     InkWell(
                            //         onTap: () async {
                            //           await Clipboard.setData(
                            //             ClipboardData(text: parseLpaString(widget.selectedEsim.ac)["smDpAddress"]!),
                            //           );

                            //           DisplayUtils.showSnackBar(
                            //               context, "SM-DP Address copied to clipboard",
                            //               type: "success");
                            //         },
                            //         child:
                            //             Icon(Icons.copy, color: Colors.white, size: 18)),
                            //   ],
                            // ),

                            // const SizedBox(height: 10),
                            // Text(
                            //   "Activation Code",
                            //   style: TextStyle(
                            //     color: Colors.black,
                            //     fontSize: 12,
                            //     fontWeight: FontWeight.w500,
                            //   ),
                            // ),
                            // const SizedBox(height: 4),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Expanded(
                            //       child: Text(
                            //         parseLpaString(widget.selectedEsim.ac)["activationCode"]!,
                            //         style: TextStyle(
                            //           color: Colors.white,
                            //           fontSize: 14,
                            //         ),
                            //       ),
                            //     ),
                            //     InkWell(
                            //         onTap: () async {
                            //           await Clipboard.setData(
                            //             ClipboardData(text: parseLpaString(widget.selectedEsim.ac)["activationCode"]!),
                            //           );

                            //           DisplayUtils.showSnackBar(
                            //               context, "Activation code copied to clipboard",
                            //               type: "success");
                            //         },
                            //         child:
                            //             Icon(Icons.copy, color: Colors.white, size: 18)),
                            //   ],
                            // ),

                            // const SizedBox(height: 10),
                            // Text(
                            //   "LPA Format",
                            //   style: TextStyle(
                            //     color: Colors.black,
                            //     fontSize: 12,
                            //     fontWeight: FontWeight.w500,
                            //   ),
                            // ),
                            // const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.selectedEsim.ac,
                                    style: TextStyle(
                                      // color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                InkWell(
                                    onTap: () async {
                                      await Clipboard.setData(
                                        ClipboardData(
                                            text: widget.selectedEsim.ac),
                                      );

                                      DisplayUtils.showToast(context,
                                          "LPA Activation Code copied to clipboard");
                                    },
                                    child: Icon(Icons.copy, size: 18)),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Description
                            Text(
                              "Copy this information and enter details manually to install your eSIM.\n\n⏱️ Installation typically takes about 2 minutes. Please ensure you have a stable internet connection during the process.",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    h2,

                    // Install eSIM Section
                    Text(
                      'Step 1 - eSIM Installation',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.greyColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                    ),

                    h1,

                    // Installation Steps
                    _buildInstallationStep(
                      context,
                      number: '1',
                      text:
                          'Go to Settings > Network & internet > SIM & mobile network ',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '2',
                      text:
                          'Tap Download new SIM >Set up an eSIM > Enter Activation Code (SM-DP+ address and activation)',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '3',
                      text: 'Tap Confirm to complete the installation',
                    ),

                    h1,

                    Text(
                      'Step 2 - Data Access',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.greyColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                    ),

                    h1,

                    Card(
                      color: AppColors.bgGrey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SettingsItem(
                            title: "Network Carrier",
                            value: widget.selectedEsim.coverage == null
                                ? ""
                                : CoverageList(
                                    networkList: widget.selectedEsim.coverage),
                            isWidget: true,
                          ),
                          Divider(height: 1),
                          SettingsItem(
                            title: "APN",
                            value: widget.selectedEsim.apn,
                            additional: Platform.isAndroid
                                ? "Turn on data roaming and update APN settings if needed."
                                : "For most carriers, the APN settings are configured automatically.",
                          ),
                          //  Divider(height: 1),
                          //  SettingsItem(title: "Data Roaming", value: ""),
                        ],
                      ),
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '1',
                      text:
                          'Go to Settings > Network & internet > SIM & mobile network > Enable new install eSIM ',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '2',
                      text: 'Select mobile data > on',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '3',
                      text: 'Select Roaming > on ',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '4',
                      text:
                          'Go to Access Point Name > Select Add  >\n- Enter the name (Any easy to identify name)\n- Enter the APN (See “APN”)\n- SAVE',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '5',
                      text: 'Select the New APN',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '6',
                      text: 'Toggle off Automatically select network  ',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '7',
                      text: 'Select the eSIM network (See “Network Carrier”)',
                    ),

                    h1,
                    h1,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                        // border: Border.all(color: Colors.red.shade200),
                        // gradient: LinearGradient(
                        //   colors: [
                        //     const Color(0xffFF668B).withOpacity(.7),
                        //     const Color(0xffCA2045),
                        //   ],
                        //   begin: Alignment.centerLeft,
                        //   end: Alignment.centerRight,
                        // ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SM-DP+ ADDRESS
                            Text(
                              "SM-DP+ ADDRESS",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    parseLpaString(
                                        widget.selectedEsim.ac)["smDpAddress"]!,
                                    style: TextStyle(
                                      // color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                InkWell(
                                    onTap: () async {
                                      await Clipboard.setData(
                                        ClipboardData(
                                            text: parseLpaString(widget
                                                .selectedEsim
                                                .ac)["smDpAddress"]!),
                                      );

                                      DisplayUtils.showToast(
                                        context,
                                        "SM-DP Address copied to clipboard",
                                      );
                                    },
                                    child: Icon(Icons.copy, size: 18)),
                              ],
                            ),

                            const SizedBox(height: 10),
                            Text(
                              "Activation Code",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    parseLpaString(widget.selectedEsim.ac)[
                                        "activationCode"]!,
                                    style: TextStyle(
                                      // color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                InkWell(
                                    onTap: () async {
                                      await Clipboard.setData(
                                        ClipboardData(
                                            text: parseLpaString(widget
                                                .selectedEsim
                                                .ac)["activationCode"]!),
                                      );

                                      DisplayUtils.showToast(
                                        context,
                                        "Activation code copied to clipboard",
                                      );
                                    },
                                    child: Icon(Icons.copy, size: 18)),
                              ],
                            ),

                            // const SizedBox(height: 10),
                            // Text(
                            //   "LPA Format",
                            //   style: TextStyle(
                            //     color: Colors.black,
                            //     fontSize: 12,
                            //     fontWeight: FontWeight.w500,
                            //   ),
                            // ),
                            // const SizedBox(height: 4),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Expanded(
                            //       child: Text(
                            //         widget.selectedEsim.ac,
                            //         style: TextStyle(
                            //           // color: Colors.white,
                            //           fontSize: 14,
                            //         ),
                            //       ),
                            //     ),
                            //     InkWell(
                            //         onTap: () async {
                            //           await Clipboard.setData(
                            //             ClipboardData(
                            //                 text: widget.selectedEsim.ac),
                            //           );

                            //           DisplayUtils.showSnackBar(context,
                            //               "LPA Activation Code copied to clipboard",
                            //               type: "success");
                            //         },
                            //         child: Icon(Icons.copy,
                            //    size: 18)),
                            //   ],
                            // ),

                            const SizedBox(height: 16),

                            // Description
                            Text(
                              "Copy this information and enter details manually to install your eSIM. "
                              "*Make sure your device has a stable internet connection before installing.",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    h2,

                    // Install eSIM Section
                    Text(
                      'Step 1 - eSIM Installation',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.greyColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                    ),

                    h1,

                    // Installation Steps
                    _buildInstallationStep(
                      context,
                      number: '1',
                      text:
                          'Go to: . Settings > Cellular or Mobile Data > Add eSIM',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '2',
                      text:
                          'Other Options > Ues QR Code > Enter Details Manually',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '3',
                      text:
                          'Enter SM-DP+ Address and Activation Code, Tap Next, then tap Continue twice and wait for setup.',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '4',
                      text:
                          'Your eSIM will connect to the network (may take a few minutes). Tap Done',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '5',
                      text:
                          'Choose "NubesSIM" as the label for your new eSIM plan',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '6',
                      text:
                          'Choose "Primary" for your default line. Tap Continue',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '7',
                      text:
                          'Choose "Primary" again for i Message & Face Time for Apple ID. Tap Continue',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '8',
                      text:
                          'Choose your NubesSIM plan for mobile data. Tap Continue ',
                    ),

                    h1,

                    Text(
                      'Step 2 - Data Access',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.greyColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                    ),

                    h1,

                    Card(
                      color: AppColors.bgGrey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SettingsItem(
                            title: "Network Carrier",
                            value: widget.selectedEsim.coverage == null
                                ? ""
                                : CoverageList(
                                    networkList: widget.selectedEsim.coverage),
                            isWidget: true,
                          ),
                          Divider(height: 1),
                          SettingsItem(
                            title: "APN",
                            value: widget.selectedEsim.apn,
                            additional:
                                "Important Note:  For most carriers, the APN settings are configured automatically.",
                          ),
                          //  Divider(height: 1),
                          //  SettingsItem(title: "Data Roaming", value: ""),
                        ],
                      ),
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '1',
                      text:
                          'Go to Settings > “Cellular/ Mobile Data” then select the recently downloaded eSIM on your device. ',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '2',
                      text:
                          'Enable the “Turn on this line” toggle, then select your new eSIM plan for cellular / mobile data.',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '3',
                      text:
                          'Tap “Network selection” , Disable the “Automatic” toggle, then select the supported network manually if your eSIM has connected to the wrong network. ',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '4',
                      text:
                          'Enable the “Data Roaming” toggle for your new eSIM plan.',
                    ),

                    h1,
                    h1,
                  ],
                ),

          Text(
            'Important Note:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.greyColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
          ),

          h1,

          Text(
            'Once you arrive at your destination, go to Settings >Cellular or Mobile Data, then select your newly added eSIM. Toggle it ON, and make sure your primary SIM is toggled OFF to avoid roaming charges.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  color: AppColors.greyColor,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
          ),

          h2,

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PrimaryButton(
                fontSize: 12,
                width: size.width * 0.80,
                hMargin: 0,
                height: 50,
                title: "Setup Instructions",
                shadowColor: AppColors.transparent,
                borderRadius: 10,
                borderColor: AppColors.primaryColor,
                backgroundColor: AppColors.primaryColor,
                titleColor: AppColors.white,
                onPressed: () {
                  if (Platform.isAndroid) {
                    openYouTubeVideo("https://youtu.be/vlP85BHzbu0");
                  } else {
                    openYouTubeVideo("https://youtu.be/pySf_KpuYZI");
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstallationStep(
    BuildContext context, {
    required String number,
    required String text,
    String? subText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            number,
            style: context.textTheme.bodyMedium!.copyWith(
              color: AppColors.greyColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: context.textTheme.bodyMedium!.copyWith(
                  color: AppColors.greyColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subText != null) ...[
                const SizedBox(height: 4),
                Text(
                  subText,
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: AppColors.greyColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
