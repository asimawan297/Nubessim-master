import 'package:equatable/equatable.dart';
import '../../models/all_esim_model.dart';

/// Status enum for EsimCubit
enum EsimStatus {
  initial,
  loading,
  success,
  error,
}

class EsimState extends Equatable {
  final EsimStatus status;
  final String message;
  final List<EsimList>? activeEsims;
  final List<EsimList>? cancelledEsims;
  final int totalEsims;
  final bool isVoice;

  const EsimState(
      {required this.status,
      required this.message,
      required this.activeEsims,
      required this.cancelledEsims,
      required this.totalEsims,
      required this.isVoice});

  /// Initial state factory
  factory EsimState.initial() {
    return const EsimState(
        status: EsimStatus.initial,
        message: '',
        activeEsims: [],
        cancelledEsims: [],
        totalEsims: 0,
        isVoice: false);
  }

  List<EsimList> getTotalEsims() {
    List<EsimList> all = [...activeEsims!, ...cancelledEsims!];

    all.sort((a, b) {
      DateTime dateA = _parseDate(a.packageList.first.createTime ?? "");
      DateTime dateB = _parseDate(b.packageList.first.createTime ?? "");

      return dateB.compareTo(dateA);
    });

    return all;
  }

  /// Copy with method
  EsimState copyWith(
      {EsimStatus? status,
      String? message,
      List<EsimList>? activeEsims,
      List<EsimList>? cancelledEsims,
      int? totalEsims,
      bool? isVoice}) {
    return EsimState(
        status: status ?? this.status,
        message: message ?? this.message,
        activeEsims: activeEsims ?? this.activeEsims,
        cancelledEsims: cancelledEsims ?? this.cancelledEsims,
        totalEsims: totalEsims ?? this.totalEsims,
        isVoice: isVoice ?? false);
  }

  @override
  List<Object?> get props =>
      [status, message, activeEsims, cancelledEsims, totalEsims, isVoice];
}

DateTime _parseDate(String date) {
  // Convert 2026-01-07T20:13:26+0000 → 2026-01-07T20:13:26+00:00
  String formatted = date.replaceFirstMapped(
    RegExp(r'([+-]\d{2})(\d{2})$'),
    (m) => '${m[1]}:${m[2]}',
  );

  return DateTime.parse(formatted);
}
