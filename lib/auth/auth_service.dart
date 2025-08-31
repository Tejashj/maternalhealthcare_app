import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// A simple class to hold user profile data for the AuthWrapper
class UserProfile {
  final String uid;
  final String? fullName;
  final String role;
  UserProfile({required this.uid, this.fullName, required this.role});
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Core Properties ---
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // --- Authentication Methods (Called by UI) ---

  /// Triggers the Firebase phone authentication flow.
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

  /// Signs the user in with a Firebase credential.
  Future<UserCredential?> signInWithCredential(
    AuthCredential credential,
  ) async {
    return await _auth.signInWithCredential(credential);
  }

  /// Signs the user in manually with the OTP code.
  Future<UserCredential?> signInWithSmsCode(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await signInWithCredential(credential);
    } catch (e) {
      debugPrint("Error in signInWithSmsCode: $e");
      return null;
    }
  }

  /// Signs the user out from Firebase.
  Future<void> signOut() async {
    await _auth.signOut();
    debugPrint("✅ User signed out from Firebase.");
  }

  // --- Profile Management Methods ---

  /// Fetches the user's profile from the Firestore 'users' collection.
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (!docSnapshot.exists) {
        return null; // Profile doesn't exist
      }
      final data = docSnapshot.data()!;
      return UserProfile(
        uid: uid,
        fullName: data['fullName'],
        role: data['role'],
      );
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
      return null;
    }
  }

  /// Creates the patient's profile in Firestore after onboarding.
  Future<void> createPatientProfile({
    required String uid,
    required String phoneNumber,
    required String fullName,
    required DateTime dateOfBirth,
    required double weight,
    required String selectedDoctorId,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'phoneNumber': phoneNumber,
        'fullName': fullName,
        'dateOfBirth': Timestamp.fromDate(dateOfBirth),
        'weightKg': weight,
        'consultingDoctorId': selectedDoctorId,
        'role': 'patient',
      });
    } catch (e) {
      debugPrint('Error creating patient profile: $e');
      rethrow;
    }
  }
}
