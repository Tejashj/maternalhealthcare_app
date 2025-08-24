import 'package:flutter/foundation.dart';

// Mock data models
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
  // Private state
  bool _isVitalsLoading = false;
  bool _isFetalDataLoading = false;
  List<Vital> _vitals = [];
  List<FetalData> _fetalData = [];

  // Getters to expose state to the UI
  bool get isVitalsLoading => _isVitalsLoading;
  bool get isFetalDataLoading => _isFetalDataLoading;
  List<Vital> get vitals => _vitals;
  List<FetalData> get fetalData => _fetalData;

  PatientDataProvider() {
    // Fetch initial data when the provider is created
    fetchVitals();
    fetchFetalData();
  }

  // --- Business Logic ---

  Future<void> fetchVitals() async {
    _isVitalsLoading = true;
    notifyListeners(); // Notify UI to show a loading indicator

    // Simulate a network request
    await Future.delayed(const Duration(seconds: 1));

    _vitals = [
      Vital(name: 'Heart Rate', value: '82 bpm'),
      Vital(name: 'Blood Pressure', value: '120/80 mmHg'),
      Vital(name: 'SpO2', value: '98%'),
      Vital(name: 'Temperature', value: '37.0°C'),
    ];
    _isVitalsLoading = false;
    notifyListeners(); // Notify UI that data is ready
  }

  Future<void> fetchFetalData() async {
    _isFetalDataLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _fetalData = [
      FetalData(name: 'FHR', value: '140 bpm'),
      FetalData(name: 'UC', value: '2 per 10 min'),
    ];
    _isFetalDataLoading = false;
    notifyListeners();
  }
}
