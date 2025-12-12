import 'package:bookmycar/auth/login_screen.dart';
import 'package:bookmycar/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
// import your SearchScreen here
// import 'package:bookmycar/pages/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book My Car',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(), // 👈 start from Splash always
    );
  }
}
