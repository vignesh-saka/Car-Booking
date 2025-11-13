import 'package:flutter/material.dart';
import 'nav_bar_item.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final double screenWidth;
  final double screenHeight;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                onTap: () => onItemTapped(0),
              ),
              NavBarItem(
                icon: Icons.airplane_ticket_outlined,
                label: 'My Bookings',
                isSelected: selectedIndex == 1,
                screenWidth: screenWidth,
                onTap: () => onItemTapped(1),
              ),
              NavBarItem(
                icon: Icons.search,
                label: 'Search',
                isSelected: selectedIndex == 2,
                screenWidth: screenWidth,
                onTap: () => onItemTapped(2),
              ),
              NavBarItem(
                icon: Icons.menu,
                label: 'History',
                isSelected: selectedIndex == 3,
                screenWidth: screenWidth,
                onTap: () => onItemTapped(3),
              ),
              NavBarItem(
                icon: Icons.person_outline,
                label: 'Profile',
                isSelected: selectedIndex == 4,
                screenWidth: screenWidth,
                onTap: () => onItemTapped(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
