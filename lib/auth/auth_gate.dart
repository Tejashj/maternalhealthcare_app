import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maternalhealthcare/auth/auth_service.dart';
import 'package:maternalhealthcare/auth/login_page.dart';
import 'package:maternalhealthcare/auth/profile.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // User is not signed in
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        // User is signed in
        return const ProfilePage();
      },
    );
  }
}
