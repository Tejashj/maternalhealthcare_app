import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maternalhealthcare/doctor_side/auth/auth_service.dart';
import 'package:maternalhealthcare/doctor_side/auth/onboarding_screen.dart';
import 'package:maternalhealthcare/doctor_side/auth/returning_user_login.dart';

class DoctorLoginScreen extends StatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final DoctorAuthService _doctorAuthService = DoctorAuthService();

  final _licenseController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _verificationId;
  bool _isLoading = false;

  @override
  void dispose() {
    _licenseController.dispose();
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

  Future<void> _verifyDoctor() async {
    if (!_formKey.currentState!.validate()) return;
    _setLoading(true);
    try {
      await _doctorAuthService.verifyDoctorAndSendOtp(
        licenseId: _licenseController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        verificationCompleted: (credential) async {
          // Handle auto-verification if it occurs
          await _claimAndSignIn(credential: credential);
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
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'An error occurred', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _claimAndSignIn({AuthCredential? credential}) async {
    if (credential == null && _smsCodeController.text.isEmpty) {
      _showMessage('Please enter the OTP.', isError: true);
      return;
    }
    _setLoading(true);
    try {
      final authCredential =
          credential ??
          PhoneAuthProvider.credential(
            verificationId: _verificationId!,
            smsCode: _smsCodeController.text.trim(),
          );

      final userCredential = await _doctorAuthService.signInWithCredential(
        authCredential,
      );

      if (userCredential?.user != null) {
        await _doctorAuthService.createDoctorProfile(
          uid: userCredential!.user!.uid,
          licenseId: _licenseController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DoctorOnboardingScreen()),
            (route) => false,
          );
        }
      } else {
        _showMessage('Sign in failed. Please check the OTP.', isError: true);
      }
    } catch (e) {
      _showMessage('An error occurred during sign in: $e', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Verification')),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child:
                  _verificationId == null
                      ? _buildVerificationForm()
                      : _buildOtpForm(),
            ),
          ),
          if (_isLoading)
            Container(
              color: const Color.fromARGB(255, 255, 109, 109).withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Column _buildVerificationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Enter your credentials to claim your profile.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _licenseController,
          decoration: const InputDecoration(
            labelText: 'Medical License ID',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? 'License ID cannot be empty' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number (+91...)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          validator: (v) => v!.isEmpty ? 'Phone number cannot be empty' : null,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _verifyDoctor,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Verify & Send OTP'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ExistingDoctorLoginScreen(),
              ),
            );
          },
          child: const Text("Already have an account? Sign In"),
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
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _smsCodeController,
          decoration: const InputDecoration(
            labelText: '6-digit OTP',
            border: OutlineInputBorder(),
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
          onPressed: () => _claimAndSignIn(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Confirm & Sign In'),
        ),
        TextButton(
          onPressed: () => setState(() => _verificationId = null),
          child: const Text('Change Details?'),
        ),
      ],
    );
  }
}
