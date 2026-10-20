part of 'login_cubit.dart';

enum LoginStatus { initial, success, loading, error, logout }

class LoginState extends Equatable {
  final String email;
  final String password;
  final User? user;
  final String message;
  final bool hidePassword;
  final LoginStatus loginStatus;

  const LoginState({
    this.user,
    this.email = '',
    this.password = '',
    this.message = '',
    this.hidePassword = true,
    this.loginStatus = LoginStatus.initial,
  });

  LoginState copyWith({
    String? email,
    User? user,
    String? password,
    String? message,
    bool? hidePassword,
    LoginStatus? loginStatus,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      user: user ?? this.user,
      message: message ?? this.message,
      hidePassword: hidePassword ?? this.hidePassword,
      loginStatus: loginStatus ?? this.loginStatus,
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        user,
        message,
        hidePassword,
        loginStatus,
      ];
}
