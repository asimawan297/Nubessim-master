import 'package:equatable/equatable.dart';
import 'package:nubesim/modules/shop/model/account_balance_response.dart';

enum AccountBalanceStatus {
  initial,
  loading,
  success,
  error,
}

class AccountBalanceState extends Equatable {
  final AccountBalanceStatus status;
  final String message;
  final BalanceObj? balance;

  const AccountBalanceState({
    required this.status,
    required this.message,
    this.balance,
  });

  factory AccountBalanceState.initial() {
    return AccountBalanceState(
      status: AccountBalanceStatus.initial,
      message: '',
    );
  }

  AccountBalanceState copyWith({
    AccountBalanceStatus? status,
    String? message,
    BalanceObj? balance,
  }) {
    return AccountBalanceState(
      status: status ?? this.status,
      message: message ?? this.message,
      balance: balance ?? this.balance,
    );
  }

  @override
  List<Object?> get props => [status, message, balance];
}
