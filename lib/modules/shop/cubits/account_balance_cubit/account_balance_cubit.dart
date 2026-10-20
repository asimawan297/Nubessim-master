import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nubesim/core/exceptions/api_error.dart';
import 'package:nubesim/modules/shop/repository/shop_repository.dart';

import 'account_balance_state.dart';

class AccountBalanceCubit extends Cubit<AccountBalanceState> {
  final ShopRepository shopRepository;

  AccountBalanceCubit({required this.shopRepository})
      : super(AccountBalanceState.initial());

  Future<void> fetchAccountBalance() async {
    emit(state.copyWith(status: AccountBalanceStatus.loading));
    try {
      final response = await shopRepository.getAccountBalance();
      emit(state.copyWith(
        status: AccountBalanceStatus.success,
        balance: response.obj,
      ));
    } on ApiError catch (e) {
      emit(state.copyWith(
        status: AccountBalanceStatus.error,
        message: e.message,
      ));
    }
  }
}
