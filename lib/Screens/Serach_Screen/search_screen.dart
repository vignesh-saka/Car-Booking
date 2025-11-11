import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  int passengers = 1;
  int selectedIndex = 2;

  // Backend data - replace with actual API call
  List<RecentRide> recentRides = [
    RecentRide(from: 'Hyderabad', to: 'Karimnagar'),
    RecentRide(from: 'Karimnagar', to: 'Hyderabad'),
  ];

  void incrementPassengers() {
    setState(() {
      passengers++;
    });
  }

  void decrementPassengers() {
    if (passengers > 1) {
      setState(() {
        passengers--;
      });
    }
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFFF3B30)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void handleSearch() {
    // TODO: Connect to backend API
    // Example API call structure:
    /*
    final response = await http.post(
      Uri.parse('YOUR_API_ENDPOINT/search'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'from': fromController.text,
        'to': toController.text,
        'date': dateController.text,
        'passengers': passengers,
      }),
    );
    */

    print('Search clicked');
    print('From: ${fromController.text}');
    print('To: ${toController.text}');
    print('Date: ${dateController.text}');
    print('Passengers: $passengers');
  }

  void onNavItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    // TODO: Navigate to respective screens
    print('Navigated to index: $index');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Red Header Section
              Container(
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
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.04,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Find a Ride?',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.065,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.025),

                      // From Field
                      Text(
                        'Where are you going?',
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.04,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      Text(
                        'From',
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.035,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      TextField(
                        controller: fromController,
                        decoration: InputDecoration(
                          hintText: 'Enter City Name',
                          hintStyle: GoogleFonts.lexend(
                            color: Colors.grey[400],
                            fontSize: screenWidth * 0.038,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.018,
                          ),
                        ),
                        style: GoogleFonts.lexend(fontSize: screenWidth * 0.04),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // To Field
                      Text(
                        'To',
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.035,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      TextField(
                        controller: toController,
                        decoration: InputDecoration(
                          hintText: 'Enter City Name',
                          hintStyle: GoogleFonts.lexend(
                            color: Colors.grey[400],
                            fontSize: screenWidth * 0.038,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.018,
                          ),
                        ),
                        style: GoogleFonts.lexend(fontSize: screenWidth * 0.04),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Date Field
                      Text(
                        'Date',
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.035,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.008),
                      TextField(
                        controller: dateController,
                        readOnly: true,
                        onTap: selectDate,
                        decoration: InputDecoration(
                          hintText: 'Enter Date',
                          hintStyle: GoogleFonts.lexend(
                            color: Colors.grey[400],
                            fontSize: screenWidth * 0.038,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.018,
                          ),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        style: GoogleFonts.lexend(fontSize: screenWidth * 0.04),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Passengers
                      Text(
                        'No. of Passengers',
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.035,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.012),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: decrementPassengers,
                            child: Container(
                              width: screenWidth * 0.1,
                              height: screenWidth * 0.1,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Color(0xFFFF4444),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          Text(
                            '$passengers',
                            style: GoogleFonts.lexend(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          GestureDetector(
                            onTap: incrementPassengers,
                            child: Container(
                              width: screenWidth * 0.1,
                              height: screenWidth * 0.1,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Color(0xFFFF4444),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.025),

                      // Search Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: handleSearch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.018,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Search',
                            style: GoogleFonts.lexend(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFF4444),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Recents Section
              if (recentRides.isNotEmpty)
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recents',
                        style: GoogleFonts.lexend(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      ...recentRides.map(
                        (ride) => RecentRideItem(
                          ride: ride,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),

       // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenHeight * 0.012,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavBarItem(
                  icon: Icons.add,
                  label: 'Publish',
                  isSelected: selectedIndex == 0,
                  screenWidth: screenWidth,
                  onTap: () => {onNavItemTapped(0)},
                ),
                NavBarItem(
                  icon: Icons.airplane_ticket_outlined,
                  label: 'My Bookings',
                  isSelected: selectedIndex == 1,
                  screenWidth: screenWidth,
                  onTap: () => {onNavItemTapped(1)},
                ),
                NavBarItem(
                  icon: Icons.search,
                  label: 'Search',
                  isSelected: selectedIndex == 2,
                  screenWidth: screenWidth,
                  onTap: () => {onNavItemTapped(2)},
                ),
                NavBarItem(
                  icon: Icons.menu,
                  label: 'History',
                  isSelected: selectedIndex == 3,
                  screenWidth: screenWidth,
                  onTap: () => {onNavItemTapped(3)},
                ),
                NavBarItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  isSelected: selectedIndex == 4,
                  screenWidth: screenWidth,
                  onTap: () => {onNavItemTapped(4)},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class RecentRide {
  final String from;
  final String to;

  RecentRide({required this.from, required this.to});

  // Factory constructor for JSON parsing
  factory RecentRide.fromJson(Map<String, dynamic> json) {
    return RecentRide(from: json['from'], to: json['to']);
  }
}

class RecentRideItem extends StatelessWidget {
  final RecentRide ride;
  final double screenWidth;
  final double screenHeight;

  const RecentRideItem({
    super.key,
    required this.ride,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.012),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history,
            color: Colors.grey[600],
            size: screenWidth * 0.06,
          ),
          SizedBox(width: screenWidth * 0.03),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'From',
                style: GoogleFonts.lexend(
                  fontSize: screenWidth * 0.03,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                ride.from,
                style: GoogleFonts.lexend(
                  fontSize: screenWidth * 0.038,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(width: screenWidth * 0.04),
          Icon(
            Icons.arrow_forward,
            color: Colors.grey[400],
            size: screenWidth * 0.05,
          ),
          SizedBox(width: screenWidth * 0.04),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To',
                style: GoogleFonts.lexend(
                  fontSize: screenWidth * 0.03,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                ride.to,
                style: GoogleFonts.lexend(
                  fontSize: screenWidth * 0.038,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final double screenWidth;
  final VoidCallback? onTap;

  const NavBarItem({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.screenWidth,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.025,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF4444) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black87,
                size: screenWidth * 0.058,
              ),
            ),
            SizedBox(height: 5),
            Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: screenWidth * 0.029,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}