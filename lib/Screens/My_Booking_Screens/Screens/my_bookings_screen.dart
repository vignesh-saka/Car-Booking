import 'package:bookmycar/Screens/Comman/bottom_navigation.dart';
import 'package:bookmycar/Screens/History_Screens/Screens/history_screen.dart';
import 'package:bookmycar/Screens/My_Booking_Screens/Model/models.dart';
import 'package:bookmycar/Screens/Profile_Screen/profile_screen.dart';
import 'package:bookmycar/Screens/Publish_Ride_Screens/publishride_screen.dart';
import 'package:bookmycar/Screens/Serach_Screen/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/booking_card.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 1; // My Bookings tab selected

  // Sample bookings - Replace with backend API call
  List<Booking> allBookings = [
    Booking(
      id: '1',
      rideId: 'ride_1',
      date: 'Mon 12 November 2025',
      startTime: '05:00 PM',
      endTime: '07:00 PM',
      from: 'Hyderabad',
      to: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 6309762855',
      price: '600',
      passengerCount: 2,
      status: 'accepted',
      isCompleted: false,
    ),
    Booking(
      id: '2',
      rideId: 'ride_2',
      date: 'Mon 12 November 2025',
      startTime: '05:00 PM',
      endTime: '07:00 PM',
      from: 'Hyderabad',
      to: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 6309762855',
      price: '600',
      passengerCount: 1,
      status: 'rejected',
      isCompleted: false,
    ),
    Booking(
      id: '3',
      rideId: 'ride_3',
      date: 'Mon 12 November 2025',
      startTime: '05:00 PM',
      endTime: '07:00 PM',
      from: 'Hyderabad',
      to: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 6309762855',
      price: '600',
      passengerCount: 3,
      status: 'requested',
      isCompleted: false,
    ),
    Booking(
      id: '3',
      rideId: 'ride_3',
      date: 'Mon 12 November 2025',
      startTime: '05:00 PM',
      endTime: '07:00 PM',
      from: 'Hyderabad',
      to: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 6309762855',
      price: '600',
      passengerCount: 3,
      status: 'requested',
      isCompleted: false,
    ),
    // Completed bookings
    Booking(
      id: '4',
      rideId: 'ride_4',
      date: 'Mon 10 November 2025',
      startTime: '05:00 PM',
      endTime: '07:00 PM',
      from: 'Hyderabad',
      to: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 6309762855',
      price: '600',
      passengerCount: 2,
      status: 'accepted',
      isCompleted: true,
    ),
    Booking(
      id: '5',
      rideId: 'ride_5',
      date: 'Mon 9 November 2025',
      startTime: '05:00 PM',
      endTime: '07:00 PM',
      from: 'Hyderabad',
      to: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 6309762855',
      price: '600',
      passengerCount: 1,
      status: 'rejected',
      isCompleted: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  List<Booking> get bookedBookings =>
      allBookings.where((b) => !b.isCompleted).toList();

  List<Booking> get completedBookings =>
      allBookings.where((b) => b.isCompleted).toList();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFFF3B30),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              // Header
              SizedBox(height: screenHeight * 0.02),
              Text(
                'My Bookings',
                style: GoogleFonts.lexend(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
                  dividerColor: Colors.transparent,
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
                    Tab(text: 'Booked'),
                    Tab(text: 'All Bookings'),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingsList(
                      bookedBookings,
                      screenWidth,
                      screenHeight,
                    ),
                    _buildBookingsList(
                      completedBookings,
                      screenWidth,
                      screenHeight,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigation(
        selectedIndex: selectedIndex,
        onItemTapped: onNavItemTapped,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      ),
    );
  }

  Widget _buildBookingsList(
    List<Booking> bookings,
    double screenWidth,
    double screenHeight,
  ) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(
          'No bookings found',
          style: GoogleFonts.lexend(
            fontSize: screenWidth * 0.04,
            color: Colors.white,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.01,
      ),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return BookingCard(
          booking: bookings[index],
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        );
      },
    );
  }
}
