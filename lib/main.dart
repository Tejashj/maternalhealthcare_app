import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maternalhealthcare/patient_side/auth/authwrapper.dart';
import 'package:maternalhealthcare/config/firebase_options.dart';
import 'package:maternalhealthcare/doctor_side/provider/doctor_provider.dart';
import 'package:maternalhealthcare/patient_side/provider/patient_provider.dart';
import 'package:maternalhealthcare/patient_side/provider/profile_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: true, // Set to false in production
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientDataProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => DoctorDataProvider()),
      ],
      child: MaterialApp(
        title: 'Maternal Healthcare App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.grey[50],
          // Apply the 'Inter' font globally using the google_fonts package
          textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}
