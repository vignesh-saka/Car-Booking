// // search_screen.dart
// ignore_for_file: unused_field

import 'dart:async';
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:bookmycar/Screens/Avalabile_Ride_Screens/avalabile_rides_screen.dart';
import 'package:bookmycar/Screens/History_Screens/Screens/history_screen.dart';
import 'package:bookmycar/Screens/My_Booking_Screens/Screens/my_bookings_screen.dart';
import 'package:bookmycar/Screens/Profile_Screen/profile_screen.dart';
import 'package:bookmycar/Screens/Publish_Ride_Screens/publishride_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:bookmycar/widgets/notification_icon.dart';

/// SearchScreen with Google Places Autocomplete (India-only) for From/To fields.
/// Autocomplete triggers after 3 characters and uses a session token.
class SearchScreen extends StatefulWidget {
  final VoidCallback onBookingSuccess;
  const SearchScreen({super.key, required this.onBookingSuccess});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
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

class _SearchScreenState extends State<SearchScreen> {
  // Controllers
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  // Passengers + bottom nav
  int passengers = 1;
  int selectedIndex = 2;

  bool isSubmitting = false;
  bool isPublished = false;

  // Backend data
  List<RecentRide> recentRides = [];

  // Autocomplete state
  Timer? _debounceTimer;
  String? _sessionToken;

  List<PlacePrediction> fromSuggestions = [];
  List<PlacePrediction> toSuggestions = [];
  bool showFromSuggestions = false;
  bool showToSuggestions = false;
  bool _isLoadingFrom = false;
  bool _isLoadingTo = false;

  // Selected lat/lng & place ids (for robust matching)
  LatLngPair? fromLatLng;
  LatLngPair? toLatLng;
  String? _fromPlaceId;
  String? _toPlaceId;

  // Extra optional extracted address components (if needed)
  String? _fromLocality;
  String? _fromAdminArea;
  String? _toLocality;
  String? _toAdminArea;

  // Google API key (you provided earlier). Restrict this in production.
  // Google API Key selection based on platform
  String get googleApiKey {
    if (kIsWeb) {
      return 'AIzaSyBnmoEDuYaANSe4eO-2B4FUdW7-rJ5Ed_s';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'AIzaSyC0YzYM2SMNib_QNRiqnILXWqieKZrXjqQ';
      case TargetPlatform.iOS:
        return 'AIzaSyCJqyEEOjscQ8gKXZoZWYGOiTUJH5N5FtQ';
      default:
        return 'AIzaSyC0YzYM2SMNib_QNRiqnILXWqieKZrXjqQ';
    }
  }

  @override
  void initState() {
    super.initState();
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
    _fetchRecentSearches();
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    dateController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Passengers handlers
  void incrementPassengers() => setState(() => passengers++);
  void decrementPassengers() {
    if (passengers > 1) setState(() => passengers--);
  }

  // Date picker
  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFFF3B30)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void clearFields() {
    setState(() {
      fromController.clear();
      toController.clear();
      dateController.clear();
    });
  }

  void _swapLocations() {
    setState(() {
      // Swap Text
      final tempText = fromController.text;
      fromController.text = toController.text;
      toController.text = tempText;

      // Swap Coordinates
      final tempLatLng = fromLatLng;
      fromLatLng = toLatLng;
      toLatLng = tempLatLng;

      // Swap Place IDs
      final tempPlaceId = _fromPlaceId;
      _fromPlaceId = _toPlaceId;
      _toPlaceId = tempPlaceId;

      // Swap Locality/AdminArea
      final tempLocality = _fromLocality;
      _fromLocality = _toLocality;
      _toLocality = tempLocality;

      final tempAdminArea = _fromAdminArea;
      _fromAdminArea = _toAdminArea;
      _toAdminArea = tempAdminArea;

      // Clear suggestions to avoid confusion
      fromSuggestions.clear();
      toSuggestions.clear();
      showFromSuggestions = false;
      showToSuggestions = false;
    });
  }

