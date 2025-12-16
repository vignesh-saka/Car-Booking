// import 'package:bookmycar/Screens/Comman/bottom_navigation.dart';
// import 'package:bookmycar/Screens/History_Screens/Screens/history_screen.dart';
// import 'package:bookmycar/Screens/My_Booking_Screens/Screens/my_bookings_screen.dart';
// import 'package:bookmycar/Screens/Profile_Screen/profile_screen.dart';
// import 'package:bookmycar/Screens/Publish_Ride_Screens/publishride_screen.dart';
// import 'package:bookmycar/Screens/Serach_Screen/search_screen.dart';
// import 'package:flutter/material.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int selectedIndex = 4; // Profile default

//   final List<Widget> screens = const [
//     PublishRideScreen(),
//     MyBookingsScreen(),
//     SearchScreen(),
//     HistoryScreen(),
//     ProfileScreen(),
//   ];

//   void onItemTapped(int index) {
//     if (selectedIndex == index) return; // 🔒 prevent duplicate tap

//     setState(() {
//       selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       body: IndexedStack(
//         index: selectedIndex,
//         children: screens,
//       ),
//       bottomNavigationBar: BottomNavigation(
//         selectedIndex: selectedIndex,
//         onItemTapped: onItemTapped,
//         screenWidth: size.width,
//         screenHeight: size.height,
//       ),
//     );
//   }
// }
