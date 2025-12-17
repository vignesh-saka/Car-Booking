import 'package:bookmycar/Screens/Avalabile_Ride_Screens/avalabile_rides_screen.dart';
import 'package:bookmycar/Screens/Avalabile_Ride_Screens/bookingsucess_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Firestore & Auth
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingDetailsScreen extends StatefulWidget {
  final RideData ride;

  final VoidCallback onBookingSuccess;

  const BookingDetailsScreen({
    super.key,
    required this.ride,
    required this.onBookingSuccess,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  int selectedIndex = 2;
  int numberOfPassengers = 1;
  List<PassengerDetail> passengers = [
    PassengerDetail(name: '', age: '', phone: ''),
  ];

  void incrementPassengers() {
    if (numberOfPassengers < widget.ride.availableSeats) {
      setState(() {
        numberOfPassengers++;
        if (passengers.length < numberOfPassengers) {
          passengers.add(PassengerDetail(name: '', age: '', phone: ''));
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No more seats available', style: GoogleFonts.lexend()),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
    }
  }

  // --------------------------------------------------
  // 📧 Send "Booking Requested" Email to Passenger
  // --------------------------------------------------
  Future<void> _sendBookingRequestedEmail({
    required String fromCity,
    required String toCity,
    required String date,
    required String departureTime,
  }) async {
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
        'subject': '🚗 Ride Request Sent Successfully | Book My Car',

        'text':
            'Hi $name,\n\n'
            '✅ Your ride request has been sent successfully.\n\n'
            'Route: $fromCity → $toCity\n'
            'Date: $date\n'
            'Departure Time: $departureTime\n\n'
            'Please wait for the rider’s response.\n\n'
            '— Book My Car Team',

        'html':
            '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Ride Requested</title>
</head>
<body style="margin:0; padding:0; background:#f5f5f5; font-family:Arial;">
  <table width="100%" cellpadding="0" cellspacing="0">
    <tr>
      <td align="center" style="padding:20px;">
        <table width="600" cellpadding="0" cellspacing="0"
          style="background:#ffffff; border-radius:10px;
          overflow:hidden; box-shadow:0 4px 12px rgba(0,0,0,0.1);">

          <!-- Header -->
          <tr>
            <td align="center" style="background:#d32f2f; padding:20px;">
              <h1 style="color:#ffffff; margin:0;">🚗 Book My Car</h1>
              <p style="color:#ffffff; margin:6px 0 0;">
                Ride Request Sent
              </p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:30px; color:#333;">
              <h2 style="color:#d32f2f;">✅ Request Submitted Successfully</h2>

              <p>Hi <b>$name</b>,</p>

              <p>Your ride request has been successfully sent with the following details:</p>

              <table width="100%" style="margin-top:15px;">
                <tr><td><b>From</b></td><td>$fromCity</td></tr>
                <tr><td><b>To</b></td><td>$toCity</td></tr>
                <tr><td><b>Date</b></td><td>$date</td></tr>
                <tr><td><b>Pickup Time</b></td><td>$departureTime</td></tr>
              </table>

              <div style="margin:25px 0; text-align:center;">
                <span style="background:#d32f2f; color:#fff;
                padding:12px 24px; border-radius:6px;">
                  ⏳ Waiting for Rider Response
                </span>
              </div>

              <p style="font-size:14px; color:#777;">
                You will be notified once the rider accepts or rejects your request.
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

  void decrementPassengers() {
    if (numberOfPassengers > 1) {
      setState(() {
        numberOfPassengers--;
        if (passengers.length > numberOfPassengers) {
          passengers.removeLast();
        }
      });
    }
  }


  // ----------------------------------------------------------
  // Save booking to Firestore + create ride_request
  // ----------------------------------------------------------
  void onBookNow() async {
    // Ensure passengers list length matches numberOfPassengers
    while (passengers.length < numberOfPassengers) {
      passengers.add(PassengerDetail(name: '', age: '', phone: ''));
    }

    bool allFieldsFilled = true;
    for (int i = 0; i < numberOfPassengers; i++) {
      final p = passengers[i];
      // Name and age required for all passengers
      if (i == 0) {
        if (p.phone.trim().isEmpty || p.phone.trim().length != 10) {
          allFieldsFilled = false;
          break;
        }
      }
      // Phone required only for first passenger
      if (i == 0 && p.phone.trim().isEmpty) {
        allFieldsFilled = false;
        break;
      }
    }

    if (!allFieldsFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill required passenger details.\n(First passenger: name, age, phone. Others: name, age.)',
            style: GoogleFonts.lexend(),
          ),
          backgroundColor: const Color(0xFFFF3B30),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // ✅ Require login (needed for Firestore rules)
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please sign in to book a ride',
            style: GoogleFonts.lexend(),
          ),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
      return;
    }
    final String userId = currentUser.uid;

    // Build passengers list to save (array)
    final List<Map<String, dynamic>> passengerMaps = List.generate(
      numberOfPassengers,
      (index) {
        final p = passengers[index];
        return {
          'name': p.name.trim(),
          'age': p.age.trim(),
          'phone': p.phone.trim(),
          'isPrimary': index == 0,
        };
      },
    );

    // -------- Booking document --------
    final Map<String, dynamic> bookingDoc = {
      'userId': userId, // ✅ must match request.auth.uid for rules
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'requested', // initial status
      'rideId': widget.ride.id, // used to link with ride & ride_details
      'date': widget.ride.date, // for splitting Booked / All Bookings
      // ride snapshot
      'ride': {
        'departureTime': widget.ride.departureTime,
        'arrivalTime': widget.ride.arrivalTime,
        'fromCity': widget.ride.fromCity,
        'toCity': widget.ride.toCity,
        'driverName': widget.ride.driverName,
        'driverPhone': widget.ride.driverPhone,
        'price': widget.ride.price,
        'date': widget.ride.date,
      },

      // all passengers
      'passengers': passengerMaps,
      'seatsBooked': numberOfPassengers,

      // primary passenger (for driver's queries)
      'passengerName': passengers[0].name.trim(),
      'passengerPhone': passengers[0].phone.trim(),
      'passengerAge': passengers[0].age.trim(),
    };

    try {
      // Save booking
      final docRef = await FirebaseFirestore.instance
          .collection('bookings')
          .add(bookingDoc);

      debugPrint('Booking created: ${docRef.id}');

      // Create ride_request for driver (passenger creates it)
      try {
        final String passengerUid = currentUser.uid;
        final String rideId = (widget.ride.id ?? '').toString();

        final Map<String, dynamic> rideRequestDoc = {
          'rideId': rideId,
          'passengerUid': passengerUid, // ✅ must equal auth.uid (rules)
          'passengerName': passengers[0].name.trim(),
          'passengerPhone': passengers[0].phone.trim(),
          'passengerAge': passengers[0].age.trim(),
          'status': 'requested',
          'bookingId': docRef.id,
          'groupSize': numberOfPassengers,
          'createdAt': FieldValue.serverTimestamp(),
        };
        await FirebaseFirestore.instance
            .collection('ride_requests')
            .add(rideRequestDoc);

        debugPrint('Ride request created for booking ${docRef.id}');

        // 📧 SEND EMAIL TO PASSENGER
        _sendBookingRequestedEmail(
          fromCity: widget.ride.fromCity,
          toCity: widget.ride.toCity,
          date: widget.ride.date,
          departureTime: widget.ride.departureTime,
        );
      } catch (e, st) {
        debugPrint('Failed to create ride_request: $e\n$st');
        // Not fatal – booking already exists.
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking successful!', style: GoogleFonts.lexend()),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );

      // Navigate to success screen
      Future.delayed(const Duration(milliseconds: 600), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingSucessScreen(
              onGoToMyBookings: () {
                Navigator.pop(context); // close success screen
                widget.onBookingSuccess(); // 👈 notify MainDashboard
              },
            ),
          ),
        );
      });
    } catch (e, st) {
      debugPrint('Booking save error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save booking. Please try again.',
            style: GoogleFonts.lexend(),
          ),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
    }
  }

  // --------------------------------------------------------------------
  // UI build
  // --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.025,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: screenWidth * 0.05,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Booking Details',
                            style: GoogleFonts.lexend(
                              fontSize: screenWidth * 0.055,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.09),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Booking Form Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Combined Time + Price Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: times & locations
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Departure block
                                  Text(
                                    widget.ride.departureTime,
                                    style: GoogleFonts.lexend(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.004),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: screenWidth * 0.04,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: screenWidth * 0.01),
                                      Flexible(
                                        child: Text(
                                          widget.ride.fromCity,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.lexend(
                                            fontSize: screenWidth * 0.035,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.012),

                                  // Arrival block
                                  Text(
                                    widget.ride.arrivalTime,
                                    style: GoogleFonts.lexend(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.004),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: screenWidth * 0.04,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: screenWidth * 0.01),
                                      Flexible(
                                        child: Text(
                                          widget.ride.toCity,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.lexend(
                                            fontSize: screenWidth * 0.035,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Right: price
                            SizedBox(width: screenWidth * 0.02),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: screenWidth * 0.32,
                                minWidth: 0,
                              ),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  'Rs. ${widget.ride.price}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.lexend(
                                    fontSize: screenWidth * 0.042,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFF3B30),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Divider(
                          height: screenHeight * 0.025,
                          color: Colors.grey[300],
                        ),

                        // Driver Info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: screenWidth * 0.05,
                              backgroundColor: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                color: Colors.grey[600],
                                size: screenWidth * 0.05,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.ride.driverName,
                                    style: GoogleFonts.lexend(
                                      fontSize: screenWidth * 0.038,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    widget.ride.driverPhone,
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

                        Divider(
                          height: screenHeight * 0.025,
                          color: Colors.grey[300],
                        ),

                        Center(
                          child: Text(
                            'No. of Passengers: ${widget.ride.availableSeats}',
                            style: GoogleFonts.lexend(
                              fontSize: screenWidth * 0.038,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        Center(
                          child: Text(
                            'Please Enter Booking Details to Continue',
                            style: GoogleFonts.lexend(
                              fontSize: screenWidth * 0.035,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        Center(
                          child: Text(
                            'Enter No.of Passengers:',
                            style: GoogleFonts.lexend(
                              fontSize: screenWidth * 0.038,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.012),

                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: decrementPassengers,
                                child: Container(
                                  width: screenWidth * 0.1,
                                  height: screenWidth * 0.1,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Color(0xFFFF4444),
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.05),
                              Text(
                                '$numberOfPassengers',
                                style: GoogleFonts.lexend(
                                  fontSize: screenWidth * 0.06,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.05),
                              GestureDetector(
                                onTap: incrementPassengers,
                                child: Container(
                                  width: screenWidth * 0.1,
                                  height: screenWidth * 0.1,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF4444),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.025),

                        // Passenger forms
                        ...List.generate(numberOfPassengers, (index) {
                          if (index >= passengers.length) {
                            passengers.add(
                              PassengerDetail(name: '', age: '', phone: ''),
                            );
                          }
                          return PassengerForm(
                            passengerNumber: index + 1,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            onNameChanged: (value) {
                              passengers[index].name = value;
                            },
                            onAgeChanged: (value) {
                              passengers[index].age = value;
                            },
                            onPhoneChanged: (value) {
                              passengers[index].phone = value;
                            },
                            phoneRequired: index == 0,
                          );
                        }),

                        SizedBox(height: screenHeight * 0.02),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onBookNow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF3B30),
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Book Now',
                              style: GoogleFonts.lexend(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PassengerDetail {
  String name;
  String age;
  String phone;

  PassengerDetail({required this.name, required this.age, required this.phone});
}

class PassengerForm extends StatelessWidget {
  final int passengerNumber;
  final double screenWidth;
  final double screenHeight;
  final Function(String) onNameChanged;
  final Function(String) onAgeChanged;
  final Function(String) onPhoneChanged;
  final bool phoneRequired;

  const PassengerForm({
    super.key,
    required this.passengerNumber,
    required this.screenWidth,
    required this.screenHeight,
    required this.onNameChanged,
    required this.onAgeChanged,
    required this.onPhoneChanged,
    this.phoneRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passenger $passengerNumber',
            style: GoogleFonts.lexend(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),

          Text(
            'Name *',
            style: GoogleFonts.lexend(
              fontSize: screenWidth * 0.035,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          TextField(
            onChanged: onNameChanged,
            decoration: InputDecoration(
              hintText: 'Enter Passenger Name',
              hintStyle: GoogleFonts.lexend(
                color: Colors.grey[400],
                fontSize: screenWidth * 0.035,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFFF3B30)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.015,
              ),
            ),
            style: GoogleFonts.lexend(fontSize: screenWidth * 0.038),
          ),
          SizedBox(height: screenHeight * 0.015),

          Text(
            'Age *',
            style: GoogleFonts.lexend(
              fontSize: screenWidth * 0.035,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          TextField(
            onChanged: onAgeChanged,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter Age',
              hintStyle: GoogleFonts.lexend(
                color: Colors.grey[400],
                fontSize: screenWidth * 0.035,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFFF3B30)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.015,
              ),
            ),
            style: GoogleFonts.lexend(fontSize: screenWidth * 0.038),
          ),
          SizedBox(height: screenHeight * 0.015),

          Text(
            'Phone${phoneRequired ? ' *' : ' (optional)'}',
            style: GoogleFonts.lexend(
              fontSize: screenWidth * 0.035,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          TextField(
            onChanged: onPhoneChanged,
            keyboardType: TextInputType.phone,
            maxLength: 10, // ✅ limit to 10
            decoration: InputDecoration(
              counterText: "", // ✅ hides counter UI
              hintText: phoneRequired
                  ? 'Enter Phone Number'
                  : 'Enter Phone Number (optional)',
              hintStyle: GoogleFonts.lexend(
                color: Colors.grey[400],
                fontSize: screenWidth * 0.035,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFFF3B30)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.015,
              ),
            ),
            style: GoogleFonts.lexend(fontSize: screenWidth * 0.038),
          ),
        ],
      ),
    );
  }
}
