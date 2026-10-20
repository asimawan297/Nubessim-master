import 'dart:io';
import 'package:esim_installer_flutter/esim_installer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/modules/my_esim/models/all_esim_model.dart';
import 'package:nubesim/ui/primary_button.dart';
import 'package:nubesim/utils/display/display_utils.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:nubesim/utils/heights_and_widths.dart';
import 'package:nubesim/utils/sim_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'coverage_list.dart';

class QuickInstallTab extends StatefulWidget {
  final EsimList selectedEsim;
  const QuickInstallTab({super.key, required this.selectedEsim});

  @override
  State<QuickInstallTab> createState() => _QuickInstallTabState();
}

class _QuickInstallTabState extends State<QuickInstallTab> {
  bool hide = true;
  String platformVersion = 'Unknown';
  bool isEsimSupported = false;
  String installationResult = '';
  String instructions = '';

  Future<void> _initPlatformState() async {
    String platformVersion;
    bool isEsimSupported;
    String instructions;

    try {
      platformVersion = await EsimInstallerFlutter().getPlatformVersion() ??
          'Unknown platform version';
      isEsimSupported = await EsimInstallerFlutter().isSupportESim() ?? false;
      instructions = await EsimInstallerFlutter().instructions() ??
          'No instructions available';
    } catch (e) {
      platformVersion = 'Failed to get platform version.';
      isEsimSupported = false;
      instructions = 'Failed to get instructions.';
    }

    if (!mounted) return;

    setState(() {
      platformVersion = platformVersion;
      isEsimSupported = isEsimSupported;
      instructions = instructions;
    });
  }

  Future<void> _installEsimProfile() async {
    String result = '';

    try {
      if (Platform.isAndroid) {
        result = await EsimInstallerFlutter().installESimProfile(
          smdpAddress: parseLpaString(widget.selectedEsim.ac)["smDpAddress"]!,
          activationToken:
              parseLpaString(widget.selectedEsim.ac)["activationCode"]!,
        );
      } else {
        EsimInstallerIOS.installESim(widget.selectedEsim.ac);
      }
    } on PlatformException catch (e) {
      result = 'Failed to install eSIM profile.';

      // 🔑 Specific handling for LPA / eSIM issues
      if (e.code == 'ESIM_NOT_SUPPORTED' ||
          e.code == 'LPA_NOT_FOUND' ||
          e.message?.contains('No Activity found to handle Intent') == true) {
        DisplayUtils.showToast(
          context,
          'Your device supports eSIM installation using a QR Code or Manual setup.',
        );
      } else {
        DisplayUtils.showToast(context, e.message ?? e.toString());
      }
    } catch (e) {
      result = 'Failed to install eSIM profile.';
      DisplayUtils.showToast(context, e.toString());
    }

    setState(() {
      // _installationResult = result;
    });
  }

  openESimInstallationLink(String lpaString) async {
    // print(lpaString);
    final uri = Uri.parse('https://$lpaString');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return "true";
    } else {
      throw 'Could not launch eSIM link';
    }
  }

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          hide && widget.selectedEsim.installationTime == null
              ? SizedBox()
              : Card(
                  color: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
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
                      ],
                    ),
                  ),
                ),
          h1,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
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
                  padding: const EdgeInsets.all(8.0),
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
          Platform.isAndroid
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      text: 'Tap “Install eSIM”, and wait for while.',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '2',
                      text:
                          'Please do not close the app, this may take a few minutes. ',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '3',
                      text: 'Tap “Allow”',
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
                      text: 'Select the New APN ',
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
                          'Tap “Install eSIM”, then tap “Continue” twice and wait.',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '2',
                      text:
                          'Your eSIM will connect to the network — this may take a few minutes. When done, tap “Done”.',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '3',
                      text:
                          'Choose "NubesSIM" as the label for your new eSIM plan.',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '4',
                      text:
                          'Select “Primary” for your default line, then tap “Continue”.',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '5',
                      text:
                          'Choose which Primary line to use for iMessage and FaceTime, then tap “Continue”.',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '6',
                      text:
                          'Select your NubesSIM plan for cellular/mobile data, then tap “Continue”.',
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
                title: "Install eSIM",
                shadowColor: AppColors.transparent,
                borderRadius: 10,
                borderColor: AppColors.primaryColor,
                backgroundColor: AppColors.primaryColor,
                titleColor: AppColors.white,
                onPressed: () {
                  if (hide && widget.selectedEsim.installationTime == null) {
                    _installEsimProfile();
                  } else {
                    DisplayUtils.showSnackBar(
                        type: "sj",
                        bgColor: Colors.red,
                        context,
                        "Your eSIM has already been installed");
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
          child: Text(
            text,
            style: context.textTheme.bodyMedium!.copyWith(
              color: AppColors.greyColor,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsItem extends StatelessWidget {
  final String title;
  final dynamic value;
  final String? additional;
  final bool isWidget;

  const SettingsItem(
      {required this.title,
      required this.value,
      super.key,
      this.additional,
      this.isWidget = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          if (isWidget) value,
          if (!isWidget)
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 2,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (title == "APN")
                  InkWell(
                      onTap: () async {
                        await Clipboard.setData(
                          ClipboardData(text: value),
                        );

                        DisplayUtils.showToast(
                          context,
                          "APN copied to clipboard",
                        );
                      },
                      child: Icon(Icons.copy, size: 18)),
              ],
            ),
          if (additional != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "Important Note:",
                    maxLines: 2,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Text(
                    additional!,
                    maxLines: 2,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                        color: AppColors.textGrey, fontSize: 14),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class EsimInstallerIOS {
  static const _channel = MethodChannel('samples.flutter.dev/esim');

  static Future<void> installESim(String activationCode) async {
    try {
      final result =
          await _channel.invokeMethod('launchESimSetup', activationCode);
      // debugPrint('✅ eSIM launched: $result');
    } on PlatformException catch (e) {
      // debugPrint('❌ Error launching eSIM: ${e.message}');
    }
  }
}
