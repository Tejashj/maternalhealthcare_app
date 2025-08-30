// patient_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientDetailScreen extends StatelessWidget {
  final dynamic patient;

  const PatientDetailScreen({super.key, required this.patient});

  // Ask for permissions
  Future<bool> _askPermissions() async {
    // Check and request storage or photo permissions based on the platform
    if (Platform.isAndroid) {
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
      return await Permission.storage.isGranted;
    } else if (Platform.isIOS) {
      if (await Permission.photos.isDenied) {
        await Permission.photos.request();
      }
      return await Permission.photos.isGranted;
    }
    // For other platforms, assume permission is not an issue
    return true;
  }

  // Upload prescription (image only)
  Future<void> _uploadPhoto(BuildContext context) async {
    final supabase = Supabase.instance.client;

    // Check permissions before proceeding
    final hasPermission = await _askPermissions();
    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Permission denied. Please allow access."),
          ),
        );
      }
      return;
    }

    // Pick image file
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) {
      print("❌ No file selected");
      return;
    }

    final file = File(result.files.single.path!);
    final ext = result.files.single.extension ?? "jpg";

    // Create a unique file name using patient ID and a timestamp
    final patientId =
        patient is Map && patient.containsKey('id')
            ? patient['id']
            : 'unknown_patient';
    final fileName =
        "${patientId}_${DateTime.now().millisecondsSinceEpoch}.$ext";

    // Define the path inside the 'prescription_documents' bucket
    // Note: The folder "prescription" will be automatically created if it doesn't exist
    final filePath = "prescription/$fileName";

    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("📤 Uploading prescription..."),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // ✅ The correct Supabase upload method
      await supabase.storage
          .from('prescription_documents') // Your bucket name
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(upsert: false),
          );

      print("✅ Upload success: $filePath");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Prescription uploaded successfully")),
        );
      }
    } on StorageException catch (e) {
      print("❌ Upload failed: ${e.message}");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Upload failed: ${e.message}")),
        );
      }
    } catch (e) {
      print("❌ An unknown error occurred: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ An unknown error occurred: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientName =
        (patient is Map && patient.containsKey('name'))
            ? patient['name']
            : patient.toString();

    return Scaffold(
      appBar: AppBar(title: Text("Patient: $patientName")),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: const Text("Upload Prescription"),
          onPressed: () => _uploadPhoto(context),
        ),
      ),
    );
  }
}
