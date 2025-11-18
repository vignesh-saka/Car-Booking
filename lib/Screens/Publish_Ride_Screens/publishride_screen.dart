// publish_ride_screen.dart
import 'dart:async';
import 'dart:convert';

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
<<<<<<< HEAD
import 'package:http/http.dart' as http;
=======
import 'dart:io';
import 'package:image_picker/image_picker.dart';

>>>>>>> 23c31bbd1c0c81e875c48de1645fd908d8d13ee1

/// Complete PublishRideScreen with Google Places Autocomplete + Place Details (lat/lng)
/// Autocomplete only triggers when user types >= 3 characters and restricted to India.
class PublishRideScreen extends StatefulWidget {
  const PublishRideScreen({super.key});

  @override
  State<PublishRideScreen> createState() => _PublishRideScreenState();
}

class PlacePrediction {
  final String description;
  final String placeId;
  PlacePrediction({required this.description, required this.placeId});
}

class LatLngPair {
  final double lat;
  final double lng;
  LatLngPair(this.lat, this.lng);
}

class _PublishRideScreenState extends State<PublishRideScreen> {
<<<<<<< HEAD
  // --- Controllers ---
  final TextEditingController riderNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController alternatePhoneController = TextEditingController();
=======
  final _formKey = GlobalKey<FormState>();

  final TextEditingController riderNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
>>>>>>> 23c31bbd1c0c81e875c48de1645fd908d8d13ee1
  final TextEditingController fromCityController = TextEditingController();
  final TextEditingController toCityController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController pickupTimeController = TextEditingController();
  final TextEditingController dropTimeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // --- Autocomplete state ---
  Timer? _debounceTimer;
  List<PlacePrediction> fromSuggestions = [];
  List<PlacePrediction> toSuggestions = [];
  bool showFromSuggestions = false;
  bool showToSuggestions = false;
  bool _isLoadingFrom = false;
  bool _isLoadingTo = false;

  // Session token for grouping autocomplete + details
  String? _sessionToken;

  // Selected place lat/lng (optional: use these when submitting)
  LatLngPair? fromLatLng;
  LatLngPair? toLatLng;

  // Replace with your API key (you provided earlier; restrict it in production)
  static const String googleApiKey = 'AIzaSyCwizUugA6ySbo1PnnuNdPxGDXHPZAWtjY';

  // --- Other existing state & functions ---
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
<<<<<<< HEAD
    // Build payload including coordinates if available
    final payload = {
      'riderName': riderNameController.text,
      'phone': phoneController.text,
      'alternatePhone': alternatePhoneController.text,
      'fromCity': fromCityController.text,
      'toCity': toCityController.text,
      'fromLatLng': fromLatLng != null
          ? {'lat': fromLatLng!.lat, 'lng': fromLatLng!.lng}
          : null,
      'toLatLng': toLatLng != null
          ? {'lat': toLatLng!.lat, 'lng': toLatLng!.lng}
          : null,
      'timings': timingsController.text,
      'date': dateController.text,
      'pickupTime': pickupTimeController.text,
      'dropTime': dropTimeController.text,
      'pickupPlace': pickupPlaceController.text,
      'passengers': passengers,
      'price': priceController.text,
      'description': descriptionController.text,
    };

    // TODO: send payload to your backend
    debugPrint('Submit clicked: $payload');

=======
>>>>>>> 23c31bbd1c0c81e875c48de1645fd908d8d13ee1
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PublishsucessScreen()),
    );
  }

