import 'package:firebase_auth/firebase_auth.dart';
import 'package:nubesim/constants/keys.dart';

import '../../../core/storage_service/storage_service.dart';
import '../../../utils/logger/logger.dart';

class SessionRepository {
  final StorageService _storageService;
  final _log = logger(SessionRepository);

  SessionRepository({
    required StorageService storageService,
  }) : _storageService = storageService;

  Future<void> setLoggedIn(bool value) async {
    await _storageService.setBool(StorageKeys.isLoggedIn, value);
    _log.i('setLoggedIn $value');
  }


  Future<String>? getLoggedIn() async {
    final location = _storageService.getString(StorageKeys.location);
    _log.i('setLoggedIn $location');
    return location;
  }


  Future<void> setLocation(String value) async {
    await _storageService.setString(StorageKeys.location, value);
  }

  bool isLoggedIn() {
    // bool isLoggedIn = _storageService.getBool(StorageKeys.isLoggedIn);
    // _log.i('isLoggedIn: $isLoggedIn');
    var user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  Future<void> clearLocalStorage() async {
    await _storageService.clear();
  }
}
