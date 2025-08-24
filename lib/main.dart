import 'package:flutter/material.dart';
import 'package:maternalhealthcare/doctor_side/provider/doctor_provider.dart';
import 'package:maternalhealthcare/patient_side/provider/patient_provider.dart';
import 'package:provider/provider.dart';
import 'role_selection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MultiProvider to make all data providers available at the top level
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientDataProvider()),
        ChangeNotifierProvider(create: (_) => DoctorDataProvider()),
      ],
      child: MaterialApp(
        title: 'Health App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
          fontFamily: 'Inter',
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const RoleSelectionScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
