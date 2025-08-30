import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'record_button.dart';
import 'take_appointment.dart'; // <-- Import your appointment page

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  bool _showReports = false;
  late Future<List<String>> _imageUrlsFuture;

  @override
  void initState() {
    super.initState();
    _imageUrlsFuture = _fetchAllImages();
  }

  // Fetch all image URLs from the folder
  Future<List<String>> _fetchAllImages() async {
    try {
      final storage = Supabase.instance.client.storage;

      // List all files in 'prescription' folder
      final List<FileObject> files = await storage
          .from('prescription_documents')
          .list(path: 'prescription');

      if (files.isEmpty) return [];

      // Map each file to its public URL
      final List<String> urls =
          files
              .map(
                (file) => storage
                    .from('prescription_documents')
                    .getPublicUrl('prescription/${file.name}'),
              )
              .toList();

      return urls;
    } catch (e) {
      print('Error fetching images: $e');
      return [];
    }
  }

  // Refresh all images when user taps
  void _refreshImages() {
    setState(() {
      _showReports = true;
      _imageUrlsFuture = _fetchAllImages();
    });
  }

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
            onPressed: () {},
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
              title: 'Vitals and Fetal History',
              iconData: Icons.history_edu_rounded,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            RecordButton(
              title: 'View Reports',
              iconData: Icons.article_outlined,
              onTap: _refreshImages,
            ),
            const SizedBox(height: 12),
            if (_showReports)
              FutureBuilder<List<String>>(
                future: _imageUrlsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No reports found.'));
                  } else {
                    return Column(
                      children:
                          snapshot.data!
                              .map(
                                (url) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.broken_image,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Failed to load image',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Container(
                                          height: 200,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    );
                  }
                },
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
                  child: ActionTile(
                    title: 'Take Appointment',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TakeAppointmentPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
        margin: EdgeInsets.zero,
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
