import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bookmycar/Screens/Comman/ride_share_helper.dart';

class PublishsucessScreen extends StatelessWidget {
  final VoidCallback onGoToHistory;
  final String from;
  final String to;
  final String date;
  final String time;
  final int passengers;
  final String driverName;

  const PublishsucessScreen({
    super.key,
    required this.onGoToHistory,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.passengers,
    required this.driverName,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.03,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.10),

                        // success animation (GIF / PNG)
                        Center(
                          child: SizedBox(
                            height: screenHeight * 0.25,
                            width: screenHeight * 0.25,
                            child: Image.asset(
                              'assets/Success.gif',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.01),

                        Center(
                          child: Text(
                            'Ride Added Successfully',
                            style: GoogleFonts.lexend(
                              fontSize: screenWidth * 0.065,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Kindly check Requests in History Section',
                            style: GoogleFonts.lexend(
                              fontSize: screenWidth * 0.035,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),

                        // Share Button using reusable helper
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () => RideShareHelper.shareRide(
                              context: context,
                              date: date,
                              time: time,
                              from: from,
                              to: to,
                              availableSeats: passengers,
                              driverName: driverName,
                            ),
                            icon: const Icon(Icons.share, color: Color(0xFFFF3B30)),
                            label: Text(
                              'Share Ride Details',
                              style: GoogleFonts.lexend(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFF3B30),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.08,
                                vertical: screenHeight * 0.015,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.25),
                        Center(
                          child: TextButton(
                            onPressed: onGoToHistory,
                            child: Text(
                              'Go To History Section',
                              style: GoogleFonts.lexend(
                                fontSize: screenWidth * 0.035,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                                decorationThickness: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
