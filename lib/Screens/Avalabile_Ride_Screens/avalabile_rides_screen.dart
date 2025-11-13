import 'package:bookmycar/Screens/Avalabile_Ride_Screens/ride_detail_screen.dart';
import 'package:bookmycar/Screens/Comman/bottom_navigation.dart';
import 'package:bookmycar/Screens/History_Screens/Screens/history_screen.dart';
import 'package:bookmycar/Screens/My_Booking_Screens/Screens/my_bookings_screen.dart';
import 'package:bookmycar/Screens/Profile_Screen/profile_screen.dart';
import 'package:bookmycar/Screens/Publish_Ride_Screens/publishride_screen.dart';
import 'package:bookmycar/Screens/Serach_Screen/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AvailableRidesScreen extends StatefulWidget {
  final String from;
  final String to;
  final String date;
  final int passengers;

  const AvailableRidesScreen({
    super.key,
    required this.from,
    required this.to,
    required this.date,
    required this.passengers,
  });

  @override
  State<AvailableRidesScreen> createState() => _AvailableRidesScreenState();
}

class _AvailableRidesScreenState extends State<AvailableRidesScreen> {
  int selectedIndex = 2;

  // Mock data - Replace with actual API call
  List<RideData> availableRides = [
    RideData(
      departureTime: '05:00 PM',
      arrivalTime: '07:00 PM',
      fromCity: 'Hyderabad',
      toCity: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 9392782895',
      totalSeats: 5,
      bookedSeats: 0,
      price: 600,
      date: 'Mon 12 November 2025',
    ),
    RideData(
      departureTime: '05:00 PM',
      arrivalTime: '07:00 PM',
      fromCity: 'Hyderabad',
      toCity: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 9392782895',
      totalSeats: 5,
      bookedSeats: 2,
      price: 600,
      date: 'Mon 12 November 2025',
    ),
    RideData(
      departureTime: '05:00 PM',
      arrivalTime: '07:00 PM',
      fromCity: 'Hyderabad',
      toCity: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 9392782895',
      totalSeats: 4,
      bookedSeats: 0,
      price: 600,
      date: 'Mon 12 November 2025',
    ),
    RideData(
      departureTime: '05:00 PM',
      arrivalTime: '07:00 PM',
      fromCity: 'Hyderabad',
      toCity: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 9392782895',
      totalSeats: 4,
      bookedSeats: 0,
      price: 600,
      date: 'Mon 12 November 2025',
    ),
    RideData(
      departureTime: '05:00 PM',
      arrivalTime: '07:00 PM',
      fromCity: 'Hyderabad',
      toCity: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 9392782895',
      totalSeats: 4,
      bookedSeats: 0,
      price: 600,
      date: 'Mon 12 November 2025',
    ),
    RideData(
      departureTime: '05:00 PM',
      arrivalTime: '07:00 PM',
      fromCity: 'Hyderabad',
      toCity: 'Karimnagar',
      driverName: 'Vignesh Kumar Saka',
      driverPhone: '+91 9392782895',
      totalSeats: 4,
      bookedSeats: 0,
      price: 600,
      date: 'Mon 12 November 2025',
    ),
  ];

  void onNavItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
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

  void onRideSelected(RideData ride) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideDetailScreen(
          ride: ride,
          requestedPassengers: widget.passengers,
        ),
      ),
    );
  }

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
              // Red Header part
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.025,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: screenWidth * 0.05,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Available Rides',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.01),
                  ],
                ),
              ),

              // Subtitle inside the same red container
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.012,
                ),
                child: Text(
                  'Book a Safe & Enjoy Ride',
                  style: GoogleFonts.lexend(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[200], // maybe lighter so it shows on red
                  ),
                ),
              ),

              SizedBox(width: screenWidth * 0.09),

              // Rides list area inside red container
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.01,
                  ),
                  child: availableRides.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: screenWidth * 0.2,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                'No rides available',
                                style: GoogleFonts.lexend(
                                  fontSize: screenWidth * 0.045,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: availableRides.length,
                          itemBuilder: (context, index) {
                            return RideCard(
                              ride: availableRides[index],
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              onTap: () =>
                                  onRideSelected(availableRides[index]),
                            );
                          },
                        ),
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
}

class RideData {
  final String departureTime;
  final String arrivalTime;
  final String fromCity;
  final String toCity;
  final String driverName;
  final String driverPhone;
  final int totalSeats;
  final int bookedSeats;
  final int price;
  final String date;

  RideData({
    required this.departureTime,
    required this.arrivalTime,
    required this.fromCity,
    required this.toCity,
    required this.driverName,
    required this.driverPhone,
    required this.totalSeats,
    required this.bookedSeats,
    required this.price,
    required this.date,
  });

  int get availableSeats => totalSeats - bookedSeats;
}

class RideCard extends StatelessWidget {
  final RideData ride;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onTap;

  const RideCard({
    super.key,
    required this.ride,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.015),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time and Cities Row
            Row(
              children: [
                // Departure
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.departureTime,
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.004),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: screenWidth * 0.04,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Flexible(
                            child: Text(
                              ride.fromCity,
                              style: GoogleFonts.lexend(
                                fontSize: screenWidth * 0.035,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Container(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.grey[400],
                    size: screenWidth * 0.05,
                  ),
                ),

                // Arrival and Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        ride.arrivalTime,
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.004),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              ride.toCity,
                              style: GoogleFonts.lexend(
                                fontSize: screenWidth * 0.035,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Icon(
                            Icons.location_on,
                            size: screenWidth * 0.04,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Divider(height: screenHeight * 0.025, color: Colors.grey[300]),

            // Driver Info
            Row(
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.05,
                  backgroundColor: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    color: Colors.grey[600],
                    size: screenWidth * 0.05,
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.driverName,
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.038,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        ride.driverPhone,
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.032,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Rs. ${ride.price}',
                  style: GoogleFonts.lexend(
                    fontSize: screenWidth * 0.042,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF3B30),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
