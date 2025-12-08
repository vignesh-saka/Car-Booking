// // search_screen.dart
import 'dart:async';
import 'dart:convert';
// import 'dart:math';

import 'package:bookmycar/Screens/Avalabile_Ride_Screens/avalabile_rides_screen.dart';
import 'package:bookmycar/Screens/Comman/bottom_navigation.dart';
import 'package:bookmycar/Screens/History_Screens/Screens/history_screen.dart';
import 'package:bookmycar/Screens/My_Booking_Screens/Screens/my_bookings_screen.dart';
import 'package:bookmycar/Screens/Profile_Screen/profile_screen.dart';
import 'package:bookmycar/Screens/Publish_Ride_Screens/publishride_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

/// SearchScreen with Google Places Autocomplete (India-only) for From/To fields.
/// Autocomplete triggers after 3 characters and uses a session token.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

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

  // Backend data - replace with actual API call
  List<RecentRide> recentRides = [
    RecentRide(from: 'Hyderabad', to: 'Karimnagar'),
    RecentRide(from: 'Karimnagar', to: 'Hyderabad'),
  ];

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
  static const String googleApiKey = 'AIzaSyCwizUugA6ySbo1PnnuNdPxGDXHPZAWtjY';

  @override
  void initState() {
    super.initState();
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
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
    if (picked != null && mounted) {
      setState(() {
        dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  // Search action
  void handleSearch() {
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
          content: Text('Please enter departure city', style: GoogleFonts.lexend()),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
      return;
    }
    if (toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter destination city', style: GoogleFonts.lexend()),
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

    // Navigate and pass place_id/coordinates along with text so backend/screen can match using them
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvailableRidesScreen(
          from: fromController.text,
          to: toController.text,
          date: dateController.text,
          passengers: passengers,
          // optional robust matching props - AvailableRidesScreen should accept them (optional)
          fromPlaceId: _fromPlaceId,
          fromLat: fromLatLng?.lat,
          fromLng: fromLatLng?.lng,
          toPlaceId: _toPlaceId,
          toLat: toLatLng?.lat,
          toLng: toLatLng?.lng,
        ),
      ),
    );
  }

  // Bottom nav
  void onNavItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => PublishRideScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => MyBookingsScreen()));
        break;
      case 2:
        // already in search
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
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

  Future<void> fetchPlaceSuggestions(String input, {required bool isFrom}) async {
    final String baseUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    _sessionToken ??= DateTime.now().millisecondsSinceEpoch.toString();

    final String request = '$baseUrl'
        '?input=${Uri.encodeComponent(input)}'
        '&key=$googleApiKey'
        '&types=geocode'
        '&language=en'
        '&components=country:in'
        '&sessiontoken=${Uri.encodeComponent(_sessionToken!)}';

    try {
      if (!mounted) return;
      setState(() {
        if (isFrom) {
          _isLoadingFrom = true;
        } else {
          _isLoadingTo = true;
        }
      });

      final response = await http.get(Uri.parse(request));
      debugPrint('Autocomplete HTTP ${response.statusCode}: ${response.body}');

      if (!mounted) return;
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final String status = (data['status'] ?? '') as String;

        if (status == 'OK') {
          final List predictions = data['predictions'] as List? ?? [];
          final List<PlacePrediction> suggestions = predictions.map<PlacePrediction>((p) {
            final Map<String, dynamic> item = p as Map<String, dynamic>;
            return PlacePrediction(
              description: item['description'] as String? ?? '',
              placeId: item['place_id'] as String? ?? '',
            );
          }).where((p) => p.description.isNotEmpty && p.placeId.isNotEmpty).toList();

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
        } else if (status == 'ZERO_RESULTS') {
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
        } else {
          debugPrint('Autocomplete API status: $status');
          if (status == 'REQUEST_DENIED') {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Places API request denied. Check API key & billing.')),
            );
          }
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
        }
      } else {
        debugPrint('Autocomplete HTTP error: ${response.statusCode}');
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
      }
    } catch (e, st) {
      debugPrint('Autocomplete exception: $e\n$st');
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

  Future<void> fetchPlaceDetailsAndSet(String placeId, {required bool isFrom}) async {
    final String baseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
    _sessionToken ??= DateTime.now().millisecondsSinceEpoch.toString();

    final String request = '$baseUrl'
        '?place_id=${Uri.encodeComponent(placeId)}'
        '&fields=geometry,formatted_address,address_component,place_id'
        '&key=$googleApiKey'
        '&language=en'
        '&sessiontoken=${Uri.encodeComponent(_sessionToken!)}';

    try {
      final response = await http.get(Uri.parse(request));
      debugPrint('PlaceDetails HTTP ${response.statusCode}: ${response.body}');

      if (!mounted) return;
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final String status = (data['status'] ?? '') as String;

        if (status == 'OK') {
          final Map<String, dynamic> result = data['result'] as Map<String, dynamic>;
          final Map<String, dynamic> geometry = result['geometry'] as Map<String, dynamic>? ?? {};
          final Map<String, dynamic> location = geometry['location'] as Map<String, dynamic>? ?? {};
          final double? lat = (location['lat'] != null) ? (location['lat'] as num).toDouble() : null;
          final double? lng = (location['lng'] != null) ? (location['lng'] as num).toDouble() : null;
          final String formattedAddress = result['formatted_address'] as String? ?? '';
          final String returnedPlaceId = result['place_id'] as String? ?? '';

          // address components -> extract locality/admin_area/postal_code
          String? locality, adminArea, postalCode;
          final List<dynamic> components = result['address_components'] as List<dynamic>? ?? [];
          for (final c in components) {
            final comp = c as Map<String, dynamic>;
            final List types = comp['types'] as List? ?? [];
            if (types.contains('locality')) locality = comp['long_name'] as String?;
            if (types.contains('administrative_area_level_1') || types.contains('administrative_area_level_2')) {
              adminArea ??= comp['long_name'] as String?;
            }
            if (types.contains('postal_code')) postalCode = comp['long_name'] as String?;
          }

          if (!mounted) return;
          setState(() {
            if (isFrom) {
              if (formattedAddress.isNotEmpty) fromController.text = formattedAddress;
              if (lat != null && lng != null) fromLatLng = LatLngPair(lat, lng);
              _fromPlaceId = returnedPlaceId;
              _fromLocality = locality;
              _fromAdminArea = adminArea;
              fromSuggestions = [];
              showFromSuggestions = false;
            } else {
              if (formattedAddress.isNotEmpty) toController.text = formattedAddress;
              if (lat != null && lng != null) toLatLng = LatLngPair(lat, lng);
              _toPlaceId = returnedPlaceId;
              _toLocality = locality;
              _toAdminArea = adminArea;
              toSuggestions = [];
              showToSuggestions = false;
            }
          });

          // Reset session token after selection
          _sessionToken = null;
        } else {
          debugPrint('Place Details API status: $status');
          if (status == 'REQUEST_DENIED') {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Place Details request denied. Check API key & billing.')),
            );
          }
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
        }
      } else {
        debugPrint('Place Details HTTP error: ${response.statusCode}');
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
      }
    } catch (e, st) {
      debugPrint('Place Details exception: $e\n$st');
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
    }
  }

  // ---------------- UI helpers ----------------

  Widget _buildAutocompleteBox({
    required List<PlacePrediction> suggestions,
    required bool show,
    required bool isLoading,
    required double screenWidth,
    required double screenHeight,
    required Function(PlacePrediction) onTap,
  }) {
    if (!show || suggestions.isEmpty) return const SizedBox.shrink();

    if (isLoading) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      constraints: BoxConstraints(maxHeight: 180),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final p = suggestions[index];
          return ListTile(
            title: Text(p.description, style: GoogleFonts.lexend(fontSize: screenWidth * 0.038)),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========================= HEADER ===========================
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF3B30),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenHeight * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text('Find a Ride?', style: GoogleFonts.lexend(fontSize: screenWidth * 0.065, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                      SizedBox(height: screenHeight * 0.025),
                      Text('Where are you going?', style: GoogleFonts.lexend(fontSize: screenWidth * 0.04, color: Colors.white)),
                      SizedBox(height: screenHeight * 0.012),

                      // ================= FROM FIELD =================
                      Text('From', style: GoogleFonts.lexend(fontSize: screenWidth * 0.035, color: Colors.white)),
                      SizedBox(height: 8),

                      TextField(
                        controller: fromController,
                        onTap: () {
                          // if already typed 3+ chars, fetch suggestions
                          if ((fromController.text).trim().length >= 3) {
                            _onFromChanged(fromController.text);
                          }
                        },
                        onChanged: (value) => _onFromChanged(value),
                        decoration: InputDecoration(
                          hintText: 'Enter City Name',
                          hintStyle: GoogleFonts.lexend(color: Colors.grey[400], fontSize: screenWidth * 0.038),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.018),
                        ),
                      ),

                      // Places suggestions
                      if (showFromSuggestions)
                        _buildAutocompleteBox(
                          suggestions: fromSuggestions,
                          show: showFromSuggestions,
                          isLoading: _isLoadingFrom,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          onTap: (p) => fetchPlaceDetailsAndSet(p.placeId, isFrom: true),
                        ),

                      SizedBox(height: screenHeight * 0.02),

                      // ================= TO FIELD =================
                      Text('To', style: GoogleFonts.lexend(fontSize: screenWidth * 0.035, color: Colors.white)),
                      SizedBox(height: 8),
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
                          hintStyle: GoogleFonts.lexend(color: Colors.grey[400], fontSize: screenWidth * 0.038),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.018),
                        ),
                      ),

                      if (showToSuggestions)
                        _buildAutocompleteBox(
                          suggestions: toSuggestions,
                          show: showToSuggestions,
                          isLoading: _isLoadingTo,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          onTap: (p) => fetchPlaceDetailsAndSet(p.placeId, isFrom: false),
                        ),

                      SizedBox(height: screenHeight * 0.02),

                      // ================= DATE =================
                      Text('Date', style: GoogleFonts.lexend(fontSize: screenWidth * 0.035, color: Colors.white)),
                      SizedBox(height: 8),
                      TextField(
                        controller: dateController,
                        readOnly: true,
                        onTap: selectDate,
                        decoration: InputDecoration(
                          hintText: 'Enter Date',
                          hintStyle: GoogleFonts.lexend(color: Colors.grey[400], fontSize: screenWidth * 0.038),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.018),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // ================= PASSENGERS =================
                      Text('No. of Passengers', style: GoogleFonts.lexend(fontSize: screenWidth * 0.035, color: Colors.white)),
                      SizedBox(height: screenHeight * 0.012),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: decrementPassengers,
                            child: Container(width: screenWidth * 0.1, height: screenWidth * 0.1, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.remove, color: Color(0xFFFF4444))),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          Text('$passengers', style: GoogleFonts.lexend(fontSize: screenWidth * 0.05, fontWeight: FontWeight.w600, color: Colors.white)),
                          SizedBox(width: screenWidth * 0.04),
                          GestureDetector(
                            onTap: incrementPassengers,
                            child: Container(width: screenWidth * 0.1, height: screenWidth * 0.1, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.add, color: Color(0xFFFF4444))),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.025),

                      // ================= SEARCH BUTTON =================
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: handleSearch,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: Text('Search', style: GoogleFonts.lexend(fontSize: screenWidth * 0.045, fontWeight: FontWeight.w600, color: const Color(0xFFFF4444))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ================= RECENTS =================
              if (recentRides.isNotEmpty)
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Recents', style: GoogleFonts.lexend(fontSize: screenWidth * 0.05, fontWeight: FontWeight.w600, color: Colors.black87)),
                    SizedBox(height: screenHeight * 0.015),
                    ...recentRides.map((ride) => RecentRideItem(ride: ride, screenWidth: screenWidth, screenHeight: screenHeight)),
                  ]),
                ),
            ],
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

