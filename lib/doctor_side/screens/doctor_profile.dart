import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/doctor_provider.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doctorData = Provider.of<DoctorDataProvider>(context);
    final profile = doctorData.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
      ),
      body:
          doctorData.isLoadingProfile || profile == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 35,
                              backgroundColor: Color(0xFFE0E0E0),
                              child: Icon(
                                Icons.person_outline,
                                size: 40,
                                color: Color(0xFF757575),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'License ID: ${profile.licenseId}',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 10,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
