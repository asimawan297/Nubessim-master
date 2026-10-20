
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static const String clientId =
      '472345055409-30l2mah194rc1a8ss0eous1udm17v9ra.apps.googleusercontent.com';

  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // // Obtain the auth details from the request
    // final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // // Create a new credential
    // final credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth?.accessToken,
    //   idToken: googleAuth?.idToken,
    // );

    // // Once signed in, return the UserCredential
    // return await FirebaseAuth.instance.signInWithCredential(credential);
    try {
      await signOut();
      // Initialize client ID for Android or web (if needed)
      // await GoogleSignIn.initialize(
      //   clientId: Platform.isAndroid ? clientId : null,
      // );
      // debugger();
      // 🔹 Use signIn(), not authenticate()
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // debugger();
      if (googleUser == null) {
        return null;
      }


      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Debug info
      if (userCredential.user != null) {
      }

      return userCredential;
    }
    //  on GoogleSignInException catch (e) {
    //   if (e.code == GoogleSignInExceptionCode.canceled) {
    //     print('Google Sign-In cancelled by user');
    //     return null;
    //   }
    //   print('GoogleSignInException: ${e.code}');
    //   rethrow;
    // }
    on PlatformException catch (e) {
      // 👇 Catch the cancellation case cleanly
      // debugger();
      if (e.code == 'sign_in_canceled' ||
          e.code == 'popup_closed_by_user' ||
          e.message?.contains('12501') == true) {
        // print('Google Sign-In cancelled by user (PlatformException)');
        return null;
      }

      // print('PlatformException during Google Sign-In: $e');
      rethrow;
    } on FirebaseAuthException catch (e) {
      // print('FirebaseAuthException during Google Sign-In: ${e.code}');
      rethrow;
    } catch (e) {
      // print('General Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
