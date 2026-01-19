class RideRequest {
  final String name;
  final String phone;
  final String status;
  final String? age;
  final int groupSize; // 👈 group size
  final String? bookingId; 
  final String? passengerUid; // Added UID

  RideRequest({
    required this.name,
    required this.phone,
    required this.status,
    this.age,
    this.groupSize = 1, // default 1 passenger
    this.bookingId,
    this.passengerUid,
  });

  factory RideRequest.fromMap(Map<String, dynamic> data) {
    // ---- Parse groupSize safely ----
    final rawGroupSize = data['groupSize'];
    int parsedGroupSize = 1;

    if (rawGroupSize is int) {
      parsedGroupSize = rawGroupSize;
    } else if (rawGroupSize != null) {
      parsedGroupSize = int.tryParse(rawGroupSize.toString()) ?? 1;
    }

    final bookingIdRaw = (data['bookingId'] ?? '').toString().trim();

    final String? passengerUid = data['passengerUid']?.toString();

    return RideRequest(
      name: (data['passengerName'] ?? data['name'] ?? '').toString(),
      phone: (data['passengerPhone'] ?? data['phone'] ?? '').toString(),
      age: (data['passengerAge'] ?? data['age'])?.toString(),
      status: (data['status'] ?? 'pending').toString(),
      groupSize: parsedGroupSize,
      bookingId: bookingIdRaw.isEmpty ? null : bookingIdRaw,
      passengerUid: passengerUid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'age': age,
      'status': status,
      'groupSize': groupSize,
      'bookingId': bookingId,
      'passengerUid': passengerUid,
    };
  }
}
