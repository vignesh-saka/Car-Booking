import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PublishsucessScreen extends StatelessWidget {
  const PublishsucessScreen({super.key});

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
                        SizedBox(height: screenHeight * 0.25),
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
                        SizedBox(height: screenHeight * 0.25),
                        Center(
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Go To History Section',
                              style: GoogleFonts.lexend(
                                fontSize: screenWidth * 0.035,
                                color: Colors.white,
                                decoration: TextDecoration
                                    .underline,
                                decorationColor: Colors
                                    .white,
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
