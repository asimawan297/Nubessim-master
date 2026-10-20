import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../utils/logger/logger.dart';
import '../../../authentication/repository/auth_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository _authRepository;
  final _log = logger(ProfileCubit);

  ProfileCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const ProfileState());

  void onNameChanged(String name) {
    emit(state.copyWith(name: name));
  }

  void onPhoneNumberChanged(String phoneNumber) {
    emit(state.copyWith(phoneNumber: phoneNumber));
  }

  Future<void> updateProfile() async {
    emit(state.copyWith(updateStatus: UpdateStatus.loading));
    try {
      final uid = _authRepository.currentUser?.uid;
      if (uid == null) {
        throw Exception('User not logged in.');
      }

      await _authRepository.updateUserProfile(
        uid: uid,
        name: state.name,
        phoneNumber: state.phoneNumber,
      );

      emit(
        state.copyWith(
          updateStatus: UpdateStatus.success,
          message: 'Profile updated successfully!',
        ),
      );
    } catch (e, stackTrace) {
      _log.e('Profile update failed', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          updateStatus: UpdateStatus.error,
          message: e.toString(),
        ),
      );
    }
  }

  /// This function can be used to pre-populate the form fields
  /// with the current user's data from local storage.
// void loadCurrentUserProfile() async {
//   final uid = _authRepository.currentUser?.uid;
//   if (uid != null) {
//     final name = await _authRepository.getStoredUserName();
//     final phone = await _authRepository.getStoredUserPhone();
//     emit(state.copyWith(name: name, phoneNumber: phone));
//   }
// }
}
