import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  final String patientName;
  final String date;
  final String time;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.patientName,
    required this.date,
    required this.time,
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
          child: Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFE0E0E0),
                child: Icon(
                  Icons.person_outline,
                  size: 24,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  patientName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Date: $date',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Time: $time',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
