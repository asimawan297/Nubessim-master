class SendEmailInput {
  final String senderName;
  final String senderEmail;
  final String receiverName;
  final String receiverEmail;
  final String subject;
  final String htmlContent;

  SendEmailInput({
    required this.senderName,
    required this.senderEmail,
    required this.receiverName,
    required this.receiverEmail,
    required this.subject,
    required this.htmlContent,
  });

  Map<String, dynamic> toJson() {
    return {
      "sender": {
        "name": senderName,
        "email": senderEmail,
      },
      "to": [
        {
          "email": receiverEmail,
          "name": receiverName,
        }
      ],
      "subject": subject,
      "htmlContent": htmlContent,
    };
  }
}
