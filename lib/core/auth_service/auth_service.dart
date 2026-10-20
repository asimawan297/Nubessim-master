import 'package:firebase_auth/firebase_auth.dart';
import 'package:nubesim/core/exceptions/api_error.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Sign in with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
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
        case 'invalid-credential':
          throw ApiError(message: 'The credentials are invalid', code: 400);
        case 'network-request-failed':
          throw ApiError(message: 'No internet connection.', code: 503);
        default:
          throw ApiError(
              message:
                  'Something went wrong, please try again after some time.',
              code: 0);
      }
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;
}
