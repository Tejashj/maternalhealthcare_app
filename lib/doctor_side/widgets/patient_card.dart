import 'package:flutter/material.dart';

class PatientCard extends StatelessWidget {
  final String patientName;
  final VoidCallback onTap;

  const PatientCard({
    super.key,
    required this.patientName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFE0E0E0), // Grey color from wireframe
                child: Icon(
                  Icons.person_outline,
                  size: 30,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                patientName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              // Placeholders for the grey lines
              Container(
                height: 6,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 6,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
