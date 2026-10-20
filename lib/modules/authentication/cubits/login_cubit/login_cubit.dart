import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nubesim/core/exceptions/api_error.dart';
import '../../../../utils/logger/logger.dart';
import '../../repository/auth_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;
  final _log = logger(LoginCubit);

  LoginCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const LoginState());

  void onEmailChanged(String email) {
    emit(state.copyWith(email: email));
  }

  void onPasswordChanged(String password) {
    emit(state.copyWith(password: password));
  }

  void clearStatus() {
  emit(state.copyWith(loginStatus: LoginStatus.initial, message: ''));
}

  void onPasswordVisibilityChanged() {
    emit(state.copyWith(hidePassword: !state.hidePassword));
  }

Future<void> login() async {
  emit(state.copyWith(loginStatus: LoginStatus.loading));
  try {
    // Request location permission and get location
    // await getLocation();

    final user = await _authRepository.signin(
      email: state.email,
      password: state.password
    );
    emit(
      state.copyWith(
        loginStatus: LoginStatus.success,
        user: user,
        message: 'Login successful',
      ),
    );
  } on ApiError catch (e, stackTrace) {
    _log.e('Login failed', error: e, stackTrace: stackTrace);
    emit(
        state.copyWith(loginStatus: LoginStatus.error, message: "Something went wrong, please try again after some time."),
    );
  } catch (e) {
    emit(
        state.copyWith(loginStatus: LoginStatus.error, message: "Something went wrong, please try again after some time."),
    );
  }
}

  Future<void> loginWithGoogle() async {
    emit(state.copyWith(loginStatus: LoginStatus.loading));
    try {
      final user = await _authRepository.signInWithGoogle();
      // print(user);
      emit(
        state.copyWith(
          loginStatus: LoginStatus.success,
          user: user,
          message: 'Google Login successful',
        ),
      );
    } on ApiError catch (e, stackTrace) {
      _log.e('Google Login failed', error: e, stackTrace: stackTrace);
      emit(state.copyWith(loginStatus: LoginStatus.error, message: "Something went wrong, please try again after some time."));
    }
  }

  Future<void> loginWithApple() async {
    emit(state.copyWith(loginStatus: LoginStatus.loading));
    try {
      final user = await _authRepository.signInWithApple();
      // print(user);
      emit(
        state.copyWith(
          loginStatus: LoginStatus.success,
          user: user,
          message: 'Apple Login successful',
        ),
      );
    } on ApiError catch (e, stackTrace) {
      _log.e('Apple Login failed', error: e, stackTrace: stackTrace);
      emit(state.copyWith(loginStatus: LoginStatus.error, message: "Something went wrong, please try again after some time."));
    }
  }

  Future<void> sendPasswordResetLink() async {
    emit(state.copyWith(loginStatus: LoginStatus.loading));
    try {
      await _authRepository.sendPasswordResetEmail(state.email);
      emit(state.copyWith(
        loginStatus: LoginStatus.success,
        message: 'Password reset link sent to your email.',
      ));
    } on ApiError catch (e, stackTrace) {
      _log.e('Password reset failed', error: e, stackTrace: stackTrace);
      emit(state.copyWith(
        loginStatus: LoginStatus.error,
        message: "Something went wrong, please try again after some time."
      ));
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.signOut();

      emit(state.copyWith(loginStatus: LoginStatus.logout, user: null));
    } on ApiError catch (e) {
      _log.e('Logout failed', error: e.message);
    }
  }
}
