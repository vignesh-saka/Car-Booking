import 'package:bookmycar/Screens/Avalabile_Ride_Screens/avalabile_rides_screen.dart';
import 'package:bookmycar/Screens/Avalabile_Ride_Screens/bookingsucess_screen.dart';
import 'package:bookmycar/Screens/Comman/bottom_navigation.dart';
// ignore: unused_import
import 'package:bookmycar/Screens/Comman/nav_bar_item.dart';
import 'package:bookmycar/Screens/History_Screens/Screens/history_screen.dart';
import 'package:bookmycar/Screens/My_Booking_Screens/Screens/my_bookings_screen.dart';
import 'package:bookmycar/Screens/Profile_Screen/profile_screen.dart';
import 'package:bookmycar/Screens/Publish_Ride_Screens/publishride_screen.dart';
import 'package:bookmycar/Screens/Serach_Screen/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingDetailsScreen extends StatefulWidget {
  final RideData ride;

  const BookingDetailsScreen({super.key, required this.ride});

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
        passengers.add(PassengerDetail(name: '', age: '', phone: ''));
      });
    }
  }

  void decrementPassengers() {
    if (numberOfPassengers > 1) {
      setState(() {
        numberOfPassengers--;
        passengers.removeLast();
      });
    }
  }

  void onNavItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    switch (index) {
    case 0:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PublishRideScreen()),
      );
      break;

    case 1:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyBookingsScreen()),
      );
      break;

    case 2:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchScreen()),
      );
      break;

    case 3:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HistoryScreen()),
      );
      break;

    case 4:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
      break;

    default:
      break;
  }
  }

  void onBookNow() {
    bool allFieldsFilled = true;
    for (int i = 0; i < passengers.length; i++) {
      if (passengers[i].name.isEmpty ||
          passengers[i].age.isEmpty ||
          passengers[i].phone.isEmpty) {
        allFieldsFilled = false;
        break;
      }
    }

    if (!allFieldsFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all passenger details',
            style: GoogleFonts.lexend(),
          ),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
      return;
    }

    print('Booking confirmed for $numberOfPassengers passengers');
    for (int i = 0; i < passengers.length; i++) {
      print(
        'Passenger ${i + 1}: ${passengers[i].name}, ${passengers[i].age}, ${passengers[i].phone}',
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking successful!', style: GoogleFonts.lexend()),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
    Future.delayed(const Duration(milliseconds: 600), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BookingSucessScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFF3B30),
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical:   screenHeight * 0.025,
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
                        // Ride Summary
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                    Text(
                                      widget.ride.fromCity,
                                      style: GoogleFonts.lexend(
                                        fontSize: screenWidth * 0.035,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Spacer(),
                            Text(
                              'Rs. ${widget.ride.price}',
                              style: GoogleFonts.lexend(
                                fontSize: screenWidth * 0.042,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFF3B30),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.012),

                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                    Text(
                                      widget.ride.toCity,
                                      style: GoogleFonts.lexend(
                                        fontSize: screenWidth * 0.035,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF4444),
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

                        ...List.generate(
                          numberOfPassengers,
                          (index) => PassengerForm(
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
                          ),
                        ),

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
      bottomNavigationBar: BottomNavigation(
        selectedIndex: selectedIndex,
        onItemTapped: onNavItemTapped,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
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

  const PassengerForm({
    super.key,
    required this.passengerNumber,
    required this.screenWidth,
    required this.screenHeight,
    required this.onNameChanged,
    required this.onAgeChanged,
    required this.onPhoneChanged,
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
            'Name',
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
            'Age',
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
            'Phone',
            style: GoogleFonts.lexend(
              fontSize: screenWidth * 0.035,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          TextField(
            onChanged: onPhoneChanged,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Enter Phone Number',
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
