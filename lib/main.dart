import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:maternalhealthcare/config/appwrite_client.dart';
import 'package:maternalhealthcare/doctor_side/provider/doctor_provider.dart';
import 'package:maternalhealthcare/patient_side/provider/patient_provider.dart';
import 'package:maternalhealthcare/role_selection.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'config/constants.dart';
import 'package:maternalhealthcare/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Initialize Appwrite
  AppwriteClient.instance.init();

  // Run the app with providers
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
