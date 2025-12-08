import 'ride_request.dart';

class Ride {
  final String? id;
  final String date;
  final String startTime;
  final String endTime;
  final String from;
  final String to;
  final String driverName;
  final String driverPhone;
  final String price;
  final int totalPassengers;
  final List<RideRequest> requests;
  final bool isLive;

  Ride({
    this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.from,
    required this.to,
    required this.driverName,
    required this.driverPhone,
    required this.price,
    required this.totalPassengers,
    required this.requests,
    required this.isLive,
  });

  bool get hasPendingRequests => requests.any((r) => r.status == 'pending');

  factory Ride.fromFirestore(Map<String, dynamic> data, String docId) {
    return Ride(
      id: docId,
      date: data['date'] ?? '',
      startTime: data['pickupTime'] ?? '',
      endTime: data['dropTime'] ?? '',
      from: data['fromCity'] ?? '',
      to: data['toCity'] ?? '',
      driverName: data['riderName'] ?? '',
      driverPhone: data['phoneNumber'] ?? '',
      price: data['price'] ?? '',
      totalPassengers: data['passengers'] ?? 1,
      requests: [], // Requests feature not in Firestore yet
      isLive: true, // Will be overridden in history_screen.dart
    );
  }
}
