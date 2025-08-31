import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Data Models ---

class Doctor {
  final String id;
  final String fullName;

  Doctor({required this.id, required this.fullName});

  factory Doctor.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Doctor(id: doc.id, fullName: data['fullName'] ?? '');
  }
}

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Private State ---
  bool _isLoadingDoctors = false;
  List<Doctor> _doctors = [];
  bool _isVitalsLoading = false;
  List<Vital> _vitals = [];
  bool _isFetalDataLoading = false;
  List<FetalData> _fetalData = [];

  // --- Getters to expose state to the UI ---
  bool get isLoadingDoctors => _isLoadingDoctors;
  List<Doctor> get doctors => _doctors;
  bool get isVitalsLoading => _isVitalsLoading;
  List<Vital> get vitals => _vitals;
  bool get isFetalDataLoading => _isFetalDataLoading;
  List<FetalData> get fetalData => _fetalData;

  // ** FIX: The constructor is now empty. **
  // We no longer fetch data automatically. The UI will trigger it.
  PatientDataProvider();

  /// Fetches the list of doctors from the Firestore 'doctors' collection for the onboarding screen.
  Future<void> fetchDoctors() async {
    // Prevent refetching if already loaded or currently loading
    if (_isLoadingDoctors || _doctors.isNotEmpty) return;

    _isLoadingDoctors = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('doctors').get();
      _doctors = snapshot.docs.map((doc) => Doctor.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint("Error fetching doctors: $e");
      _doctors = [];
    } finally {
      _isLoadingDoctors = false;
      notifyListeners();
    }
  }

  /// Fetches the latest vitals data for the current patient from Firestore.
  Future<void> fetchVitals() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isVitalsLoading = true;
    notifyListeners();

    try {
      // Fetch the latest blood pressure reading
      final bpSnapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('vitals_history')
              .where('type', isEqualTo: 'Blood Pressure')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      // Fetch the latest heart rate reading
      final hrSnapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('vitals_history')
              .where('type', isEqualTo: 'Heart Rate')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      final bpValue =
          bpSnapshot.docs.isNotEmpty
              ? bpSnapshot.docs.first['value']
              : '-- mmHg';
      final hrValue =
          hrSnapshot.docs.isNotEmpty
              ? hrSnapshot.docs.first['value']
              : '-- bpm';

      _vitals = [
        Vital(name: 'Blood Pressure', value: bpValue),
        Vital(name: 'Heart Rate', value: hrValue),
      ];
    } catch (e) {
      debugPrint("Error fetching vitals: $e");
      _vitals = [
        Vital(name: 'Blood Pressure', value: 'Error'),
        Vital(name: 'Heart Rate', value: 'Error'),
      ];
    } finally {
      _isVitalsLoading = false;
      notifyListeners();
    }
  }

  /// Fetches the latest fetal data for the current patient from Firestore.
  Future<void> fetchFetalData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isFetalDataLoading = true;
    notifyListeners();

    try {
      // Fetch the latest Fetal Heart Rate reading
      final fhrSnapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('fetal_data_history')
              .where('type', isEqualTo: 'FHR')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      final fhrValue =
          fhrSnapshot.docs.isNotEmpty
              ? fhrSnapshot.docs.first['value']
              : '-- bpm';

      _fetalData = [FetalData(name: 'FHR', value: fhrValue)];
    } catch (e) {
      debugPrint("Error fetching fetal data: $e");
      _fetalData = [FetalData(name: 'FHR', value: 'Error')];
    } finally {
      _isFetalDataLoading = false;
      notifyListeners();
    }
  }

  /// Updates the heart rate vital locally and saves the new reading to Firestore.
  void updateHeartRate(double averageBpm) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final newBpmValue = '${averageBpm.toStringAsFixed(0)} bpm';

    // Update local state immediately for a responsive UI
    int index = _vitals.indexWhere((vital) => vital.name == 'Heart Rate');
    if (index != -1) {
      _vitals[index] = Vital(name: 'Heart Rate', value: newBpmValue);
    } else {
      _vitals.add(Vital(name: 'Heart Rate', value: newBpmValue));
    }
    notifyListeners();

    // Persist the new reading to Firestore in the background
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('vitals_history')
          .add({
            'type': 'Heart Rate',
            'value': newBpmValue,
            'timestamp': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint("Error saving heart rate to Firestore: $e");
      // Optionally, handle the error, e.g., show a snackbar
    }
  }
}
