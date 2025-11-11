import 'package:bookmycar/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
// import 'home_screen.dart'; // Replace with your next screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()), // Replace as needed
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Image.asset(
              'assets/images/book_my_car_logo.png', // your image path
              height: height * 0.35,
              width: width * 0.6,
              fit: BoxFit.contain,
            ),
            SizedBox(height: height * 0.02),
            // App name
            Text(
              'Book My Car',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: height * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
