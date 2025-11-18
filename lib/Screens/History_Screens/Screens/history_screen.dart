import 'package:bookmycar/Screens/Comman/bottom_navigation.dart';
import 'package:bookmycar/Screens/History_Screens/Widgets/history_ride_card.dart';
import 'package:bookmycar/Screens/My_Booking_Screens/Screens/my_bookings_screen.dart';
import 'package:bookmycar/Screens/Profile_Screen/profile_screen.dart';
import 'package:bookmycar/Screens/Publish_Ride_Screens/publishride_screen.dart';
import 'package:bookmycar/Screens/Serach_Screen/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ride.dart';
import 'ride_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 3;

  List<Ride> liveRides = [];
  List<Ride> completedRides = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchRides();
  }

  Future<void> fetchRides() async {
    FirebaseFirestore.instance
        .collection("rides")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen((snapshot) {
      List<Ride> tempLive = [];
      List<Ride> tempCompleted = [];

      DateTime now = DateTime.now();

      for (var doc in snapshot.docs) {
        Ride ride = Ride.fromFirestore(doc.data(), doc.id);

        try {
          // Convert to datetime
          List<String> dateParts = ride.date.split("/");
          DateTime rideDate = DateTime(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
          );

          TimeOfDay endTime = _parseTimeOfDay(ride.endTime);
          DateTime rideEndDateTime = DateTime(
            rideDate.year,
            rideDate.month,
            rideDate.day,
            endTime.hour,
            endTime.minute,
          );

          // A ride is completed ONLY IF drop time is passed
if (rideEndDateTime.isAfter(now)) {
  // Future rides → LIVE
  tempLive.add(ride);
} else {
  // Drop time already passed → COMPLETED
  tempCompleted.add(ride);
}

        } catch (e) {
          tempLive.add(ride); // fallback
        }
      }

      setState(() {
        liveRides = tempLive;
        completedRides = tempCompleted;
      });
    });
  }

  TimeOfDay _parseTimeOfDay(String time) {
  try {
    final lower = time.toUpperCase().trim();

    // Example: “05:00 PM” → ["05:00", "PM"]
    final parts = lower.split(" ");
    final hm = parts[0].split(":");

    int hour = int.parse(hm[0]);
    int minute = int.parse(hm[1]);
    bool isPM = parts[1] == "PM";

    if (isPM && hour != 12) hour += 12;     // 5 PM → 17
    if (!isPM && hour == 12) hour = 0;      // 12 AM → 00

    return TimeOfDay(hour: hour, minute: minute);
  } catch (e) {
    print("Time parsing failed for: $time");
    return const TimeOfDay(hour: 23, minute: 59); 
    // fallback to ensure ride stays LIVE, not completed
  }
}


  void onNavItemTapped(int index) {
    setState(() => selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (_) => PublishRideScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => MyBookingsScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final List<Ride> currentRides =
        _tabController.index == 0 ? liveRides : completedRides;

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
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                children: [
                  Center(
                    child: Text('History',
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        )),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // TAB BAR (same as your UI)
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
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black54,
                      labelStyle: GoogleFonts.lexend(
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth * 0.04,
                      ),
                      tabs: const [
                        Tab(text: 'Live'),
                        Tab(text: 'Completed'),
                      ],
                      onTap: (_) => setState(() {}),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  Column(
                    children: currentRides.map((ride) {
                      return Padding(
                        padding:
                            EdgeInsets.only(bottom: screenHeight * 0.015),
                        child: HistoryRideCard(
                          ride: ride,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isLive: (_tabController.index == 0),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RideDetailsScreen(ride: ride),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
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
