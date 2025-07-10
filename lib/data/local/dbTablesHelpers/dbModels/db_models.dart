class NotificationItem {
  int? id;
  final String title;
  final String description;
  final String action;
  final String topic;


  NotificationItem({required this.title, required this.description, required this.action, required this.topic});

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'action': action,
    'topic': topic,
  };

  factory NotificationItem.fromMap(Map<String, dynamic> map) => NotificationItem(
    // id: map['id'],
    title: map['title'],
    description: map['description'],
    action: map['action'],
    topic: map['topic'],
  );
}

class RideItem {
  final int id;
  final int userId;
  final int carId;
  final String departureDate;
  final String departureTime;
  final String startLat;
  final String startLng;
  final String startName;
  final String destLat;
  final String destLng;
  final String destName;
  final int seats;
  final int price;
  final String description;


  RideItem({
    required this.id,
    required this.userId,
    required this.carId,
    required this.departureDate,
    required this.departureTime,
    required this.startLat,
    required this.startLng,
    required this.startName,
    required this.destLat,
    required this.destLng,
    required this.destName,
    required this.seats,
    required this.price,
    required this.description,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'carId': carId,
    'departureDate': departureDate,
    'departureTime': departureTime,
    'startLat': startLat,
    'startLng': startLng,
    'startName': startName,
    'destLat': destLat,
    'destLng': destLng,
    'destName': destName,
    'seats': seats,
    'price': price,
    'description': description,
  };

  factory RideItem.fromMap(Map<String, dynamic> map) => RideItem(
    id: map['id'],
    userId: map['userId'],
    carId: map['carId'],
    departureDate: map['departureDate'],
    departureTime: map['departureTime'],
    startLat: map['startLat'],
    startLng: map['startLng'],
    startName: map['startName'],
    destLat: map['destLat'],
    destLng: map['destLng'],
    destName: map['destName'],
    seats: int.parse(map['seats'].toString()),
    price: int.parse(map['price'].toString()),
    description: map['description'],
  );
}

class ChallengeE {
  final int id;
  final String name;
  final double lat;
  final double lng;
  final double radius;
  final String? image;
  final String? charImage;
  final String? guideImage;
  final String? video;
  final int? order;
  final int timer;
  final int activityId;
  final String type;
  final String status;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Local fields for progress management
  final int isCompleted;
  final int isUnlocked;
  final int timeSpent;
  final int userPoints;

  ChallengeE({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.radius,
    this.image,
    this.charImage,
    this.guideImage,
    this.video,
    required this.order,
    required this.timer,
    required this.activityId,
    required this.type,
    required this.status,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.isCompleted = 0,
    this.isUnlocked = 0,
    this.timeSpent = 0,
    this.userPoints = 0,
  });

  factory ChallengeE.fromJson(Map<String, dynamic> json) {
    return ChallengeE(
      id: json['id'],
      name: json['name'],
      lat: double.parse(json['lat'].toString()),
      lng: double.parse(json['lng'].toString()),
      radius: double.parse(json['radius'].toString()),
      image: json['image'],
      charImage: json['char_image'],
      guideImage: json['guide_image'],
      video: json['video'],
      order: json['order'],
      timer: json['timer'],
      activityId: json['activity_id'],
      type: json['type'],
      status: json['status'],
      description: json['description'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  factory ChallengeE.fromMap(Map<String, dynamic> map) {
    return ChallengeE(
      id: map['id'],
      name: map['name'],
      lat: double.parse(map['lat'].toString()),
      lng: double.parse(map['lng'].toString()),
      radius: double.parse(map['radius'].toString()),
      image: map['image'],
      charImage: map['char_image'],
      guideImage: map['guide_image'],
      video: map['video'],
      order: map['order'],
      timer: map['timer'],
      activityId: map['activity_id'],
      type: map['type'],
      status: map['status'],
      description: map['description'],
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,

      // Local fields
      isCompleted: map['is_completed'] ?? 0,
      isUnlocked: map['is_unlocked'] ?? 0,
      timeSpent: map['time_spent'] ?? 0,
      userPoints: map['user_points'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'radius': radius,
      'image': image,
      'char_image': charImage,
      'guide_image': guideImage,
      'video': video,
      'order': order,
      'timer': timer,
      'activity_id': activityId,
      'type': type,
      'status': status,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),

      // Local fields
      'is_completed': isCompleted,
      'is_unlocked': isUnlocked,
      'time_spent': timeSpent,
      'user_points': userPoints,
    };
  }
}

