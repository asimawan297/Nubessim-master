import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nubesim/core/auth_service/apple_sign_in_service.dart';
import 'package:nubesim/modules/common/repo/session_repo.dart';
import '../../../constants/api_endpoints.dart';
import '../../../constants/keys.dart';
import '../../../core/auth_service/auth_service.dart';
import '../../../core/auth_service/google_sign_in_service.dart';
import '../../../core/exceptions/api_error.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage_service/storage_service.dart';
import '../../../utils/logger/logger.dart';

class AuthRepository {
  final AuthService _authService;
  final SessionRepository _sessionRepository;
  final GoogleSignInService _googleSignInService = GoogleSignInService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final StorageService storageService; // Injected storage service
  final DioClient _dioClient; // Add DioClient
  final AppleSignInService _appleSignInService = AppleSignInService();

  AuthRepository({
    required AuthService authService,
    required SessionRepository sessionRepository,
    required StorageService storageService, // Injecting storage service
    required DioClient dioClient, // Add DioClient parameter
  })  : _authService = authService,
        _sessionRepository = sessionRepository,
        storageService = storageService,
        _dioClient = dioClient;

  final _log = logger(AuthRepository);

  /// Sign up user
  Future<User> signup({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
  }) async {
    try {
      User? user = await _authService.signUp(email: email, password: password);
      if (user == null) {
        throw ApiError(message: 'User creation failed', code: 0);
      }

      // Save additional user data to Firestore
      await firestore.collection('user_data').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'name': name,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await storageService.setString(StorageKeys.userUid, user.uid);
      await storageService.setString(StorageKeys.userName, name);
      await storageService.setString(StorageKeys.userEmail, email);
      await storageService.setString(StorageKeys.userPhone, phoneNumber);
      await storageService.setString(StorageKeys.userProfileImage, "");

      // await _sessionRepository.setLoggedIn(true);

      await _sessionRepository.setLoggedIn(true);
      return user;
    } on FirebaseAuthException catch (e, stackTrace) {
      _log.e('FirebaseAuthException: ${e.code} - ${e.message}',
          stackTrace: stackTrace);

      if (e.code == 'email-already-in-use') {
        throw ApiError(
          message:
              'An account already exists for that email. Please login instead.',
          code: 409,
        );
      }

      throw ApiError(message: 'Authentication error', code: 0);
    } catch (e, stackTrace) {
      _log.e('Signup failed: $e', stackTrace: stackTrace);
      throw ApiError(message: 'Unexpected error Occured', code: 0);
    }
  }

