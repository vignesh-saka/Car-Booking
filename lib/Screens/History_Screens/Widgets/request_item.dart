import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ride_request.dart';

class RequestItem extends StatelessWidget {
  final RideRequest request;
  final int index;
  final double screenWidth;
  final double screenHeight;
  final Function(int) onAccept;
  final Function(int) onReject;

  const RequestItem({
    super.key,
    required this.request,
    required this.index,
    required this.screenWidth,
    required this.screenHeight,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: screenHeight * 0.015),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.05,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.grey[600]),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      style: GoogleFonts.lexend(
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      request.phone,
                      style: GoogleFonts.lexend(
                        fontSize: screenWidth * 0.032,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (request.age != null)
                Text(
                  'Age: ${request.age}',
                  style: GoogleFonts.lexend(
                    fontSize: screenWidth * 0.032,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          
          // Action Buttons
          if (request.status == 'pending')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onAccept(index),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'ACCEPT',
                      style: GoogleFonts.lexend(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onReject(index),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'REJECT',
                      style: GoogleFonts.lexend(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else if (request.status == 'accepted')
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ACCEPTED',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            )
          else if (request.status == 'rejected')
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'REJECTED',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ),
        ],
      ),
    );
  }
}