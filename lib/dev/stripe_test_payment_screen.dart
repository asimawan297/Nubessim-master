// ISOLATED STRIPE + FIRESTORE TEST SCREEN — does not alter shop/checkout flows.
//
// Open from anywhere after app start (e.g. temporary button in debug):
//   NavRouter.navigationKey.currentState?.pushNamed('/stripe-test-payment');
//
// Requirements:
// 1) main.dart: Stripe.publishableKey must be your pk_test_... (already set for test).
// 2) Run with secret (never commit the secret):
//    flutter run --dart-define=STRIPE_SECRET_KEY=sk_test_YOUR_SECRET
//
// Writes to Firestore collection `order_data` (same as production order history),
// using OrderHistoryModel + FireStoreService.storeOrderHistory.
//
// After Stripe: calls POST /api/v1/open/esim/order (same payload shape as production),
// then uses returned `orderNo` for Firestore, esim/query (QR image URL), and email.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:nubesim/common/email_cubit/email_cubit.dart';
import 'package:nubesim/common/model/send_email_input.dart';
import 'package:intl/intl.dart';
import 'package:nubesim/config/routes/nav_router.dart';
import 'package:nubesim/constants/keys.dart';
import 'package:nubesim/core/auth_service/firestore_service.dart';
import 'package:nubesim/core/di/service_locator.dart';
import 'package:nubesim/core/model/countries_data_model.dart';
import 'package:nubesim/core/model/order_history_model.dart';
import 'package:nubesim/core/storage_service/storage_service.dart';
import 'package:nubesim/core/exceptions/api_error.dart';
import 'package:nubesim/modules/shop/model/all_data_packages_model.dart';
import 'package:nubesim/modules/shop/model/order_esim_input.dart';
import 'package:nubesim/modules/shop/model/order_profile_response.dart';
import 'package:nubesim/modules/shop/pages/complete_order_screen.dart';
import 'package:nubesim/modules/shop/repository/shop_repository.dart';
import 'package:nubesim/utils/html_templates.dart';
import 'package:uuid/uuid.dart';

String? _paymentIntentIdFromClientSecret(String? clientSecret) {
  if (clientSecret == null || clientSecret.isEmpty) return null;
  const marker = '_secret_';
  final i = clientSecret.indexOf(marker);
  if (i <= 0) return null;
  return clientSecret.substring(0, i);
}

/// Creates a PaymentIntent using Stripe REST (secret key via dart-define only).
Future<String?> _createTestPaymentIntentClientSecret(
  int amountCents, {
  required String whatsappNumber,
}) async {
  const sk =
      "";
  if (sk.isEmpty) return null;

  final auth = base64Encode(utf8.encode('$sk:'));
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 25),
    ),
  );

  final encodedWhatsapp = Uri.encodeQueryComponent(whatsappNumber.trim());
  final body =
      'amount=$amountCents&currency=usd&automatic_payment_methods[enabled]=true&metadata[whatsapp_number]=$encodedWhatsapp';

  final response = await dio.post<Map<String, dynamic>>(
    'https://api.stripe.com/v1/payment_intents',
    data: body,
    options: Options(
      contentType: Headers.formUrlEncodedContentType,
      headers: {'Authorization': 'Basic $auth'},
    ),
  );

  final data = response.data;
  if (data == null) return null;
  return data['client_secret'] as String?;
}

class StripeTestPaymentScreen extends StatefulWidget {
  const StripeTestPaymentScreen({super.key});

  @override
  State<StripeTestPaymentScreen> createState() =>
      _StripeTestPaymentScreenState();
}

class _StripeTestPaymentScreenState extends State<StripeTestPaymentScreen> {
  final FireStoreService _fireStoreService = FireStoreService();
  final TextEditingController _whatsappController = TextEditingController();

  List<CountriesData> _countries = [];
  bool _loadingCountries = true;
  String? _countryError;

