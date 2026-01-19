import 'package:bookmycar/Screens/notification_screen.dart';
import 'package:bookmycar/controllers/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class NotificationIcon extends StatelessWidget {
  final Color iconColor;
  
  const NotificationIcon({
    super.key, 
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NotificationController(),
      builder: (context, _) {
        return IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            );
          },
          icon: badges.Badge(
            position: badges.BadgePosition.topEnd(top: -10, end: -5),
            showBadge: NotificationController().unreadCount > 0,
            badgeContent: Text(
              NotificationController().unreadCount.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: iconColor,
              size: 28,
            ),
          ),
        );
      },
    );
  }
}