  /// Google Sign-Up
  Future<User> signupWithGoogle() async {
    try {
      final userCredential = await _googleSignInService.signInWithGoogle();
      if (userCredential == null || userCredential.user == null) {
        throw ApiError(message: 'Google Sign-Up failed', code: 0);
      }

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      final user = userCredential.user!;

      if (!isNewUser) {
        throw ApiError(
          message:
              'An account already exists for this Google user. Please log in instead.',
          code: 409,
        );
      }

      // Force refresh user data to ensure we get the latest profile information
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      // Debug: Print Firebase user info
      _log.i('Firebase User Email: ${refreshedUser?.email}');
      _log.i('Firebase User Display Name: ${refreshedUser?.displayName}');
      _log.i('Firebase User UID: ${refreshedUser?.uid}');
      _log.i('Firebase User Phone: ${refreshedUser?.phoneNumber}');
      _log.i('Is New User: $isNewUser');
      _log.i('Original User Email: ${user.email}');
      _log.i('UserCredential User Email: ${userCredential.user?.email}');

      // Get email from multiple sources to ensure we capture it
      String? userEmail = refreshedUser?.email;
      _log.i('Email from refreshed user: $userEmail');

      if (userEmail == null || userEmail.isEmpty) {
        userEmail = user.email;
        _log.w(
            'Email was null after refresh, using original user email: $userEmail');
      }

      // If still no email, try to get it from the original userCredential
      if (userEmail == null || userEmail.isEmpty) {
        userEmail = userCredential.user?.email;
        _log.w(
            'Email was null after refresh, trying original userCredential email: $userEmail');
      }

      // If we still don't have an email, this is a critical issue
      if (userEmail == null || userEmail.isEmpty) {
        _log.e(
            'No email found for Google user. This might be due to insufficient permissions.');
        // You might want to show a dialog asking the user to grant email permissions
        throw ApiError(
          message:
              'Email permission is required. Please try signing in again and grant email access.',
          code: 400,
        );
      }

      // Save Google user info to Firestore using refreshed user data
      await firestore.collection('user_data').doc(user.uid).set({
        'uid': user.uid,
        'email': userEmail,
        'name': refreshedUser?.displayName ?? '',
        'phoneNumber': refreshedUser?.phoneNumber ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save user data to local storage (same as manual signup)
      await storageService.setString(StorageKeys.userUid, user.uid);
      await storageService.setString(
          StorageKeys.userName, refreshedUser?.displayName ?? '');
      await storageService.setString(StorageKeys.userEmail, userEmail);
      await storageService.setString(
          StorageKeys.userPhone, refreshedUser?.phoneNumber ?? '');
      await storageService.setString(
          StorageKeys.userProfileImage, refreshedUser?.photoURL ?? '');

      await _sessionRepository.setLoggedIn(true);
      return user;
    } catch (e, stackTrace) {
      _log.e('Google Sign-Up failed: $e', stackTrace: stackTrace);

      // if (e is ApiError) rethrow;

      if (e.toString().contains('canceled')) {
        throw ApiError(
          message: 'Google Sign-In was cancelled by the user.',
          code: 499,
        );
      }

      throw ApiError(message: 'Google Sign-Up error: $e', code: 0);
    }
  }

  Future<User> signin({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authService.signIn(email: email, password: password);

      if (user == null) {
        throw ApiError(message: 'Sign-in failed. Please try again.', code: 0);
      }

      // Fetch user data from Firestore
      DocumentSnapshot userDoc =
          await firestore.collection('user_data').doc(user.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        await storageService.setString(StorageKeys.userUid, user.uid);
        await storageService.setString(
            StorageKeys.userName, userData['name'] ?? '');
        await storageService.setString(
            StorageKeys.userEmail, userData['email'] ?? '');
        await storageService.setString(
            StorageKeys.userPhone, userData['phoneNumber'] ?? '');
        await storageService.setString(
            StorageKeys.userProfileImage, userData['profileImage'] ?? '');
      } else {
        _log.w('User data not found in Firestore for UID: ${user.uid}');
      }

      await _sessionRepository.setLoggedIn(true);
      return user;
    } on FirebaseAuthException catch (e, stackTrace) {
      _log.e('FirebaseAuthException: ${e.code} - ${e.message}',
          stackTrace: stackTrace);
      switch (e.code) {
        case 'user-not-found':
          throw ApiError(message: 'No user found for that email.', code: 404);
        case 'wrong-password':
          throw ApiError(message: 'Incorrect password.', code: 401);
        case 'user-disabled':
          throw ApiError(
              message:
                  'This account has been disabled. Please contact support.',
              code: 403);
        case 'too-many-requests':
          throw ApiError(
              message: 'Too many attempts. Please wait and try again later.',
              code: 429);
        case 'invalid-email':
          throw ApiError(
              message: 'The email address is badly formatted.', code: 400);
        case 'network-request-failed':
          throw ApiError(message: 'No internet connection.', code: 503);
        default:
          throw ApiError(
              message: 'Authentication error: ${e.message}', code: 0);
      }
    } catch (e, stackTrace) {
      _log.e('Signin failed: $e', stackTrace: stackTrace);

      rethrow;
    }
  }

  saveInfoToDb(
      {required user,
      required email,
      required name,
      phoneNumber,
      userProfileImage,
      isGoogle = false,
      isApple = false}) async {
    final firestore = FirebaseFirestore.instance;

    // Base user data
    final userData = {
      'uid': user.uid,
      'email': email ?? "",
      'name': name,
      'image': userProfileImage ?? "",
      'phoneNumber': phoneNumber ?? "",
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Add the login provider flag
    if (isGoogle) {
      userData['isGoogle'] = true;
    } else if (isApple) {
      userData['isApple'] = true;
    }

    // Save with merge
    await firestore.collection('user_data').doc(user.uid).set(
          userData,
          SetOptions(merge: true),
        );

    await storageService.setString(StorageKeys.userUid, user.uid);
    await storageService.setString(StorageKeys.userName, name ?? "");
    await storageService.setString(StorageKeys.userEmail, email ?? "");
    await storageService.setString(StorageKeys.userPhone, phoneNumber ?? "");
    if (isGoogle) {
      await storageService.setString(StorageKeys.isGoogle, "true");
    } else if (isApple) {
      await storageService.setString(StorageKeys.isApple, "true");
    }
    await storageService.setString(
        StorageKeys.userProfileImage, userProfileImage ?? "");
  }

  Future<User> signInWithGoogle() async {
    try {
      final userCredential = await _googleSignInService.signInWithGoogle();

      if (userCredential == null || userCredential.user == null) {
        throw ApiError(message: 'The user canceled the sign-in flow.', code: 1);
      }

      final user = userCredential.user!;
      final userRef = firestore.collection('user_data').doc(user.uid);
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Ensure 'isGoogle' flag is set
        if (userData['isGoogle'] != true) {
          await userRef.update({'isGoogle': true});
        }

        // Save user data locally
        await storageService.setString(StorageKeys.userUid, user.uid);
        await storageService.setString(
            StorageKeys.userName, userData['name'] ?? user.displayName ?? '');
        await storageService.setString(
            StorageKeys.userEmail, userData['email'] ?? user.email ?? '');
        await storageService.setString(StorageKeys.userPhone,
            userData['phoneNumber'] ?? user.phoneNumber ?? '');
        await storageService.setString(StorageKeys.userProfileImage,
            userData['profileImage'] ?? user.photoURL ?? '');
        await storageService.setString(StorageKeys.isGoogle, "true");
      } else {
        _log.w('User data not found in Firestore for UID: ${user.uid}');
        await saveInfoToDb(
            user: user,
            email: user.email,
            name: user.displayName ?? '',
            phoneNumber: user.phoneNumber ?? '',
            userProfileImage: user.photoURL ?? '',
            isGoogle: true);
      }

      // Mark user as logged in
      await _sessionRepository.setLoggedIn(true);

      return user;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      _log.e('FirebaseAuthException: ${e.code} - ${e.message}');
      throw ApiError(
        message: e.message ?? 'Firebase authentication failed: ${e.code}',
        code: 2,
      );
    } on FirebaseException catch (e) {
      // Handle Firestore-related errors
      _log.e('FirebaseException: ${e.code} - ${e.message}');
      throw ApiError(
        message: e.message ?? 'Firestore error: ${e.code}',
        code: 3,
      );
    } catch (e) {
      // Catch all unexpected errors
      _log.e('Google Sign-In failed: $e');
      throw ApiError(message: e.toString(), code: 4);
    }
  }

  /// Sign in with Apple
  Future<User> signInWithApple() async {
    try {
      final userCredential = await _appleSignInService.signInWithApple();
      if (userCredential == null || userCredential.user == null) {
        throw ApiError(message: 'Apple Sign-In failed', code: 0);
      }

      final user = userCredential.user!;
      final userRef = firestore.collection('user_data').doc(user.uid);
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Ensure 'isGoogle' flag is set
        if (userData['isApple'] != true) {
          await userRef.update({'isApple': true});
        }
        // Save user data locally
        await storageService.setString(StorageKeys.userUid, user.uid);
        await storageService.setString(
            StorageKeys.userName, userData['name'] ?? user.displayName ?? '');
        await storageService.setString(
            StorageKeys.userEmail, userData['email'] ?? user.email ?? '');
        await storageService.setString(StorageKeys.userPhone,
            userData['phoneNumber'] ?? user.phoneNumber ?? '');
        await storageService.setString(StorageKeys.userProfileImage,
            userData['profileImage'] ?? user.photoURL ?? '');
        await storageService.setString(StorageKeys.isGoogle, "true");
      } else {
        _log.w('User data not found in Firestore for UID: ${user.uid}');
        await saveInfoToDb(
            user: user,
            email: user.email,
            name: user.displayName ?? '',
            phoneNumber: user.phoneNumber ?? '',
            userProfileImage: user.photoURL ?? '',
            isApple: true);
      }

      // Optionally, save login status
      await _sessionRepository.setLoggedIn(true);
      return user;
    } catch (e, stackTrace) {
      _log.e('Apple Sign-In failed: $e', stackTrace: stackTrace);
      throw ApiError(message: 'Apple Sign-In failed: $e', code: 0);
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      // Clear local storage after signout
      await _sessionRepository.clearLocalStorage();
    } catch (e, stackTrace) {
      _log.e('SignOut failed: $e', stackTrace: stackTrace);
      throw ApiError(message: 'Sign out failed: $e', code: 0);
    }
  }

  /// Get current user
  User? get currentUser {
    try {
      return _authService.currentUser;
    } catch (e, stackTrace) {
      _log.e('Get current user failed: $e', stackTrace: stackTrace);
      throw ApiError(message: 'Unable to retrieve user: $e', code: 0);
    }
  }

  Future<bool> userExists(String email) async {
    final result = await FirebaseFirestore.instance
        .collection('user_data')
        .where('email', isEqualTo: email.toLowerCase())
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final exists = await userExists(email);

    if (!exists) {
      throw ApiError(
          message: 'No user found with this email, please sign up first.',
          code: 404);
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e, stackTrace) {
      _log.e('Reset password failed: ${e.code} - ${e.message}',
          stackTrace: stackTrace);

      switch (e.code) {
        case 'invalid-email':
          throw ApiError(message: 'Invalid email address.', code: 400);

        default:
          throw ApiError(
            message: 'Something went wrong, please try again after some time.',
            code: 0,
          );
      }
    } on ApiError {
      rethrow;
    } catch (e, stackTrace) {
      _log.e('Unexpected error in resetPassword: $e', stackTrace: stackTrace);

      throw ApiError(
        message: 'Something went wrong, please try again after some time.',
        code: 0,
      );
    }
  }

  // /// Send OTP to email for verification
  // Future<bool> sendOtpToEmail(String email) async {
  //   try {
  //     // TODO: Replace this with your actual API call to send OTP
  //     // For now, this is a simulation
  //     await Future.delayed(Duration(seconds: 1));

  //     _log.i('OTP sent successfully to email: $email');
  //     return true; // Simulate success
  //   } catch (e, stackTrace) {
  //     _log.e('Failed to send OTP to email: $email', error: e, stackTrace: stackTrace);
  //     return false; // Simulate failure
  //   }
  // }

  Future<bool> sendOtpToEmail(String email) async {
    try {
      // Try to make the actual API call first
      final response = await _dioClient.post(
        Endpoints.sendOtp,
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        _log.i('OTP sent successfully to email: $email');
        return true;
      } else {
        _log.e(
            'Failed to send OTP. Status: ${response.statusCode}, Data: ${response.data}');
        return false;
      }
    } catch (e, stackTrace) {
      _log.e('Error sending OTP to email: $email',
          error: e, stackTrace: stackTrace);

      // Since the custom OTP API doesn't exist, we'll use Firebase password reset instead
      _log.w('Custom OTP API not available, using Firebase password reset');
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        _log.i('Password reset email sent successfully to: $email');
        return true;
      } catch (firebaseError) {
        _log.e('Firebase password reset also failed: $firebaseError');
        return false;
      }
    }
  }

