// To parse this JSON data, do
//
//     final stripePaymentResponse = stripePaymentResponseFromJson(jsonString);

import 'dart:convert';

StripePaymentResponse stripePaymentResponseFromJson(String str) =>
    StripePaymentResponse.fromJson(json.decode(str));

String stripePaymentResponseToJson(StripePaymentResponse data) =>
    json.encode(data.toJson());

class StripePaymentResponse {
  String id;
  String object;
  int amount;
  int amountCapturable;
  AmountDetails amountDetails;
  int amountReceived;
  dynamic application;
  dynamic applicationFeeAmount;
  AutomaticPaymentMethods automaticPaymentMethods;
  dynamic canceledAt;
  dynamic cancellationReason;
  String captureMethod;
  String clientSecret;
  String confirmationMethod;
  int created;
  String currency;
  dynamic customer;
  dynamic description;
  dynamic lastPaymentError;
  dynamic latestCharge;
  bool livemode;
  Metadata metadata;
  dynamic nextAction;
  dynamic onBehalfOf;
  dynamic paymentMethod;
  PaymentMethodConfigurationDetails paymentMethodConfigurationDetails;
  PaymentMethodOptions paymentMethodOptions;
  List<String> paymentMethodTypes;
  dynamic processing;
  dynamic receiptEmail;
  dynamic review;
  dynamic setupFutureUsage;
  dynamic shipping;
  dynamic source;
  dynamic statementDescriptor;
  dynamic statementDescriptorSuffix;
  String status;
  dynamic transferData;
  dynamic transferGroup;

  StripePaymentResponse({
    required this.id,
    required this.object,
    required this.amount,
    required this.amountCapturable,
    required this.amountDetails,
    required this.amountReceived,
    required this.application,
    required this.applicationFeeAmount,
    required this.automaticPaymentMethods,
    required this.canceledAt,
    required this.cancellationReason,
    required this.captureMethod,
    required this.clientSecret,
    required this.confirmationMethod,
    required this.created,
    required this.currency,
    required this.customer,
    required this.description,
    required this.lastPaymentError,
    required this.latestCharge,
    required this.livemode,
    required this.metadata,
    required this.nextAction,
    required this.onBehalfOf,
    required this.paymentMethod,
    required this.paymentMethodConfigurationDetails,
    required this.paymentMethodOptions,
    required this.paymentMethodTypes,
    required this.processing,
    required this.receiptEmail,
    required this.review,
    required this.setupFutureUsage,
    required this.shipping,
    required this.source,
    required this.statementDescriptor,
    required this.statementDescriptorSuffix,
    required this.status,
    required this.transferData,
    required this.transferGroup,
  });

  factory StripePaymentResponse.fromJson(Map<String, dynamic> json) =>
      StripePaymentResponse(
        id: json["id"],
        object: json["object"],
        amount: json["amount"],
        amountCapturable: json["amount_capturable"],
        amountDetails: AmountDetails.fromJson(json["amount_details"]),
        amountReceived: json["amount_received"],
        application: json["application"],
        applicationFeeAmount: json["application_fee_amount"],
        automaticPaymentMethods:
            AutomaticPaymentMethods.fromJson(json["automatic_payment_methods"]),
        canceledAt: json["canceled_at"],
        cancellationReason: json["cancellation_reason"],
        captureMethod: json["capture_method"],
        clientSecret: json["client_secret"],
        confirmationMethod: json["confirmation_method"],
        created: json["created"],
        currency: json["currency"],
        customer: json["customer"],
        description: json["description"],
        lastPaymentError: json["last_payment_error"],
        latestCharge: json["latest_charge"],
        livemode: json["livemode"],
        metadata: Metadata.fromJson(json["metadata"]),
        nextAction: json["next_action"],
        onBehalfOf: json["on_behalf_of"],
        paymentMethod: json["payment_method"],
        paymentMethodConfigurationDetails:
            PaymentMethodConfigurationDetails.fromJson(
                json["payment_method_configuration_details"]),
        paymentMethodOptions:
            PaymentMethodOptions.fromJson(json["payment_method_options"]),
        paymentMethodTypes:
            List<String>.from(json["payment_method_types"].map((x) => x)),
        processing: json["processing"],
        receiptEmail: json["receipt_email"],
        review: json["review"],
        setupFutureUsage: json["setup_future_usage"],
        shipping: json["shipping"],
        source: json["source"],
        statementDescriptor: json["statement_descriptor"],
        statementDescriptorSuffix: json["statement_descriptor_suffix"],
        status: json["status"],
        transferData: json["transfer_data"],
        transferGroup: json["transfer_group"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "amount": amount,
        "amount_capturable": amountCapturable,
        "amount_details": amountDetails.toJson(),
        "amount_received": amountReceived,
        "application": application,
        "application_fee_amount": applicationFeeAmount,
        "automatic_payment_methods": automaticPaymentMethods.toJson(),
        "canceled_at": canceledAt,
        "cancellation_reason": cancellationReason,
        "capture_method": captureMethod,
        "client_secret": clientSecret,
        "confirmation_method": confirmationMethod,
        "created": created,
        "currency": currency,
        "customer": customer,
        "description": description,
        "last_payment_error": lastPaymentError,
        "latest_charge": latestCharge,
        "livemode": livemode,
        "metadata": metadata.toJson(),
        "next_action": nextAction,
        "on_behalf_of": onBehalfOf,
        "payment_method": paymentMethod,
        "payment_method_configuration_details":
            paymentMethodConfigurationDetails.toJson(),
        "payment_method_options": paymentMethodOptions.toJson(),
        "payment_method_types":
            List<dynamic>.from(paymentMethodTypes.map((x) => x)),
        "processing": processing,
        "receipt_email": receiptEmail,
        "review": review,
        "setup_future_usage": setupFutureUsage,
        "shipping": shipping,
        "source": source,
        "statement_descriptor": statementDescriptor,
        "statement_descriptor_suffix": statementDescriptorSuffix,
        "status": status,
        "transfer_data": transferData,
        "transfer_group": transferGroup,
      };
}

class AmountDetails {
  Metadata tip;

