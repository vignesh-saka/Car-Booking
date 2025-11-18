import 'package:bookmycar/Screens/Comman/bottom_navigation.dart';
import 'package:bookmycar/Screens/History_Screens/Screens/history_screen.dart';
import 'package:bookmycar/Screens/My_Booking_Screens/Screens/my_bookings_screen.dart';
import 'package:bookmycar/Screens/Profile_Screen/profile_screen.dart';
import 'package:bookmycar/Screens/Publish_Ride_Screens/publishsucess_screen.dart';
import 'package:bookmycar/Screens/Serach_Screen/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


class PublishRideScreen extends StatefulWidget {
  const PublishRideScreen({super.key});

  @override
  State<PublishRideScreen> createState() => _PublishRideScreenState();
}

class _PublishRideScreenState extends State<PublishRideScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController riderNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController fromCityController = TextEditingController();
  final TextEditingController toCityController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController pickupTimeController = TextEditingController();
  final TextEditingController dropTimeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  int passengers = 1;
  int selectedIndex = 0;

  File? profileImage;

  /// SAMPLE CITY LIST – LATER YOU CAN PUT 100+ CITIES HERE
  List<String> cities = [
    "Hyderabad",
    "Chennai",
    "Mumbai",
    "Delhi",
    "Pune",
    "Bengaluru",
    "Kolkata",
  ];

  /// FILTERED LISTS
  List<String> filteredFromCities = [];
  List<String> filteredToCities = [];

  /// Dropdown states
  bool showFromDropdown = false;
  bool showToDropdown = false;

  Future<void> pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (image == null) return;

    bool? confirm = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewImageScreen(imageFile: File(image.path)),
      ),
    );

    if (confirm == true) {
      setState(() {
        profileImage = File(image.path);
      });
    }
  }

  void incrementPassengers() => setState(() => passengers++);
  void decrementPassengers() {
    if (passengers > 1) setState(() => passengers--);
  }

  void incrementPrice() {
    int current = int.tryParse(priceController.text) ?? 500;
    setState(() => priceController.text = (current + 50).toString());
  }

  void decrementPrice() {
    int current = int.tryParse(priceController.text) ?? 500;
    if (current > 50) {
      setState(() => priceController.text = (current - 50).toString());
    }
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025, 12, 31),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFFF4444)),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => dateController.text =
          '${picked.day}/${picked.month}/${picked.year}');
    }
  }

  Future<void> selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFFF4444)),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => controller.text = picked.format(context));
    }
  }

  void handleSubmit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PublishsucessScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    priceController.text = "500";
  }

  Future<void> saveRideToFirebase() async {
  try {
    // 1️⃣ Upload profile image to Firebase Storage
    String imageUrl = "";
    if (profileImage != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("ride_profiles/${DateTime.now().millisecondsSinceEpoch}.jpg");

      await storageRef.putFile(profileImage!);
      imageUrl = await storageRef.getDownloadURL();
    }

    // 2️⃣ Store ride data in Firestore
    await FirebaseFirestore.instance.collection("rides").add({
      "riderName": riderNameController.text.trim(),
      "phoneNumber": phoneController.text.trim(),
      "profileImage": imageUrl,
      "fromCity": fromCityController.text.trim(),
      "toCity": toCityController.text.trim(),
      "date": dateController.text.trim(),
      "pickupTime": pickupTimeController.text.trim(),
      "dropTime": dropTimeController.text.trim(),
      "price": priceController.text.trim(),
      "passengers": passengers,
      "description": descriptionController.text.trim(),
      "createdAt": Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ride Published Successfully!")),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PublishsucessScreen()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}





  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  "Publish A Ride?",
                                  style: GoogleFonts.lexend(
                                    fontSize: screenWidth * 0.065,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.025),

                              // ----------------- NAME ------------------

                              Text("Enter Rider Details",
                                  style: GoogleFonts.lexend(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              SizedBox(height: screenHeight * 0.012),

                              Text("Name",
                                  style: GoogleFonts.lexend(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              SizedBox(height: screenHeight * 0.010),

                              _buildTextField(
                                "Enter Rider Name",
                                riderNameController,
                                screenWidth,
                                screenHeight,
                                keyboardType: TextInputType.name,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return "Name is required";
                                  }
                                  if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(v)) {
                                    return "Only alphabets allowed";
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: screenHeight * 0.015),

                              // ----------------- PHONE ------------------
                              Text("Phone Number",
                                  style: GoogleFonts.lexend(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              SizedBox(height: screenHeight * 0.010),

                              _buildTextField(
                                "Enter Phone Number",
                                phoneController,
                                screenWidth,
                                screenHeight,
                                keyboardType: TextInputType.phone,
                                 inputFormatters: [
    LengthLimitingTextInputFormatter(10),
    FilteringTextInputFormatter.digitsOnly,
  ],
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return "Phone number required";
                                  }
                                  if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                                    return "Enter valid 10-digit number";
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: screenHeight * 0.02),

                              // ----------------- PROFILE PIC ------------------
                              Text("Profile Picture",
                                  style: GoogleFonts.lexend(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              SizedBox(height: screenHeight * 0.012),

                              InkWell(
                                onTap: pickProfileImage,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                    vertical: screenHeight * 0.018,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        profileImage == null
                                            ? "Add Profile Picture"
                                            : "Picture Added ✓",
                                        style: GoogleFonts.lexend(
                                          color: Colors.grey[600],
                                          fontSize: screenWidth * 0.038,
                                        ),
                                      ),
                                      const Icon(Icons.camera_alt,
                                          color: Colors.black54),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.02),

                              // ----------------- FROM ------------------
                              Text("Enter Ride Details",
                                  style: GoogleFonts.lexend(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              SizedBox(height: screenHeight * 0.012),

                             // ----------------- FROM ------------------
Text("From",
    style: GoogleFonts.lexend(
        fontSize: screenWidth * 0.04,
        fontWeight: FontWeight.w500,
        color: Colors.white)),
SizedBox(height: screenHeight * 0.010),

_buildTextField(
  "Enter City Name",
  fromCityController,
  screenWidth,
  screenHeight,
  validator: (v) =>
      v == null || v.isEmpty ? "Select a City" : null,
  onTap: () {
    setState(() {
      filteredFromCities = cities;
      showFromDropdown = true;
    });
  },
  onChanged: (value) {
    setState(() {
      filteredFromCities = cities
          .where((city) =>
              city.toLowerCase().startsWith(value.toLowerCase()))
          .toList();
      showFromDropdown = true;

      if (toCityController.text.isNotEmpty &&
        toCityController.text == value) {
      _formKey.currentState!.validate();
    }
    });
  },
),

// DROPDOWN placed JUST AFTER FROM field and INSIDE scroll view
if (showFromDropdown)
  Container(
    width: double.infinity,
    margin: EdgeInsets.only(top: 6, bottom: 10),
    constraints: const BoxConstraints(maxHeight: 200),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 3))
      ],
    ),
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: filteredFromCities.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            setState(() {
              fromCityController.text = filteredFromCities[index];
              showFromDropdown = false;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              filteredFromCities[index],
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    ),
  ),
   SizedBox(height: screenHeight * 0.02),


// ----------------- TO ------------------
Text("To",
    style: GoogleFonts.lexend(
        fontSize: screenWidth * 0.04,
        fontWeight: FontWeight.w500,
        color: Colors.white)),
SizedBox(height: screenHeight * 0.010),

_buildTextField(
  "Enter City Name",
  toCityController,
  screenWidth,
  screenHeight,
  validator: (v) {
  if (v == null || v.isEmpty) {
    return "Select a City";
  }
  if (v == fromCityController.text) {
    return "From & To cannot be same";
  }
  return null;
},

  onTap: () {
    setState(() {
      filteredToCities = cities;
      showToDropdown = true;
    });
  },
  onChanged: (value) {
    setState(() {
      filteredToCities = cities
          .where((city) =>
              city.toLowerCase().startsWith(value.toLowerCase()))
          .toList();
      showToDropdown = true;
        if (fromCityController.text.isNotEmpty &&
        fromCityController.text == value) {
      _formKey.currentState!.validate();
    }
    });
  },
),

// TO DROPDOWN SCROLLABLE INSIDE PAGE
if (showToDropdown)
  Container(
    width: double.infinity,
    margin: EdgeInsets.only(top: 6, bottom: 10),
    constraints: const BoxConstraints(maxHeight: 200),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 3))
      ],
    ),
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: filteredToCities.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            setState(() {
              toCityController.text = filteredToCities[index];
              showToDropdown = false;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              filteredToCities[index],
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    ),
  ),


                              SizedBox(height: screenHeight * 0.02),

                              // ----------------- PASSENGERS ------------------
                              Text("No of Passengers",
                                  style: GoogleFonts.lexend(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              SizedBox(height: screenHeight * 0.012),

                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: decrementPassengers,
                                    child: Container(
                                      width: screenWidth * 0.1,
                                      height: screenWidth * 0.1,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.remove,
                                          color: Color(0xFFFF4444)),
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.04),
                                  Text(
                                    "$passengers",
                                    style: GoogleFonts.lexend(
                                        fontSize: screenWidth * 0.05,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                  SizedBox(width: screenWidth * 0.04),
                                  GestureDetector(
                                    onTap: incrementPassengers,
                                    child: Container(
                                      width: screenWidth * 0.1,
                                      height: screenWidth * 0.1,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add,
                                          color: Color(0xFFFF4444)),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: screenHeight * 0.02),

                              // ----------------- DATE & TIME ------------------
                              Text("Enter Ride Timings",
                                  style: GoogleFonts.lexend(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              SizedBox(height: screenHeight * 0.012),

                              Text("Date",
                                  style: GoogleFonts.lexend(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              SizedBox(height: screenHeight * 0.012),

                              _buildTextField(
                                "Enter Date",
                                dateController,
                                screenWidth,
                                screenHeight,
                                readOnly: true,
                                onTap: selectDate,
                                suffixIcon: Icons.calendar_today,
                                validator: (v) =>
                                    v == null || v.isEmpty ? "Please select a date" : null,
                              ),

                              SizedBox(height: screenHeight * 0.015),

                              Text("Pickup Time",
                                  style: GoogleFonts.lexend(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              SizedBox(height: screenHeight * 0.012),

                              _buildTextField(
                                "Enter Pickup Time",
                                pickupTimeController,
                                screenWidth,
                                screenHeight,
                                readOnly: true,
                                onTap: () => selectTime(pickupTimeController),
                                suffixIcon: Icons.access_time,
                                validator: (v) =>
                                    v == null || v.isEmpty ? "Pickup time required" : null,
                              ),

                              SizedBox(height: screenHeight * 0.015),

                              Text("Drop Time",
                                  style: GoogleFonts.lexend(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              SizedBox(height: screenHeight * 0.012),

                              _buildTextField(
                                "Enter Drop Time",
                                dropTimeController,
                                screenWidth,
                                screenHeight,
                                readOnly: true,
                                onTap: () => selectTime(dropTimeController),
                                suffixIcon: Icons.access_time,
                                validator: (v) =>
                                    v == null || v.isEmpty ? "Drop time required" : null,
                              ),

                              SizedBox(height: screenHeight * 0.02),

                              // ----------------- PRICE ------------------
                              Text("Enter Ride Price",
                                  style: GoogleFonts.lexend(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              SizedBox(height: screenHeight * 0.012),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: decrementPrice,
                                    child: Container(
                                      width: screenWidth * 0.1,
                                      height: screenWidth * 0.1,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.remove,
                                          color: Color(0xFFFF4444)),
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
                                        const Icon(Icons.currency_rupee,
                                            color: Color(0xFFFF4444)),
                                        SizedBox(
                                          width: screenWidth * 0.15,
                                          child: TextFormField(
                                            controller: priceController,
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            validator: (v) {
                                              if (v == null || v.isEmpty) {
                                                return "Enter price";
                                              }
                                              if (!RegExp(r'^[0-9]+$')
                                                  .hasMatch(v)) {
                                                return "Only numbers allowed";
                                              }
                                              return null;
                                            },
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              isDense: true,
                                              errorStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
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
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add,
                                          color: Color(0xFFFF4444)),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: screenHeight * 0.02),

                              // ----------------- DESCRIPTION ------------------
                              Text("Enter Description ",
                                  style: GoogleFonts.lexend(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              SizedBox(height: screenHeight * 0.012),

                              TextFormField(
                                controller: descriptionController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText:
                                      "Enter description...(Pickup Place - Drop Place)",
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
                              ),

                              SizedBox(height: screenHeight * 0.025),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      if (profileImage == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Please add a profile picture")));
                                        return;
                                      }
                                      await saveRideToFirebase(); 
                                    }
                                  },
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
                                    "Submit",
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
                ),
              ],
            ),

            // ---------- FROM DROPDOWN ----------
           

            // ---------- TO DROPDOWN ----------
           
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigation(
        selectedIndex: selectedIndex,
        onItemTapped: (index) {
          setState(() => selectedIndex = index);
          switch (index) {
            case 0:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PublishRideScreen()));
              break;
            case 1:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyBookingsScreen()));
              break;
            case 2:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchScreen()));
              break;
            case 3:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()));
              break;
            case 4:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()));
              break;
          }
        },
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      ),
    );
  }

  // ------------------------------------------------------------------
  // ---------------------- Text Field Widget -------------------------
  // ------------------------------------------------------------------
  Widget _buildTextField(
    String hint,
    TextEditingController? controller,
    double screenWidth,
    double screenHeight, {
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lexend(
          color: Colors.grey[400],
          fontSize: screenWidth * 0.038,
        ),
        errorStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
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
      style: GoogleFonts.lexend(
        fontSize: screenWidth * 0.04,
      ),
    );
  }

  // ------------------------------------------------------------------
  // ---------------------- DROPDOWN BUILDER --------------------------
  // ------------------------------------------------------------------
  Widget _buildDropdownBox(
      List<String> results,
      TextEditingController controller,
      VoidCallback closeDropdown) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: results.length,
        itemBuilder: (context, index) => InkWell(
          onTap: () {
            controller.text = results[index];
            closeDropdown();
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              results[index],
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// ---------------------- PREVIEW SCREEN ----------------------------
// ------------------------------------------------------------------
class PreviewImageScreen extends StatelessWidget {
  final File imageFile;
  const PreviewImageScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(child: Image.file(imageFile, fit: BoxFit.contain)),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Retake"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Save"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}