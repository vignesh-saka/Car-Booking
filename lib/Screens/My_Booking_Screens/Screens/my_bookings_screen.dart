// my_bookings_screen.dart
import 'dart:async';

import 'package:bookmycar/Screens/My_Booking_Screens/Model/models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/booking_card.dart';
import 'package:bookmycar/widgets/notification_icon.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

// final Set<String> _processedBookingIds = {};
StreamSubscription<QuerySnapshot>? _bookingSub;

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 1; // My Bookings tab selected

  void _listenForBookingStatusChanges(String uid) {
    _bookingSub?.cancel();

    _bookingSub = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          for (final doc in snapshot.docs) {
            // ignore: unnecessary_cast
            final data = doc.data() as Map<String, dynamic>;
            // final bookingId = doc.id;

            // Prevent re-processing same booking in this session
            // if (_processedBookingIds.contains(bookingId)) continue;

            final status = (data['status'] ?? '').toString().toLowerCase();
            // final bool acceptEmailSent = data['acceptEmailSent'] == true;
            // final bool rejectEmailSent = data['rejectEmailSent'] == true;

            final booking = _bookingFromDoc(doc);

            if (status == 'accepted' && data['acceptEmailSent'] != true) {
              // _processedBookingIds.add(bookingId);

              Future.microtask(() async {
                await _sendBookingAcceptedEmail(booking);
                await doc.reference.update({
                  'acceptEmailSent': true,
                  'acceptEmailSentAt': FieldValue.serverTimestamp(),
                });
              });
            }

            if (status == 'rejected' && data['rejectEmailSent'] != true) {
              // _processedBookingIds.add(bookingId);

              Future.microtask(() async {
                await _sendBookingRejectedEmail(booking);
                await doc.reference.update({
                  'rejectEmailSent': true,
                  'rejectEmailSentAt': FieldValue.serverTimestamp(),
                });
              });
            }
          }
        });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _listenForBookingStatusChanges(uid);
    }
  }

  @override
  void dispose() {
    _bookingSub?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _sendBookingAcceptedEmail(Booking booking) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = userDoc.data() ?? {};
    final String email = (data['email'] ?? user.email ?? '').toString().trim();
    final String name = (data['name'] ?? user.displayName ?? 'there')
        .toString()
        .trim();

    if (email.isEmpty) return;

    await FirebaseFirestore.instance.collection('mail').add({
      'to': email,
      'message': {
        'subject': '✅ Ride Request Accepted | Book My Car',

        'html':
            '''
<!DOCTYPE html>
<html>
<body style="background:#f5f5f5; font-family:Arial;">
  <table width="100%" cellpadding="0" cellspacing="0">
    <tr>
      <td align="center" style="padding:20px;">
        <table width="600" style="background:#fff; border-radius:10px; overflow:hidden;">
          <tr>
            <td style="background:#d32f2f; padding:20px; color:#fff; text-align:center;">
              <h1>🚗 Book My Car</h1>
              <p>Ride Accepted</p>
            </td>
          </tr>
          <tr>
            <td style="padding:30px;">
              <h2 style="color:#d32f2f;">🎉 Request Accepted!</h2>
              <p>Hi <b>$name</b>,</p>
              <p>Your ride request has been <b>successfully accepted</b>.</p>

              <table width="100%" style="margin-top:15px;">
                <tr><td><b>From:</b></td><td>${booking.from}</td></tr>
                <tr><td><b>To:</b></td><td>${booking.to}</td></tr>
                <tr><td><b>Date:</b></td><td>${booking.date}</td></tr>
                <tr><td><b>Start Time:</b></td><td>${booking.startTime}</td></tr>
              </table>

              <p style="margin-top:20px;">
                You can now proceed with your travel.
              </p>

              <p>— <b>Book My Car Team</b></p>
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

  Future<void> _sendBookingRejectedEmail(Booking booking) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = userDoc.data() ?? {};
    final String email = (data['email'] ?? user.email ?? '').toString().trim();
    final String name = (data['name'] ?? user.displayName ?? 'there')
        .toString()
        .trim();

    if (email.isEmpty) return;

    await FirebaseFirestore.instance.collection('mail').add({
      'to': email,
      'message': {
        'subject': '❌ Ride Request Rejected | Book My Car',

        'html':
            '''
<!DOCTYPE html>
<html>
<body style="background:#f5f5f5; font-family:Arial;">
  <table width="100%" cellpadding="0" cellspacing="0">
    <tr>
      <td align="center" style="padding:20px;">
        <table width="600" style="background:#fff; border-radius:10px; overflow:hidden;">
          <tr>
            <td style="background:#d32f2f; padding:20px; color:#fff; text-align:center;">
              <h1>🚗 Book My Car</h1>
              <p>Ride Request Update</p>
            </td>
          </tr>
          <tr>
            <td style="padding:30px;">
              <h2 style="color:#d32f2f;">😔 Request Rejected</h2>
              <p>Hi <b>$name</b>,</p>
              <p>
                Unfortunately, your ride request has been <b>rejected</b>.
              </p>

              <table width="100%" style="margin-top:15px;">
                <tr><td><b>From:</b></td><td>${booking.from}</td></tr>
                <tr><td><b>To:</b></td><td>${booking.to}</td></tr>
                <tr><td><b>Date:</b></td><td>${booking.date}</td></tr>
              </table>

              <p style="margin-top:20px;">
                You may try booking another available ride.
              </p>

              <p>— <b>Book My Car Team</b></p>
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

  // ------------------ Helpers ------------------

  DateTime? _tryParseDate(String input) {
    final s = input.trim();
    if (s.isEmpty) return null;

    // Try slash format d/M/yyyy
    if (s.contains('/')) {
      final parts = s.split('/');
      if (parts.length == 3) {
        try {
          final d = int.tryParse(parts[0].trim()) ?? 0;
          final m = int.tryParse(parts[1].trim()) ?? 0;
          final y = int.tryParse(parts[2].trim()) ?? 0;
          if (d > 0 && m > 0 && y > 0) return DateTime(y, m, d);
        } catch (_) {}
      }
    }

    // Try ISO yyyy-MM-dd
    if (s.contains('-')) {
      try {
        final dt = DateTime.tryParse(s);
        if (dt != null) return DateTime(dt.year, dt.month, dt.day);
      } catch (_) {}
    }

    // Try "12 November 2025" or "Mon 12 November 2025"
    final monthNames = {
      'january': 1,
      'february': 2,
      'march': 3,
      'april': 4,
      'may': 5,
      'june': 6,
      'july': 7,
      'august': 8,
      'september': 9,
      'october': 10,
      'november': 11,
      'december': 12,
    };

    final tokens = s.split(RegExp(r'\s+'));
    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i].replaceAll(',', '').toLowerCase();
      if (monthNames.containsKey(token)) {
        int? day;
        int? year;
        if (i - 1 >= 0) {
          day = int.tryParse(tokens[i - 1].replaceAll(',', ''));
        }
        if (i + 1 < tokens.length) {
          year = int.tryParse(tokens[i + 1].replaceAll(',', ''));
        }
        if (day != null && year != null) {
          final m = monthNames[token]!;
          return DateTime(year, m, day);
        }
      }
    }

    try {
      final dt = DateTime.tryParse(s);
      if (dt != null) return DateTime(dt.year, dt.month, dt.day);
    } catch (_) {}

    return null;
  }

  bool _isCompletedByDate(String dateString) {
    final dt = _tryParseDate(dateString);
    if (dt == null) return false;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return dt.isBefore(todayDate);
  }

  // 🔥 UPDATED: build Booking from Firestore document
  Booking _bookingFromDoc(QueryDocumentSnapshot doc) {
    final Map<String, dynamic> data =
        (doc.data() as Map<String, dynamic>?) ?? {};

    final rideId =
        data['rideId']?.toString() ??
        data['ride_id']?.toString() ??
        data['ride']?['id']?.toString() ??
        doc.id;

    final date =
        data['date']?.toString() ??
        (data['ride'] is Map ? (data['ride']['date']?.toString() ?? '') : '');

    final startTime =
        data['startTime']?.toString() ??
        data['pickupTime']?.toString() ??
        (data['ride'] is Map
            ? (data['ride']['departureTime']?.toString() ?? '')
            : '');

    final endTime =
        data['endTime']?.toString() ??
        data['dropTime']?.toString() ??
        (data['ride'] is Map
            ? (data['ride']['arrivalTime']?.toString() ?? '')
            : '');

    final from =
        data['from']?.toString() ??
        data['ride.fromCity']?.toString() ??
        (data['ride'] is Map
            ? (data['ride']['fromCity']?.toString() ?? '')
            : '');

    final to =
        data['to']?.toString() ??
        data['ride.toCity']?.toString() ??
        (data['ride'] is Map ? (data['ride']['toCity']?.toString() ?? '') : '');

    final driverName =
        data['driverName']?.toString() ??
        data['riderName']?.toString() ??
        (data['ride'] is Map
            ? (data['ride']['driverName']?.toString() ??
                  data['ride']['riderName']?.toString() ??
                  '')
            : '');

    final driverPhone =
        data['driverPhone']?.toString() ??
        data['phone']?.toString() ??
        (data['ride'] is Map
            ? (data['ride']['driverPhone']?.toString() ??
                  data['ride']['phoneNumber']?.toString() ??
                  '')
            : '');

    final price =
        data['price']?.toString() ??
        (data['ride'] is Map ? (data['ride']['price']?.toString() ?? '') : '');

    // 👇 NEW: primary passenger details (we stored them in bookingDoc)
    final String? passengerName = data['passengerName']?.toString();
    final String? passengerAge = data['passengerAge']?.toString();
    final String? passengerPhone = data['passengerPhone']?.toString();

    // 👇 NEW: parse passengers array
    List<Map<String, dynamic>> passengers = [];
    if (data['passengers'] is List) {
      passengers = (data['passengers'] as List)
          .where((e) => e is Map)
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    // if Firestore has no passengers array, fall back to single passenger fields
    if (passengers.isEmpty && passengerName != null) {
      passengers = [
        {'name': passengerName, 'age': passengerAge, 'phone': passengerPhone},
      ];
    }

    // 👇 your passengerCount logic (you likely already have something)
    int passengerCount = passengers.isNotEmpty
        ? passengers.length
        : (data['groupSize'] is int
              ? data['groupSize'] as int
              : (int.tryParse((data['passengerCount'] ?? '0').toString()) ??
                    0));

    // 👇 BETTER: derive passengerCount from seatsBooked / passengers[] / fallback
    // int passengerCount = 0;

    if (data['seatsBooked'] is int) {
      passengerCount = data['seatsBooked'] as int;
    } else if (data['passengerCount'] is int) {
      passengerCount = data['passengerCount'] as int;
    } else if (data['passengers'] is List) {
      passengerCount = (data['passengers'] as List).length;
    } else {
      passengerCount =
          int.tryParse((data['passengerCount'] ?? '0').toString()) ?? 0;
    }

    final status =
        (data['status']?.toString() ??
                data['rideRequestStatus']?.toString() ??
                'requested')
            .toLowerCase();

    return Booking(
      id: doc.id,
      rideId: rideId,
      date: date ?? '',
      startTime: startTime ?? '',
      endTime: endTime ?? '',
      from: from ?? '',
      to: to ?? '',
      driverName: driverName ?? '',
      driverPhone: driverPhone ?? '',
      price: price ?? '',
      passengerCount: passengerCount,
      status: status,
      isCompleted: _isCompletedByDate(date ?? ''),
      description: data['description']?.toString() ?? '',
      passengerName: passengerName,
      passengerAge: passengerAge,
      passengerPhone: passengerPhone,
      passengers: passengers,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFF3B30),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'My Bookings',
                  style: GoogleFonts.lexend(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  child: Text(
                    'Please sign in to view your bookings.',
                    style: GoogleFonts.lexend(
                      fontSize: screenWidth * 0.04,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bookingsStream = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: bookingsStream,
          builder: (context, snapshot) {
            Widget headerAndTabs = Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFF3B30),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40), // Balance the icon
                        Text(
                          'My Bookings',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const NotificationIcon(),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      dividerColor: Colors.transparent,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black54,
                      labelStyle: GoogleFonts.lexend(
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth * 0.04,
                      ),
                      unselectedLabelStyle: GoogleFonts.lexend(
                        fontWeight: FontWeight.w400,
                        fontSize: screenWidth * 0.04,
                      ),
                      tabs: const [
                        Tab(text: 'Booked'),
                        Tab(text: 'All Bookings'),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            );

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                children: [
                  headerAndTabs,
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ],
              );
            }

            if (snapshot.hasError) {
              return Column(
                children: [
                  headerAndTabs,
                  Expanded(
                    child: Center(
                      child: Text(
                        'Error loading bookings',
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.04,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            final docs = snapshot.data?.docs ?? [];
            final List<Booking> allBookings = docs
                .map((d) => _bookingFromDoc(d))
                .toList();

            // for (final doc in docs) {
            //   final data = doc.data() as Map<String, dynamic>;
            //   final status = (data['status'] ?? '').toString().toLowerCase();

            //   final bool acceptEmailSent = data['acceptEmailSent'] == true;
            //   final bool rejectEmailSent = data['rejectEmailSent'] == true;

            //   final booking = _bookingFromDoc(doc);

            //   if (status == 'accepted' && !acceptEmailSent) {
            //     _sendBookingAcceptedEmail(booking);
            //     doc.reference.update({
            //       'acceptEmailSent': true,
            //       'acceptEmailSentAt': FieldValue.serverTimestamp(),
            //     });
            //   }

            //   if (status == 'rejected' && !rejectEmailSent) {
            //     _sendBookingRejectedEmail(booking);
            //     doc.reference.update({
            //       'rejectEmailSent': true,
            //       'rejectEmailSentAt': FieldValue.serverTimestamp(),
            //     });
            //   }
            // }

            final List<Booking> bookedBookings = allBookings
                .where((b) => !b.isCompleted)
                .toList();
            final List<Booking> completedBookings = allBookings
                .where((b) => b.isCompleted)
                .toList();

            return Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFF3B30),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  headerAndTabs,
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBookingsList(
                          bookedBookings,
                          screenWidth,
                          screenHeight,
                        ),
                        _buildBookingsList(
                          completedBookings,
                          screenWidth,
                          screenHeight,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingsList(
    List<Booking> bookings,
    double screenWidth,
    double screenHeight,
  ) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(
          'No bookings found',
          style: GoogleFonts.lexend(
            fontSize: screenWidth * 0.04,
            color: Colors.white,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.01,
      ),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return BookingCard(
          booking: bookings[index],
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        );
      },
    );
  }
}
