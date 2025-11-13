import 'package:bookmycar/Screens/History_Screens/Screens/history_screen.dart';
import 'package:bookmycar/Screens/Profile_Screen/profile_screen.dart';
import 'package:bookmycar/Screens/Publish_Ride_Screens/publishsucess_screen.dart';
import 'package:bookmycar/Screens/Serach_Screen/search_screen.dart';
import 'package:bookmycar/auth/login_screen.dart';
import 'package:bookmycar/pages/splash_screen.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book My Car',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen()
    );
  } 
}