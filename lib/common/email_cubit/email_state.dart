import 'package:equatable/equatable.dart';
import '../model/send_email_response.dart';

enum EmailStatus {
  initial,
  loading,
  success,
  error,
}

class EmailState extends Equatable {
  final EmailStatus status;
  final String message;
  final SendEmailResponse? response;

  const EmailState({
    required this.status,
    required this.message,
    this.response,
  });

  factory EmailState.initial() {
    return const EmailState(
      status: EmailStatus.initial,
      message: '',
    );
  }

  EmailState copyWith({
    EmailStatus? status,
    String? message,
    SendEmailResponse? response,
  }) {
    return EmailState(
      status: status ?? this.status,
      message: message ?? this.message,
      response: response ?? this.response,
    );
  }

  @override
  List<Object?> get props => [status, message, response];
}
