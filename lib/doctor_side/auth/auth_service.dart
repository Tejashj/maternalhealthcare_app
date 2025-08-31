import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// A dedicated authentication service for handling the unique doctor
/// "claim profile" workflow.
class DoctorAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Verifies if a doctor exists in the whitelist and sends an OTP.
  Future<void> verifyDoctorAndSendOtp({
    required String licenseId,
    required String phoneNumber,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('doctors_whitelist')
              .where('licenseId', isEqualTo: licenseId)
              .where('phoneNumber', isEqualTo: phoneNumber)
              .where('isClaimed', isEqualTo: false)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'not-found-in-whitelist',
          message:
              'Invalid License ID or Phone Number, or the profile has already been claimed.',
        );
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      debugPrint("Error during doctor verification: $e");
      rethrow;
    }
  }

  /// Signs in the doctor with a credential.
  Future<UserCredential?> signInWithCredential(
    AuthCredential credential,
  ) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Error signing in with credential: $e");
      return null;
    }
  }

  /// Creates the doctor's initial profile and claims the license.
  Future<void> createDoctorProfile({
    required String uid,
    required String licenseId,
    required String phoneNumber,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'phoneNumber': phoneNumber,
        'licenseId': licenseId,
        'role': 'doctor',
      });

      final whitelistQuery =
          await _firestore
              .collection('doctors_whitelist')
              .where('licenseId', isEqualTo: licenseId)
              .limit(1)
              .get();

      if (whitelistQuery.docs.isNotEmpty) {
        await whitelistQuery.docs.first.reference.update({'isClaimed': true});
      }
    } catch (e) {
      debugPrint("Error creating doctor profile: $e");
      rethrow;
    }
  }

  /// Updates the doctor's profile with their full name and specialization.
  Future<void> updateDoctorProfileDetails({
    required String fullName,
    required String specialization,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No doctor is signed in.");
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'fullName': fullName,
        'specialization': specialization,
      });
    } catch (e) {
      debugPrint("Error updating doctor details: $e");
      rethrow;
    }
  }

  /// Signs the doctor out from Firebase.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint("✅ Doctor signed out from Firebase.");
    } catch (e) {
      debugPrint("Error signing out doctor: $e");
    }
  }
}
