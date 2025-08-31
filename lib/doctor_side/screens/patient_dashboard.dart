import 'package:flutter/material.dart';
import 'package:maternalhealthcare/doctor_side/provider/doctor_provider.dart';
import 'package:maternalhealthcare/doctor_side/screens/PatientDetailsScreen.dart';
import 'package:maternalhealthcare/doctor_side/widgets/patient_card.dart';
import 'package:provider/provider.dart';

class PatientsDashboardScreen extends StatefulWidget {
  const PatientsDashboardScreen({super.key});

  @override
  State<PatientsDashboardScreen> createState() =>
      _PatientsDashboardScreenState();
}

class _PatientsDashboardScreenState extends State<PatientsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger the fetch for the list of patients when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DoctorDataProvider>(context, listen: false).fetchPatients();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen for changes in the provider
    return Consumer<DoctorDataProvider>(
      builder: (context, doctorData, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Patients Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 1,
            foregroundColor: Colors.black87,
          ),
          body:
              doctorData.isLoadingPatients
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                    onRefresh: () => doctorData.fetchPatients(),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: doctorData.patients.length,
                      itemBuilder: (context, index) {
                        final patient = doctorData.patients[index];
                        return PatientCard(
                          // ** THE FIX: Use 'fullName' instead of 'name' **
                          patientName: patient.fullName,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        PatientDetailScreen(patient: patient),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
        );
      },
    );
  }
}
