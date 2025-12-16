import 'package:flutter/material.dart';
import 'nav_bar_item.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      top: false,
      child: Container(
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
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02,
          vertical: screenHeight * 0.012,
        ),
        child: Row(
          children: [
            _item(
              index: 0,
              icon: Icons.add,
              label: 'Publish',
              width: screenWidth,
            ),
            _item(
              index: 1,
              icon: Icons.airplane_ticket_outlined,
              label: 'My Bookings',
              width: screenWidth,
            ),
            _item(
              index: 2,
              icon: Icons.search,
              label: 'Search',
              width: screenWidth,
            ),
            _item(
              index: 3,
              icon: Icons.menu,
              label: 'History',
              width: screenWidth,
            ),
            _item(
              index: 4,
              icon: Icons.person_outline,
              label: 'Profile',
              width: screenWidth,
            ),
          ],
        ),
      ),
    );
  }

  Widget _item({
    required int index,
    required IconData icon,
    required String label,
    required double width,
  }) {
    return Expanded(
      child: NavBarItem(
        icon: icon,
        label: label,
        screenWidth: width,
        isSelected: selectedIndex == index,
        onTap: () {
          if (selectedIndex == index) return; // 🚫 prevent reload
          onItemTapped(index);
        },
      ),
    );
  }
}
