// publish_ride_screen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bookmycar/Screens/Publish_Ride_Screens/publishsucess_screen.dart';
import 'package:bookmycar/controllers/notification_controller.dart';
import 'package:bookmycar/widgets/notification_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // <-- added

/// PublishRideScreen with Google Places Autocomplete + Place Details
/// Autocomplete triggers after >=3 characters and is restricted to India.
class PublishRideScreen extends StatefulWidget {
  final VoidCallback? onPublishSuccess;
  const PublishRideScreen({super.key, this.onPublishSuccess});

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
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController riderNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController fromCityController = TextEditingController();
  final TextEditingController toCityController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController pickupTimeController = TextEditingController();
  final TextEditingController dropTimeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Places autocomplete state
  Timer? _debounceTimer;
  String? _sessionToken;
  TimeOfDay? _pickupTimeOfDay;
  // ignore: unused_field
  TimeOfDay? _dropTimeOfDay;

  List<PlacePrediction> fromSuggestions = [];
  List<PlacePrediction> toSuggestions = [];
  bool showFromSuggestions = false;
  bool showToSuggestions = false;
  bool _isLoadingFrom = false;
  bool _isLoadingTo = false;
  bool isSubmitting = false;
  bool isPublished = false;

  // Selected place coordinates
  LatLngPair? fromLatLng;
  LatLngPair? toLatLng;

  // YOUR GOOGLE API KEY (restrict it in production)
  static const String googleApiKey = 'AIzaSyCwizUugA6ySbo1PnnuNdPxGDXHPZAWtjY';

  // Other state
  int passengers = 1;
  int selectedIndex = 0;

  // Profile picture (commented as requested)
  // File? profileImage;

  /// Image pick & preview (commented as requested)
  /*
  Future<void> pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if (image == null) return;

    final confirm = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewImageScreen(imageFile: File(image.path)),
      ),
    );

    if (confirm == true) {
      setState(() => profileImage = File(image.path));
    }
  }
  */

  // --------------------------------------------------
  // 📧 Send "Ride Published Successfully" Email
  // --------------------------------------------------
  Future<void> _sendRidePublishedEmail({
    required String from,
    required String to,
    required String date,
    required String pickupTime,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final data = userDoc.data() ?? {};
    final String email = (data["email"] ?? user.email ?? "").toString().trim();
    final String name = (data["name"] ?? user.displayName ?? "there")
        .toString()
        .trim();

    if (email.isEmpty) return;

    await FirebaseFirestore.instance.collection("mail").add({
      "to": email,
      "message": {
        "subject": "🚗 Your Ride is Published Successfully | Book My Car",

        "text":
            "Hi $name,\n\n"
            "🎉 Your ride has been published successfully!\n\n"
            "Route: $from → $to\n"
            "Date: $date\n"
            "Pickup Time: $pickupTime\n\n"
            "Passengers can now book your ride.\n\n"
            "— Book My Car Team",

        "html":
            '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Ride Published</title>
</head>
<body style="margin:0; padding:0; background:#f5f5f5; font-family:Arial;">
  <table width="100%" cellpadding="0" cellspacing="0">
    <tr>
      <td align="center" style="padding:20px;">
        <table width="600" cellpadding="0" cellspacing="0"
          style="background:#ffffff; border-radius:10px; overflow:hidden;
          box-shadow:0 4px 12px rgba(0,0,0,0.1);">

          <!-- Header -->
          <tr>
            <td align="center" style="background:#d32f2f; padding:20px;">
              <h1 style="color:#ffffff; margin:0;">🚗 Book My Car</h1>
              <p style="color:#ffffff; margin:6px 0 0;">Ride Published</p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:30px; color:#333;">
              <h2 style="color:#d32f2f;">🎉 Ride Published Successfully!</h2>

              <p>Hi <b>$name</b>,</p>

              <p>Your ride has been successfully published with the following details:</p>

              <table width="100%" style="margin-top:15px;">
                <tr><td><b>From:</b></td><td>$from</td></tr>
                <tr><td><b>To:</b></td><td>$to</td></tr>
                <tr><td><b>Date:</b></td><td>$date</td></tr>
                <tr><td><b>Pickup Time:</b></td><td>$pickupTime</td></tr>
              </table>

              <div style="margin:25px 0; text-align:center;">
                <span style="background:#d32f2f; color:#fff;
                padding:12px 24px; border-radius:6px;">
                  🚘 Ride is Live
                </span>
              </div>

              <p style="font-size:14px; color:#777;">
                Passengers can now view and book your ride.
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

  void incrementPassengers() => setState(() => passengers++);
  void decrementPassengers() {
    if (passengers > 1) setState(() => passengers--);
  }

  void incrementPrice() {
    final current = int.tryParse(priceController.text) ?? 500;
    setState(() => priceController.text = (current + 50).toString());
  }

  void decrementPrice() {
    final current = int.tryParse(priceController.text) ?? 500;
    if (current > 50)
      setState(() => priceController.text = (current - 50).toString());
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100, 12, 31),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFFF4444)),
        ),
        child: child!,
      ),
    );
    if (picked != null)
      setState(
        () => dateController.text =
            '${picked.day}/${picked.month}/${picked.year}',
      );
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

