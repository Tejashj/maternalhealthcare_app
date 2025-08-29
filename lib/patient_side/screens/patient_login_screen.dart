import 'package:flutter/material.dart';
import 'package:maternalhealthcare/patient_side/screens/home.dart';

class PatientLoginScreen extends StatelessWidget {
  const PatientLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Basic login UI, replace with your actual authentication logic
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const PatientHomeScreen(),
                ),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('Login as Patient'),
          ),
        ),
      ),
    );
  }
}
