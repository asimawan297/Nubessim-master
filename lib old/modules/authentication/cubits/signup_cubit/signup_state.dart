part of 'signup_cubit.dart';

enum SignupStatus { initial, success, loading, error }

class SignupState extends Equatable {
  final String name;
  final String phoneNumber;
  final String email;
  final String password;
  final bool hidePassword;
  final User? user;
  final String message;
  final SignupStatus signupStatus;

  const SignupState({
    this.name = '',
    this.phoneNumber = '',
    this.email = '',
    this.password = '',
    this.hidePassword = true,
    this.user,
    this.message = '',
    this.signupStatus = SignupStatus.initial,
  });

  SignupState copyWith({
    String? name,
    String? phoneNumber,
    String? email,
    String? password,
    bool? hidePassword,
    User? user,
    String? message,
    SignupStatus? signupStatus,
  }) {
    return SignupState(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      password: password ?? this.password,
      hidePassword: hidePassword ?? this.hidePassword,
      user: user ?? this.user,
      message: message ?? this.message,
      signupStatus: signupStatus ?? this.signupStatus,
    );
  }

  @override
  List<Object?> get props => [
        name,
        phoneNumber,
        email,
        password,
        hidePassword,
        user,
        message,
        signupStatus,
      ];
}
