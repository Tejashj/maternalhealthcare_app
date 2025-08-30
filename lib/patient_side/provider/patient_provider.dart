import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model for a Doctor
class Doctor {
  final String id;
  final String fullName;
  Doctor({required this.id, required this.fullName});
}

// Your existing data models
class Vital {
  final String name;
  final String value;
  Vital({required this.name, required this.value});
}

class FetalData {
  final String name;
  final String value;
  FetalData({required this.name, required this.value});
}

class PatientDataProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- Private State ---
  bool _isVitalsLoading = false;
  bool _isFetalDataLoading = false;
  List<Vital> _vitals = [];
  List<FetalData> _fetalData = [];

  // New state for fetching doctors for the onboarding screen
  List<Doctor> _doctors = [];
  bool _isLoadingDoctors = false;

  // --- Getters to expose state to the UI ---
  bool get isVitalsLoading => _isVitalsLoading;
  bool get isFetalDataLoading => _isFetalDataLoading;
  List<Vital> get vitals => _vitals;
  List<FetalData> get fetalData => _fetalData;
  List<Doctor> get doctors => _doctors;
  bool get isLoadingDoctors => _isLoadingDoctors;

  PatientDataProvider() {
    // Fetch initial data when the provider is created
    fetchVitals();
    fetchFetalData();
  }

  // --- Onboarding Logic ---

  Future<void> fetchDoctors() async {
    if (_doctors.isNotEmpty) return; // Don't fetch if already loaded

    _isLoadingDoctors = true;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> data = await _supabase
          .from('doctors')
          .select('id, full_name');

      _doctors =
          data.map((doc) {
            return Doctor(id: doc['id'], fullName: doc['full_name']);
          }).toList();
    } catch (e) {
      debugPrint("Error fetching doctors: $e");
    } finally {
      _isLoadingDoctors = false;
      notifyListeners();
    }
  }

  // --- Business Logic ---

  Future<void> fetchVitals() async {
    _isVitalsLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    // Added Heart Rate to the initial list
    _vitals = [
      Vital(name: 'Blood Pressure', value: '-- mmHg'),
      Vital(name: 'Heart Rate', value: '-- bpm'),
    ];
    _isVitalsLoading = false;
    notifyListeners();
  }

  Future<void> fetchFetalData() async {
    _isFetalDataLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _fetalData = [FetalData(name: 'FHR', value: '-- bpm')];
    _isFetalDataLoading = false;
    notifyListeners();
  }

  // ** CORRECTED METHOD: To update the heart rate from the monitoring screen **
  void updateHeartRate(double averageBpm) {
    int index = _vitals.indexWhere((vital) => vital.name == 'Heart Rate');
    String newBpmValue = '${averageBpm.round()} bpm';

    if (index != -1) {
      // Update the existing 'Heart Rate' vital
      _vitals[index] = Vital(name: 'Heart Rate', value: newBpmValue);
    } else {
      // Or add it if it doesn't exist for some reason
      _vitals.add(Vital(name: 'Heart Rate', value: newBpmValue));
    }
    notifyListeners();
  }
}