  // Search action
  // Search action
  Future<void> handleSearch() async {
    // Hide keyboard and suggestions
    FocusScope.of(context).unfocus();
    if (!mounted) return;
    setState(() {
      fromSuggestions = [];
      toSuggestions = [];
      showFromSuggestions = false;
      showToSuggestions = false;
    });

    if (fromController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter departure city',
            style: GoogleFonts.lexend(),
          ),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
      return;
    }
    if (toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter destination city',
            style: GoogleFonts.lexend(),
          ),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
      return;
    }
    if (dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select date', style: GoogleFonts.lexend()),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
      return;
    }

    // ✅ All validations passed → start animation
    if (!mounted) return;
    setState(() {
      isSubmitting = true;
    });

    // Same as PublishRideScreen: 3 sec GIF
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    setState(() {
      isSubmitting = false;
      isPublished = true;
    });

    // Show "Published!" (here: search success) for 1 sec
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      isPublished = false;
    });

    // Save to Recents before navigating
    await _saveRecentSearch();

    // Now actually navigate to results screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvailableRidesScreen(
          from: fromController.text,
          to: toController.text,
          date: dateController.text,
          passengers: passengers,
          fromPlaceId: _fromPlaceId,
          fromLat: fromLatLng?.lat,
          fromLng: fromLatLng?.lng,
          toPlaceId: _toPlaceId,
          toLat: toLatLng?.lat,
          toLng: toLatLng?.lng,
          onBookingSuccess: () {
            Navigator.pop(context); // close success screen
            widget.onBookingSuccess(); // 👈 notify MainDashboard
          },
        ),
      ),
    );
    // clearFields(); // Optional: keep fields for better UX or clear them
  }

  // ------------------- Recent Searches Logic -------------------

  Future<void> _fetchRecentSearches() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()!.containsKey('recentSearches')) {
        final List<dynamic> data = doc.data()!['recentSearches'];
        setState(() {
          recentRides = data.map((e) => RecentRide.fromJson(e)).toList();
        });
      } else {
        setState(() {
          recentRides = [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching recent searches: $e");
    }
  }

  Future<void> _saveRecentSearch() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newRide = RecentRide(
      from: fromController.text,
      to: toController.text,
      fromPlaceId: _fromPlaceId,
      toPlaceId: _toPlaceId,
      fromLat: fromLatLng?.lat,
      fromLng: fromLatLng?.lng,
      toLat: toLatLng?.lat,
      toLng: toLatLng?.lng,
    );

    try {
      // Get current list
      List<RecentRide> currentList = [...recentRides];

      // Remove duplicates (same from & to)
      currentList.removeWhere((r) =>
          r.from.toLowerCase() == newRide.from.toLowerCase() &&
          r.to.toLowerCase() == newRide.to.toLowerCase());

      // Insert at beginning
      currentList.insert(0, newRide);

      // Keep max 5
      if (currentList.length > 5) {
        currentList = currentList.sublist(0, 5);
      }

      // Update Local State
      setState(() {
        recentRides = currentList;
      });

      // Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'recentSearches': currentList.map((e) => e.toJson()).toList(),
      }, SetOptions(merge: true));

    } catch (e) {
      debugPrint("Error saving recent search: $e");
    }
  }

  // Bottom nav
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
        // already in search
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
    final trimmed = input.trim();
    _debounceTimer?.cancel();

    // hide suggestions if less than 3 chars
    if (trimmed.length < 3) {
      if (!mounted) return;
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
    _sessionToken ??= DateTime.now().millisecondsSinceEpoch.toString();

    // Loading state
    if (!mounted) return;
    setState(() {
      if (isFrom) {
        _isLoadingFrom = true;
      } else {
        _isLoadingTo = true;
      }
    });

    try {
      List<PlacePrediction> suggestions = [];

      if (kIsWeb) {
        // WEB: Call Cloud Function to avoid CORS
        final HttpsCallable callable =
            FirebaseFunctions.instance.httpsCallable('getPlacesAutocomplete');
        final result = await callable.call({
          'input': input,
          'sessionToken': _sessionToken,
        });

        final Map<String, dynamic> data =
            Map<String, dynamic>.from(result.data as Map);
        final String status = (data['status'] ?? '') as String;

        if (status == 'OK') {
          final List predictions = data['predictions'] as List? ?? [];
          suggestions = predictions
              .map<PlacePrediction>((p) {
                final Map<String, dynamic> item =
                    Map<String, dynamic>.from(p as Map);
                return PlacePrediction(
                  description: item['description'] as String? ?? '',
                  placeId: item['place_id'] as String? ?? '',
                );
              })
              .where((p) => p.description.isNotEmpty && p.placeId.isNotEmpty)
              .toList();
        }
      } else {
        // MOBILE: Direct HTTP Call
        final String baseUrl =
            'https://maps.googleapis.com/maps/api/place/autocomplete/json';
        final String request = '$baseUrl'
            '?input=${Uri.encodeComponent(input)}'
            '&key=$googleApiKey'
            '&types=geocode'
            '&language=en'
            '&components=country:in'
            '&sessiontoken=${Uri.encodeComponent(_sessionToken!)}';

        final response = await http.get(Uri.parse(request));
        if (response.statusCode == 200) {
          final Map<String, dynamic> data =
              json.decode(response.body) as Map<String, dynamic>;
          final String status = (data['status'] ?? '') as String;

          if (status == 'OK') {
            final List predictions = data['predictions'] as List? ?? [];
            suggestions = predictions
                .map<PlacePrediction>((p) {
                  final Map<String, dynamic> item = p as Map<String, dynamic>;
                  return PlacePrediction(
                    description: item['description'] as String? ?? '',
                    placeId: item['place_id'] as String? ?? '',
                  );
                })
                .where((p) => p.description.isNotEmpty && p.placeId.isNotEmpty)
                .toList();
          }
        }
      }

      if (!mounted) return;
      setState(() {
        if (isFrom) {
          fromSuggestions = suggestions;
          showFromSuggestions = suggestions.isNotEmpty;
        } else {
          toSuggestions = suggestions;
          showToSuggestions = suggestions.isNotEmpty;
        }
      });
    } catch (e) {
      debugPrint('Autocomplete exception: $e');
      if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        if (isFrom) {
          _isLoadingFrom = false;
        } else {
          _isLoadingTo = false;
        }
      });
    }
  }

  Future<void> fetchPlaceDetailsAndSet(
    String placeId, {
    required bool isFrom,
  }) async {
    _sessionToken ??= DateTime.now().millisecondsSinceEpoch.toString();

    try {
      Map<String, dynamic> result = {};

      if (kIsWeb) {
        // WEB: Call Cloud Function
        final HttpsCallable callable =
            FirebaseFunctions.instance.httpsCallable('getPlaceDetails');
        final response = await callable.call({
          'placeId': placeId,
          'sessionToken': _sessionToken,
        });
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(response.data as Map);
        if (data['status'] == 'OK') {
          result = Map<String, dynamic>.from(data['result'] as Map);
        }
      } else {
        // MOBILE: Direct HTTP Call
        final String baseUrl =
            'https://maps.googleapis.com/maps/api/place/details/json';
        final String request = '$baseUrl'
            '?place_id=${Uri.encodeComponent(placeId)}'
            '&fields=geometry,formatted_address,address_component,place_id'
            '&key=$googleApiKey'
            '&language=en'
            '&sessiontoken=${Uri.encodeComponent(_sessionToken!)}';

        final response = await http.get(Uri.parse(request));
        debugPrint(
            'PlaceDetails HTTP ${response.statusCode}: ${response.body}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> data =
              json.decode(response.body) as Map<String, dynamic>;
          if (data['status'] == 'OK') {
            result = data['result'] as Map<String, dynamic>;
          }
        }
      }

      if (result.isNotEmpty && mounted) {
        final Map<String, dynamic> geometry =
            result['geometry'] as Map<String, dynamic>? ?? {};
        final Map<String, dynamic> location =
            geometry['location'] as Map<String, dynamic>? ?? {};
        final double? lat = (location['lat'] != null)
            ? (location['lat'] as num).toDouble()
            : null;
        final double? lng = (location['lng'] != null)
            ? (location['lng'] as num).toDouble()
            : null;
        final String formattedAddress =
            result['formatted_address'] as String? ?? '';
        final String returnedPlaceId = result['place_id'] as String? ?? '';

        // address components -> extract locality/admin_area/postal_code
        String? locality, adminArea, postalCode;
        final List<dynamic> components =
            result['address_components'] as List<dynamic>? ?? [];
        for (final c in components) {
          final comp = Map<String, dynamic>.from(c as Map);
          final List types = comp['types'] as List? ?? [];
          if (types.contains('locality'))
            locality = comp['long_name'] as String?;
          if (types.contains('administrative_area_level_1') ||
              types.contains('administrative_area_level_2')) {
            adminArea ??= comp['long_name'] as String?;
          }
          if (types.contains('postal_code'))
            postalCode = comp['long_name'] as String?;
        }

        setState(() {
          if (isFrom) {
            fromController.text = formattedAddress; // full address
            _fromPlaceId = returnedPlaceId;
            if (lat != null && lng != null) {
              fromLatLng = LatLngPair(lat, lng);
            }
            _fromLocality = locality;
            _fromAdminArea = adminArea;
            // hide suggestions
            fromSuggestions = [];
            showFromSuggestions = false;
          } else {
            toController.text = formattedAddress;
            _toPlaceId = returnedPlaceId;
            if (lat != null && lng != null) {
              toLatLng = LatLngPair(lat, lng);
            }
            _toLocality = locality;
            _toAdminArea = adminArea;
            // hide suggestions
            toSuggestions = [];
            showToSuggestions = false;
          }
        });
      }
    } catch (e) {
      debugPrint('PlaceDetails exception: $e');
    }
  }



  // ---------------- UI helpers ----------------

  Widget _buildAutocompleteBox({
    required List<PlacePrediction> suggestions,
    required bool show,
    required bool isLoading,
    required Function(PlacePrediction) onTap,
  }) {
    if (!show || suggestions.isEmpty) return const SizedBox.shrink();

    if (isLoading) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(vertical: 16),
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
      constraints: const BoxConstraints(maxHeight: 180),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final p = suggestions[index];
          return ListTile(
            title: Text(
              p.description,
              style: GoogleFonts.lexend(fontSize: 15),
            ),
            onTap: () => onTap(p),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // ----------------------- BUILD ----------------------------
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ========================= HEADER ===========================
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 30.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Center(
                                child: Text(
                                  'Find a Ride?',
                                  style: GoogleFonts.lexend(
                                    fontSize: 24,
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
                          const SizedBox(height: 20),
                          Text(
                            'Where are you going?',
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ================= FROM FIELD =================
                          Text(
                            'From',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),

                          TextField(
                            controller: fromController,
                            onTap: () {
                              if ((fromController.text).trim().length >= 3) {
                                _onFromChanged(fromController.text);
                              }
                            },
                            onChanged: (value) => _onFromChanged(value),
                            decoration: InputDecoration(
                              hintText: 'Enter City Name',
                              hintStyle: GoogleFonts.lexend(
                                color: Colors.grey[400],
                                fontSize: 15,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),

                          // Places suggestions
                          if (showFromSuggestions)
                            _buildAutocompleteBox(
                              suggestions: fromSuggestions,
                              show: showFromSuggestions,
                              isLoading: _isLoadingFrom,

                              onTap: (p) => fetchPlaceDetailsAndSet(p.placeId,
                                  isFrom: true),
                            ),

                          const SizedBox(height: 20),

                          // ================= SWAP BUTTON & TO FIELD =================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'To',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              // Swap Button (Right Side)
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: _swapLocations,
                                  icon: const Icon(
                                    Icons.swap_vert,
                                    color: Color(0xFFFF3B30),
                                    size: 18,
                                  ),
                                  tooltip: 'Swap Locations',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          TextField(
                            controller: toController,
                            onTap: () {
                              if ((toController.text).trim().length >= 3) {
                                _onToChanged(toController.text);
                              }
                            },
                            onChanged: (value) => _onToChanged(value),
                            decoration: InputDecoration(
                              hintText: 'Enter City Name',
                              hintStyle: GoogleFonts.lexend(
                                color: Colors.grey[400],
                                fontSize: 15,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),

                          if (showToSuggestions)
                            _buildAutocompleteBox(
                              suggestions: toSuggestions,
                              show: showToSuggestions,
                              isLoading: _isLoadingTo,

                              onTap: (p) => fetchPlaceDetailsAndSet(p.placeId,
                                  isFrom: false),
                            ),

                          const SizedBox(height: 20),

                          // ================= DATE =================
                          Text(
                            'Date',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: dateController,
                            readOnly: true,
                            onTap: selectDate,
                            decoration: InputDecoration(
                              hintText: 'Enter Date',
                              hintStyle: GoogleFonts.lexend(
                                color: Colors.grey[400],
                                fontSize: 15,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ================= SEARCH BUTTON =================
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => handleSearch(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: isSubmitting
                                      ? SizedBox.expand(
                                          key: const ValueKey('loading'),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            child: Image.asset(
                                              "assets/car_loading.gif",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : isPublished
                                          ? Text(
                                              "Searching...",
                                              key: const ValueKey('published'),
                                              style: GoogleFonts.lexend(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green,
                                              ),
                                            )
                                          : Text(
                                              "Search",
                                              key: const ValueKey('search'),
                                              style: GoogleFonts.lexend(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFFFF3B30),
                                              ),
                                            ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ================= RECENTS =================
                  if (recentRides.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Recents',
                                style: GoogleFonts.lexend(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                            const SizedBox(height: 15),
                            ...recentRides.map(
                              (ride) => RecentRideItem(
                                ride: ride,

                                onTap: () {
                                  // Populate fields
                                  setState(() {
                                    fromController.text = ride.from;
                                    toController.text = ride.to;
                                    _fromPlaceId = ride.fromPlaceId;
                                    _toPlaceId = ride.toPlaceId;
                                    if (ride.fromLat != null &&
                                        ride.fromLng != null) {
                                      fromLatLng = LatLngPair(
                                          ride.fromLat!, ride.fromLng!);
                                    }
                                    if (ride.toLat != null &&
                                        ride.toLng != null) {
                                      toLatLng = LatLngPair(
                                          ride.toLat!, ride.toLng!);
                                    }
                                  });
                                },
                              ),
                            ),
                          ]),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// ====================== RECENT RIDE MODEL =========================
// ==================================================================
class RecentRide {
  final String from;
  final String to;
  final String? fromPlaceId;
  final String? toPlaceId;
  final double? fromLat;
  final double? fromLng;
  final double? toLat;
  final double? toLng;

  RecentRide({
    required this.from,
    required this.to,
    this.fromPlaceId,
    this.toPlaceId,
    this.fromLat,
    this.fromLng,
    this.toLat,
    this.toLng,
  });

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'fromPlaceId': fromPlaceId,
        'toPlaceId': toPlaceId,
        'fromLat': fromLat,
        'fromLng': fromLng,
        'toLat': toLat,
        'toLng': toLng,
      };

  factory RecentRide.fromJson(Map<String, dynamic> json) => RecentRide(
        from: json['from'] ?? '',
        to: json['to'] ?? '',
        fromPlaceId: json['fromPlaceId'],
        toPlaceId: json['toPlaceId'],
        fromLat: json['fromLat'],
        fromLng: json['fromLng'],
        toLat: json['toLat'],
        toLng: json['toLng'],
      );
}

class RecentRideItem extends StatelessWidget {
  final RecentRide ride;
  final VoidCallback onTap;

  const RecentRideItem({
    super.key,
    required this.ride,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
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
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    ride.from.split(',')[0].trim(), // Only first part
                    style: GoogleFonts.lexend(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    ride.to.split(',')[0].trim(), // Only first part
                    style: GoogleFonts.lexend(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
