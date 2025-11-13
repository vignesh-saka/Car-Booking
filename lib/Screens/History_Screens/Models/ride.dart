import 'ride_request.dart';

class Ride {
  final String id;
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
    required this.id,
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
    this.isLive = true,
  });

  bool get hasPendingRequests => requests.any((r) => r.status == 'pending');

  // For backend integration
  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'],
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      from: json['from'],
      to: json['to'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      price: json['price'],
      totalPassengers: json['totalPassengers'],
      requests: (json['requests'] as List)
          .map((req) => RideRequest.fromJson(req))
          .toList(),
      isLive: json['isLive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'from': from,
      'to': to,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'price': price,
      'totalPassengers': totalPassengers,
      'requests': requests.map((req) => req.toJson()).toList(),
      'isLive': isLive,
    };
  }
}