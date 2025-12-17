import 'package:bookmycar/Screens/Avalabile_Ride_Screens/ride_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AvailableRidesScreen extends StatefulWidget {
  final String from;
  final String to;
  final String date;
  final int passengers;
  final VoidCallback onBookingSuccess;

  // NEW: optional robust-matching fields (nullable)
  final String? fromPlaceId;
  final double? fromLat;
  final double? fromLng;
  final String? toPlaceId;
  final double? toLat;
  final double? toLng;

  const AvailableRidesScreen({
    super.key,
    required this.from,
    required this.to,
    required this.date,
    required this.passengers,
    this.fromPlaceId,
    this.fromLat,
    this.fromLng,
    this.toPlaceId,
    this.toLat,
    this.toLng,
    required this.onBookingSuccess,
  });

  @override
  State<AvailableRidesScreen> createState() => _AvailableRidesScreenState();
}

class _AvailableRidesScreenState extends State<AvailableRidesScreen> {
  int selectedIndex = 2;

  /// 🔥 Selected date dynamically
  late String selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.date; // Start with the searched date
  }

  /// 🔥 Fetch rides for selected date
  Stream<QuerySnapshot> fetchRides() {
    return FirebaseFirestore.instance
        .collection("rides")
        .where("fromCity", isEqualTo: widget.from)
        .where("toCity", isEqualTo: widget.to)
        .where("date", isEqualTo: selectedDate)
        .snapshots();
  }

  /// 🔥 Calendar Picker
  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 0)),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFFF3B30)),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        selectedDate = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }


  void onRideSelected(RideData ride) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideDetailScreen(
          ride: ride,
          requestedPassengers: widget.passengers,
          onBookingSuccess: () {
            Navigator.pop(context); // close success screen
            widget.onBookingSuccess(); // 👈 notify MainDashboard
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
              // ---------------- HEADER ----------------
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.025,
                ),
                child: Row(
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
                          'Available Rides',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.01),
                  ],
                ),
              ),

              // ---------------- TOP TITLE + CALENDAR ----------------
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Book a Safe & Enjoy Ride',
                      style: GoogleFonts.lexend(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey[200],
                      ),
                    ),

                    // 🔥 Calendar Icon
                    GestureDetector(
                      onTap: pickDate,
                      child: Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: screenWidth * 0.07,
                      ),
                    ),
                  ],
                ),
              ),

              // 🔥 Dynamic Selected Date Display
              Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.05,
                  top: screenHeight * 0.005,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    selectedDate,
                    style: GoogleFonts.lexend(
                      fontSize: screenWidth * 0.038,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.01),

              // ---------------- RIDES LIST ----------------
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.01,
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: fetchRides(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off,
                                size: screenWidth * 0.2,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                'No rides available',
                                style: GoogleFonts.lexend(
                                  fontSize: screenWidth * 0.045,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;

                          RideData ride = RideData(
                            id: docs[index].id,
                            departureTime: data["pickupTime"],
                            arrivalTime: data["dropTime"],
                            fromCity: data["fromCity"],
                            toCity: data["toCity"],
                            driverName: data["riderName"],
                            driverPhone: data["phoneNumber"],
                            totalSeats: data["passengers"],
                            bookedSeats: 0,
                            price: int.tryParse(data["price"].toString()) ?? 0,
                            date: data["date"],
                            description: data["description"] ?? '',
                          );

                          return RideCard(
                            ride: ride,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            onTap: () => onRideSelected(ride),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ---------------- BOTTOM NAV ----------------
    );
  }
}

// ---------------- DATA MODEL (UNCHANGED) ----------------

class RideData {
  final String? id;
  final String departureTime;
  final String arrivalTime;
  final String fromCity;
  final String toCity;
  final String driverName;
  final String driverPhone;
  final int totalSeats;
  final int bookedSeats;
  final int price;
  final String date;
  final String description;

  RideData({
    this.id,
    required this.departureTime,
    required this.arrivalTime,
    required this.fromCity,
    required this.toCity,
    required this.driverName,
    required this.driverPhone,
    required this.totalSeats,
    required this.bookedSeats,
    required this.price,
    required this.date,
    this.description = '',
  });

  int get availableSeats => totalSeats - bookedSeats;
}

// ---------------- RIDE CARD (UNCHANGED) ----------------
class RideCard extends StatelessWidget {
  final RideData ride;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onTap;

  const RideCard({
    super.key,
    required this.ride,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTap,
  });

  /// Split "City, State" → { city: "City", rest: "State" }
  Map<String, String> splitAddress(String text) {
    final parts = text.split(",");
    final city = parts[0].trim();
    final rest = parts.length > 1 ? parts.sublist(1).join(",").trim() : "";
    return {"city": city, "rest": rest};
  }

  /// UI builder → City(bold) + Rest(normal)
  Widget buildAddress(String text, bool alignRight) {
    final address = splitAddress(text);

    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          address["city"]!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lexend(
            fontSize: screenWidth * 0.036,
            fontWeight: FontWeight.w600, // BOLD
            color: Colors.black87,
          ),
        ),
        if (address["rest"]!.isNotEmpty)
          Text(
            address["rest"]!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lexend(
              fontSize: screenWidth * 0.032,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.015),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ------------------ TOP ROW ------------------
            Row(
              children: [
                /// LEFT SIDE → From address
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.departureTime,
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.004),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: screenWidth * 0.04,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: screenWidth * 0.01),

                          Flexible(child: buildAddress(ride.fromCity, false)),
                        ],
                      ),
                    ],
                  ),
                ),

                /// Arrow icon
                Container(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.grey[400],
                    size: screenWidth * 0.05,
                  ),
                ),

                /// RIGHT SIDE → To address
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        ride.arrivalTime,
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.004),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(child: buildAddress(ride.toCity, true)),
                          SizedBox(width: screenWidth * 0.01),
                          Icon(
                            Icons.location_on,
                            size: screenWidth * 0.04,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// Divider
            Divider(height: screenHeight * 0.025, color: Colors.grey[300]),

            /// ------------------ DRIVER + PRICE ------------------
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
                        ride.driverName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.038,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        ride.driverPhone,
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.032,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  'Rs. ${ride.price}',
                  style: GoogleFonts.lexend(
                    fontSize: screenWidth * 0.042,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF3B30),
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
