import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream for auth state changes (handles automatic persistence)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      debugPrint("1. Starting Google Sign-In process...");
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        debugPrint("   -> Google Sign-In was cancelled by the user.");
        return null;
      }
      debugPrint("2. Google account selected: ${googleUser.email}");

      debugPrint("3. Obtaining Google Auth credentials...");
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      debugPrint("   -> Google Auth credentials obtained successfully.");

      debugPrint("4. Creating Firebase credential...");
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      debugPrint("   -> Firebase credential created.");

      debugPrint("5. Signing in to Firebase with credential...");
      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint(
        "✅ Firebase sign-in successful! UID: ${userCredential.user?.uid}",
      );
      return userCredential;
    } catch (e) {
      debugPrint("❌ ERROR during Google sign-in: $e");
      return null;
    }
  }

  // Phone Number Sign In (Verification part 1)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // Sign in with SMS code (Verification part 2)
  Future<UserCredential?> signInWithSmsCode(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
