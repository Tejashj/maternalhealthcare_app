import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Data Models ---

// Represents a patient in the doctor's dashboard list
class Patient {
  final String id;
  final String fullName;
  final String phoneNumber;

  Patient({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
  });

  factory Patient.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Patient(
      id: doc.id,
      fullName: data['fullName'] ?? 'N/A',
      phoneNumber: data['phoneNumber'] ?? 'N/A',
    );
  }
}

// Represents the logged-in doctor's own profile
class DoctorProfile {
  final String name;
  final String licenseId; // Assuming licenseId is stored in the profile

  DoctorProfile({required this.name, required this.licenseId});

  factory DoctorProfile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return DoctorProfile(
      name: data['fullName'] ?? 'Dr. Name Not Found',
      licenseId:
          data['licenseId'] ?? 'N/A', // Assumes you have a 'licenseId' field
    );
  }
}

class DoctorDataProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- State for Patients List ---
  bool _isLoadingPatients = false;
  List<Patient> _patients = [];
  bool get isLoadingPatients => _isLoadingPatients;
  List<Patient> get patients => _patients;

  // --- State for Doctor's Own Profile ---
  bool _isLoadingProfile = false;
  DoctorProfile? _profile;
  bool get isLoadingProfile => _isLoadingProfile;
  DoctorProfile? get profile => _profile;

  /// Fetches all users with the role 'patient' from Firestore.
  Future<void> fetchPatients() async {
    _isLoadingPatients = true;
    notifyListeners();

    try {
      final snapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'patient')
              .get();
      _patients =
          snapshot.docs.map((doc) => Patient.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint("Error fetching patients: $e");
      _patients = [];
    } finally {
      _isLoadingPatients = false;
      notifyListeners();
    }
  }

  /// Fetches the profile for the currently logged-in doctor.
  Future<void> fetchDoctorProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoadingProfile = true;
    notifyListeners();

    try {
      final docSnapshot =
          await _firestore.collection('users').doc(user.uid).get();
      if (docSnapshot.exists) {
        _profile = DoctorProfile.fromFirestore(docSnapshot);
      }
    } catch (e) {
      debugPrint("Error fetching doctor profile: $e");
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }
}
