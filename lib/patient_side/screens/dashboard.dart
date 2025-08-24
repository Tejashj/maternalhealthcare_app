import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/patient_provider.dart';
import '../widgets/action_card.dart';
import '../widgets/monitoring_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to listen to changes in PatientDataProvider
    return Consumer<PatientDataProvider>(
      builder: (context, patientData, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Real time dashboard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 1,
            foregroundColor: Colors.black87,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Vitals Monitoring Card
                MonitoringCard(
                  title: 'Vitals Monitoring',
                  isLoading: patientData.isVitalsLoading,
                  onRefresh: () => patientData.fetchVitals(),
                  dataWidgets:
                      patientData.vitals
                          .map(
                            (vital) =>
                                DataChip(label: vital.name, value: vital.value),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),

                // Fetal Monitoring Card
                MonitoringCard(
                  title: 'Fetal Monitoring',
                  isLoading: patientData.isFetalDataLoading,
                  onRefresh: () => patientData.fetchFetalData(),
                  dataWidgets:
                      patientData.fetalData
                          .map(
                            (data) =>
                                DataChip(label: data.name, value: data.value),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),

                // Action cards remain stateless as they don't depend on the provider
                ActionCard(
                  title: 'Fetal Position Detection',
                  buttonText: 'Analyze Position',
                  onButtonPressed: () {},
                ),
                const SizedBox(height: 16),

                ActionCard(
                  title: 'Ultrasound report analysis',
                  buttonText: 'Upload & Analyze',
                  onButtonPressed: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// A styled chip to display data, replacing the old placeholder
class DataChip extends StatelessWidget {
  final String label;
  final String value;
  const DataChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.blue.shade50,
      label: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: Colors.grey[700]),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