<<<<<<< HEAD
  void onNavItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    debugPrint('Navigated to index: $index');
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

  // ------------------- Autocomplete helpers -------------------

  void _onFromChanged(String input) {
    _onInputChanged(input, isFrom: true);
  }

  void _onToChanged(String input) {
    _onInputChanged(input, isFrom: false);
  }

  void _onInputChanged(String input, {required bool isFrom}) {
    // only trigger autocomplete after user types at least 3 characters
    final trimmed = input.trim();
    _debounceTimer?.cancel();

    if (trimmed.length < 3) {
      // hide/clear suggestions if less than 3 chars
      setState(() {
        if (isFrom) {
          fromSuggestions = [];
          showFromSuggestions = false;
          _isLoadingFrom = false;
        } else {
          toSuggestions = [];
          showToSuggestions = false;
          _isLoadingTo = false;
        }
      });
      return;
    }

    // Debounce to avoid too many calls
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      fetchPlaceSuggestions(trimmed, isFrom: isFrom);
    });
  }

  Future<void> fetchPlaceSuggestions(String input, {required bool isFrom}) async {
    // Places Autocomplete Web Service (restricted to India)
    final String baseUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    // Ensure we have a session token
    _sessionToken ??= DateTime.now().millisecondsSinceEpoch.toString();

    final String request = '$baseUrl'
        '?input=${Uri.encodeComponent(input)}'
        '&key=$googleApiKey'
        '&types=geocode'
        '&language=en'
        '&components=country:in'
        '&sessiontoken=${Uri.encodeComponent(_sessionToken!)}';

    try {
      // mark loading
      setState(() {
        if (isFrom) {
          _isLoadingFrom = true;
        } else {
          _isLoadingTo = true;
        }
      });

      final response = await http.get(Uri.parse(request));
      // DEBUG: print response for troubleshooting
      debugPrint('Places Autocomplete HTTP ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        final Map data = json.decode(response.body);
        final String status = (data['status'] ?? '') as String;

        if (status == 'OK') {
          final List predictions = data['predictions'] ?? [];
          final List<PlacePrediction> suggestions = predictions
              .map<PlacePrediction>((p) {
                return PlacePrediction(
                  description: (p['description'] ?? '') as String,
                  placeId: (p['place_id'] ?? '') as String,
                );
              })
              .where((p) => p.description.isNotEmpty && p.placeId.isNotEmpty)
              .toList();

          setState(() {
            if (isFrom) {
              fromSuggestions = suggestions;
              showFromSuggestions = suggestions.isNotEmpty;
            } else {
              toSuggestions = suggestions;
              showToSuggestions = suggestions.isNotEmpty;
            }
          });
        } else if (status == 'ZERO_RESULTS') {
          setState(() {
            if (isFrom) {
              fromSuggestions = [];
              showFromSuggestions = false;
            } else {
              toSuggestions = [];
              showToSuggestions = false;
            }
          });
        } else {
          debugPrint('Places Autocomplete API returned status: $status');
          if (status == 'REQUEST_DENIED') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Places API request denied. Check API key & billing.'),
              ),
            );
          }
          setState(() {
            if (isFrom) {
              fromSuggestions = [];
              showFromSuggestions = false;
            } else {
              toSuggestions = [];
              showToSuggestions = false;
            }
          });
        }
      } else {
        debugPrint('Places Autocomplete HTTP error: ${response.statusCode}');
        setState(() {
          if (isFrom) {
            fromSuggestions = [];
            showFromSuggestions = false;
          } else {
            toSuggestions = [];
            showToSuggestions = false;
          }
        });
      }
    } catch (e, st) {
      debugPrint('Places Autocomplete exception: $e\n$st');
      setState(() {
        if (isFrom) {
          fromSuggestions = [];
          showFromSuggestions = false;
        } else {
          toSuggestions = [];
          showToSuggestions = false;
        }
      });
    } finally {
      setState(() {
        if (isFrom) {
          _isLoadingFrom = false;
        } else {
          _isLoadingTo = false;
        }
      });
    }
  }

  Future<void> fetchPlaceDetailsAndSet(String placeId, {required bool isFrom}) async {
    // Place Details Web Service: request geometry & formatted_address
    final String baseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';

    // Ensure we have a session token (same one used in autocomplete)
    _sessionToken ??= DateTime.now().millisecondsSinceEpoch.toString();

    final String request = '$baseUrl'
        '?place_id=${Uri.encodeComponent(placeId)}'
        '&fields=geometry,name,formatted_address'
        '&key=$googleApiKey'
        '&language=en'
        '&sessiontoken=${Uri.encodeComponent(_sessionToken!)}';

    try {
      final response = await http.get(Uri.parse(request));
      debugPrint('Place Details HTTP ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        final Map data = json.decode(response.body);
        final String status = (data['status'] ?? '') as String;

        if (status == 'OK') {
          final Map result = data['result'] ?? {};
          final Map geometry = result['geometry'] ?? {};
          final Map location = geometry['location'] ?? {};
          final double? lat = (location['lat'] != null) ? (location['lat'] as num).toDouble() : null;
          final double? lng = (location['lng'] != null) ? (location['lng'] as num).toDouble() : null;
          final String? formattedAddress = result['formatted_address'] as String?;

          setState(() {
            if (isFrom) {
              if (lat != null && lng != null) fromLatLng = LatLngPair(lat, lng);
              if (formattedAddress != null && formattedAddress.isNotEmpty) fromCityController.text = formattedAddress;
              fromSuggestions = [];
              showFromSuggestions = false;
            } else {
              if (lat != null && lng != null) toLatLng = LatLngPair(lat, lng);
              if (formattedAddress != null && formattedAddress.isNotEmpty) toCityController.text = formattedAddress;
              toSuggestions = [];
              showToSuggestions = false;
            }
          });

          // Reset session token after successful place selection
          _sessionToken = null;
        } else {
          debugPrint('Place Details API returned status: $status');
          if (status == 'REQUEST_DENIED') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Place Details request denied. Check API key & billing.')),
            );
          }
          setState(() {
            if (isFrom) {
              fromSuggestions = [];
              showFromSuggestions = false;
            } else {
              toSuggestions = [];
              showToSuggestions = false;
            }
          });
        }
      } else {
        debugPrint('Place Details HTTP error: ${response.statusCode}');
        setState(() {
          if (isFrom) {
            fromSuggestions = [];
            showFromSuggestions = false;
          } else {
            toSuggestions = [];
            showToSuggestions = false;
          }
        });
      }
    } catch (e, st) {
      debugPrint('Place Details exception: $e\n$st');
      setState(() {
        if (isFrom) {
          fromSuggestions = [];
          showFromSuggestions = false;
        } else {
          toSuggestions = [];
          showToSuggestions = false;
        }
      });
    }
  }

  // ------------------- Build UI -------------------
