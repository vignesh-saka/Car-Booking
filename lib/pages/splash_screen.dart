import 'dart:async';
import 'package:bookmycar/Screens/Comman/main_dashboard.dart';
import 'package:bookmycar/auth/login_screen.dart';
import 'package:bookmycar/utils/responsive_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Show splash for 3 seconds, then decide where to go
    Timer(const Duration(seconds: 3), _handleNavigation);
  }

  void _handleNavigation() {
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user == null) {
      // 👉 Not logged in → go to LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      // 👉 Already logged in → go to SearchScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Constrained Box for Web/Desktop
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // App logo
                    Image.asset(
                      'assets/images/car_splash.png', // your image path
                      height: ResponsiveWidget.isMobile(context)
                          ? height * 0.35
                          : 300, // Fixed height for desktop
                      width: ResponsiveWidget.isMobile(context)
                          ? width * 0.6
                          : 300, // Fixed width for desktop
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: height * 0.02),
                    // App name
                    Text(
                      'Book My Car',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: ResponsiveWidget.isMobile(context)
                            ? height * 0.035
                            : 32, // Fixed font size for desktop
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
