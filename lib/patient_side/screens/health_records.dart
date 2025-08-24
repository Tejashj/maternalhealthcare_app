import 'package:flutter/material.dart';

import '../widgets/record_button.dart';

class HealthRecordsScreen extends StatelessWidget {
  const HealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health records',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
        actions: [
          TextButton.icon(
            onPressed: () {
              // Handle Help action
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
            label: const Text('Help'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            RecordButton(
              title: 'vitals and fetal history',
              iconData: Icons.history_edu_rounded,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            RecordButton(
              title: 'View Reports',
              iconData: Icons.article_outlined,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            RecordButton(
              title: 'View Prescriptions',
              iconData: Icons.medication_outlined,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ActionTile(
                    title: 'Call Doctor or Physician',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ActionTile(title: 'Take Appointment', onTap: () {}),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// A simple widget for the bottom action tiles
class ActionTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const ActionTile({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: EdgeInsets.zero, // Remove default card margin
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