=======
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




>>>>>>> 23c31bbd1c0c81e875c48de1645fd908d8d13ee1

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
<<<<<<< HEAD
                        SizedBox(height: screenHeight * 0.025),

                        // Rider Details
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

                        // Profile Picture placeholder
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

                        // From field (autocomplete)
                        Text(
                          'From',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.010),
                        _buildAutocompleteField(
                          hint: 'Enter City Name',
                          controller: fromCityController,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          onChanged: _onFromChanged,
                          suggestions: fromSuggestions,
                          showSuggestions: showFromSuggestions,
                          onSuggestionTap: (PlacePrediction p) {
                            fetchPlaceDetailsAndSet(p.placeId, isFrom: true);
                          },
                          isLoading: _isLoadingFrom,
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        // To field (autocomplete)
                        Text(
                          'To',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.010),
                        _buildAutocompleteField(
                          hint: 'Enter City Name',
                          controller: toCityController,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          onChanged: _onToChanged,
                          suggestions: toSuggestions,
                          showSuggestions: showToSuggestions,
                          onSuggestionTap: (PlacePrediction p) {
                            fetchPlaceDetailsAndSet(p.placeId, isFrom: false);
                          },
                          isLoading: _isLoadingTo,
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
                        Text(
                          'Date',
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

                        // Drop Time
                        Text(
                          'Drop Time',
                          style: GoogleFonts.lexend(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.012),
                        _buildTextField(
                          'Enter Drop Time',
                          dropTimeController,
                          screenWidth,
                          screenHeight,
                          readOnly: true,
                          onTap: () => selectTime(dropTimeController),
                          suffixIcon: Icons.access_time,
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
=======
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
>>>>>>> 23c31bbd1c0c81e875c48de1645fd908d8d13ee1
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
<<<<<<< HEAD
                                        color: Colors.black87,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
=======
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
>>>>>>> 23c31bbd1c0c81e875c48de1645fd908d8d13ee1
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

<<<<<<< HEAD
  // Basic reusable text field used in UI
=======
  // ------------------------------------------------------------------
  // ---------------------- Text Field Widget -------------------------
  // ------------------------------------------------------------------
>>>>>>> 23c31bbd1c0c81e875c48de1645fd908d8d13ee1
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

<<<<<<< HEAD
  // Autocomplete field widget that accepts PlacePrediction suggestions
  Widget _buildAutocompleteField({
    required String hint,
    required TextEditingController controller,
    required double screenWidth,
    required double screenHeight,
    required Function(String) onChanged,
    required List<PlacePrediction> suggestions,
    required bool showSuggestions,
    required Function(PlacePrediction) onSuggestionTap,
    required bool isLoading,
  }) {
    return Column(
      children: [
        TextField(
          controller: controller,
          readOnly: false,
          onChanged: onChanged,
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
          ),
          style: GoogleFonts.lexend(fontSize: screenWidth * 0.04),
        ),

        // Suggestions box
        if (isLoading)
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          )
        else if (showSuggestions && suggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxHeight: 180,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = suggestions[index];
                return ListTile(
                  title: Text(
                    p.description,
                    style: GoogleFonts.lexend(fontSize: screenWidth * 0.038),
                  ),
                  onTap: () => onSuggestionTap(p),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    priceController.text = '500'; // Default price
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  void dispose() {
    riderNameController.dispose();
    phoneController.dispose();
    alternatePhoneController.dispose();
    fromCityController.dispose();
    toCityController.dispose();
    timingsController.dispose();
    dateController.dispose();
    pickupTimeController.dispose();
    dropTimeController.dispose();
    pickupPlaceController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
=======
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
>>>>>>> 23c31bbd1c0c81e875c48de1645fd908d8d13ee1
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