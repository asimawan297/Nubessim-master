import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nubesim/config/routes/nav_router.dart';
import 'package:nubesim/core/di/service_locator.dart';
import 'package:nubesim/core/storage_service/storage_service.dart';
import 'package:nubesim/modules/shop/cubits/currency_cubit/currency_cubit.dart';
import 'package:nubesim/modules/shop/cubits/order_esim_cubit/order_esim_cubit.dart';
import 'package:nubesim/modules/shop/model/order_esim_input.dart';
import 'package:nubesim/modules/shop/repository/shop_repository.dart';
import 'package:nubesim/modules/shop/pages/complete_order_screen.dart';
import 'package:nubesim/utils/display/display_utils.dart';
import 'package:nubesim/utils/html_templates.dart';
import 'package:uuid/uuid.dart';
import 'package:nubesim/common/email_cubit/email_cubit.dart';
import 'package:nubesim/common/model/send_email_input.dart';
import 'package:nubesim/constants/keys.dart';
import 'package:nubesim/core/model/order_history_model.dart';
import '../modules/shop/cubits/account_balance_cubit/account_balance_state.dart'; // sl<StorageService>()

/// Stripe PaymentSheet client secrets look like `pi_xxx_secret_yyy`.
String? paymentIntentIdFromClientSecret(String? clientSecret) {
  if (clientSecret == null || clientSecret.isEmpty) return null;
  const marker = '_secret_';
  final i = clientSecret.indexOf(marker);
  if (i <= 0) return null;
  return clientSecret.substring(0, i);
}

class OrderService {
  final BuildContext context;

  OrderService(this.context);

  Future<void> placeOrder({
    required dynamic package, // Replace with your PackageModel
    required String? name,
    String? orderType,
    required amountInDollar,
    required AccountBalanceState balanceState,
    required String? appliedPromoDocId,
    String? stripeClientSecret,
    String? stripeCustomerEmail,
    String? whatsappNumber,
  }) async {
    var uuid = Uuid();
    String txid = uuid.v4();
    // print("period num: ${package.duration}");
    final OrderSimInput input = OrderSimInput(
      transactionId: txid,
      packageInfoList: [
        PackageInfoList(
            packageCode: package.packageCode,
            count: 1,
            periodNum: package.duration),
      ],
    );
    // debugger();
    // API Call for ordering eSIM
    await context.read<OrderEsimCubit>().orderEsim(input);
    // return ;
    final orderProfile = context.read<OrderEsimCubit>().state.orderProfile;
    // debugger();
    if (orderProfile != null) {
      final StorageService storageService = sl<StorageService>();

      final canonicalTrx = orderProfile.transactionId.isNotEmpty
          ? orderProfile.transactionId
          : txid;
      final resolvedOrderNo =
          orderProfile.orderNo.isNotEmpty ? orderProfile.orderNo : canonicalTrx;
      final coverageList =
          package.locationNetworkList.map<dynamic>((e) => e.toJson()).toList();
      final storedEmail =
          (stripeCustomerEmail != null && stripeCustomerEmail.trim().isNotEmpty)
              ? stripeCustomerEmail.trim()
              : storageService.getString(StorageKeys.userEmail);

      OrderHistoryModel model = OrderHistoryModel(
        name: package.name,
        duration: "${package.duration} ${package.durationUnit}",
        logo:
            "https://static.redteago.com${package.locationNetworkList.first.locationLogo}",
        orderNumber: resolvedOrderNo,
        trxId: canonicalTrx,
        uid: storageService.getString(StorageKeys.userUid),
        coverage: coverageList,
        createdAt: DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
            .format(DateTime.now().toUtc()),
        stripeAmount: amountInDollar is num
            ? amountInDollar
            : num.tryParse(amountInDollar.toString()),
        stripeCurrency: 'usd',
        stripeCustomerEmail: storedEmail.isEmpty ? null : storedEmail,
        whatsappNumber: whatsappNumber?.trim().isEmpty ?? true
            ? null
            : whatsappNumber!.trim(),
        stripePaymentIntent:
            paymentIntentIdFromClientSecret(stripeClientSecret),
        stripeSessionId: null,
        web: false,
      );

      // Save order history
      await context.read<OrderEsimCubit>().storeOrderHistory(model);

      // Promo Code Update
      if (appliedPromoDocId != null) {
        final promoRef = FirebaseFirestore.instance
            .collection('promo_codes')
            .doc(appliedPromoDocId);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(promoRef);
          int currentLimit = snapshot.get('usageLimit');
          if (currentLimit > 0) {
            transaction.update(promoRef, {'usageLimit': currentLimit - 1});
          }
        });
      }

