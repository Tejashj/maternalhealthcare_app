import 'package:flutter/material.dart';
import 'package:maternalhealthcare/patient_side/auth/auth_service.dart';
import 'package:maternalhealthcare/patient_side/screens/home.dart';

class PatientLoginScreen extends StatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  State<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  final AuthService _authService = AuthService();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _verificationId;
  bool _isLoading = false;
  bool _isPhoneValid = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    if (mounted) {
      setState(() => _isLoading = value);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  bool _validatePhone(String phone) {
    // Basic Indian phone number validation
    final RegExp phoneRegex = RegExp(r'^\+91[1-9]\d{9}$');
    return phoneRegex.hasMatch(phone);
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    _setLoading(true);
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: _phoneController.text,
        verificationCompleted: (credential) async {
          // Auto-verification case (rare on most devices)
          try {
            final result = await _authService.signInWithCredential(credential);
            if (result != null && mounted) {
              _navigateToHome();
            }
          } catch (e) {
            _showMessage('Auto-verification failed: $e', isError: true);
          }
        },
        verificationFailed: (e) {
          _showMessage(e.message ?? 'Verification failed', isError: true);
        },
        codeSent: (verificationId, resendToken) {
          setState(() => _verificationId = verificationId);
          _showMessage('OTP sent successfully!');
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _showMessage('OTP timeout. Please try again.', isError: true);
        },
      );
    } catch (e) {
      _showMessage('Error: $e', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _verifyAndSignIn() async {
    if (_smsCodeController.text.length != 6) {
      _showMessage('Please enter a valid 6-digit OTP', isError: true);
      return;
    }

    _setLoading(true);
    try {
      final result = await _authService.signInWithSmsCode(
        _verificationId!,
        _smsCodeController.text,
      );

      if (result != null) {
        // Success - navigate to home page
        _showMessage('Sign in successful!');
        if (mounted) {
          _navigateToHome();
        }
      } else {
        // Failed verification
        _showMessage('Invalid OTP. Please try again.', isError: true);
        _setLoading(false);
      }
    } catch (e) {
      _showMessage('Error: $e', isError: true);
      _setLoading(false);
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder:
            (context) =>
                const PatientHomeScreen(), // Adjust class name as needed
      ),
      (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patient Sign In',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [_buildPhoneAuthForm()],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhoneAuthForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sign In with Phone',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (_verificationId == null) ...[
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: '+91 1234567890',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a phone number';
              }
              if (!_validatePhone(value)) {
                return 'Please enter a valid Indian phone number';
              }
              return null;
            },
            onChanged: (value) {
              setState(() => _isPhoneValid = _validatePhone(value));
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isPhoneValid ? _sendOtp : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Send OTP',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ] else ...[
          TextFormField(
            controller: _smsCodeController,
            decoration: InputDecoration(
              labelText: 'Enter OTP',
              hintText: '6-digit code',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: (value) {
              if (value == null || value.length != 6) {
                return 'Please enter a valid 6-digit OTP';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _verifyAndSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Verify & Sign In',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _verificationId = null),
            child: const Text('Change Number?'),
          ),
        ],
      ],
    );
  }
}
