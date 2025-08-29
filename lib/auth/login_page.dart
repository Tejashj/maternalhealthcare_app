import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();

  String? _verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPhoneAuthForm(),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'OR',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            _buildGoogleSignInButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneAuthForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sign In with Phone',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (_verificationId == null)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone (+1 650-555-1234)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  await _authService.verifyPhoneNumber(
                    phoneNumber: _phoneController.text,
                    verificationCompleted: (credential) {},
                    verificationFailed: (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.message ?? 'Verification failed'),
                        ),
                      );
                    },
                    codeSent: (verificationId, resendToken) {
                      setState(() {
                        _verificationId = verificationId;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('OTP has been sent!')),
                      );
                    },
                    codeAutoRetrievalTimeout: (verificationId) {},
                  );
                },
                child: const Text('Send OTP'),
              ),
            ],
          ),
        if (_verificationId != null)
          Column(
            children: [
              TextField(
                controller: _smsCodeController,
                decoration: const InputDecoration(
                  labelText: '6-digit OTP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await _authService.signInWithSmsCode(
                    _verificationId!,
                    _smsCodeController.text,
                  );
                },
                child: const Text('Verify & Sign In'),
              ),
              TextButton(
                onPressed: () => setState(() => _verificationId = null),
                child: const Text('Change Number?'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return SignInButton(
      Buttons.Google,
      text: "Sign in with Google",
      onPressed: () async {
        await _authService.signInWithGoogle();
      },
    );
  }
}
