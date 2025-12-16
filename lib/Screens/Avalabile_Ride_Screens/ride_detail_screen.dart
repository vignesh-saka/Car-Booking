import 'package:bookmycar/Screens/Avalabile_Ride_Screens/avalabile_rides_screen.dart';
import 'package:bookmycar/Screens/Avalabile_Ride_Screens/booking_details_screen.dart';
import 'package:bookmycar/Screens/History_Screens/Screens/history_screen.dart';
import 'package:bookmycar/Screens/My_Booking_Screens/Screens/my_bookings_screen.dart';
import 'package:bookmycar/Screens/Profile_Screen/profile_screen.dart';
import 'package:bookmycar/Screens/Publish_Ride_Screens/publishride_screen.dart';
import 'package:bookmycar/Screens/Serach_Screen/search_screen.dart';
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

  void onBookNow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailsScreen(ride: widget.ride),
      ),
    );
  }

  /// Splits an address like "Hyderabad, Telangana" into:
  /// { 'city': 'Hyderabad', 'rest': 'Telangana' }
  /// If no comma exists, 'city' contains the full string and 'rest' is empty.
  Map<String, String> _splitAddress(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return {'city': '', 'rest': ''};
    final parts = trimmed.split(',');
    final city = parts[0].trim();
    final rest = parts.length > 1 ? parts.sublist(1).join(',').trim() : '';
    return {'city': city, 'rest': rest};
  }

  Widget _buildAddressWidget(String address, double screenWidth,
      {bool alignRight = false}) {
    final parts = _splitAddress(address);
    final city = parts['city']!;
    final rest = parts['rest']!;

    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // City (bold)
        Text(
          city,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lexend(
            fontSize: screenWidth * 0.038,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        // Rest (muted) — only show if non-empty
        if (rest.isNotEmpty) ...[
          SizedBox(height: 4),
          Text(
            rest,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lexend(
              fontSize: screenWidth * 0.032,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // <- Changed: wrap whole body so container can expand
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
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.025,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Red Header
                  Row(
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

                  SizedBox(height: screenHeight * 0.03),

                  // White details card inside red container
                  Container(
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

                        // Time & route rows
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Time
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    ],
                                  ),

                                  SizedBox(width: screenWidth * 0.02),

                                  // Icon + address column (Flexible)
                                  Flexible(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: screenWidth * 0.045,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        Flexible(
                                          child: _buildAddressWidget(
                                              widget.ride.fromCity, screenWidth,
                                              alignRight: false),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Price
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
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Time
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    ],
                                  ),

                                  SizedBox(width: screenWidth * 0.02),

                                  Icon(
                                    Icons.location_on,
                                    size: screenWidth * 0.045,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: screenWidth * 0.01),

                                  // To-address column
                                  Flexible(
                                    child: _buildAddressWidget(
                                        widget.ride.toCity, screenWidth,
                                        alignRight: false),
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

                        // Driver info
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

                        // Available seats
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

                        Text(
                          "Description",
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.0),

                        Text(
                          widget.ride.description,
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.038,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Book Now button
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

                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),

      // Bottom Navigation
      
    );
  }
}
