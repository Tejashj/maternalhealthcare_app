import 'package:flutter/material.dart';
import 'package:maternalhealthcare/auth/profile.dart';
import 'package:maternalhealthcare/doc_prescription/first_page.dart';
import 'package:maternalhealthcare/patient_side/screens/govt_schemes.dart';
import 'package:maternalhealthcare/patient_side/screens/lib_and_relax.dart';
import 'diet_screen.dart';
import 'vaccination_screen.dart';
import '../widgets/feature_button.dart';
import 'package:maternalhealthcare/patient_side/screens/duedate.dart';
import 'package:maternalhealthcare/patient_side/screens/ovulation.dart';

class FeaturesDashboardScreen extends StatelessWidget {
  const FeaturesDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Features Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Manage Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scrollable content with bottom padding to avoid overlap
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom:
                  100.0, // Add bottom padding to prevent overlap with fixed buttons
            ),
            child: Column(
              children: [
                FeatureButton(
                  title: 'Prescription analysis',
                  imagePath: 'assets/images/prescription.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                FeatureButton(
                  title: 'Diet & Exercises',
                  imagePath: 'assets/images/diet_exercise.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PatientDietScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                FeatureButton(
                  title: 'Calculate Due Date',
                  imagePath: 'assets/images/duedate.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DueDateCalculator(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                FeatureButton(
                  title: 'Vaccination updates',
                  imagePath: 'assets/images/vaccination.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VaccinationPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                FeatureButton(
                  title: 'Ovulation & Cycle Tracker',
                  imagePath: 'assets/images/ovulation.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OvulationCalculatorPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                FeatureButton(
                  title: 'Government schemes',
                  imagePath: 'assets/images/government.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GovtSchemes(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                FeatureButton(
                  title: 'Library & Relaxation',
                  imagePath: 'assets/images/library.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecommendationsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Fixed bottom buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfilePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Icon(
                          Icons.sos_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfilePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
