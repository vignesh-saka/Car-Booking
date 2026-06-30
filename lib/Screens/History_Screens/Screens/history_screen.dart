import 'package:bookmycar/Screens/History_Screens/Widgets/history_ride_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ride.dart';
import 'ride_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookmycar/widgets/notification_icon.dart';

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

  int _loadedCompletedRidesCount = 5; // Initially load latest 5 in completed

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchRides();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchRides() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Not logged in -> nothing to show
      return;
    }
    FirebaseFirestore.instance
        .collection("rides")
        .where("createdBy", isEqualTo: user.uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen((snapshot) {
          List<Ride> tempLive = [];
          List<Ride> tempCompleted = [];

          DateTime now = DateTime.now();

          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, Object?>? ?? {};
            if (data['status'] == 'cancelled') continue; // Hide cancelled rides

            Ride ride = Ride.fromFirestore(data, doc.id);

            try {
              // Convert to datetime (expects dd/MM/yyyy)
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

              // Future drop time => live, otherwise completed
              if (rideEndDateTime.isAfter(now)) {
                ride.isLive = true;
                tempLive.add(ride);
              } else {
                ride.isLive = false;
                tempCompleted.add(ride);
              }
            } catch (e) {
              // fallback: treat as live
              tempLive.add(ride);
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
      final upper = time.toUpperCase().trim();
      final parts = upper.split(" ");
      final hm = parts[0].split(":");

      int hour = int.parse(hm[0]);
      int minute = int.parse(hm[1]);
      bool isPM = parts.length > 1 && parts[1] == "PM";

      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print("Time parsing failed for: $time");
      return const TimeOfDay(hour: 23, minute: 59);
    }
  }


  Widget _buildRidesList(
    List<Ride> rides,
    double screenWidth,
    double screenHeight,
    {bool isCompletedTab = false}
  ) {
    if (rides.isEmpty) {
      return Center(
        child: Text(
          'No rides found',
          style: GoogleFonts.lexend(
            fontSize: screenWidth * 0.04,
            color: Colors.white,
          ),
        ),
      );
    }

    final int displayCount = isCompletedTab
        ? (rides.length > _loadedCompletedRidesCount ? _loadedCompletedRidesCount : rides.length)
        : rides.length;

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.01,
      ),
      itemCount: displayCount + (isCompletedTab && displayCount < rides.length ? 1 : 0),
      itemBuilder: (context, index) {
        if (isCompletedTab && index == displayCount) {
          // Render Load More Button
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF3B30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06, 
                    vertical: screenHeight * 0.015
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _loadedCompletedRidesCount += 5; // Load next 5 rides
                  });
                },
                child: Text(
                  'Load More',
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }

        final ride = rides[index];
        return Padding(
          padding: EdgeInsets.only(bottom: screenHeight * 0.015),
          child: HistoryRideCard(
            ride: ride,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            isLive: _tabController.index == 0,
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
      },
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
          // fill screen so red container looks like in MyBookingsScreen
          height: screenHeight,
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

              // Title (same UI)
                // Title with Notification Icon
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40), // Balance the icon
                      Text(
                        'History',
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

              // Tab Bar (matches MyBookingsScreen style)
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
                    Tab(text: 'Live'),
                    Tab(text: 'Completed'),
                  ],
                  onTap: (_) => setState(() {}),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Expanded area — only this scrolls (lists)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3B30),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRidesList(liveRides, screenWidth, screenHeight),
                      _buildRidesList(
                        completedRides,
                        screenWidth,
                        screenHeight,
                        isCompletedTab: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