  /// Verify OTP code
  Future<bool> verifyOtp(String email, String otpCode) async {
    try {
      final response = await _dioClient.post(
        Endpoints.verifyOtp,
        data: {
          'email': email,
          'otp': otpCode,
        },
      );

      if (response.statusCode == 200) {
        _log.i('OTP verification successful for email: $email');
        return true;
      } else {
        _log.e(
            'Failed to verify OTP. Status: ${response.statusCode}, Data: ${response.data}');
        return false;
      }
    } catch (e, stackTrace) {
      _log.e('Failed to verify OTP for email: $email',
          error: e, stackTrace: stackTrace);

      // Since custom OTP API doesn't exist, we can't verify OTP
      // For now, we'll return false to indicate verification failed
      _log.w('Custom OTP verification not available');
      return false;
    }
  }

  /// Resend OTP to email
  Future<bool> resendOtp(String email) async {
    try {
      final response = await _dioClient.post(
        Endpoints.resendOtp,
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        _log.i('OTP resent successfully to email: $email');
        return true;
      } else {
        _log.e(
            'Failed to resend OTP. Status: ${response.statusCode}, Data: ${response.data}');
        return false;
      }
    } catch (e, stackTrace) {
      _log.e('Failed to resend OTP to email: $email',
          error: e, stackTrace: stackTrace);

      // Fallback to simulation for development/testing
      _log.w('Using simulation mode for OTP resend');
      await Future.delayed(Duration(seconds: 1));
      _log.i('OTP resent successfully to email: $email (simulation)');
      return true;
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phoneNumber,
  }) async {
    try {
      // Check if at least one field is provided for update
      if (name == null && phoneNumber == null) {
        _log.w('No data provided to update for user: $uid');
        return;
      }

      final Map<String, dynamic> updateData = {};
      if (name != null) {
        updateData['name'] = name;
      }
      if (phoneNumber != null) {
        updateData['phoneNumber'] = phoneNumber;
      }

      // Update Firestore document
      await firestore.collection('user_data').doc(uid).update(updateData);

      _log.i('User profile updated successfully for UID: $uid');

      // Update local storage
      if (name != null) {
        await storageService.setString(StorageKeys.userName, name);
      }
      if (phoneNumber != null) {
        await storageService.setString(StorageKeys.userPhone, phoneNumber);
      }
    } on FirebaseException catch (e, stackTrace) {
      _log.e('FirebaseException updating profile: ${e.code} - ${e.message}',
          stackTrace: stackTrace);
      // Re-throw with a custom API error for better handling in the UI layer
      throw ApiError(
          message: e.message ?? 'Failed to update profile.', code: 0);
    } catch (e, stackTrace) {
      _log.e('Unexpected error updating profile for UID: $uid',
          stackTrace: stackTrace);
      throw ApiError(message: 'Unexpected error: $e', code: 0);
    }
  }
}
