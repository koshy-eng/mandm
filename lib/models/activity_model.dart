class Activity {
  final int id;
  final String name;
  final String date;
  final String time;
  final int seats;
  final String? image;
  final String? advice;
  final double? lat;
  final double? lng;
  final double? price;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Activity({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.seats,
    this.image,
    this.advice,
    this.lat,
    this.lng,
    this.price,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      time: json['time'],
      seats: json['seats'],
      image: json['image'],
      advice: json['advice'],
      lat: (json['lat'] != null) ? double.tryParse(json['lat'].toString()) : null,
      lng: (json['lng'] != null) ? double.tryParse(json['lng'].toString()) : null,
      price: (json['price'] != null) ? double.tryParse(json['price'].toString()) : null,
      status: json['status'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }
}
