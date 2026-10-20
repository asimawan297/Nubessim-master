import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

class AppleSignInService {
  final FirebaseAuth _auth = FirebaseAuth.instance;


Future<UserCredential?> signInWithApple() async {
  try {
    // Firebase Apple provider
    final appleProvider = AppleAuthProvider();

    // Optional scopes for email & name
    appleProvider.addScope('email');
    appleProvider.addScope('name');

    UserCredential userCredential;

    if (Platform.isIOS) {
      // ✅ iOS uses native Apple Sign-In (works perfectly)
      userCredential = await _auth.signInWithProvider(appleProvider);
    } else if (Platform.isAndroid) {
      userCredential = await _auth.signInWithProvider(appleProvider);
    }  else {
      throw Exception("❌ Unsupported platform for Apple Sign-In");
    }

    return userCredential;
  } catch (e, st) {
    
    return null;
  }
}

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
