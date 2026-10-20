// To parse this JSON data, do
//
//     final orderHistoryModel = orderHistoryModelFromJson(jsonString);

import 'dart:convert';

OrderHistoryModel orderHistoryModelFromJson(String str) =>
    OrderHistoryModel.fromJson(json.decode(str));

String orderHistoryModelToJson(OrderHistoryModel data) =>
    json.encode(data.toJson());

class OrderHistoryModel {
  String? name;
  String? duration;
  String? logo;
  String? orderNumber;
  String? trxId;
  String? uid;
  /// Firestore-native list (website shape) or legacy JSON string from older app writes.
  dynamic coverage;
  String? createdAt;
  num? stripeAmount;
  String? stripeCurrency;
  String? stripeCustomerEmail;
  String? whatsappNumber;
  String? stripePaymentIntent;
  String? stripeSessionId;
  bool? web;

  OrderHistoryModel({
    required this.name,
    required this.duration,
    required this.logo,
    required this.orderNumber,
    required this.trxId,
    required this.uid,
    required this.coverage,
    this.createdAt,
    this.stripeAmount,
    this.stripeCurrency,
    this.stripeCustomerEmail,
    this.whatsappNumber,
    this.stripePaymentIntent,
    this.stripeSessionId,
    this.web,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) =>
      OrderHistoryModel(
        name: json["name"]?.toString(),
        duration: json["duration"]?.toString(),
        logo: json["logo"]?.toString(),
        orderNumber: json["order_number"]?.toString(),
        trxId: json["trx_id"]?.toString(),
        uid: json["UID"]?.toString(),
        coverage: json["coverage"],
        createdAt: json["created_at"]?.toString(),
        stripeAmount: json["stripe_amount"] is num
            ? json["stripe_amount"] as num
            : num.tryParse(json["stripe_amount"]?.toString() ?? ''),
        stripeCurrency: json["stripe_currency"]?.toString(),
        stripeCustomerEmail: json["stripe_customer_email"]?.toString(),
        whatsappNumber: json["whatsapp_number"]?.toString(),
        stripePaymentIntent: json["stripe_payment_intent"]?.toString(),
        stripeSessionId: json["stripe_session_id"]?.toString(),
        web: json["web"] is bool ? json["web"] as bool : null,
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "duration": duration,
        "logo": logo,
        "order_number": orderNumber,
        "trx_id": trxId,
        "UID": uid,
        "coverage": coverage,
        if (createdAt != null) "created_at": createdAt,
        if (stripeAmount != null) "stripe_amount": stripeAmount,
        if (stripeCurrency != null) "stripe_currency": stripeCurrency,
        if (stripeCustomerEmail != null)
          "stripe_customer_email": stripeCustomerEmail,
        if (whatsappNumber != null) "whatsapp_number": whatsappNumber,
        if (stripePaymentIntent != null)
          "stripe_payment_intent": stripePaymentIntent,
        if (stripeSessionId != null) "stripe_session_id": stripeSessionId,
        if (web != null) "web": web,
      };
}
