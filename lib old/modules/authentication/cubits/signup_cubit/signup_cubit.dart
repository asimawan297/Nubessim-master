
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nubesim/constants/keys.dart';
import 'package:nubesim/core/di/service_locator.dart';
import 'package:nubesim/core/storage_service/storage_service.dart';

import '../../../../core/exceptions/api_error.dart';
import '../../../../utils/logger/logger.dart';
import '../../repository/auth_repository.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
final StorageService _storageService =
      sl<StorageService>(); 
  final AuthRepository _authRepository;
  final _log = logger(SignupCubit);

  SignupCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const SignupState());

  void onNameChanged(String name) {
    emit(state.copyWith(name: name));
  }

  Future<void> loginWithApple() async {
    emit(state.copyWith(signupStatus: SignupStatus.loading));
    try {
      final user = await _authRepository.signInWithApple();
      // print(user);
      emit(
        state.copyWith(
          signupStatus: SignupStatus.success,
          user: user,
          message: 'Apple Login successful',
        ),
      );
    } on ApiError catch (e, stackTrace) {
      _log.e('Apple Login failed', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(signupStatus: SignupStatus.error, message: "Something went wrong, please try again after some time."),
      );
    }
  }

  void onPhoneChanged(String phoneNumber) {
    emit(state.copyWith(phoneNumber: phoneNumber));
  }

  void onEmailChanged(String email) {
    emit(state.copyWith(email: email));
  }

  void onPasswordChanged(String password) {
    emit(state.copyWith(password: password));
  }

  void clearStatus() {
  emit(state.copyWith(signupStatus: SignupStatus.initial, message: ''));
}


  void onPasswordVisibilityChanged() {
    emit(state.copyWith(hidePassword: !state.hidePassword));
  }





saveInfoToDb( { required user,required email,required name, phoneNumber, userProfileImage})async{
     await _authRepository.firestore.collection('user_data').doc(user.uid).set({
        'uid': user.uid,
        'email': email ?? "",
        'name': name,
        "image": userProfileImage ?? "",
        'isGoogle': true,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _storageService.setString(StorageKeys.userUid, user.uid);
      await _storageService.setString(StorageKeys.userName, name ?? "");
      await _storageService.setString(StorageKeys.userEmail, email ?? "");
      await _storageService.setString(StorageKeys.userPhone, phoneNumber?? "");
      await _storageService.setString(StorageKeys.isGoogle, "true");
      await _storageService.setString(StorageKeys.userProfileImage, userProfileImage ?? "");
}


  Future<void> signupWithGoogle() async {
    try {
    emit(state.copyWith(signupStatus: SignupStatus.loading));
      final user = await _authRepository.signInWithGoogle();
      _log.i('Google Sign-Up successful: ${user.uid}');
await saveInfoToDb(user: user, email: user.email, name: user.displayName ?? '', phoneNumber: user.phoneNumber ?? '', userProfileImage: user.photoURL ?? '');

     
      emit(
        state.copyWith(
          signupStatus: SignupStatus.success,
          user: user,
          message: 'Google Sign-Up successful',
        ),
      );
    } catch (e, stackTrace) {
      _log.e('Google Sign-Up failed', error: e, stackTrace: stackTrace);

      String errorMsg = 'Google Sign-Up failed';

     if (e is ApiError) {
  switch (e.code) {
    case 409:
      errorMsg = "Conflict occurred, please try again.";
      break;

    case 499:
      errorMsg = "Request was cancelled.";
      break;

    default:
      errorMsg = "Something went wrong, please try again after some time.";
      break;
  }
}


      emit(state.copyWith(signupStatus: SignupStatus.error, message: errorMsg));
    }
  }

  Future<void> signup() async {
    try {
    emit(state.copyWith(signupStatus: SignupStatus.loading));
      final user = await _authRepository.signup(
        email: state.email,
        password: state.password,
        name: state.name,
        phoneNumber: state.phoneNumber,
      );

      _log.i('Signup successful: ${user.uid}');
      emit(
        state.copyWith(
          signupStatus: SignupStatus.success,
          user: user,
          message: 'Signup successful',
        ),
      );
    } on ApiError catch (e, stackTrace) {
      _log.e('Signup failed', error: e, stackTrace: stackTrace);
      emit(
          state.copyWith(signupStatus: SignupStatus.error, message: "Something went wrong, please try again after some time."));
    }
  }
}
