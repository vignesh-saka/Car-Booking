// ============================================
// File: lib/pages/History_Screens/Widgets/historyride_card.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride.dart';

class HistoryRideCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback onTap;
  final bool isLive;

  const HistoryRideCard({
    super.key,
    required this.ride,
    required this.onTap,
    required this.isLive,
  });

  /// Returns the first word before the first comma in [s].
  /// Example: "Hyderabad, Telangana" -> "Hyderabad"
  String _cityFirstWord(String? s) {
    if (s == null || s.trim().isEmpty) return '';
    final beforeComma = s.split(',')[0].trim();
    final parts = beforeComma.split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts[0] : beforeComma;
  }

  @override
  Widget build(BuildContext context) {
    final fromCity = _cityFirstWord(ride.from);
    final toCity = _cityFirstWord(ride.to);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time and Location (top row)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left group: start time + from city
                Flexible(
                  child: Row(
                    children: [
                      // Start time
                      Text(
                        ride.startTime,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // From city with icon - use Flexible to prevent overflow
                      Flexible(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                fromCity,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lexend(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Right: price
                const SizedBox(width: 8),
                Text(
                  'Rs: ${ride.price}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF4444),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Second row: end time + to city
            Row(
              children: [
                Text(
                  ride.endTime,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.black54,
                ),
                const SizedBox(width: 4),

                // To city (use Flexible)
                Flexible(
                  child: Text(
                    toCity,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lexend(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // Only show status button for Live rides
            if (isLive) ...[
              const SizedBox(height: 12),

              // 👇 DYNAMIC PENDING / NO PENDING USING FIRESTORE
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ride_requests')
                    .where('rideId', isEqualTo: ride.id ?? '')
                    .snapshots(),
                builder: (context, snapshot) {
                  bool hasPending = false;

                  if (snapshot.hasData) {
                    for (final doc in snapshot.data!.docs) {
                      final data =
                          doc.data() as Map<String, dynamic>? ?? {};
                      final status =
                          (data['status'] ?? '').toString().toLowerCase();
                      if (status == 'pending' || status == 'requested') {
                        hasPending = true;
                        break;
                      }
                    }
                  }

                  // If still loading and no data yet, you can choose default.
                  // We'll default to "No Pending Requests" to avoid false warnings.
                  if (hasPending) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4444),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'You have Pending Requests',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'You have No Pending Requests',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],

            const SizedBox(height: 12),

            // Driver Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                // Make driver info flexible to avoid overflow on small screens
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.driverName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ride.driverPhone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
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
