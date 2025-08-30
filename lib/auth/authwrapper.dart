import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maternalhealthcare/auth/auth_service.dart';
import 'package:maternalhealthcare/doctor_side/screens/doctor_home.dart';
import 'package:maternalhealthcare/patient_side/screens/home.dart';
import 'package:maternalhealthcare/patient_side/screens/onboarding_screen.dart';
import 'package:maternalhealthcare/utils/role_selection.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

// This is your new and improved AuthGate/AuthWrapper
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to Firebase Authentication state changes
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // 1. While connecting to Firebase, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. If the snapshot has user data, the user is logged into Firebase
        if (snapshot.hasData) {
          // Now we need to check if they have a profile in Supabase
          return FutureBuilder<Map<String, dynamic>?>(
            // We create a simple future to check for profile and role
            future: _getUserProfileAndRole(),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final userProfile = profileSnapshot.data;

              // 3. If no profile exists, they are a new user -> Onboarding
              if (userProfile == null) {
                return const OnboardingScreen();
              }

              // 4. Profile exists, check their role and navigate accordingly
              final role = userProfile['role'];
              if (role == 'patient') {
                return const PatientHomeScreen();
              } else if (role == 'doctor') {
                return const DoctorHomeScreen();
              } else {
                // Fallback in case of an unexpected role
                return const RoleSelectionScreen();
              }
            },
          );
        }

        // 5. If no user data, they are logged out -> Role Selection Screen
        return const RoleSelectionScreen();
      },
    );
  }

  // Helper function to get the user's role from Supabase
  Future<Map<String, dynamic>?> _getUserProfileAndRole() async {
    final firebaseUid = FirebaseAuth.instance.currentUser?.uid;
    if (firebaseUid == null) {
      return null;
    }

    try {
      final data =
          await sp.Supabase.instance.client
              .from('users')
              .select('role')
              .eq('id', firebaseUid)
              .single();
      return data;
    } catch (e) {
      // This error likely means the user exists in Firebase Auth
      // but their profile hasn't been created in Supabase yet.
      debugPrint("Could not fetch user profile: $e");
      return null;
    }
  }
}