  CountriesData? _selectedCountry;
  List<PackageList> _packages = [];
  bool _loadingPackages = false;
  String? _packagesError;

  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  @override
  void dispose() {
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    setState(() {
      _loadingCountries = true;
      _countryError = null;
    });
    try {
      final list = await _fireStoreService.fetchCountries();
      list.sort((a, b) => a.name.common.compareTo(b.name.common));
      setState(() {
        _countries = list;
        _loadingCountries = false;
      });
    } catch (e) {
      setState(() {
        _countryError = '$e';
        _loadingCountries = false;
      });
    }
  }

  Future<void> _loadPackagesForCountry(CountriesData country) async {
    setState(() {
      _selectedCountry = country;
      _loadingPackages = true;
      _packagesError = null;
      _packages = [];
    });
    try {
      final repo = sl<ShopRepository>();
      final response =
          await repo.getAllDataPackages(selectedSimType: country.cca2);
      setState(() {
        _packages = response.obj.packageList;
        _loadingPackages = false;
      });
    } catch (e) {
      setState(() {
        _packagesError = '$e';
        _loadingPackages = false;
      });
    }
  }

  int _amountCentsForPackage(PackageList pkg) {
    final cents = pkg.retailPrice;
    if (cents < 50) return 50;
    return cents;
  }

