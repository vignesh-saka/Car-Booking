import 'package:flutter/material.dart';
import 'package:bookmycar/Screens/Publish_Ride_Screens/publishride_screen.dart';
import 'package:bookmycar/Screens/My_Booking_Screens/Screens/my_bookings_screen.dart';
import 'package:bookmycar/Screens/Serach_Screen/search_screen.dart';
import 'package:bookmycar/Screens/History_Screens/Screens/history_screen.dart';
import 'package:bookmycar/Screens/Profile_Screen/profile_screen.dart';
import 'package:bookmycar/Screens/Comman/bottom_navigation.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 2; // Search tab index

  final _screens = const [
    PublishRideScreen(), // 0
    MyBookingsScreen(), // 1
    SearchScreen(), // 2
    HistoryScreen(), // 3
    ProfileScreen(), // 4
  ];

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 2) {
      // 🔹 If not on Search → go to Search
      setState(() {
        _selectedIndex = 2;
      });
      return false; // prevent app exit
    }

    // 🔹 If already on Search → exit app
    return true; // allows app to close
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(index: _selectedIndex, children: _screens),
        ),
        bottomNavigationBar: BottomNavigation(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
