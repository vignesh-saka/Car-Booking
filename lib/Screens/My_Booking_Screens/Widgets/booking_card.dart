import 'package:bookmycar/Screens/My_Booking_Screens/Model/models.dart';
import 'package:bookmycar/controllers/notification_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // --------- ADDRESS HELPERS ---------
  Map<String, String> _splitAddress(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return {'city': '', 'rest': ''};
    final parts = trimmed.split(',');
    final city = parts[0].trim();
    final rest =
        parts.length > 1 ? parts.sublist(1).join(',').trim() : '';
    return {'city': city, 'rest': rest};
  }

  Widget _buildAddressColumn(String address) {
    final parts = _splitAddress(address);
    final city = parts['city']!;
    final rest = parts['rest']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          city,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lexend(
            fontSize: screenWidth * 0.038,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (rest.isNotEmpty) ...[
          SizedBox(height: screenHeight * 0.002),
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

  // --------- POPUP FOR PASSENGER DETAILS ---------
void _showPassengerPopup(BuildContext context) {
  final passengers = booking.passengers;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        title: Text(
          passengers.length > 1
              ? 'Group of ${passengers.length}'
              : 'Passenger Details',
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: passengers.isEmpty
              ? Text(
                  'No passenger details available',
                  style: GoogleFonts.lexend(),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: passengers.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final p =
                        (passengers[index] as Map?) ?? <String, dynamic>{};
                    final name =
                        (p['name'] ?? 'Passenger').toString();
                    final age =
                        (p['age'] ?? 'N/A').toString();
                    final phone =
                        (p['phone'] ?? 'N/A').toString();

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Passenger ${index + 1}',
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
                  },
                ),
        ),
        actionsPadding:
            const EdgeInsets.only(right: 12, bottom: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.lexend(
                color: const Color(0xFFFF3B30),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    },
  );
}

// helper for "Name: value" / "Age: value" / "Phone: value"
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

// --------- DELETE RIDE LOGIC ---------
Future<void> _cancelRide(BuildContext context) async {
  final navigator = Navigator.of(context);
  final scaffoldState = ScaffoldMessenger.of(context);

  try {
    // 1. Soft-delete booking from Firestore by updating status to 'cancelled'
    await FirebaseFirestore.instance.collection('bookings').doc(booking.id).update({
      'status': 'cancelled',
    });

    // 1b. Synchronize with ride_requests so driver sees CANCELLED in History
    final rideRequestsSnapshot = await FirebaseFirestore.instance
        .collection('ride_requests')
        .where('bookingId', isEqualTo: booking.id)
        .get();

    for (var doc in rideRequestsSnapshot.docs) {
      await doc.reference.update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // 2. Fetch driver (the creator of the ride) email to notify them
    final rideSnapshot = await FirebaseFirestore.instance.collection('rides').doc(booking.rideId).get();
    if (rideSnapshot.exists) {
      final rideData = rideSnapshot.data() as Map<String, dynamic>;
      final String driverId = rideData['createdBy'] ?? '';
      
      if (driverId.isNotEmpty) {
        final driverDoc = await FirebaseFirestore.instance.collection('users').doc(driverId).get();
        if (driverDoc.exists) {
          final driverData = driverDoc.data() ?? {};
          final String driverEmail = (driverData['email'] ?? '').toString().trim();
          final String driverName = (driverData['name'] ?? 'Driver').toString().trim();

          final currentUser = FirebaseAuth.instance.currentUser;
          final userDoc = currentUser != null ? await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get() : null;
          final String passengerName = userDoc != null ? (userDoc.data()?['name'] ?? 'A passenger') : 'A passenger';

          // Send Email
          if (driverEmail.isNotEmpty) {
            await FirebaseFirestore.instance.collection("mail").add({
              "to": driverEmail,
              "message": {
                "subject": "❌ Ride Cancelled | Book My Car",
                "text": "Hi $driverName,\n\n$passengerName has cancelled their booking for your ride.\n\nRoute: ${booking.from} → ${booking.to}\nDate: ${booking.date}\nPickup Time: ${booking.startTime}\n\n— Book My Car Team",
                "html": '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Ride Cancelled</title>
</head>
<body style="margin:0; padding:0; background:#f5f5f5; font-family:Arial;">
  <table width="100%" cellpadding="0" cellspacing="0">
    <tr>
      <td align="center" style="padding:20px;">
        <table width="600" cellpadding="0" cellspacing="0"
          style="background:#ffffff; border-radius:10px; overflow:hidden;
          box-shadow:0 4px 12px rgba(0,0,0,0.1);">

          <!-- Header -->
          <tr>
            <td align="center" style="background:#d32f2f; padding:20px;">
              <h1 style="color:#ffffff; margin:0;">🚗 Book My Car</h1>
              <p style="color:#ffffff; margin:6px 0 0;">Booking Cancelled</p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:30px; color:#333;">
              <h2 style="color:#d32f2f;">❌ A Passenger Cancelled Their Booking</h2>

              <p>Hi <b>$driverName</b>,</p>

              <p><b>$passengerName</b> has cancelled their booking for your ride. Here are the details of the ride:</p>

              <table width="100%" style="margin-top:15px;">
                <tr><td><b>From:</b></td><td>${booking.from}</td></tr>
                <tr><td><b>To:</b></td><td>${booking.to}</td></tr>
                <tr><td><b>Date:</b></td><td>${booking.date}</td></tr>
                <tr><td><b>Pickup Time:</b></td><td>${booking.startTime}</td></tr>
              </table>

              <p style="font-size:14px; color:#777; margin-top:25px">
                The seats have been freed up for other passengers to book.
              </p>

              <p>— <b>Book My Car Team</b></p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td align="center" style="background:#fafafa;
            padding:15px; font-size:12px; color:#999;">
              © ${DateTime.now().year} Book My Car
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
''',
              },
            });
          }

          // Send Push Notification
          await NotificationController().sendNotification(
            toUserId: driverId,
            title: "Booking Cancelled",
            body: "$passengerName cancelled their booking for your ride on ${booking.date}.",
            type: "booking_cancelled",
          );
        }
      }
    }

    scaffoldState.showSnackBar(
      const SnackBar(content: Text('Ride cancelled successfully.')),
    );
  } catch (e) {
    debugPrint('Error cancelling ride: $e');
    scaffoldState.showSnackBar(
      const SnackBar(content: Text('Failed to cancel ride. Please try again later.')),
    );
  }
}

void _showDeleteConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        title: Text(
          'Cancel Ride',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to cancel this booking? This action cannot be undone and the driver will be notified.',
          style: GoogleFonts.lexend(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Keep It', style: GoogleFonts.lexend(color: Colors.grey[700])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              _cancelRide(context);
            },
            child: Text('Cancel Ride', style: GoogleFonts.lexend(color: Colors.white)),
          ),
        ],
      );
    },
  );
}


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
          // ===================== DATE OF RIDE & DELETE ICON =====================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: screenWidth * 0.045,
                    color: Colors.black54,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    booking.date,
                    style: GoogleFonts.lexend(
                      fontSize: screenWidth * 0.038,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              if (booking.status.toLowerCase() == 'accepted' && !booking.isCompleted)
                GestureDetector(
                  onTap: () => _showDeleteConfirmation(context),
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.015),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: const Color(0xFFFF3B30),
                      size: screenWidth * 0.05,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: screenHeight * 0.015),

          // ===================== TOP ROW =====================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.startTime,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Icon(
                      Icons.location_on,
                      size: screenWidth * 0.04,
                      color: Colors.black54,
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Expanded(
                      child: _buildAddressColumn(booking.from),
                    ),
                  ],
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                'Rs: ${booking.price}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF4444),
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.008),

          // ===================== SECOND ROW =====================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.endTime,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Icon(
                Icons.location_on,
                size: screenWidth * 0.04,
                color: Colors.black54,
              ),
              SizedBox(width: screenWidth * 0.01),
              Expanded(
                child: _buildAddressColumn(booking.to),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.015),

          // ===================== DRIVER INFO + DESCRIPTION =====================
          Row(
            crossAxisAlignment: booking.isCompleted ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
                    if (booking.description.trim().isNotEmpty) ...[
                      Text(
                        booking.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.034,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.004),
                    ],
                    Text(
                      booking.driverName,
                      style: GoogleFonts.lexend(
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (!booking.isCompleted)
                      Row(
                        children: [
                          Text(
                            booking.driverPhone,
                            style: GoogleFonts.lexend(
                              fontSize: screenWidth * 0.032,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          GestureDetector(
                            onTap: () async {
                              final Uri url = Uri.parse('tel:${booking.driverPhone}');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                debugPrint('Could not launch $url');
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(screenWidth * 0.015),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.call,
                                color: Colors.green,
                                size: screenWidth * 0.04,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.015),

          // ===================== GROUP BADGE (TAP FOR POPUP) =====================
          if (booking.passengerCount > 0) ...[
            GestureDetector(
              onTap: () => _showPassengerPopup(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.006,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Text(
                  'Group of ${booking.passengerCount}',
                  style: GoogleFonts.lexend(
                    fontSize: screenWidth * 0.032,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
          ],

          // ===================== STATUS BADGE =====================
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
