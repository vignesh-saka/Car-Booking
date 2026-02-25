import 'dart:async';
import 'package:bookmycar/internet_screens/no_internet_widget.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:bookmycar/Screens/Comman/bottom_navigation.dart';
import 'package:bookmycar/Screens/Publish_Ride_Screens/publishride_screen.dart';
import 'package:bookmycar/Screens/My_Booking_Screens/Screens/my_bookings_screen.dart';
import 'package:bookmycar/Screens/Serach_Screen/search_screen.dart';
import 'package:bookmycar/Screens/History_Screens/Screens/history_screen.dart';
import 'package:bookmycar/Screens/Profile_Screen/profile_screen.dart';
import 'package:bookmycar/Screens/notification_screen.dart';

class MainDashboard extends StatefulWidget {
  final int initialIndex;
  const MainDashboard({super.key, this.initialIndex = 2}); // Default to Search

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  late int _selectedIndex;
  bool _hasInternet = true;

  late final List<Widget> _screens;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySub;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;



//...
    _screens = [
      PublishRideScreen(
        onPublishSuccess: () {
          setState(() {
            _selectedIndex = 3; // History (shifted back to 3)
          });
        },
      ),
      const MyBookingsScreen(),
      SearchScreen(
        onBookingSuccess: () {
          setState(() {
            _selectedIndex = 1; // My Bookings
          });
        },
      ),
      const HistoryScreen(),      // Revert to Index 3
      ProfileScreen(
        onTabChange: (index) {
          // Profile needs to handle the shifted index if it navigates
           if (_selectedIndex == index) return;
           setState(() => _selectedIndex = index);
        },
      ),
    ];

    _checkInternet();

    _connectivitySub = Connectivity().onConnectivityChanged.listen((_) {
      _checkInternet();
    });
  }

  Future<void> _checkInternet() async {
    final hasConnection =
        await InternetConnectionChecker.instance.hasConnection;

    if (!mounted) return;

    setState(() => _hasInternet = hasConnection);
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 2) {
          setState(() => _selectedIndex = 2);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: _hasInternet
              ? Row(
                  children: [
                    // Side Navigation for Desktop/Tablet
                    if (MediaQuery.of(context).size.width >= 800)
                      NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: _onItemTapped,
                        labelType: NavigationRailLabelType.all,
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.add_circle_outline),
                            selectedIcon: Icon(Icons.add_circle),
                            label: Text('Publish'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.history),
                            selectedIcon: Icon(Icons.history_edu),
                            label: Text('Bookings'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.search),
                            selectedIcon: Icon(Icons.search_rounded),
                            label: Text('Search'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.manage_history),
                            selectedIcon: Icon(Icons.history_toggle_off),
                            label: Text('History'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.person_outline),
                            selectedIcon: Icon(Icons.person),
                            label: Text('Profile'),
                          ),
                        ],
                      ),
                    
                    // Vertical Divider
                     if (MediaQuery.of(context).size.width >= 800)
                      const VerticalDivider(thickness: 1, width: 1),

                    // Main Content Area
                    Expanded(
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: _screens,
                      ),
                    ),
                  ],
                )
              : NoInternetWidget(onRetry: _checkInternet),
        ),
        // Bottom Navigation for Mobile (< 800px)
        bottomNavigationBar: (_hasInternet && MediaQuery.of(context).size.width < 800)
            ? BottomNavigation(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              )
            : null,
      ),
    );
  }
}
