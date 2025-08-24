import 'package:flutter/material.dart';
import 'package:maternalhealthcare/doctor_side/screens/doctor_home.dart';

class DoctorLoginScreen extends StatelessWidget {
  const DoctorLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Basic login UI, replace with your actual authentication logic
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const DoctorHomeScreen(),
                ),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('Login as Doctor'),
          ),
        ),
      ),
    );
  }
}
