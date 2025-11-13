import 'package:bookmycar/Screens/My_Booking_Screens/Model/models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final double screenWidth;
  final double screenHeight;

  const BookingCard({
    super.key,
    required this.booking,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time and Location
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    booking.startTime,
                    style: GoogleFonts.lexend(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Icon(Icons.location_on,
                      size: screenWidth * 0.04, color: Colors.black54),
                  SizedBox(width: screenWidth * 0.01),
                  Text(
                    booking.from,
                    style: GoogleFonts.lexend(
                      fontSize: screenWidth * 0.038,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                'Rs: ${booking.price}',
                style: GoogleFonts.lexend(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF4444),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.008),
          Row(
            children: [
              Text(
                booking.endTime,
                style: GoogleFonts.lexend(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Icon(Icons.location_on,
                  size: screenWidth * 0.04, color: Colors.black54),
              SizedBox(width: screenWidth * 0.01),
              Text(
                booking.to,
                style: GoogleFonts.lexend(
                  fontSize: screenWidth * 0.038,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),

          // Driver Info
          Row(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.05,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.grey[600]),
              ),
              SizedBox(width: screenWidth * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.driverName,
                    style: GoogleFonts.lexend(
                      fontSize: screenWidth * 0.038,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    booking.driverPhone,
                    style: GoogleFonts.lexend(
                      fontSize: screenWidth * 0.032,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),

          // Status Badge
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.008,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _getStatusColor(),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                booking.status.toUpperCase(),
                style: GoogleFonts.lexend(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (booking.status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'requested':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}