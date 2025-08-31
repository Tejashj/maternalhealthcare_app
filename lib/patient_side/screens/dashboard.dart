import 'package:flutter/material.dart';
import 'package:maternalhealthcare/patient_side/provider/patient_provider.dart';
import 'package:maternalhealthcare/patient_side/screens/babypositiondetection.dart';
import 'package:provider/provider.dart';
import 'vitals_monitoring_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger the data fetch from the UI when it loads.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PatientDataProvider>(context, listen: false);
      provider.fetchVitals();
      provider.fetchFetalData();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                UnifiedCard(
                  title: 'Vitals Monitoring',
                  isLoading: patientData.isVitalsLoading,
                  dataWidgets:
                      patientData.vitals
                          .map(
                            (vital) =>
                                DataChip(label: vital.name, value: vital.value),
                          )
                          .toList(),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VitalsMonitoringScreen(),
                        ),
                      ),
                  cardType: CardType.monitoring,
                ),
                const SizedBox(height: 8),
                UnifiedCard(
                  title: 'Fetal Monitoring',
                  isLoading: patientData.isFetalDataLoading,
                  dataWidgets:
                      patientData.fetalData
                          .map(
                            (data) =>
                                DataChip(label: data.name, value: data.value),
                          )
                          .toList(),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Fetal Monitoring Screen not yet implemented.',
                        ),
                      ),
                    );
                  },
                  cardType: CardType.monitoring,
                ),
                const SizedBox(height: 8),
                UnifiedCard(
                  title: 'Baby Head Classification',
                  buttonText: 'Classify Head',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BabyHeadClassifier(),
                      ),
                    );
                  },
                  cardType: CardType.action,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- Reusable Widgets ---
enum CardType { monitoring, action }

class UnifiedCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final CardType cardType;
  final bool? isLoading;
  final List<Widget>? dataWidgets;
  final String? buttonText;

  const UnifiedCard({
    super.key,
    required this.title,
    required this.onTap,
    required this.cardType,
    this.isLoading,
    this.dataWidgets,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Card(
        elevation: 0.5,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (cardType) {
      case CardType.monitoring:
        if (isLoading == true) {
          return const Center(child: CircularProgressIndicator());
        }
        return Wrap(spacing: 8.0, runSpacing: 8.0, children: dataWidgets ?? []);
      case CardType.action:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(buttonText ?? 'Action'),
              ),
            ),
            const Spacer(),
          ],
        );
    }
  }
}

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
