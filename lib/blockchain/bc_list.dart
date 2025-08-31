import 'package:flutter/material.dart';

class PatientListPage extends StatelessWidget {
  // This page will receive the function that fetches data from the blockchain
  final Future<List<Map<String, dynamic>>> Function() fetchPatients;

  const PatientListPage({super.key, required this.fetchPatients});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Patient Records"),
      ),
      // FutureBuilder automatically handles the loading and error states for us
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPatients(),
        builder: (context, snapshot) {
          // 1. Show a loading spinner while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Show an error message if something went wrong
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching data: ${snapshot.error}"));
          }
          // 3. Show a message if no patients are found
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No patient records found."));
          }

          // 4. If data is available, display it in a list
          final patients = snapshot.data!;

          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Patient ID: ${patient['id']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Divider(),
                      Text("Name: ${patient['name']}"),
                      Text("Age: ${patient['age']}"),
                      const SizedBox(height: 10),
                      // Display the ultrasound image from the Supabase URL
                      if (patient['ultrasoundUrl'] != null &&
                          patient['ultrasoundUrl'].isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            patient['ultrasoundUrl'],
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            // Show a loading indicator while the image downloads
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            // Show an error icon if the image URL is broken
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 40,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}