      // Query eSIM details once, then reuse same QR for email + complete-order UI
      String? qrCodeUrl;
      String? activationCode;
      var esimDetailsSection = '';
      try {
        final esim = await sl<ShopRepository>().queryEsimByOrderNo(
          resolvedOrderNo,
        );
        qrCodeUrl = esim?.qrCodeUrl;
        activationCode = esim?.ac;
        esimDetailsSection =
            buildOrderConfirmationEsimQrImageSection(qrCodeUrl);
      } catch (_) {
        // If query fails or QR not ready yet, continue without QR block.
      }

      // Navigate to Complete Order Screen
      NavRouter.pushFromRoot(
        context,
        CompleteOrderScreen(
          name: name ?? '',
          package: package,
          orderNumber: model.orderNumber ?? model.trxId ?? '',
          qrCodeUrl: qrCodeUrl,
          activationCode: activationCode,
        ),
      );

      // DisplayUtils.showSnackBar(context, "Payment and Order Successful!");

      // Send Confirmation Email (same QR row as Stripe test: esim/query → qrCodeUrl)
      final emailCubit = context.read<EmailCubit>();
      final userName = storageService.getString(StorageKeys.userName);
      final userEmail = storageService.getString(StorageKeys.userEmail);

      final htmlContent = await loadOrderConfirmationEmailTemplate(
        name: userName.isEmpty ? "Traveler" : userName,
        orderNumber: model.orderNumber ?? model.trxId ?? '',
        orderDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        paymentType: "Credit",
        totalCost: context.read<CurrencyCubit>().state.format(
              amountInDollar is num
                  ? amountInDollar
                  : num.tryParse('$amountInDollar') ?? 0,
            ),
        viewLink: "https://www.nubessim.com/auth",
        esimDetailsSection: esimDetailsSection,
      );
      // final htmlContentReadyEmail = await loadEsimReadyEmailTemplate(
      //   name: userName.isEmpty ? "Traveler" : userName,
      //   orderNumber: model.orderNumber!,
      //   instructionsLink: "https://www.nubessim.com/auth",
      // );
      final emailInput = SendEmailInput(
        senderName: "Nubes",
        senderEmail: "support@nubessim.com",
        receiverName: userName,
        receiverEmail: userEmail,
        subject: "Order Confirmation from Nubes",
        htmlContent: htmlContent,
      );

      // final emailInputInstance = SendEmailInput(
      //   senderName: "Nubes",
      //   senderEmail: "support@nubessim.com",
      //   receiverName: userName,
      //   receiverEmail: userEmail,
      //   subject: "Esim Ready from Nubes",
      //   htmlContent: htmlContentReadyEmail,
      // );
      await emailCubit.sendEmail(emailInput);
      // await emailCubit.sendEmail(emailInputInstance);
    } else {
      DisplayUtils.showToast(
          context, context.read<OrderEsimCubit>().state.message);
    }
  }

  Future<void> purchaseTopUpData(String packageCode, String iccid,
      {String? name, dynamic package, String? orderNumber}) async {
    // API Call for ordering eSIM Top-Up
    await context.read<OrderEsimCubit>().orderTopUpPlan(packageCode, iccid);

    NavRouter.pushFromRoot(
      context,
      CompleteOrderScreen(
          name: name ?? '', package: package, orderNumber: orderNumber ?? ""),
    );
  }
}
