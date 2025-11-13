// ============================================
// File: lib/widgets/ride_card.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ride.dart';

class RideCard extends StatelessWidget {
  final Ride ride;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onTap;
  final bool isLive;

  const RideCard({
    super.key,
    required this.ride,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTap,
    required this.isLive,  // Changed to required instead of optional
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
                      ride.startTime,
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
                      ride.from,
                      style: GoogleFonts.lexend(
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Rs: ${ride.price}',
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
                  ride.endTime,
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
                  ride.to,
                  style: GoogleFonts.lexend(
                    fontSize: screenWidth * 0.038,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Only show status button for Live rides
            if (isLive) ...[
              SizedBox(height: screenHeight * 0.015),
              if (ride.hasPendingRequests)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4444),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'You have Pending Requests',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'You have No Pending Requests',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
            
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
                      ride.driverName,
                      style: GoogleFonts.lexend(
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.w500,
                      ),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}