import 'package:equatable/equatable.dart';

enum DeleteAccountStatus { initial, loading, success, error }

class DeleteAccountState extends Equatable {
  final DeleteAccountStatus status;
  final String message;

  const DeleteAccountState({
    this.status = DeleteAccountStatus.initial,
    this.message = '',
  });

  DeleteAccountState copyWith({
    DeleteAccountStatus? status,
    String? message,
  }) {
    return DeleteAccountState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