// ==================================================================
// ====================== RECENT RIDE MODEL =========================
// ==================================================================
class RecentRide {
  final String from;
  final String to;
  RecentRide({required this.from, required this.to});

  factory RecentRide.fromJson(Map<String, dynamic> json) => RecentRide(from: json['from'], to: json['to']);
}

class RecentRideItem extends StatelessWidget {
  final RecentRide ride;
  final double screenWidth;
  final double screenHeight;

  const RecentRideItem({super.key, required this.ride, required this.screenWidth, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.012),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Row(children: [
        Icon(Icons.history, color: Colors.grey[600], size: screenWidth * 0.06),
        SizedBox(width: screenWidth * 0.03),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('From', style: GoogleFonts.lexend(fontSize: screenWidth * 0.03, color: Colors.grey[600])),
            Text(ride.from, style: GoogleFonts.lexend(fontSize: screenWidth * 0.038, fontWeight: FontWeight.w500, color: Colors.black87)),
          ]),
        ),
        Icon(Icons.arrow_forward, color: Colors.grey[400], size: screenWidth * 0.05),
        SizedBox(width: screenWidth * 0.04),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('To', style: GoogleFonts.lexend(fontSize: screenWidth * 0.03, color: Colors.grey[600])),
            Text(ride.to, style: GoogleFonts.lexend(fontSize: screenWidth * 0.038, fontWeight: FontWeight.w500, color: Colors.black87)),
          ]),
        ),
      ]),
    );
  }
}
