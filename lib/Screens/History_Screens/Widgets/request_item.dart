import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 ADD THIS
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

  // ===================== POPUP (UI changed only) =====================
  void _showGroupDetailsDialog(BuildContext context) {
    // If not actually a group or we don't know bookingId, just do nothing
    if (request.groupSize <= 1 || request.bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No extra group details available.',
            style: GoogleFonts.lexend(),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
          ),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255), // red background like screenshot
                borderRadius: BorderRadius.circular(22),
              ),
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('bookings')
                    .doc(request.bookingId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 80,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildWhiteCard(
                      child: Text(
                        'Failed to load group details.',
                        style: GoogleFonts.lexend(),
                      ),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return _buildWhiteCard(
                      child: Text(
                        'No booking details found.',
                        style: GoogleFonts.lexend(),
                      ),
                    );
                  }

                  final data =
                      snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  final passengers =
                      (data['passengers'] ?? []) as List<dynamic>;

                  if (passengers.isEmpty) {
                    return _buildWhiteCard(
                      child: Text(
                        'No passenger details available.',
                        style: GoogleFonts.lexend(),
                      ),
                    );
                  }

                  final int groupSize = passengers.length;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main white card
                      _buildWhiteCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Group of $groupSize',
                              style: GoogleFonts.lexend(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Passenger tiles
                            ...List.generate(passengers.length, (i) {
                              final p =
                                  passengers[i] as Map<String, dynamic>;
                              final String name =
                                  (p['name'] ?? 'Passenger ${i + 1}')
                                      .toString();
                              final String age =
                                  (p['age'] ?? 'N/A').toString();
                              final String phone =
                                  (p['phone'] ?? 'N/A').toString();

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withOpacity(0.03),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Passenger ${i + 1}',
                                      style: GoogleFonts.lexend(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    _detailRow('Name:', name),
                                    const SizedBox(height: 2),
                                    _detailRow('Age:', age),
                                    const SizedBox(height: 2),
                                    _detailRow('Phone:', phone),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Close button in red area
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(
                            'Close',
                            style: GoogleFonts.lexend(
                              color: const  Color(0xFFFF3B30),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // Small helpers for popup UI
  Widget _buildWhiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ===================== REST OF YOUR ORIGINAL CODE =====================
  @override
  Widget build(BuildContext context) {
    final String status = request.status.toLowerCase();

    return Container(
      margin: EdgeInsets.only(top: screenHeight * 0.015),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW
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

          SizedBox(height: screenHeight * 0.008),

          // GROUP BADGE (TAPPABLE)
          if (request.groupSize > 1) ...[
            GestureDetector(
              onTap: () => _showGroupDetailsDialog(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: screenHeight * 0.004,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  'Group of ${request.groupSize} • Tap to view',
                  style: GoogleFonts.lexend(
                    fontSize: screenWidth * 0.032,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.008),
          ],

          SizedBox(height: screenHeight * 0.004),

          // BUTTONS / STATUS
          if (status == 'pending' || status == 'requested')
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
          else if (status == 'accepted')
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
          else if (status == 'rejected')
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
            )
          else if (status == 'cancelled')
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'CANCELLED',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  color: Colors.orange,
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
