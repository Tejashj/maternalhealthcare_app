import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/patient_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
                // Vitals Monitoring Card
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
                          builder: (context) => const VitalsScreen(),
                        ),
                      ),
                  cardType: CardType.monitoring,
                  isVitalsCard: true,
                ),
                const SizedBox(height: 8),

                // Fetal Monitoring Card
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
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FetalMonitoringScreen(),
                        ),
                      ),
                  cardType: CardType.monitoring,
                  isFetalCard: true,
                ),
                const SizedBox(height: 8),

                // Fetal Position Detection Card
                UnifiedCard(
                  title: 'Fetal Position Detection',
                  buttonText: 'Analyze Position',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FetalPositionScreen(),
                        ),
                      ),
                  cardType: CardType.action,
                ),
                const SizedBox(height: 8),

                // Ultrasound Report Analysis Card
                UnifiedCard(
                  title: 'Ultrasound Report Analysis',
                  buttonText: 'Upload & Analyze',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const UltrasoundAnalysisScreen(),
                        ),
                      ),
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

// Unified card that can handle both monitoring and action types
enum CardType { monitoring, action }

class UnifiedCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final CardType cardType;

  // For monitoring cards
  final bool? isLoading;
  final List<Widget>? dataWidgets;
  final bool isVitalsCard;
  final bool isFetalCard;

  // For action cards
  final String? buttonText;

  const UnifiedCard({
    super.key,
    required this.title,
    required this.onTap,
    required this.cardType,
    this.isLoading,
    this.dataWidgets,
    this.buttonText,
    this.isVitalsCard = false,
    this.isFetalCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isVitalsCard ? 280 : 180, // Increased vitals card height more
      child: Card(
        elevation: 2, // Added elevation back
        color: Colors.white, // White background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row (simplified - no refresh button)
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Content area
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
        } else {
          if (isVitalsCard || isFetalCard) {
            // Static display for both monitoring cards (no scrolling)
            return Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: dataWidgets ?? [],
            );
          } else {
            // This case shouldn't occur with current setup
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: dataWidgets ?? [],
              ),
            );
          }
        }
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

// DataChip widget (moved from dashboard)
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

// Placeholder screens for navigation
class VitalsScreen extends StatelessWidget {
  const VitalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vitals Monitoring'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: const Center(
        child: Text(
          'Vitals Monitoring Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class FetalMonitoringScreen extends StatelessWidget {
  const FetalMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fetal Monitoring'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: const Center(
        child: Text(
          'Fetal Monitoring Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class FetalPositionScreen extends StatelessWidget {
  const FetalPositionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fetal Position Detection'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: const Center(
        child: Text(
          'Fetal Position Detection Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class UltrasoundAnalysisScreen extends StatelessWidget {
  const UltrasoundAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ultrasound Analysis'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: const Center(
        child: Text(
          'Ultrasound Analysis Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
