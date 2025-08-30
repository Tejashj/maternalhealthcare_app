import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final sp.SupabaseClient _supabase = sp.Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  ); // Create single instance

  // --- Core Methods ---

  // Stream for auth state changes (handles automatic persistence)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user from Firebase
  User? get currentUser => _auth.currentUser;

  // --- Sign In / Sign Up Flow ---

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      debugPrint("1. Starting Google Sign-In process...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint("   -> Google Sign-In was cancelled by the user.");
        return null;
      }
      debugPrint("2. Google account selected: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint("3. Signing in to Firebase with credential...");
      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint(
        "✅ Firebase sign-in successful! UID: ${userCredential.user?.uid}",
      );

      // ** SUPABASE BRIDGE **
      debugPrint("4. Bridging to Supabase...");
      final bool supabaseSuccess = await _signInToSupabaseWithFirebaseToken();
      if (!supabaseSuccess) {
        throw Exception("Could not sign in to Supabase.");
      }
      debugPrint("✅ Supabase sign-in successful!");

      return userCredential;
    } catch (e) {
      debugPrint("❌ ERROR during Google sign-in: $e");
      // Clean up on failure
      await signOut();
      return null;
    }
  }

  // Phone Number Sign In (Part 1: Send OTP)
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

  // Phone Number Sign In (Part 2: Verify OTP)
  Future<UserCredential?> signInWithSmsCode(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      debugPrint("1. Signing in to Firebase with SMS code...");
      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint(
        "✅ Firebase sign-in successful! UID: ${userCredential.user?.uid}",
      );

      // ** SUPABASE BRIDGE **
      debugPrint("2. Bridging to Supabase...");
      final bool supabaseSuccess = await _signInToSupabaseWithFirebaseToken();
      if (!supabaseSuccess) {
        throw Exception("Could not sign in to Supabase.");
      }
      debugPrint("✅ Supabase sign-in successful!");

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ ERROR during Firebase phone sign-in: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("❌ ERROR during Supabase bridge: $e");
      await signOut();
      return null;
    }
  }

  // --- Profile Management ---

  // Check if a user profile exists in the Supabase 'users' table
  Future<bool> doesUserExist() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return false;

    try {
      final response =
          await _supabase
              .from('users')
              .select('id')
              .eq('id', firebaseUser.uid)
              .single(); // .single() throws an error if no row is found

      // If we get here, a user was found
      return true;
    } catch (e) {
      // If .single() throws an error, it means no user was found, which is expected for new users.
      debugPrint("User does not exist in Supabase yet. $e");
      return false;
    }
  }

  // Create patient profile in Supabase
  Future<void> createPatientProfile({
    required String name,
    required String dob,
    required double weight,
    required String doctorId,
  }) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw Exception("User is not authenticated with Firebase.");
    }

    try {
      await _supabase.from('users').insert({
        'id': firebaseUser.uid, // Use Firebase UID as the primary key
        'full_name': name,
        'date_of_birth': dob,
        'phone_number': firebaseUser.phoneNumber,
        'role': 'patient',
        'weight_kg': weight,
        'consulting_doctor_id': doctorId,
      });
    } catch (e) {
      debugPrint("Error creating patient profile in Supabase: $e");
      throw Exception("Could not save profile to the database.");
    }
  }

  // --- Sign Out ---

  Future<void> signOut() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      await _supabase.auth.signOut();
      debugPrint("✅ User signed out from all services.");
    } catch (e) {
      debugPrint("❌ Error during sign out: $e");
      throw Exception("Failed to sign out properly");
    }
  }

  // --- Private Helper Methods ---

  // The "Bridge" from Firebase to Supabase
  Future<bool> _signInToSupabaseWithFirebaseToken() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        debugPrint("❌ No Firebase user found");
        return false;
      }

      final idToken = await firebaseUser.getIdToken();
      if (idToken == null) {
        debugPrint("❌ Firebase ID token is null");
        return false;
      }

      final response = await _supabase.functions.invoke(
        'firebase-auth',
        body: {'idToken': idToken},
      );

      if (response.data != null && response.data['error'] != null) {
        debugPrint("❌ Supabase function error: ${response.data['error']}");
        return false;
      }

      await _supabase.auth.setSession(
        response.data['session']['refresh_token'],
      );
      return true;
    } catch (e) {
      debugPrint("❌ Error in Supabase bridge: $e");
      return false;
    }
  }
}
