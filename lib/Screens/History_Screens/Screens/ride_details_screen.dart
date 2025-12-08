import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ride.dart';
import '../models/ride_request.dart';
import '../widgets/request_item.dart';

class RideDetailsScreen extends StatefulWidget {
  final Ride ride;

  const RideDetailsScreen({super.key, required this.ride});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  late List<RideRequest> requests;
  final Set<String> _seenPhones = {}; // to avoid duplicates
  StreamSubscription<QuerySnapshot>? _requestsSub;   // <<< NEW

  @override
  void initState() {
    super.initState();

    // Start with existing requests (if any) coming from Ride model
    requests = List.from(widget.ride.requests);

    // Mark existing request phones as seen to avoid duplicates
    for (final r in requests) {
      if (r.phone.trim().isNotEmpty) {
        _seenPhones.add(r.phone.trim());
      }
    }

    // 🔥 NEW: subscribe to ride_requests collection for this ride
    _subscribeToRideRequests();
  }

  void _subscribeToRideRequests() {
    final rideId = widget.ride.id ?? '';
    if (rideId.isEmpty) {
      debugPrint('RideDetailsScreen: rideId is empty — ride_requests query skipped');
      return;
    }

    _requestsSub = FirebaseFirestore.instance
        .collection('ride_requests')
        .where('rideId', isEqualTo: rideId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snapshot) {
      final List<RideRequest> loaded = [];

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final String name = (data['passengerName'] ?? '').toString().trim();
        final String phone = (data['passengerPhone'] ?? '').toString().trim();
        final String age = (data['passengerAge'] ?? '').toString().trim();
        final String status = (data['status'] ?? 'pending').toString().trim();


        // 👇 NEW
final dynamic rawGroupSize = data['groupSize'];
int groupSize = 1;
if (rawGroupSize is int) {
  groupSize = rawGroupSize;
} else if (rawGroupSize != null) {
  groupSize = int.tryParse(rawGroupSize.toString()) ?? 1;
}

 // 👇 bookingId
  final String bookingId = (data['bookingId'] ?? '').toString().trim();

        // Use phone as unique key if present
        final String uniqueKey = phone.isNotEmpty ? phone : '$name|$age';

        if (_seenPhones.contains(uniqueKey)) {
          // already in list (from initial model) – you could update status
          // but simplest is: ignore duplicates here
          continue;
        }

        _seenPhones.add(uniqueKey);

        loaded.add(
          RideRequest(
            name: name.isNotEmpty ? name : 'Passenger',
            phone: phone,
            age: age.isNotEmpty ? age : null,
            status: status.isNotEmpty ? status : 'pending',
            groupSize: groupSize,
            bookingId: bookingId.isNotEmpty ? bookingId : null,
            
            
          ),
        );
      }

      if (mounted) {
        setState(() {
          // If you want ONLY Firestore requests, replace the list:
          // requests = loaded;

          // If you want to keep pre-existing ones + new ones:
          // First clear only auto-loaded ones; but easiest:
          requests.addAll(loaded);
        });
      }
    }, onError: (err) {
      debugPrint('ride_requests subscription error: $err');
    });
  }

  @override
  void dispose() {
    _requestsSub?.cancel();   // <<< NEW
    super.dispose();
  }

  // -------------------- Accept / Reject with Firestore update --------------------
  Future<void> _upsertRideRequestToFirestore(
      RideRequest req, String newStatus) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseException(
        plugin: 'auth',
        message: 'Not authenticated',
      );
    }

    final coll = FirebaseFirestore.instance.collection('ride_requests');
    final String rideId = widget.ride.id ?? '';

    if (rideId.isEmpty) {
      throw Exception('Missing rideId');
    }

    // Find existing ride_request created by passenger
    final snapshot = await coll
        .where('rideId', isEqualTo: rideId)
        .where('passengerPhone', isEqualTo: req.phone.trim())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      // According to your rules, driver MUST NOT create ride_requests.
      debugPrint(
          'No ride_request found to update for rideId=$rideId phone=${req.phone}');
      return;
    }

    final docRef = snapshot.docs.first.reference;

    await docRef.update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
      'handledBy': user.uid, // driver uid
    });
  }

  /// Sync driver decision to the `bookings` collection so passenger UI updates.
  Future<void> _updateBookingStatusForPassenger(
      RideRequest req, String newStatus) async {
    try {
      final String rideId = widget.ride.id ?? '';
      if (rideId.isEmpty) return;

      Query baseQuery = FirebaseFirestore.instance
          .collection('bookings')
          .where('rideId', isEqualTo: rideId);

      final String phone = req.phone.trim();
      final String name = req.name.trim();
      final String age = (req.age ?? '').trim();

      QuerySnapshot snapshot;

      if (phone.isNotEmpty) {
        snapshot = await baseQuery
            .where('passengerPhone', isEqualTo: phone)
            .get();
      } else {
        Query q = baseQuery.where('passengerName', isEqualTo: name);
        if (age.isNotEmpty) {
          q = q.where('passengerAge', isEqualTo: age);
        }
        snapshot = await q.get();
      }

      for (final doc in snapshot.docs) {
        await doc.reference.update({
          'status': newStatus,
          'rideRequestStatus': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e, st) {
      debugPrint('Failed to update booking status: $e\n$st');
    }
  }

  // -----------------------------------------------------------------------
  // UI event handlers
  // -----------------------------------------------------------------------

  void handleAccept(int index) async {
    setState(() {
      requests[index] = RideRequest(
        name: requests[index].name,
        phone: requests[index].phone,
        status: 'accepted',
        age: requests[index].age,
        groupSize: requests[index].groupSize, 
        
      );
    });

    final req = requests[index];

    try {
      await _upsertRideRequestToFirestore(req, 'accepted');
      await _updateBookingStatusForPassenger(req, 'accepted');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Request accepted', style: GoogleFonts.lexend()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        requests[index] = RideRequest(
          name: requests[index].name,
          phone: requests[index].phone,
          status: 'pending',
          age: requests[index].age,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept request. Try again.',
              style: GoogleFonts.lexend()),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
    }
  }

  void handleReject(int index) async {
    setState(() {
      requests[index] = RideRequest(
        name: requests[index].name,
        phone: requests[index].phone,
        status: 'rejected',
        age: requests[index].age,
        groupSize: requests[index].groupSize,
      );
    });

    final req = requests[index];

    try {
      await _upsertRideRequestToFirestore(req, 'rejected');
      await _updateBookingStatusForPassenger(req, 'rejected');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Request rejected', style: GoogleFonts.lexend()),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        requests[index] = RideRequest(
          name: requests[index].name,
          phone: requests[index].phone,
          status: 'pending',
          age: requests[index].age,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reject request. Try again.',
              style: GoogleFonts.lexend()),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
    }
  }

  // -----------------------------------------------------------------------
  // UI helpers for address display
  // -----------------------------------------------------------------------

  Map<String, String> _splitAddress(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return {'city': '', 'rest': ''};
    final parts = trimmed.split(',');
    final city = parts[0].trim();
    final rest =
        parts.length > 1 ? parts.sublist(1).join(',').trim() : '';
    return {'city': city, 'rest': rest};
  }

  Widget _buildAddressColumn(String address, double screenWidth) {
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
          const SizedBox(height: 4),
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

  // -----------------------------------------------------------------------
  // BUILD (unchanged)
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
  // Red header bar
  Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF3B30), Color(0xFFFF3B30)],
      ),
    ),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        Expanded(
          child: Text(
            'Ride Details',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.12),
      ],
    ),
  ),

  // Content container with red background (rounded bottom)
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
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ride info card
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // date
                  Text(
                    widget.ride.date,
                    style: GoogleFonts.lexend(
                      fontSize: screenWidth * 0.038,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),

                  // Start time & from (left) | price (right)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left group: time + from-address column (flexible)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Start time
                            Text(
                              widget.ride.startTime,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lexend(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),

                            // Location icon + address column (Flexible)
                            Flexible(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: screenWidth * 0.04,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: screenWidth * 0.01),

                                  // Address columns (city above, rest below)
                                  Flexible(
                                    child: _buildAddressColumn(
                                      widget.ride.from,
                                      screenWidth,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right: price
                      SizedBox(width: screenWidth * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs: ${widget.ride.price}',
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
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.008),

                  // End time & to (left) | Edit (right)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // End time
                            Text(
                              widget.ride.endTime,
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

                            // To-address column
                            Flexible(
                              child: _buildAddressColumn(
                                widget.ride.to,
                                screenWidth,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Edit button
                      GestureDetector(
                        onTap: () {
                          // TODO: navigate edit
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              size: screenWidth * 0.045,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Edit',
                              style: GoogleFonts.lexend(
                                fontSize: screenWidth * 0.035,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015),

                  // Driver info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: screenWidth * 0.05,
                        backgroundColor: Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),

                      // Make driver info flexible to avoid overflow on small screens
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.ride.driverName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lexend(
                                fontSize: screenWidth * 0.038,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.ride.driverPhone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lexend(
                                fontSize: screenWidth * 0.032,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015),

                  // Requests header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Requests',
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.038,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'No. of Passengers: ${widget.ride.totalPassengers}',
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.032,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.012),

                  // Requests list or placeholder
                  if (requests.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                      ),
                      child: Center(
                        child: Text(
                          'No Pending Requests',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      itemCount: requests.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        return RequestItem(
                          request: request,
                          index: index,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          onAccept: handleAccept,
                          onReject: handleReject,
                        );
                      },
                    ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    ),
  ),
]

),
      ),
    );
  }
}
 