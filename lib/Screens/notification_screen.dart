import 'package:bookmycar/controllers/notification_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Notifications",
          style: GoogleFonts.lexend(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            tooltip: "Clear all notifications",
            onPressed: () async {
              // Confirm deletion
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Clear All"),
                  content: const Text("Are you sure you want to delete all notifications?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await NotificationController().deleteAllNotifications();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All notifications cleared")),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text("Please login to see notifications"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFF3B30)));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_off_outlined,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          "No notifications yet",
                          style: GoogleFonts.lexend(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isRead = data['isRead'] ?? false;
                    final timestamp = data['createdAt'] as Timestamp?;
                    final time = timestamp != null
                        ? DateFormat('MMM d, h:mm a').format(timestamp.toDate())
                        : '';

                    return Container(
                      color: isRead ? Colors.white : const Color(0xFFFFF0F0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFFF3B30).withOpacity(0.1),
                          child: Icon(
                            _getIconForType(data['type']),
                            color: const Color(0xFFFF3B30),
                          ),
                        ),
                        title: Text(
                          data['title'] ?? 'Notification',
                          style: GoogleFonts.lexend(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['body'] ?? '',
                              style: GoogleFonts.lexend(color: Colors.black54),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              time,
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Mark as read specifically
                          doc.reference.update({'isRead': true});
                          
                          // Handle Navigation
                          NotificationController().handleNotificationTap(data['type'] ?? '');
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'ride_published':
        return Icons.directions_car;
      case 'booking_request':
        return Icons.bookmark_add;
      case 'ride_cancelled':
      case 'ride_cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications;
    }
  }
}
