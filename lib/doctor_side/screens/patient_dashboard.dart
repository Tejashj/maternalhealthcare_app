import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/doctor_provider.dart';
import '../widgets/patient_card.dart';

class PatientsDashboardScreen extends StatelessWidget {
  const PatientsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doctorData = Provider.of<DoctorDataProvider>(context);

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
              : GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.85,
                ),
                itemCount: doctorData.patients.length,
                itemBuilder: (context, index) {
                  final patient = doctorData.patients[index];
                  return PatientCard(
                    patientName: patient.name,
                    onTap: () {
                      print('Tapped on ${patient.name}');
                    },
                  );
                },
              ),
    );
  }
}
