import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/modules/my_esim/widgets/coverage_list.dart';
import 'package:nubesim/ui/primary_button.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:nubesim/utils/heights_and_widths.dart';
import 'package:nubesim/modules/my_esim/models/all_esim_model.dart';
import 'package:http/http.dart' as http;
import 'package:nubesim/utils/urls_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'quick_install_tab.dart';

class QRCodeTab extends StatefulWidget {
  final EsimList selectedEsim;

  const QRCodeTab({
    super.key,
    required this.selectedEsim,
  });

  @override
  State<QRCodeTab> createState() => _QRCodeTabState();
}

class _QRCodeTabState extends State<QRCodeTab> {
  bool hide = true;
  Future<void> _shareQrCode(String qrUrl) async {
    try {
      // Download the QR image
      final response = await http.get(Uri.parse(qrUrl));
      final bytes = response.bodyBytes;

      // Save to a temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qr_code.png');
      await file.writeAsBytes(bytes);

      // Share using share_plus
      await Share.shareXFiles([XFile(file.path)],
          text: 'Scan QR to Install ESIM : Nubes');
    } catch (e) {
      // print("Error sharing QR code: $e");
    }
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
          // Caution Banner
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

          // QR Code Section
          if (widget.selectedEsim.qrCodeUrl.isNotEmpty) ...[
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildQRCode(widget.selectedEsim),
                ),
              ),
            ),

            h2,

            Text(
              'Scan the QR code, take a screenshot, and save it in your photos to use during the installation process.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.greyColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),

            h2,
            Text(
              '⏱️ Installation typically takes about 2 minutes. Please ensure you have a stable internet connection during the process.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.greyColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            h2,

            // Send QR Code Button
            Center(
              child: SizedBox(
                width: 200,
                height: 45,
                child: OutlinedButton(
                  onPressed: () async {
                    if (widget.selectedEsim.qrCodeUrl.isNotEmpty) {
                      await _shareQrCode(widget.selectedEsim.qrCodeUrl);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.purpleColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Send QR Code',
                    style: TextStyle(
                      color: AppColors.purpleColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            h2,
          ] else ...[
            // No active eSIMs message
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code,
                      size: 80,
                      color: AppColors.greyColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Active eSIMs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No active eSIMs found to display QR code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            h2,
          ],

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
                      text:
                          'Go to Settings > Network & internet > SIM & mobile network',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '2',
                      text:
                          'Tap Download new SIM >Set up an eSIM >Scan QR code',
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
                          'Go to Settings > Network & internet > SIM & mobile network > Enable new install eSIM.',
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
                          'Go to Settings > Cellular or Mobile Data > Add eSIM',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '2',
                      text: 'Other Options > Ues QR Code',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '3',
                      text:
                          'Scan the “NubesSIM” QR code, or use a screenshot\n - Tap Open Photos\n - Select the QR code image from your camera roll\n - Tap Next, then tap Continue twice\n - Wait while the eSIM activates',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '4',
                      text:
                          'Once connected to the network (may take a minute), tap Done',
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
                          'Select Primary for your default line, then tap Continue',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '7',
                      text:
                          'Choose Primary again for i Message and Face Time, then tap Continue',
                    ),

                    h1,

                    _buildInstallationStep(
                      context,
                      number: '8',
                      text:
                          'Select your NubesSIM plan for mobile data, then tap Continue',
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
                          'Go to Settings > “Cellular/ Mobile Data” then select the recently downloaded eSIM on your device.',
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
            'Once you arrive at your destination, go to Settings >Cellular or Mobile Data, then select your newly added eSIM.Toggle it ON, and make sure your primary SIM is toggled OFF to avoid roaming charges.',
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
                    openYouTubeVideo("https://youtu.be/3e5yjDiaa8k");
                  } else {
                    openYouTubeVideo("https://youtu.be/dDe818DdDck");
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRCode(EsimList esim) {
    // Show QR image and a copyable link when available
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // QR Code Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            esim.qrCodeUrl,
            width: 230,
            height: 230,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => Icon(
              Icons.qr_code,
              size: 120,
              color: AppColors.purpleColor,
            ),
          ),
        ),
        // const SizedBox(height: 12),
        // Link Row
        // if (esim.shortUrl.isNotEmpty)
        //   Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Icon(Icons.link, color: AppColors.purpleColor, size: 18),
        //       const SizedBox(width: 6),
        //       Flexible(
        //         child: Text(
        //           esim.shortUrl,
        //           overflow: TextOverflow.ellipsis,
        //           style: const TextStyle(
        //             fontSize: 14,
        //             decoration: TextDecoration.underline,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // if (esim.esimTranNo.isNotEmpty) ...[
        //   const SizedBox(height: 8),
        //   Text(
        //     'ID: ${esim.esimTranNo}',
        //     style: TextStyle(
        //       fontSize: 12,
        //       color: AppColors.greyColor,
        //     ),
        //   ),
        // ],
      ],
    );
  }

  Widget _buildInstallationStep(
    BuildContext context, {
    required String number,
    required String text,
    List<String>? subSteps,
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
              if (subSteps != null) ...[
                const SizedBox(height: 8),
                ...subSteps.map((step) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: AppColors.greyColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.greyColor,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
