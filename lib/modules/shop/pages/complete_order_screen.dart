import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nubesim/config/config.dart';
import 'package:nubesim/constants/app_colors.dart';
import 'package:nubesim/core/di/service_locator.dart';
import 'package:nubesim/modules/base_view/page/base_view.dart';
import 'package:nubesim/modules/shop/model/all_data_packages_model.dart';
import 'package:nubesim/modules/shop/repository/shop_repository.dart';
import 'package:nubesim/utils/extensions/extended_context.dart';
import 'package:url_launcher/url_launcher.dart';

class CompleteOrderScreen extends StatefulWidget {
  final String name, orderNumber;
  final PackageList package;
  final String? qrCodeUrl;
  final String? activationCode;
  const CompleteOrderScreen(
      {super.key,
      required this.name,
      required this.package,
      required this.orderNumber,
      this.qrCodeUrl,
      this.activationCode});

  @override
  State<CompleteOrderScreen> createState() => _CompleteOrderScreenState();
}

class _CompleteOrderScreenState extends State<CompleteOrderScreen> {
  bool isLoading = false;
  String? _qrCodeUrl;
  String? _activationCode;
  bool _preparing = false;
  bool _refreshing = false;
  Timer? _pollTimer;
  late final DateTime _pollDeadline;

  bool get _hasQr => (_qrCodeUrl?.trim().isNotEmpty ?? false);
  bool get _hasActivationCode => (_activationCode?.trim().isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    _qrCodeUrl = widget.qrCodeUrl;
    _activationCode = widget.activationCode;
    _pollDeadline = DateTime.now().add(const Duration(seconds: 30));
    if (!_hasQr || !_hasActivationCode) {
      _preparing = widget.orderNumber.trim().isNotEmpty;
      if (_preparing) {
        _refreshInstallDetails();
        _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
          _refreshInstallDetails();
        });
      }
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshInstallDetails() async {
    if (_refreshing || !mounted) return;
    if (DateTime.now().isAfter(_pollDeadline)) {
      _stopPolling();
      return;
    }
    _refreshing = true;
    try {
      final esim =
          await sl<ShopRepository>().queryEsimByOrderNo(widget.orderNumber);
      if (!mounted) return;
      final qr = esim?.qrCodeUrl.trim() ?? '';
      final ac = esim?.ac.trim() ?? '';
      if (qr.isEmpty || ac.isEmpty) {
        if (!DateTime.now().isBefore(_pollDeadline)) _stopPolling();
        return;
      }
      setState(() {
        _qrCodeUrl = qr;
        _activationCode = ac;
        _preparing = false;
      });
      _pollTimer?.cancel();
      _pollTimer = null;
    } finally {
      _refreshing = false;
    }
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    if (mounted && _preparing) {
      setState(() => _preparing = false);
    }
  }

  Future<void> _openQuickInstall() async {
    final ac = _activationCode?.trim() ?? '';
    if (ac.isEmpty) return;

    final encodedAc = Uri.encodeComponent(ac);
    final installUrl = Platform.isIOS
        ? 'https://esimsetup.apple.com/esim_qrcode_provisioning?carddata=$encodedAc'
        : 'https://esimsetup.android.com/esim_qrcode_provisioning?carddata=$encodedAc';
    final uri = Uri.tryParse(installUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildFeatureRow({
    required String assetPath,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            assetPath,
            width: 34,
            height: 34,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28 / 2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.greyColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationName = widget.package.locationNetworkList.isNotEmpty
        ? widget.package.locationNetworkList.first.locationName
        : widget.package.location;
    final hasQr = _hasQr;
    final hasActivationCode = _hasActivationCode;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              NavRouter.pushTORoot(context, BaseScreen(), bottomToTop: true);
            }),
        title: Text("Order Completed",
            style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF34A853),
                fontSize: 19.0,
                fontFamily: "Inter")),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Thanks for shopping with us!",
                style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                    fontSize: 19.0,
                    fontFamily: "Inter"),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: "Inter",
                    fontSize: 14,
                    height: 1.5,
                    letterSpacing: 0,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    const TextSpan(
                        text:
                            "You should receive a confirmation email shortly at ",
                        style: TextStyle(
                            fontSize: 14, color: AppColors.greyColor)),
                    TextSpan(
                      text: FirebaseAuth.instance.currentUser?.email,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textColor),
                    ),
                    const TextSpan(
                        text: " Order number ",
                        style: TextStyle(color: AppColors.greyColor)),
                    TextSpan(
                      text: "# ${widget.orderNumber}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              const Text(
                "Install now or later — your choice",
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 24 / 2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Your eSIM is safely saved in My eSIM, so you can access it anytime.",
                style: TextStyle(
                  color: AppColors.greyColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                locationName,
                style: const TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 28 / 2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  children: [
                    const Text(
                      "Install Your eSIM",
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (hasQr)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _qrCodeUrl!,
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 140,
                              height: 140,
                              color: Colors.white,
                              alignment: Alignment.center,
                              child: const Text(
                                "QR unavailable",
                                style: TextStyle(
                                  color: AppColors.greyColor,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        width: 140,
                        height: 140,
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: Text(
                          _preparing ? "Preparing your eSIM…" : "QR unavailable",
                          style: TextStyle(
                            color: AppColors.greyColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: hasActivationCode ? _openQuickInstall : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8E2DE2),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                      ),
                      child: const Text(
                        "Quick Install",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildFeatureRow(
                assetPath: 'assets/images/Group.png',
                title: "Instant eSIM activation",
                subtitle:
                    "Get connected in minutes with our instant activation process.",
              ),
              _buildFeatureRow(
                assetPath: 'assets/images/Group10.png',
                title: "Affordable data plans",
                subtitle:
                    "Choose from a variety of cost-effective plans tailored to your needs.",
              ),
              _buildFeatureRow(
                assetPath: 'assets/images/Group14.png',
                title: "24/7 customer support",
                subtitle:
                    "Our support team is always ready to help you anytime, anywhere.",
              ),
              _buildFeatureRow(
                assetPath: 'assets/images/Group15.png',
                title: "Works on iOS & Android",
                subtitle: "Compatible with all modern smartphones and tablets.",
              ),
              const SizedBox(height: 6),
              const Text(
                "Prefer to install later?",
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Your eSIM is securely stored in My eSIM.\nYou can install it anytime or share your QR code when needed.",
                style: TextStyle(
                  color: AppColors.greyColor,
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
