import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maternalhealthcare/patient_side/auth/auth_service.dart';
import 'package:maternalhealthcare/doctor_side/screens/doctor_home.dart';

class ExistingDoctorLoginScreen extends StatefulWidget {
  const ExistingDoctorLoginScreen({super.key});

  @override
  State<ExistingDoctorLoginScreen> createState() =>
      _ExistingDoctorLoginScreenState();
}

class _ExistingDoctorLoginScreenState extends State<ExistingDoctorLoginScreen> {
  // NOTE: We use the main AuthService because an existing doctor is just a regular user
  // in our system. The AuthWrapper will correctly route them based on their 'doctor' role.
  final AuthService _authService = AuthService();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _verificationId;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    if (mounted) setState(() => _isLoading = value);
  }

  void _showMessage(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    _setLoading(true);
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: _phoneController.text.trim(),
        verificationCompleted: (credential) async {
          // Handle auto-verification if it occurs
          final userCredential = await _authService.signInWithCredential(
            credential,
          );
          if (userCredential == null) {
            _showMessage('Auto-verification failed.', isError: true);
          }
          // AuthWrapper will handle navigation
        },
        verificationFailed: (e) {
          _showMessage(e.message ?? 'Verification failed', isError: true);
        },
        codeSent: (verificationId, resendToken) {
          setState(() => _verificationId = verificationId);
          _showMessage('OTP sent successfully!');
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (e) {
      _showMessage('An error occurred: $e', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _verifyAndSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    _setLoading(true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _smsCodeController.text.trim(),
      );
      final userCredential = await _authService.signInWithCredential(
        credential,
      );

      if (userCredential == null) {
        _showMessage('Sign in failed. Please check the OTP.', isError: true);
        return; // Add return here to prevent navigation on failure
      }

      // Add navigation after successful sign in
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DoctorHomeScreen()),
          (route) => false, // This removes all previous routes from the stack
        );
      }
    } catch (e) {
      _showMessage('Verification failed: ${e.toString()}', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doctor Sign In',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child:
                  _verificationId == null ? _buildPhoneForm() : _buildOtpForm(),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Column _buildPhoneForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Enter your registered phone number to sign in.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number (+91...)',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.black87),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          keyboardType: TextInputType.phone,
          validator: (v) => v!.isEmpty ? 'Phone number cannot be empty' : null,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _sendOtp,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Send OTP',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Column _buildOtpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'An OTP has been sent to ${_phoneController.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _smsCodeController,
          decoration: const InputDecoration(
            labelText: '6-digit OTP',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.black87),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          validator:
              (v) =>
                  v!.isEmpty || v.length < 6
                      ? 'Please enter the 6-digit OTP'
                      : null,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _verifyAndSignIn,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Confirm & Sign In',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _verificationId = null),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('Change Number?', style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}