  AmountDetails({
    required this.tip,
  });

  factory AmountDetails.fromJson(Map<String, dynamic> json) => AmountDetails(
        tip: Metadata.fromJson(json["tip"]),
      );

  Map<String, dynamic> toJson() => {
        "tip": tip.toJson(),
      };
}

class Metadata {
  Metadata();

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata();

  Map<String, dynamic> toJson() => {};
}

class AutomaticPaymentMethods {
  String allowRedirects;
  bool enabled;

  AutomaticPaymentMethods({
    required this.allowRedirects,
    required this.enabled,
  });

  factory AutomaticPaymentMethods.fromJson(Map<String, dynamic> json) =>
      AutomaticPaymentMethods(
        allowRedirects: json["allow_redirects"],
        enabled: json["enabled"],
      );

  Map<String, dynamic> toJson() => {
        "allow_redirects": allowRedirects,
        "enabled": enabled,
      };
}

class PaymentMethodConfigurationDetails {
  String id;
  dynamic parent;

  PaymentMethodConfigurationDetails({
    required this.id,
    required this.parent,
  });

  factory PaymentMethodConfigurationDetails.fromJson(
          Map<String, dynamic> json) =>
      PaymentMethodConfigurationDetails(
        id: json["id"],
        parent: json["parent"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "parent": parent,
      };
}

class PaymentMethodOptions {
  Card card;
  Link link;

  PaymentMethodOptions({
    required this.card,
    required this.link,
  });

  factory PaymentMethodOptions.fromJson(Map<String, dynamic> json) =>
      PaymentMethodOptions(
        card: Card.fromJson(json["card"]),
        link: Link.fromJson(json["link"]),
      );

  Map<String, dynamic> toJson() => {
        "card": card.toJson(),
        "link": link.toJson(),
      };
}

class Card {
  dynamic installments;
  dynamic mandateOptions;
  dynamic network;
  String requestThreeDSecure;

  Card({
    required this.installments,
    required this.mandateOptions,
    required this.network,
    required this.requestThreeDSecure,
  });

  factory Card.fromJson(Map<String, dynamic> json) => Card(
        installments: json["installments"],
        mandateOptions: json["mandate_options"],
        network: json["network"],
        requestThreeDSecure: json["request_three_d_secure"],
      );

  Map<String, dynamic> toJson() => {
        "installments": installments,
        "mandate_options": mandateOptions,
        "network": network,
        "request_three_d_secure": requestThreeDSecure,
      };
}

class Link {
  dynamic persistentToken;

  Link({
    required this.persistentToken,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        persistentToken: json["persistent_token"],
      );

  Map<String, dynamic> toJson() => {
        "persistent_token": persistentToken,
      };
}
