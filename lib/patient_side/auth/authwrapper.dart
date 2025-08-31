import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maternalhealthcare/patient_side/auth/auth_service.dart';
import 'package:maternalhealthcare/doctor_side/screens/doctor_home.dart';
import 'package:maternalhealthcare/patient_side/screens/home.dart';
import 'package:maternalhealthcare/patient_side/screens/onboarding_screen.dart';
import 'package:maternalhealthcare/utils/role_selection.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  // These state variables are the key to the fix.
  // They prevent the FutureBuilder from re-running on every build.
  Future<UserProfile?>? _profileFuture;
  String? _currentUid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, firebaseUserSnapshot) {
        if (firebaseUserSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final firebaseUser = firebaseUserSnapshot.data;

        // CASE 1: User is logged out.
        if (firebaseUser == null) {
          // Reset the future when the user logs out.
          _profileFuture = null;
          _currentUid = null;
          return const RoleSelectionScreen();
        }

        // ** THE FIX IS HERE **
        // We only create a new future if the user has changed (e.g., just logged in).
        // On subsequent rebuilds where the user is the same, we reuse the existing future.
        if (firebaseUser.uid != _currentUid) {
          _currentUid = firebaseUser.uid;
          _profileFuture = _authService.getUserProfile(firebaseUser.uid);
        }

        // CASE 2: User is logged in, use the memoized future to get their profile.
        return FutureBuilder<UserProfile?>(
          future:
              _profileFuture, // Use the state variable, not a new function call
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final userProfile = profileSnapshot.data;

            if (userProfile == null) {
              return const OnboardingScreen();
            }

            if (userProfile.fullName == null || userProfile.fullName!.isEmpty) {
              return const OnboardingScreen();
            }

            if (userProfile.role == 'patient') {
              return const PatientHomeScreen();
            } else if (userProfile.role == 'doctor') {
              return const DoctorHomeScreen();
            } else {
              return const RoleSelectionScreen();
            }
          },
        );
      },
    );
  }
}