  Future<void> _buy(PackageList pkg) async {
    const sk =
        "";
    if (sk.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Missing STRIPE_SECRET_KEY. Run: flutter run '
            '--dart-define=STRIPE_SECRET_KEY=sk_test_...',
          ),
          duration: Duration(seconds: 8),
        ),
      );
      return;
    }

    final whatsappNumber = _whatsappController.text.trim();
    if (whatsappNumber.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WhatsApp number is required for test payment.'),
        ),
      );
      return;
    }

    setState(() => _paying = true);
    try {
      final amountCents = _amountCentsForPackage(pkg);
      final clientSecret = await _createTestPaymentIntentClientSecret(
        amountCents,
        whatsappNumber: whatsappNumber,
      );
      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('Could not create PaymentIntent (check secret key)');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Nubes (test)',
          returnURL: 'nubesim://payment-success',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      if (!mounted) return;
      final emailCubit = context.read<EmailCubit>();

      final txid = const Uuid().v4();
      // Same body as production [order_utils]: no amount/price — the API resolves
      // current price from packageCode. Sending client retailPrice triggers 200005
      // ("package`s price is expired") when it does not match their catalog.
      final orderInput = OrderSimInput(
        transactionId: txid,
        packageInfoList: [
          PackageInfoList(
            packageCode: pkg.packageCode,
            count: 1,
            periodNum: pkg.duration,
          ),
        ],
      );

      final OrderProfileResponse orderResponse;
      try {
        orderResponse = await sl<ShopRepository>().orderEsim(input: orderInput);
      } on ApiError catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment succeeded but eSIM order failed: ${e.message}',
            ),
            duration: const Duration(seconds: 10),
          ),
        );
        return;
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment succeeded but eSIM order failed: $e'),
            duration: const Duration(seconds: 10),
          ),
        );
        return;
      }

      final profile = orderResponse.obj;
      final canonicalTrx =
          profile.transactionId.isNotEmpty ? profile.transactionId : txid;
      final orderNo =
          profile.orderNo.isNotEmpty ? profile.orderNo : canonicalTrx;

      final storage = sl<StorageService>();
      var uid = storage.getString(StorageKeys.userUid);
      if (uid.isEmpty) {
        uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      }
      if (uid.isEmpty) {
        uid = 'stripe_test_no_uid';
      }

      final email = storage.getString(StorageKeys.userEmail);
      final coverageList =
          pkg.locationNetworkList.map((e) => e.toJson()).toList();
      final logoPath = pkg.locationNetworkList.isNotEmpty
          ? pkg.locationNetworkList.first.locationLogo
          : '';

      final model = OrderHistoryModel(
        name: pkg.name,
        duration: '${pkg.duration} ${pkg.durationUnit}',
        logo: logoPath.startsWith('http')
            ? logoPath
            : 'https://static.redteago.com$logoPath',
        orderNumber: orderNo,
        trxId: canonicalTrx,
        uid: uid,
        coverage: coverageList,
        createdAt: DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
            .format(DateTime.now().toUtc()),
        stripeAmount: amountCents / 100.0,
        stripeCurrency: 'usd',
        stripeCustomerEmail: email.isEmpty ? null : email,
        whatsappNumber: whatsappNumber,
        stripePaymentIntent: _paymentIntentIdFromClientSecret(clientSecret),
        stripeSessionId: null,
        web: false,
      );

      await _fireStoreService.storeOrderHistory(model);

      final amountInDollar = amountCents / 100.0;
      final userName = storage.getString(StorageKeys.userName);
      var userEmail = storage.getString(StorageKeys.userEmail);
      String? qrCodeUrl;
      String? activationCode;
      if (userEmail.isEmpty) {
        userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      }

      if (userEmail.isNotEmpty) {
        try {
          final esim = await sl<ShopRepository>().queryEsimByOrderNo(orderNo);
          qrCodeUrl = esim?.qrCodeUrl;
          activationCode = esim?.ac;
          final esimSection = buildOrderConfirmationEsimQrImageSection(
            qrCodeUrl,
          );

          final htmlContent = await loadOrderConfirmationEmailTemplate(
            name: userName.isEmpty ? 'Traveler' : userName,
            orderNumber: orderNo,
            orderDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            paymentType: 'Credit',
            totalCost: '\$ ${amountInDollar.toStringAsFixed(2)}',
            viewLink: 'https://www.nubessim.com/auth',
            esimDetailsSection: esimSection,
          );
          final emailInput = SendEmailInput(
            senderName: 'Nubes',
            senderEmail: 'support@nubessim.com',
            receiverName: userName.isEmpty ? 'Traveler' : userName,
            receiverEmail: userEmail,
            subject: 'Order Confirmation from Nubes',
            htmlContent: htmlContent,
          );
          await emailCubit.sendEmail(emailInput);
        } catch (_) {}
      }

      if (!mounted) return;
      NavRouter.pushFromRoot(
        context,
        CompleteOrderScreen(
          name: pkg.name,
          package: pkg,
          orderNumber: orderNo,
          qrCodeUrl: qrCodeUrl,
          activationCode: activationCode,
        ),
      );
    } on StripeException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stripe: ${e.error.localizedMessage ?? e}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe test (isolated)'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => NavRouter.pop(context),
        ),
      ),
      body: _loadingCountries
          ? const Center(child: CircularProgressIndicator())
          : _countryError != null
              ? Center(child: Text(_countryError!))
              : Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ListView.builder(
                        itemCount: _countries.length,
                        itemBuilder: (context, i) {
                          final c = _countries[i];
                          final sel = _selectedCountry?.cca2 == c.cca2;
                          return ListTile(
                            dense: true,
                            selected: sel,
                            title: Text(c.name.common),
                            subtitle: Text(c.cca2),
                            onTap: () => _loadPackagesForCountry(c),
                          );
                        },
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      flex: 3,
                      child: _selectedCountry == null
                          ? const Center(child: Text('Select a country'))
                          : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      12.0, 12.0, 12.0, 8.0),
                                  child: TextField(
                                    controller: _whatsappController,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      labelText: 'WhatsApp Number',
                                      hintText: 'e.g. +355672432897',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _loadingPackages
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : _packagesError != null
                                          ? Center(
                                              child: Text(_packagesError!))
                                          : ListView.builder(
                                              itemCount: _packages.length,
                                              itemBuilder: (context, i) {
                                                final p = _packages[i];
                                                final cents =
                                                    _amountCentsForPackage(p);
                                                return ListTile(
                                                  title: Text(
                                                    p.name,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  subtitle: Text(
                                                    '${p.packageCode} · \$${(cents / 100).toStringAsFixed(2)} (test charge)',
                                                  ),
                                                  trailing: _paying
                                                      ? const SizedBox(
                                                          width: 24,
                                                          height: 24,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                        )
                                                      : TextButton(
                                                          onPressed: _paying
                                                              ? null
                                                              : () => _buy(p),
                                                          child: const Text(
                                                              'Buy'),
                                                        ),
                                                );
                                              },
                                            ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
    );
  }
}
