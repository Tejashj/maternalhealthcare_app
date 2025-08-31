import 'package:flutter/material.dart';
import 'package:maternalhealthcare/patient_side/auth/auth_service.dart';
import 'package:maternalhealthcare/patient_side/provider/patient_provider.dart';
import 'package:maternalhealthcare/patient_side/screens/home.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedDoctorId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PatientDataProvider>(context, listen: false).fetchDoctors();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDoctorId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a doctor')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authService = AuthService();
      final currentUser = authService.currentUser;
      if (currentUser == null) throw Exception("No user signed in.");

      await authService.createPatientProfile(
        uid: currentUser.uid,
        phoneNumber: currentUser.phoneNumber ?? 'N/A',
        fullName: _nameController.text,
        dateOfBirth: DateTime.parse(_dobController.text),
        weight: double.parse(_weightController.text),
        selectedDoctorId: _selectedDoctorId!,
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: Consumer<PatientDataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDoctors) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Welcome! Please provide a few details to get started.",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _dobController,
                        label: 'Date of Birth (YYYY-MM-DD)',
                        hint: 'e.g., 1995-07-20',
                        icon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.datetime,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _weightController,
                        label: 'Current Weight (kg)',
                        icon: Icons.monitor_weight_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                      _buildDoctorDropdown(provider.doctors),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Save and Continue'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isSaving)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  TextFormField _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator:
          (value) => value!.isEmpty ? 'This field cannot be empty' : null,
    );
  }

  DropdownButtonFormField<String> _buildDoctorDropdown(List<Doctor> doctors) {
    return DropdownButtonFormField<String>(
      value: _selectedDoctorId,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.medical_services_outlined),
        labelText: 'Consulting Doctor',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      hint: const Text('Select your doctor'),
      items:
          doctors.map((doctor) {
            return DropdownMenuItem(
              value: doctor.id,
              child: Text(doctor.fullName),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDoctorId = value;
        });
      },
      validator: (value) => value == null ? 'Please select a doctor' : null,
    );
  }
}
