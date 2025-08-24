import 'package:flutter/foundation.dart';

// Mock data models
class Patient {
  final String id;
  final String name;
  Patient({required this.id, required this.name});
}

class Appointment {
  final String id;
  final String patientName;
  final String date;
  final String time;
  Appointment({
    required this.id,
    required this.patientName,
    required this.date,
    required this.time,
  });
}

class DoctorProfile {
  final String name;
  final String licenseId;
  DoctorProfile({required this.name, required this.licenseId});
}

class DoctorDataProvider with ChangeNotifier {
  // Private state
  bool _isLoadingPatients = false;
  bool _isLoadingAppointments = false;
  bool _isLoadingProfile = false;

  List<Patient> _patients = [];
  List<Appointment> _appointments = [];
  DoctorProfile? _profile;

  // Getters to expose state to the UI
  bool get isLoadingPatients => _isLoadingPatients;
  bool get isLoadingAppointments => _isLoadingAppointments;
  bool get isLoadingProfile => _isLoadingProfile;

  List<Patient> get patients => _patients;
  List<Appointment> get appointments => _appointments;
  DoctorProfile? get profile => _profile;

  DoctorDataProvider() {
    // Fetch initial data when the provider is created
    fetchPatients();
    fetchAppointments();
    fetchDoctorProfile();
  }

  // --- Business Logic ---

  Future<void> fetchPatients() async {
    _isLoadingPatients = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
    _patients = List.generate(
      8,
      (i) => Patient(id: '$i', name: 'Patient ${i + 1}'),
    );
    _isLoadingPatients = false;
    notifyListeners();
  }

  Future<void> fetchAppointments() async {
    _isLoadingAppointments = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
    _appointments = [
      Appointment(
        id: '1',
        patientName: 'Patient 1',
        date: '25 Aug 2025',
        time: '10:00 AM',
      ),
      Appointment(
        id: '2',
        patientName: 'Patient 2',
        date: '25 Aug 2025',
        time: '11:30 AM',
      ),
      Appointment(
        id: '3',
        patientName: 'Patient 3',
        date: '26 Aug 2025',
        time: '09:00 AM',
      ),
      Appointment(
        id: '4',
        patientName: 'Patient 4',
        date: '26 Aug 2025',
        time: '12:00 PM',
      ),
    ];
    _isLoadingAppointments = false;
    notifyListeners();
  }

  Future<void> fetchDoctorProfile() async {
    _isLoadingProfile = true;
    notifyListeners();
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network call
    _profile = DoctorProfile(name: 'Dr. Alex Ray', licenseId: '123456789');
    _isLoadingProfile = false;
    notifyListeners();
  }

  Future<void> cancelAllAppointments() async {
    _isLoadingAppointments = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    _appointments = []; // Clear the list
    _isLoadingAppointments = false;
    notifyListeners();
  }
}
