import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    requests = List.from(widget.ride.requests);

    // Sample additional requests for demo
    if (requests.isNotEmpty) {
      requests.addAll([
        RideRequest(
          name: 'Vignesh Kumar Saka',
          phone: '+91 6309762855',
          status: 'pending',
          age: '20',
        ),
        RideRequest(
          name: 'Vignesh Kumar Saka',
          phone: '+91 6309762855',
          status: 'accepted',
          age: '20',
        ),
        RideRequest(
          name: 'Vignesh Kumar Saka',
          phone: '+91 6309762855',
          status: 'rejected',
          age: '20',
        ),
        RideRequest(
          name: 'Vignesh Kumar Saka',
          phone: '+91 6309762855',
          status: 'pending',
          age: '20',
        ),
      ]);
    }
  }

  void handleAccept(int index) {
    setState(() {
      requests[index] = RideRequest(
        name: requests[index].name,
        phone: requests[index].phone,
        status: 'accepted',
        age: requests[index].age,
      );
    });
    // TODO: backend API accept-logic
  }

  void handleReject(int index) {
    setState(() {
      requests[index] = RideRequest(
        name: requests[index].name,
        phone: requests[index].phone,
        status: 'rejected',
        age: requests[index].age,
      );
    });
    // TODO: backend API reject-logic
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;

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

            // Content container with red background
            Expanded(
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
                            Text(
                              widget.ride.date,
                              style: GoogleFonts.lexend(
                                fontSize: screenWidth * 0.038,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),

                            // Start time & from
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.ride.startTime,
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
                                    Text(
                                      widget.ride.from,
                                      style: GoogleFonts.lexend(
                                        fontSize: screenWidth * 0.038,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Rs: ${widget.ride.price}',
                                  style: GoogleFonts.lexend(
                                    fontSize: screenWidth * 0.035,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFF4444),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.008),

                            // End time & to
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.ride.endTime,
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
                                    Text(
                                      widget.ride.to,
                                      style: GoogleFonts.lexend(
                                        fontSize: screenWidth * 0.038,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.ride.driverName,
                                      style: GoogleFonts.lexend(
                                        fontSize: screenWidth * 0.038,
                                        fontWeight: FontWeight.w500,
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
                                child: Text(
                                  'No Pending Requests',
                                  style: GoogleFonts.lexend(
                                    fontSize: screenWidth * 0.035,
                                    color: Colors.grey[600],
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
          ],
        ),
      ),
    );
  }
}
