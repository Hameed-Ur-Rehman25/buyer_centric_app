import 'package:buyer_centric_app/app_theme.dart';
import 'package:buyer_centric_app/screens/auth/login_screen.dart';
import 'package:buyer_centric_app/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  // try {
  //   await dotenv.load(fileName: ".env");
  //   // Check if .env file is loaded correctly
  //   print("FIREBASE_API_KEY_WEB: ${dotenv.env['FIREBASE_API_KEY_WEB']}");
  //   print("FIREBASE_APP_ID_WEB: ${dotenv.env['FIREBASE_APP_ID_WEB']}");
  //   print(
  //       "FIREBASE_API_KEY_ANDROID: ${dotenv.env['FIREBASE_API_KEY_ANDROID']}");
  //   print("FIREBASE_PROJECT_ID: ${dotenv.env['FIREBASE_PROJECT_ID']}");
  // } catch (e) {
  //   print("Error loading .env file: $e");
  // }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Trading App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return MainScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
