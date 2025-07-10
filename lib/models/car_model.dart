class Car {
  final int id;
  final int userId;
  final String brand;
  final String model;
  final int seats;
  final String transType;
  final String color;
  final String description;
  final String createdAt;
  final String? carImageUrl;
  final String? licenseImageUrl;
  final String? car_image;

  Car({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.seats,
    required this.transType,
    required this.color,
    required this.description,
    required this.createdAt,
    this.carImageUrl,
    this.licenseImageUrl,
    this.car_image,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      userId: json['user_id'],
      brand: json['brand'],
      model: json['model'],
      seats: json['seats'],
      transType: json['trans_type'],
      color: json['color'],
      description: json['description'],
      createdAt: json['created_at'],
      carImageUrl: json['car_image_url'],
      licenseImageUrl: json['license_image_url'],
      car_image: json['car_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'brand': brand,
      'model': model,
      'seats': seats,
      'trans_type': transType,
      'color': color,
      'description': description,
      'created_at': createdAt,
      'car_image_url': carImageUrl,
      'license_image_url': licenseImageUrl,
      'car_image': car_image,
    };
  }
}
