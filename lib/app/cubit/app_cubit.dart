import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage_service/storage_service.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  final StorageService storageService;

  AppCubit(this.storageService) : super(AppState(locale: const Locale('en')));

  void init() {
    String locale = storageService.getString('locale');
    emit(state.copyWith(
      locale: locale.isEmpty ? const Locale('en') : Locale(locale),
    ));
  }

  void updateLanguage(String locale) async {
    await storageService.setString('locale', locale);
    emit(state.copyWith(locale: Locale(locale)));
  }
}
