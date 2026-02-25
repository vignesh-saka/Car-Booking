import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bookmycar/Screens/Comman/main_dashboard.dart';
import 'package:bookmycar/Screens/notification_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationController with ChangeNotifier {
  static final NotificationController _instance = NotificationController._internal();
  factory NotificationController() => _instance;
  NotificationController._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Navigation Key to handle redirection from background
  static GlobalKey<NavigatorState>? navigatorKey;

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  // Initialize
  Future<void> initialize() async {
    // 1. Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      await _saveDeviceToken();
      if (!kIsWeb) {
        await _firebaseMessaging.subscribeToTopic('all_users');
      }
    }

    // 2. Local Notifications Setup
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle local notification tap
        if (response.payload != null) {
          handleNotificationTap(response.payload!);
        }
      },
    );

    // Create Channel for Android (HEADS UP NOTIFICATIONS)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    if (!kIsWeb) {
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // 3. Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
      _fetchUnreadCount(); // Refresh count on new message
    });

    // 4. Background/Terminated Tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationTap(message.data['type'] ?? '');
    });
    
    // 5. Initial unread count fetch
    _fetchUnreadCount();
  }

  void _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      // In-app Notification (Banner) - Commented out as per user request
      /*
      final context = navigatorKey?.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            backgroundColor: Colors.white,
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFF3B30),
              child: Icon(Icons.notifications, color: Colors.white),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  notification.title ?? 'New Notification',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(notification.body ?? ''),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                  // Optional: handle tap
                  if (message.data['type'] != null) {
                    handleNotificationTap(message.data['type']);
                  }
                },
                child: const Text('VIEW', style: TextStyle(color: Color(0xFFFF3B30))),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                },
                child: const Text('DISMISS', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        );
      }
      */
      
      // Still show system notification for tray (optional, but good for history)
      await _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data['type'],
      );
    }
  }

  void handleNotificationTap(String type) {
    if (navigatorKey?.currentState == null) {
        debugPrint("Navigator Key is null or not attached");
        return;
    }

    if (type == 'ride_published') {
      // Navigate to History (Index 3)
      navigatorKey!.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainDashboard(initialIndex: 3)),
        (route) => false,
      );
    } else if (type == 'booking_request') {
       // Navigate to History (Index 3) where requests are managed
       navigatorKey!.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainDashboard(initialIndex: 3)),
        (route) => false,
      );
    } else if (type == 'booking_status') {
      // Navigate to My Bookings (Index 1)
       navigatorKey!.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainDashboard(initialIndex: 1)),
        (route) => false,
      );
    } else {
        // Default to Notifications Screen
       navigatorKey!.currentState!.push(
        MaterialPageRoute(builder: (_) => const NotificationScreen()),
      );
    }
  }

  // --- Logic to Trigger Notifications (Simulation/Client-side) ---

  Future<void> sendNotification({
    required String toUserId,
    required String title,
    required String body,
    required String type, // 'ride_published', 'booking_request', 'booking_status'
  }) async {
    // 1. Write to Firestore 'notifications' collection
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': toUserId,
      'title': title,
      'body': body,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Fetch FCM Token of the recipient
    if (toUserId.isNotEmpty) {
       final userDoc = await FirebaseFirestore.instance.collection('users').doc(toUserId).get();
       final token = userDoc.data()?['fcmToken'];
       if (token != null) {
          await sendPushMessage(token, title, body, type);
       }
    } else {
        // Send to topic 'all_users' if userId is empty (broadcast)
        await sendPushMessage('/topics/all_users', title, body, type);
    }
  }

  // 🔥 Send Push via FCM Legacy API
  // REPLACEMENT REQUIRED: Put your SERVER KEY here
  final String _serverKey = '63717521520'; 

  Future<void> sendPushMessage(String token, String title, String body, String type) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'type': type,
              'body': body,
              'title': title,
            },
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
              'android_channel_id': 'high_importance_channel',
            },
            'to': token,
          },
        ),
      );
      print("Push notification sent to $token");
    } catch (e) {
      print("Error sending push notification: $e");
    }
  }

  // --- Fetch Unread Count ---
  
  void _fetchUnreadCount() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      _unreadCount = snapshot.docs.length;
      notifyListeners();
    });
  }
  
  Future<void> markAllAsRead() async {
     final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();
    final snapshots = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshots.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Future<void> deleteAllNotifications() async {
     final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();
    final snapshots = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .get();

    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
  Future<void> _saveDeviceToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print("Saving FCM Token: $token");
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}
