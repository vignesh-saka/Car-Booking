// ============================================
// File: lib/screens/history_screen.dart
// ============================================
import 'package:bookmycar/Screens/Comman/bottom_navigation.dart';
import 'package:bookmycar/Screens/My_Booking_Screens/Screens/my_bookings_screen.dart';
import 'package:bookmycar/Screens/Profile_Screen/profile_screen.dart';
import 'package:bookmycar/Screens/Publish_Ride_Screens/publishride_screen.dart';
import 'package:bookmycar/Screens/Serach_Screen/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ride.dart';
import '../models/ride_request.dart';
import '../widgets/ride_card.dart';
import 'ride_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 3; // History tab selected

  // Sample data – replace with backend API call
  final List<Ride> liveRides = [
    Ride(
      id: '1',
      date: 'Mon 12 November 2025',
      startTime: '05:00 PM',
      endTime: '07:00 PM',
      from: 'Hyderabad',
      to: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 6309762855',
      price: '600',
      totalPassengers: 3,
      requests: [
        RideRequest(
          name: 'Vignesh Kumar Saka',
          phone: '+91 6309762855',
          status: 'pending',
          age: '20',
        ),
      ],
    ),
    Ride(
      id: '2',
      date: 'Mon 12 November 2025',
      startTime: '05:00 PM',
      endTime: '07:00 PM',
      from: 'Hyderabad',
      to: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 6309762855',
      price: '600',
      totalPassengers: 3,
      requests: [],
    ),
  ];

  final List<Ride> completedRides = [
    Ride(
      id: '3',
      date: 'Mon 10 November 2025',
      startTime: '05:00 PM',
      endTime: '07:00 PM',
      from: 'Hyderabad',
      to: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 6309762855',
      price: '600',
      totalPassengers: 3,
      requests: [],
      isLive: false,
    ),
    // ... more items
    Ride(
      id: '4',
      date: 'Mon 9 November 2025',
      startTime: '05:00 PM',
      endTime: '07:00 PM',
      from: 'Hyderabad',
      to: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 6309762855',
      price: '600',
      totalPassengers: 3,
      requests: [],
      isLive: false,
    ),
    Ride(
      id: '5',
      date: 'Mon 8 November 2025',
      startTime: '05:00 PM',
      endTime: '07:00 PM',
      from: 'Hyderabad',
      to: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 6309762855',
      price: '600',
      totalPassengers: 3,
      requests: [],
      isLive: false,
    ),
    Ride(
      id: '6',
      date: 'Mon 7 November 2025',
      startTime: '05:00 PM',
      endTime: '07:00 PM',
      from: 'Hyderabad',
      to: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 6309762855',
      price: '600',
      totalPassengers: 3,
      requests: [],
      isLive: false,
    ),
    Ride(
      id: '4',
      date: 'Mon 9 November 2025',
      startTime: '05:00 PM',
      endTime: '07:00 PM',
      from: 'Hyderabad',
      to: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 6309762855',
      price: '600',
      totalPassengers: 3,
      requests: [],
      isLive: false,
    ),
    Ride(
      id: '5',
      date: 'Mon 8 November 2025',
      startTime: '05:00 PM',
      endTime: '07:00 PM',
      from: 'Hyderabad',
      to: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 6309762855',
      price: '600',
      totalPassengers: 3,
      requests: [],
      isLive: false,
    ),
    Ride(
      id: '6',
      date: 'Mon 7 November 2025',
      startTime: '05:00 PM',
      endTime: '07:00 PM',
      from: 'Hyderabad',
      to: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 6309762855',
      price: '600',
      totalPassengers: 3,
      requests: [],
      isLive: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void onNavItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    // TODO: Navigate to respective screens
    switch (index) {
    case 0:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PublishRideScreen()),
      );
      break;

    case 1:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyBookingsScreen()),
      );
      break;

    case 2:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchScreen()),
      );
      break;

    case 3:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HistoryScreen()),
      );
      break;

    case 4:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
      break;

    default:
      break;
  }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Decide which list to show based on selected tab:
    final List<Ride> currentRides = _tabController.index == 0
        ? liveRides
        : completedRides;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // scroll whole container when content is large
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFF3B30),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'History',
                      style: GoogleFonts.lexend(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Tab Bar
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black54,
                      labelStyle: GoogleFonts.lexend(
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth * 0.04,
                      ),
                      unselectedLabelStyle: GoogleFonts.lexend(
                        fontWeight: FontWeight.w400,
                        fontSize: screenWidth * 0.04,
                      ),
                      tabs: const [
                        Tab(text: 'Live'),
                        Tab(text: 'Completed'),
                      ],
                      onTap: (idx) {
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // List items inside Column so container expands
                  Column(
                    children: currentRides.map((ride) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                        child: RideCard(
                          ride: ride,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isLive: (_tabController.index == 0),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RideDetailsScreen(ride: ride),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),

                  // optionally some bottom padding
                  // SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: selectedIndex,
        onItemTapped: onNavItemTapped,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      ),
    );
  }
}
