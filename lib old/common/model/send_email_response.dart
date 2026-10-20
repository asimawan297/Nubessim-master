class SendEmailResponse {
  final String messageId;

  SendEmailResponse({required this.messageId});

  factory SendEmailResponse.fromJson(Map<String, dynamic> json) {
    return SendEmailResponse(
      messageId: json["messageId"] ?? "",
    );
  }
}
