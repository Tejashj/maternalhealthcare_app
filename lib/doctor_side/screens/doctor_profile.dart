import 'package:flutter/material.dart';
import 'package:maternalhealthcare/doctor_side/provider/doctor_provider.dart';
import 'package:provider/provider.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger the profile fetch when the screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DoctorDataProvider>(
        context,
        listen: false,
      ).fetchDoctorProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: Consumer<DoctorDataProvider>(
        builder: (context, doctorData, child) {
          if (doctorData.isLoadingProfile) {
            return const Center(child: CircularProgressIndicator());
          }
          if (doctorData.profile == null) {
            return const Center(child: Text("Could not load doctor profile."));
          }

          final profile = doctorData.profile!;

          return Padding(
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
                            Icons
                                .medical_services_outlined, // More relevant icon
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
                              style: Theme.of(context).textTheme.headlineSmall
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
                    // Placeholder content from your wireframe
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
                      width: 200, // This won't have an effect due to stretch
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
        },
      ),
    );
  }
}
