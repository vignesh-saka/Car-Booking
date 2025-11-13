class Booking {
  final String id;
  final String rideId;
  final String date;
  final String startTime;
  final String endTime;
  final String from;
  final String to;
  final String driverName;
  final String driverPhone;
  final String price;
  final int passengerCount;
  final String status; // 'requested', 'accepted', 'rejected'
  final bool isCompleted;

  Booking({
    required this.id,
    required this.rideId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.from,
    required this.to,
    required this.driverName,
    required this.driverPhone,
    required this.price,
    required this.passengerCount,
    required this.status,
    this.isCompleted = false,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      rideId: json['rideId'],
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      from: json['from'],
      to: json['to'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      price: json['price'],
      passengerCount: json['passengerCount'],
      status: json['status'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rideId': rideId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'from': from,
      'to': to,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'price': price,
      'passengerCount': passengerCount,
      'status': status,
      'isCompleted': isCompleted,
    };
  }

  Booking copyWith({
    String? status,
    bool? isCompleted,
  }) {
    return Booking(
      id: id,
      rideId: rideId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      from: from,
      to: to,
      driverName: driverName,
      driverPhone: driverPhone,
      price: price,
      passengerCount: passengerCount,
      status: status ?? this.status,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}