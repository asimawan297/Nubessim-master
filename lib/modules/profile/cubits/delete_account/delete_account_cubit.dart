import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nubesim/core/exceptions/api_error.dart';

import '../../../../core/auth_service/auth_service.dart';
import 'delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final AuthService _authService;
  final FirebaseFirestore _firestore;

  DeleteAccountCubit({
    required AuthService authService,
    FirebaseFirestore? firestore,
  })  : _authService = authService,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const DeleteAccountState());

  Future<void> deleteUserAccount() async {
    emit(state.copyWith(status: DeleteAccountStatus.loading));

    try {
      final currentUser = _authService.currentUser;

      if (currentUser == null) {
        emit(state.copyWith(
          status: DeleteAccountStatus.error,
          message: 'No authenticated user found',
        ));
        return;
      }

      final uid = currentUser.uid;

      // Delete user document from Firestore
      await _firestore.collection('user_data').doc(uid).delete();

      // Delete user from Firebase Auth
      await currentUser.delete();

      emit(state.copyWith(
        status: DeleteAccountStatus.success,
        message: 'Account deleted successfully',
      ));
    } on FirebaseAuthException catch (e) {
      // Handle re-authentication required error
      if (e.code == 'requires-recent-login') {
        emit(state.copyWith(
          status: DeleteAccountStatus.error,
          message: 'Please re-authenticate before deleting your account.',
        ));
      } else {
        emit(state.copyWith(
          status: DeleteAccountStatus.error,
          message: e.message ?? 'Error deleting account',
        ));
      }
    } on ApiError catch (e) {
      emit(state.copyWith(
          status: DeleteAccountStatus.error, message: e.message));
    }
  }
}
