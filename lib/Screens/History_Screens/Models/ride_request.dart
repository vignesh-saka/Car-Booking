class RideRequest {
  final String name;
  final String phone;
  final String status; // 'pending', 'accepted', 'rejected'
  final String? age;

  RideRequest({
    required this.name,
    required this.phone,
    this.status = 'pending',
    this.age,
  });

  // For backend integration
  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      name: json['name'],
      phone: json['phone'],
      status: json['status'] ?? 'pending',
      age: json['age'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'status': status,
      'age': age,
    };
  }
}