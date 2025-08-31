// import 'package:flutter/material.dart';
// import 'package:flutter_signin_button/flutter_signin_button.dart';
// import 'auth_service.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);

//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final AuthService _authService = AuthService();
//   final _phoneController = TextEditingController();
//   final _smsCodeController = TextEditingController();

//   String? _verificationId;
//   bool _isLoading = false;

//   // --- Helper methods for loading and error handling ---
//   void _setLoading(bool value) {
//     setState(() {
//       _isLoading = value;
//     });
//   }

//   void _showError(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message), backgroundColor: Colors.red),
//       );
//     }
//   }

//   // --- Sign-in Logic ---

//   Future<void> _sendOtp() async {
//     if (_phoneController.text.isEmpty) {
//       _showError('Please enter a phone number.');
//       return;
//     }
//     _setLoading(true);
//     try {
//       await _authService.verifyPhoneNumber(
//         phoneNumber: _phoneController.text,
//         verificationCompleted: (credential) async {
//           // This is for auto-retrieval, rare on most devices
//           // We can optionally sign in here
//         },
//         verificationFailed: (e) {
//           _showError(e.message ?? 'Verification failed. Please try again.');
//         },
//         codeSent: (verificationId, resendToken) {
//           setState(() {
//             _verificationId = verificationId;
//           });
//           if (mounted) {
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(const SnackBar(content: Text('OTP has been sent!')));
//           }
//         },
//         codeAutoRetrievalTimeout: (verificationId) {},
//       );
//     } catch (e) {
//       _showError('An unexpected error occurred: $e');
//     } finally {
//       if (mounted) {
//         _setLoading(false);
//       }
//     }
//   }

//   Future<void> _verifyAndSignIn() async {
//     if (_smsCodeController.text.isEmpty || _verificationId == null) {
//       _showError('Please enter the OTP.');
//       return;
//     }
//     _setLoading(true);
//     try {
//       final userCredential = await _authService.signInWithSmsCode(
//         _verificationId!,
//         _smsCodeController.text,
//       );
//       // No navigation needed here. AuthWrapper will handle it.
//       if (userCredential == null) {
//         _showError('Sign in failed. Please check the OTP and try again.');
//       }
//     } catch (e) {
//       _showError('An unexpected error occurred during sign in: $e');
//     } finally {
//       if (mounted) {
//         _setLoading(false);
//       }
//     }
//   }

//   Future<void> _signInWithGoogle() async {
//     _setLoading(true);
//     try {
//       await _authService.signInWithGoogle();
//       // No navigation needed here. AuthWrapper will handle it.
//     } catch (e) {
//       _showError('Google sign in failed: $e');
//     } finally {
//       if (mounted) {
//         _setLoading(false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Sign In')),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 _buildPhoneAuthForm(),
//                 const SizedBox(height: 20),
//                 Row(
//                   children: [
//                     const Expanded(child: Divider()),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                       child: Text(
//                         'OR',
//                         style: TextStyle(color: Colors.grey.shade600),
//                       ),
//                     ),
//                     const Expanded(child: Divider()),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 _buildGoogleSignInButton(),
//               ],
//             ),
//           ),
//           // Loading indicator overlay
//           if (_isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: const Center(child: CircularProgressIndicator()),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPhoneAuthForm() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Text(
//           'Sign In with Phone',
//           style: Theme.of(context).textTheme.headlineSmall,
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 16),
//         if (_verificationId == null)
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _phoneController,
//                   decoration: const InputDecoration(
//                     labelText: 'Phone (+91 1234567890)',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.phone,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               ElevatedButton(
//                 onPressed: _sendOtp,
//                 child: const Text('Send OTP'),
//               ),
//             ],
//           ),
//         if (_verificationId != null)
//           Column(
//             children: [
//               TextField(
//                 controller: _smsCodeController,
//                 decoration: const InputDecoration(
//                   labelText: '6-digit OTP',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 12),
//               ElevatedButton(
//                 onPressed: _verifyAndSignIn,
//                 child: const Text('Verify & Sign In'),
//               ),
//               TextButton(
//                 onPressed: () => setState(() => _verificationId = null),
//                 child: const Text('Change Number?'),
//               ),
//             ],
//           ),
//       ],
//     );
//   }

//   Widget _buildGoogleSignInButton() {
//     return SignInButton(
//       Buttons.Google,
//       text: "Sign in with Google",
//       onPressed: _signInWithGoogle,
//     );
//   }
// }
