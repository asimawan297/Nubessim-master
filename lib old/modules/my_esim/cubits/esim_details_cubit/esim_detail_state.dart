import 'package:equatable/equatable.dart';
import 'package:nubesim/modules/my_esim/models/all_esim_model.dart';
/// Status enum for EsimCubit
enum EsimDetailStatus {
  initial,
  loading,
  success,
  error,
}

class EsimDetailState extends Equatable {
  final EsimDetailStatus status;
  final String message;
  final bool success;
  final String errorCode;
  final dynamic errorMsg;
  final List<EsimList> esimList; // non-nullable
  final Pager? pager; // nullable, API may or may not return pager

  const EsimDetailState({
    required this.status,
    required this.message,
    required this.success,
    required this.errorCode,
    required this.errorMsg,
    required this.esimList,
    required this.pager,
  });

  /// Initial state
  factory EsimDetailState.initial() {
    return const EsimDetailState(
      status: EsimDetailStatus.initial,
      message: '',
      success: false,
      errorCode: '',
      errorMsg: null,
      esimList: [],
      pager: null,
    );
  }

  EsimDetailState copyWith({
    EsimDetailStatus? status,
    String? message,
    bool? success,
    String? errorCode,
    dynamic errorMsg,
    List<EsimList>? esimList,
    Pager? pager,
  }) {
    return EsimDetailState(
      status: status ?? this.status,
      message: message ?? this.message,
      success: success ?? this.success,
      errorCode: errorCode ?? this.errorCode,
      errorMsg: errorMsg ?? this.errorMsg,
      esimList: esimList ?? this.esimList, // always a list
      pager: pager ?? this.pager,
    );
  }

  @override
  List<Object?> get props =>
      [status, message, success, errorCode, errorMsg, esimList, pager];
}
