part of 'profile_cubit.dart';

enum UpdateStatus { initial, loading, success, error }

class ProfileState extends Equatable {
  final String name;
  final String phoneNumber;
  final UpdateStatus updateStatus;
  final String message;

  const ProfileState({
    this.name = '',
    this.phoneNumber = '',
    this.updateStatus = UpdateStatus.initial,
    this.message = '',
  });

  ProfileState copyWith({
    String? name,
    String? phoneNumber,
    UpdateStatus? updateStatus,
    String? message,
  }) {
    return ProfileState(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      updateStatus: updateStatus ?? this.updateStatus,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [name, phoneNumber, updateStatus, message];
}
