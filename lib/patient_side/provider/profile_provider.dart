import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Model for the detailed patient profile
class PatientProfile {
  final String fullName;
  final String phoneNumber;
  final String dateOfBirth;
  final String weightKg;
  final String doctorName;

  PatientProfile({
    required this.fullName,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.weightKg,
    required this.doctorName,
  });
}

class ProfileProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  PatientProfile? _patientProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  PatientProfile? get patientProfile => _patientProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches the complete patient profile, including the doctor's name.
  Future<void> fetchPatientProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = "No user logged in.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch the patient's user document
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists || userDoc.data() == null) {
        throw Exception("User profile not found in the database.");
      }
      final userData = userDoc.data()!;

      // --- THE DEFINITIVE FIX IS HERE ---

      // 2. Safely get the doctor's name
      String doctorName = 'Not Assigned'; // Default value
      // Check if the 'consultingDoctorId' field exists AND is not null
      if (userData.containsKey('consultingDoctorId') &&
          userData['consultingDoctorId'] != null) {
        final doctorId = userData['consultingDoctorId'];
        final doctorDoc =
            await _firestore.collection('doctors').doc(doctorId).get();
        if (doctorDoc.exists && doctorDoc.data() != null) {
          doctorName = doctorDoc.data()!['fullName'] ?? 'N/A';
        }
      }

      // 3. Safely format the date for display
      String formattedDob = 'Not Provided';
      if (userData.containsKey('dateOfBirth') &&
          userData['dateOfBirth'] != null) {
        final dobTimestamp = userData['dateOfBirth'] as Timestamp;
        final dob = dobTimestamp.toDate();
        formattedDob =
            "${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}";
      }

      // 4. Build the profile with safe fallbacks for every field
      _patientProfile = PatientProfile(
        fullName: userData['fullName'] ?? 'No Name Provided',
        phoneNumber: userData['phoneNumber'] ?? 'No Phone Provided',
        dateOfBirth: formattedDob,
        weightKg: (userData['weightKg'] ?? 0).toString(),
        doctorName: doctorName,
      );
    } catch (e) {
      _errorMessage = "Failed to load profile. Please try again.";
      debugPrint("Detailed Error: $e"); // For your debugging
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
