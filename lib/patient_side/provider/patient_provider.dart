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

    _vitals = [Vital(name: 'Blood Pressure', value: '-- mmHg')];
    _isVitalsLoading = false;
    notifyListeners(); // Notify UI that data is ready
  }

  Future<void> fetchFetalData() async {
    _isFetalDataLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _fetalData = [FetalData(name: 'FHR', value: '-- bpm')];
    _isFetalDataLoading = false;
    notifyListeners();
  }

  // ** NEW METHOD: To update the heart rate from the monitoring screen **
  void updateHeartRate(double averageBpm) {
    // Find the index of the heart rate vital in our list
    int index = _vitals.indexWhere((vital) => vital.name == 'Blood Pressure');
    String newBpmValue = '${averageBpm.toStringAsFixed(0)} mmHg';

    // If a 'Heart Rate' vital exists, update its value
    if (index != -1) {
      _vitals[index] = Vital(name: 'Blood Pressure', value: newBpmValue);
    } else {
      // Otherwise, add it to the list
      _vitals.add(Vital(name: 'Blood Pressure', value: newBpmValue));
    }

    // Announce the change to all listening widgets (like the DashboardScreen)
    notifyListeners();
  }
}
