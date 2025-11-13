import 'package:bookmycar/Screens/Avalabile_Ride_Screens/avalabile_rides_screen.dart';
import 'package:bookmycar/Screens/Avalabile_Ride_Screens/booking_details_screen.dart';
import 'package:bookmycar/Screens/Comman/nav_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RideDetailScreen extends StatefulWidget {
  final RideData ride;
  final int requestedPassengers;

  const RideDetailScreen({
    super.key,
    required this.ride,
    required this.requestedPassengers,
  });

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  int selectedIndex = 2;

  void onNavItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    print('Navigated to index: $index');
  }

  void onBookNow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailsScreen(
          ride: widget.ride,
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
        child: Column(
          children: [
            // Red Header
            Container(
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
                          'Ride Details',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.09),
                  ],
                ),
              ),
            ),

            // Details Card
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date
                      Text(
                        widget.ride.date,
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Time and Route
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.ride.departureTime,
                                style: GoogleFonts.lexend(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.004),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: screenWidth * 0.045,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: screenWidth * 0.01),
                                  Text(
                                    widget.ride.fromCity,
                                    style: GoogleFonts.lexend(
                                      fontSize: screenWidth * 0.038,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Spacer(),
                          Text(
                            'Rs. ${widget.ride.price}',
                            style: GoogleFonts.lexend(
                              fontSize: screenWidth * 0.048,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFF3B30),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.015),

                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.ride.arrivalTime,
                                style: GoogleFonts.lexend(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.004),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: screenWidth * 0.045,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: screenWidth * 0.01),
                                  Text(
                                    widget.ride.toCity,
                                    style: GoogleFonts.lexend(
                                      fontSize: screenWidth * 0.038,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      Divider(
                        height: screenHeight * 0.03,
                        color: Colors.grey[300],
                      ),

                      // Driver Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: screenWidth * 0.06,
                            backgroundColor: Colors.grey[300],
                            child: Icon(
                              Icons.person,
                              color: Colors.grey[600],
                              size: screenWidth * 0.06,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.ride.driverName,
                                  style: GoogleFonts.lexend(
                                    fontSize: screenWidth * 0.042,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  widget.ride.driverPhone,
                                  style: GoogleFonts.lexend(
                                    fontSize: screenWidth * 0.035,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Divider(
                        height: screenHeight * 0.03,
                        color: Colors.grey[300],
                      ),

                      // Available Passengers
                      Center(
                        child: Text(
                          'No. of Passengers: ${widget.ride.availableSeats}',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Book Now Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.ride.availableSeats > 0
                              ? onBookNow
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF3B30),
                            disabledBackgroundColor: Colors.grey[400],
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Book Now',
                            style: GoogleFonts.lexend(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenHeight * 0.012,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavBarItem(
                  icon: Icons.add,
                  label: 'Publish',
                  isSelected: selectedIndex == 0,
                  screenWidth: screenWidth,
                  onTap: () => onNavItemTapped(0),
                ),
                NavBarItem(
                  icon: Icons.airplane_ticket_outlined,
                  label: 'My Bookings',
                  isSelected: selectedIndex == 1,
                  screenWidth: screenWidth,
                  onTap: () => onNavItemTapped(1),
                ),
                NavBarItem(
                  icon: Icons.search,
                  label: 'Search',
                  isSelected: selectedIndex == 2,
                  screenWidth: screenWidth,
                  onTap: () => onNavItemTapped(2),
                ),
                NavBarItem(
                  icon: Icons.menu,
                  label: 'History',
                  isSelected: selectedIndex == 3,
                  screenWidth: screenWidth,
                  onTap: () => onNavItemTapped(3),
                ),
                NavBarItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  isSelected: selectedIndex == 4,
                  screenWidth: screenWidth,
                  onTap: () => onNavItemTapped(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reuse RideData and NavBarItem classes from previous file