    if (picked == null) return;

    // If user selects DROP TIME
    if (controller == dropTimeController && _pickupTimeOfDay != null) {
      // Convert both to minutes since midnight → universal comparison
      final int pickupMinutes =
          _pickupTimeOfDay!.hour * 60 + _pickupTimeOfDay!.minute;
      final int dropMinutes = picked.hour * 60 + picked.minute;

      if (dropMinutes <= pickupMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Drop time must be after Pickup time")),
        );
        return; // don't set invalid drop time
      }
    }

    // If valid, set values
    setState(() {
      controller.text = picked.format(context); // auto formats 12h or 24h
      if (controller == pickupTimeController) {
        _pickupTimeOfDay = picked;
      } else if (controller == dropTimeController) {
        _dropTimeOfDay = picked;
      }
    });
  }

  void clearFields() {
    setState(() {
      riderNameController.clear();
      phoneController.clear();
      fromCityController.clear();
      toCityController.clear();
      dateController.clear();
      pickupTimeController.clear();
      dropTimeController.clear();
      priceController.text = "500";
      descriptionController.clear();

      passengers = 1;
      fromLatLng = null;
      toLatLng = null;
      fromSuggestions.clear();
      toSuggestions.clear();
      showFromSuggestions = false;
      showToSuggestions = false;
    });
  }

  void handleSubmit() {
    // existing save flow handled by saveRideToFirebase
    // kept for compatibility
    final String fromCity = fromCityController.text.trim();
    final String toCity = toCityController.text.trim();
    final String date = dateController.text.trim();
    final String time = pickupTimeController.text.trim();
    final String riderName = riderNameController.text.trim();
    final int passengerCount = passengers;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublishsucessScreen(
          from: fromCity,
          to: toCity,
          date: date,
          time: time,
          passengers: passengerCount,
          driverName: riderName,
          onGoToHistory: () {
            Navigator.pop(context); // close success screen
            widget.onPublishSuccess?.call();
          },
        ),
      ),
    );
    clearFields();
  }

  @override
  void initState() {
    super.initState();
    priceController.text = "500";
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  void dispose() {
    riderNameController.dispose();
    phoneController.dispose();
    fromCityController.dispose();
    toCityController.dispose();
    dateController.dispose();
    pickupTimeController.dispose();
    dropTimeController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ---------------- Firestore upload ----------------
  Future<void> saveRideToFirebase() async {
    try {
      // Profile image upload commented as requested
      /*
      String imageUrl = "";
      if (profileImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
          "ride_profiles/${DateTime.now().millisecondsSinceEpoch}.jpg",
        );
        await storageRef.putFile(profileImage!);
        imageUrl = await storageRef.getDownloadURL();
      }
      */

      // ignore: unused_local_variable
      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

      await FirebaseFirestore.instance.collection("rides").add({
        "riderName": riderNameController.text.trim(),
        "phoneNumber": phoneController.text.trim(),
        // "profileImage": imageUrl, // commented as requested
        "fromCity": fromCityController.text.trim(),
        "fromLatLng": fromLatLng != null
            ? {"lat": fromLatLng!.lat, "lng": fromLatLng!.lng}
            : null,
        "toCity": toCityController.text.trim(),
        "toLatLng": toLatLng != null
            ? {"lat": toLatLng!.lat, "lng": toLatLng!.lng}
            : null,
        "date": dateController.text.trim(),
        "pickupTime": pickupTimeController.text.trim(),
        "dropTime": dropTimeController.text.trim(),
        "price": priceController.text.trim(),
        "passengers": passengers,
        "description": descriptionController.text.trim(),
        "createdAt": Timestamp.now(),
        "createdBy": FirebaseAuth.instance.currentUser!.uid,
      });

      // 📧 SEND EMAIL (non-blocking)
      _sendRidePublishedEmail(
        from: fromCityController.text.trim(),
        to: toCityController.text.trim(),
        date: dateController.text.trim(),
        pickupTime: pickupTimeController.text.trim(),
      );

      // 🔔 Trigger In-App Notification
      await NotificationController().sendNotification(
        toUserId: FirebaseAuth.instance.currentUser!.uid,
        title: "Ride Published",
        body: "Your ride from ${fromCityController.text} to ${toCityController.text} is live.",
        type: "ride_published",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ride Published Successfully!")),
      );

      final String fromCity = fromCityController.text.trim();
      final String toCity = toCityController.text.trim();
      final String date = dateController.text.trim();
      final String time = pickupTimeController.text.trim();
      final String riderName = riderNameController.text.trim();
      final int passengerCount = passengers;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PublishsucessScreen(
            from: fromCity,
            to: toCity,
            date: date,
            time: time,
            passengers: passengerCount,
            driverName: riderName,
            onGoToHistory: () {
              Navigator.pop(context); // close success screen
              widget.onPublishSuccess?.call();
            },
          ),
        ),
      );
      clearFields();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ---------------- Autocomplete helpers ----------------

  void _onFromChanged(String input) => _onInputChanged(input, isFrom: true);
  void _onToChanged(String input) => _onInputChanged(input, isFrom: false);

  void _onInputChanged(String input, {required bool isFrom}) {
    final trimmed = input.trim();
    _debounceTimer?.cancel();

    if (trimmed.length < 3) {
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

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      fetchPlaceSuggestions(trimmed, isFrom: isFrom);
    });
  }

  Future<void> fetchPlaceSuggestions(
    String input, {
    required bool isFrom,
  }) async {
    final String baseUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    _sessionToken ??= DateTime.now().millisecondsSinceEpoch.toString();

    final String request =
        '$baseUrl'
        '?input=${Uri.encodeComponent(input)}'
        '&key=$googleApiKey'
        '&types=geocode'
        '&language=en'
        '&components=country:in'
        '&sessiontoken=${Uri.encodeComponent(_sessionToken!)}';

    try {
      setState(() {
        if (isFrom)
          _isLoadingFrom = true;
        else
          _isLoadingTo = true;
      });

      final response = await http.get(Uri.parse(request));
      debugPrint(
        'Places Autocomplete HTTP ${response.statusCode}: ${response.body}',
      );

      if (response.statusCode == 200) {
        final Map data = json.decode(response.body);
        final String status = (data['status'] ?? '') as String;

        if (status == 'OK') {
          final List predictions = data['predictions'] ?? [];
          final List<PlacePrediction> suggestions = predictions
              .map<PlacePrediction>(
                (p) => PlacePrediction(
                  description: (p['description'] ?? '') as String,
                  placeId: (p['place_id'] ?? '') as String,
                ),
              )
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
                content: Text(
                  'Places API request denied. Check API key & billing.',
                ),
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
        if (isFrom)
          _isLoadingFrom = false;
        else
          _isLoadingTo = false;
      });
    }
  }

  Future<void> fetchPlaceDetailsAndSet(
    String placeId, {
    required bool isFrom,
  }) async {
    final String baseUrl =
        'https://maps.googleapis.com/maps/api/place/details/json';
    _sessionToken ??= DateTime.now().millisecondsSinceEpoch.toString();

    final String request =
        '$baseUrl'
        '?place_id=${Uri.encodeComponent(placeId)}'
        '&fields=geometry,formatted_address'
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
          final double? lat = (location['lat'] != null)
              ? (location['lat'] as num).toDouble()
              : null;
          final double? lng = (location['lng'] != null)
              ? (location['lng'] as num).toDouble()
              : null;
          final String? formattedAddress =
              result['formatted_address'] as String?;

          setState(() {
            if (isFrom) {
              if (formattedAddress != null && formattedAddress.isNotEmpty)
                fromCityController.text = formattedAddress;
              if (lat != null && lng != null) fromLatLng = LatLngPair(lat, lng);
              fromSuggestions = [];
              showFromSuggestions = false;
            } else {
              if (formattedAddress != null && formattedAddress.isNotEmpty)
                toCityController.text = formattedAddress;
              if (lat != null && lng != null) toLatLng = LatLngPair(lat, lng);
              toSuggestions = [];
              showToSuggestions = false;
            }
          });

          // reset session token after selection
          _sessionToken = null;
        } else {
          debugPrint('Place Details API returned status: $status');
          if (status == 'REQUEST_DENIED') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Place Details request denied. Check API key & billing.',
                ),
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

  // ---------------- UI ----------------

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
      style: GoogleFonts.lexend(fontSize: screenWidth * 0.04),
    );
  }

  Widget _buildAutocompleteBox({
    required List<PlacePrediction> suggestions,
    required bool show,
    required bool isLoading,
    required double screenWidth,
    required double screenHeight,
    required Function(PlacePrediction) onTap,
  }) {
    if (isLoading) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (!show || suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
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
      constraints: BoxConstraints(maxHeight: 180),
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
            onTap: () => onTap(p),
          );
        },
      ),
    );
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
                              Stack(
                                alignment: Alignment.center,
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
                                  const Positioned(
                                    right: 0,
                                    child: NotificationIcon(),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.025),

                              // Rider Details
                              Text(
                                "Enter Rider Details",
                                style: GoogleFonts.lexend(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.012),

                              Text(
                                "Name",
                                style: GoogleFonts.lexend(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.010),
                              _buildTextField(
                                "Enter Rider Name",
                                riderNameController,
                                screenWidth,
                                screenHeight,
                                keyboardType: TextInputType.name,
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return "Name is required";
                                  if (!RegExp(r'^[a-zA-Z 0-9]+$').hasMatch(v))
                                    return "Only alphabets and numbers are allowed";
                                  return null;
                                },
                              ),
                              SizedBox(height: screenHeight * 0.015),

                              // Phone
                              Text(
                                "Phone Number",
                                style: GoogleFonts.lexend(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
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
                                  if (v == null || v.isEmpty)
                                    return "Phone number required";
                                  if (!RegExp(r'^[0-9]{10}$').hasMatch(v))
                                    return "Enter valid 10-digit number";
                                  return null;
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),

                              // // Profile picture
                              // Text("Profile Picture", style: GoogleFonts.lexend(fontSize: screenWidth * 0.04, fontWeight: FontWeight.w500, color: Colors.white)),
                              // SizedBox(height: screenHeight * 0.012),
                              // InkWell(
                              //   onTap: pickProfileImage,
                              //   child: Container(
                              //     width: double.infinity,
                              //     padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.018),
                              //     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              //     child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              //       Text(profileImage == null ? "Add Profile Picture" : "Picture Added ✓", style: GoogleFonts.lexend(color: Colors.grey[600], fontSize: screenWidth * 0.038)),
                              //       const Icon(Icons.camera_alt, color: Colors.black54),
                              //     ]),
                              //   ),
                              // ),
                              // SizedBox(height: screenHeight * 0.02),

                              // Enter Ride Details
                              Text(
                                "Enter Ride Details",
                                style: GoogleFonts.lexend(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.012),

                              // From - autocomplete field
                              Text(
                                "From",
                                style: GoogleFonts.lexend(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.010),
                              _buildTextField(
                                "Enter City / Place",
                                fromCityController,
                                screenWidth,
                                screenHeight,
                                validator: (v) => v == null || v.isEmpty
                                    ? "Select a City"
                                    : null,
                                onChanged: (v) => _onFromChanged(v),
                              ),
                              _buildAutocompleteBox(
                                suggestions: fromSuggestions,
                                show: showFromSuggestions,
                                isLoading: _isLoadingFrom,
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                                onTap: (p) => fetchPlaceDetailsAndSet(
                                  p.placeId,
                                  isFrom: true,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),

                              // To - autocomplete field
                              Text(
                                "To",
                                style: GoogleFonts.lexend(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.010),
                              _buildTextField(
                                "Enter City / Place",
                                toCityController,
                                screenWidth,
                                screenHeight,
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return "Select a City";
                                  if (v == fromCityController.text)
                                    return "From & To cannot be same";
                                  return null;
                                },
                                onChanged: (v) => _onToChanged(v),
                              ),
                              _buildAutocompleteBox(
                                suggestions: toSuggestions,
                                show: showToSuggestions,
                                isLoading: _isLoadingTo,
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                                onTap: (p) => fetchPlaceDetailsAndSet(
                                  p.placeId,
                                  isFrom: false,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),

                              // Passengers
                              Text(
                                "No of Passengers",
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
                                      decoration: const BoxDecoration(
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
                                    "$passengers",
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
                                      decoration: const BoxDecoration(
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

                              // Date & Times
                              Text(
                                "Enter Ride Timings",
                                style: GoogleFonts.lexend(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.012),
                              Text(
                                "Date",
                                style: GoogleFonts.lexend(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.012),
                              _buildTextField(
                                "Enter Date",
                                dateController,
                                screenWidth,
                                screenHeight,
                                readOnly: true,
                                onTap: selectDate,
                                suffixIcon: Icons.calendar_today,
                                validator: (v) => v == null || v.isEmpty
                                    ? "Please select a date"
                                    : null,
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              Text(
                                "Pickup Time",
                                style: GoogleFonts.lexend(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.012),
                              _buildTextField(
                                "Enter Pickup Time",
                                pickupTimeController,
                                screenWidth,
                                screenHeight,
                                readOnly: true,
                                onTap: () => selectTime(pickupTimeController),
                                suffixIcon: Icons.access_time,
                                validator: (v) => v == null || v.isEmpty
                                    ? "Pickup time required"
                                    : null,
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              Text(
                                "Drop Time",
                                style: GoogleFonts.lexend(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.012),
                              _buildTextField(
                                "Enter Drop Time",
                                dropTimeController,
                                screenWidth,
                                screenHeight,
                                readOnly: true,
                                onTap: () => selectTime(dropTimeController),
                                suffixIcon: Icons.access_time,
                                validator: (v) => v == null || v.isEmpty
                                    ? "Drop time required"
                                    : null,
                              ),
                              SizedBox(height: screenHeight * 0.02),

                              // Price
                              Text(
                                "Enter Ride Price per seat",
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
                                      decoration: const BoxDecoration(
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
                                        const Icon(
                                          Icons.currency_rupee,
                                          color: Color(0xFFFF4444),
                                        ),
                                        SizedBox(
                                          width: screenWidth * 0.15,
                                          child: TextFormField(
                                            controller: priceController,
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            validator: (v) {
                                              if (v == null || v.isEmpty)
                                                return "Enter price";
                                              if (!RegExp(
                                                r'^[0-9]+$',
                                              ).hasMatch(v))
                                                return "Only numbers allowed";
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
                                      child: const Icon(
                                        Icons.add,
                                        color: Color(0xFFFF4444),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02),

                              // Description
                              Text(
                                "Enter Description ",
                                style: GoogleFonts.lexend(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
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

                              // Submit
                              // SizedBox(
                              //   width: double.infinity,
                              //   child: ElevatedButton(
                              //     onPressed: () async {
                              //       if (_formKey.currentState!.validate()) {
                              //         if (profileImage == null) {
                              //           ScaffoldMessenger.of(
                              //             context,
                              //           ).showSnackBar(
                              //             const SnackBar(
                              //               content: Text(
                              //                 "Please add a profile picture",
                              //               ),
                              //             ),
                              //           );
                              //           return;
                              //         }

                              //         // NEW VALIDATION: Drop Time must be after Pickup Time
                              //         try {
                              //           final pickup = TimeOfDayExtension.parse(
                              //             pickupTimeController.text.trim(),
                              //           );
                              //           final drop = TimeOfDayExtension.parse(
                              //             dropTimeController.text.trim(),
                              //           );

                              //           if (!drop.isAfter(pickup)) {
                              //             ScaffoldMessenger.of(
                              //               context,
                              //             ).showSnackBar(
                              //               const SnackBar(
                              //                 content: Text(
                              //                   "Drop time must be after Pickup time",
                              //                 ),
                              //               ),
                              //             );
                              //             return;
                              //           }
                              //         } catch (_) {
                              //           ScaffoldMessenger.of(
                              //             context,
                              //           ).showSnackBar(
                              //             const SnackBar(
                              //               content: Text(
                              //                 "Invalid time format",
                              //               ),
                              //             ),
                              //           );
                              //           return;
                              //         }

                              //         await saveRideToFirebase();
                              //       }
                              //     },
                              //     style: ElevatedButton.styleFrom(
                              //       backgroundColor: Colors.white,
                              //       padding: EdgeInsets.symmetric(
                              //         vertical: screenHeight * 0.018,
                              //       ),
                              //       shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(12),
                              //       ),
                              //     ),
                              //     child: Text(
                              //       "Submit",
                              //       style: GoogleFonts.lexend(
                              //         fontSize: screenWidth * 0.045,
                              //         fontWeight: FontWeight.w600,
                              //         color: const Color(0xFFFF4444),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              Center(
                                child: SizedBox(
                                  width:
                                      screenWidth *
                                      0.6, // smaller width (60% of screen)
                                  height:
                                      screenHeight *
                                      0.065, // smaller fixed height
                                  child: ElevatedButton(
                                    onPressed: isSubmitting
                                        ? null
                                        : () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              // if (profileImage == null) {
                                              //   ScaffoldMessenger.of(
                                              //     context,
                                              //   ).showSnackBar(
                                              //     const SnackBar(
                                              //       content: Text(
                                              //         "Please add a profile picture",
                                              //       ),
                                              //     ),
                                              //   );
                                              //   return;
                                              // }

                                              // START SUBMIT ANIMATION
                                              setState(() {
                                                isSubmitting = true;
                                              });

                                              // Wait for your GIF animation time
                                              await Future.delayed(
                                                const Duration(seconds: 3),
                                              );

                                              // Show Published!
                                              setState(() {
                                                isPublished = true;
                                              });

                                              await Future.delayed(
                                                const Duration(seconds: 1),
                                              );

                                              // SAVE RIDE
                                              await saveRideToFirebase();

                                              // Reset
                                              setState(() {
                                                isSubmitting = false;
                                                isPublished = false;
                                              });
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: EdgeInsets
                                          .zero, // important so height comes from SizedBox
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: isSubmitting
                                          ? SizedBox.expand(
                                              key: const ValueKey('loading'),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                child: Image.asset(
                                                  "assets/car_loading.gif",
                                                  fit: BoxFit
                                                      .cover, // fills the small button
                                                ),
                                              ),
                                            )
                                          : isPublished
                                          ? Text(
                                              "Published!",
                                              key: const ValueKey('published'),
                                              style: GoogleFonts.lexend(
                                                fontSize: screenWidth * 0.045,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green,
                                              ),
                                            )
                                          : Text(
                                              "Submit",
                                              key: const ValueKey('submit'),
                                              style: GoogleFonts.lexend(
                                                fontSize: screenWidth * 0.045,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFFFF4444),
                                              ),
                                            ),
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
          ],
        ),
      ),
    );
  }
}

// ---------------- Preview Screen ----------------
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
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Retake"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
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

extension TimeOfDayExtension on TimeOfDay {
  /// Converts "10:30 AM" or "8:15 PM" to TimeOfDay
  static TimeOfDay parse(String timeString) {
    final format = DateFormat.jm(); // uses intl package
    final dateTime = format.parse(timeString);
    return TimeOfDay.fromDateTime(dateTime);
  }

  /// Compare two TimeOfDay values
  bool isAfter(TimeOfDay other) {
    return hour > other.hour || (hour == other.hour && minute > other.minute);
  }
}
