import 'package:flutter/material.dart';
import 'package:maternalhealthcare/auth/auth_service.dart';
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
    // Fetch the list of doctors as soon as the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PatientDataProvider>(context, listen: false).fetchDoctors();
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDoctorId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select a doctor')));
        return;
      }

      setState(() => _isSaving = true);

      try {
        // We use the AuthService to create the profile in Supabase
        await AuthService().createPatientProfile(
          name: _nameController.text,
          dob: _dobController.text,
          weight: double.parse(_weightController.text),
          doctorId: _selectedDoctorId!,
        );

        // Navigate to the main app after saving is successful
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _dobController,
                    label: 'Date of Birth (YYYY-MM-DD)',
                    hint: 'e.g., 1995-07-20',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _weightController,
                    label: 'Current Weight (kg)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  _buildDoctorDropdown(provider.doctors),
                  const SizedBox(height: 32),
                  _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Save and Continue'),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  TextFormField _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
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
