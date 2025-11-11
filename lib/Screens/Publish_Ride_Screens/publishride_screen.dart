import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PublishRideScreen extends StatefulWidget {
  const PublishRideScreen({super.key});

  @override
  State<PublishRideScreen> createState() => _PublishRideScreenState();
}

class _PublishRideScreenState extends State<PublishRideScreen> {
  final TextEditingController riderNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController alternatePhoneController =
      TextEditingController();
  final TextEditingController fromCityController = TextEditingController();
  final TextEditingController toCityController = TextEditingController();
  final TextEditingController timingsController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController pickupTimeController = TextEditingController();
  final TextEditingController pickupPlaceController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  int passengers = 1;
  int selectedIndex = 0; // Publish tab selected

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

  void incrementPrice() {
    int currentPrice = int.tryParse(priceController.text) ?? 500;
    setState(() {
      priceController.text = (currentPrice + 50).toString();
    });
  }

  void decrementPrice() {
    int currentPrice = int.tryParse(priceController.text) ?? 500;
    if (currentPrice > 50) {
      setState(() {
        priceController.text = (currentPrice - 50).toString();
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
            colorScheme: const ColorScheme.light(primary: Color(0xFFFF4444)),
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

  Future<void> selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFFF4444)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  void handleSubmit() {
    // TODO: Connect to backend API
    /*
    final response = await http.post(
      Uri.parse('YOUR_API_ENDPOINT/publish-ride'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'riderName': riderNameController.text,
        'phone': phoneController.text,
        'alternatePhone': alternatePhoneController.text,
        'fromCity': fromCityController.text,
        'toCity': toCityController.text,
        'timings': timingsController.text,
        'date': dateController.text,
        'pickupTime': pickupTimeController.text,
        'pickupPlace': pickupPlaceController.text,
        'passengers': passengers,
        'price': priceController.text,
        'description': descriptionController.text,
      }),
    );
    */

    print('Submit clicked');
    print('Rider Name: ${riderNameController.text}');
    print('Phone: ${phoneController.text}');
    print('From: ${fromCityController.text}');
    print('To: ${toCityController.text}');
    print('Passengers: $passengers');
    print('Price: ${priceController.text}');
  }

  void onNavItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    print('Navigated to index: $index');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.03,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Publish A Ride?',
                            style: GoogleFonts.lexend(
                              fontSize: screenWidth * 0.065,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.025),

                        // Enter Rider Details
                        Text(
                          'Enter Rider Details',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.012),
                        Text(
                          'Name',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.010),
                        _buildTextField(
                          'Enter Rider Name',
                          riderNameController,
                          screenWidth,
                          screenHeight,
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Text(
                          'Phone Number',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.010),
                        _buildTextField(
                          'Enter Phone Number',
                          phoneController,
                          screenWidth,
                          screenHeight,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Text(
                          'Alternate Phone Number',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.010),
                        _buildTextField(
                          'Enter Alternate Phone Number',
                          alternatePhoneController,
                          screenWidth,
                          screenHeight,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Profile Picture
                        Text(
                          'Profile Picture',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.012),
                        _buildTextField(
                          'Add Profile Picture',
                          null,
                          screenWidth,
                          screenHeight,
                          readOnly: true,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Enter Ride Details
                        Text(
                          'Enter Ride Details',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.012),
                        Text(
                          'From',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.010),
                        _buildTextField(
                          'Enter City Name',
                          fromCityController,
                          screenWidth,
                          screenHeight,
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Text(
                          'To',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.010),
                        _buildTextField(
                          'Enter City Name',
                          toCityController,
                          screenWidth,
                          screenHeight,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // No of Passengers
                        Text(
                          'No of Passengers',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
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
                        SizedBox(height: screenHeight * 0.02),

                        // Enter Ride Timings
                        Text(
                          'Enter Ride Timings',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.012),
                        _buildTextField(
                          'Enter Date',
                          dateController,
                          screenWidth,
                          screenHeight,
                          readOnly: true,
                          onTap: selectDate,
                          suffixIcon: Icons.calendar_today,
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        // Pickup Time
                        Text(
                          'Pickup Time',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.012),
                        _buildTextField(
                          'Enter Pickup Time',
                          pickupTimeController,
                          screenWidth,
                          screenHeight,
                          readOnly: true,
                          onTap: () => selectTime(pickupTimeController),
                          suffixIcon: Icons.access_time,
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        // Drop Place
                        Text(
                          'Drop Place',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.012),
                        _buildTextField(
                          'Enter Pickup Place',
                          pickupPlaceController,
                          screenWidth,
                          screenHeight,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Enter Ride Price
                        Text(
                          'Enter Ride Price',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.012),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: decrementPrice,
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
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.06,
                                vertical: screenHeight * 0.01,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.currency_rupee,
                                    color: Color(0xFFFF4444),
                                    size: screenWidth * 0.05,
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.15,
                                    child: TextField(
                                      controller: priceController,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: GoogleFonts.lexend(
                                        fontSize: screenWidth * 0.045,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.04),
                            GestureDetector(
                              onTap: incrementPrice,
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
                        SizedBox(height: screenHeight * 0.02),

                        // Enter Description
                        Text(
                          'Enter Description (Pickup Place - Drop Place)',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.012),
                        TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Enter description...',
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
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.025),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: handleSubmit,
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
                              'Submit',
                              style: GoogleFonts.lexend(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFF4444),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
                  onTap: () => onNavItemTapped(0),
                ),
                NavBarItem(
                  icon: Icons.airplane_ticket_outlined,
                  label: 'My Bookings',
                  isSelected: selectedIndex == 1,
                  screenWidth: screenWidth,
                  onTap: () => onNavItemTapped(1),
                ),
                NavBarItem(
                  icon: Icons.search,
                  label: 'Search',
                  isSelected: selectedIndex == 2,
                  screenWidth: screenWidth,
                  onTap: () => onNavItemTapped(2),
                ),
                NavBarItem(
                  icon: Icons.menu,
                  label: 'History',
                  isSelected: selectedIndex == 3,
                  screenWidth: screenWidth,
                  onTap: () => onNavItemTapped(3),
                ),
                NavBarItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  isSelected: selectedIndex == 4,
                  screenWidth: screenWidth,
                  onTap: () => onNavItemTapped(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController? controller,
    double screenWidth,
    double screenHeight, {
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller ?? TextEditingController(),
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
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
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
      ),
      style: GoogleFonts.lexend(fontSize: screenWidth * 0.04),
    );
  }

  @override
  void initState() {
    super.initState();
    priceController.text = '500'; // Default price
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
                color: isSelected
                    ? const Color(0xFFFF4444)
                    : Colors.transparent,
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
