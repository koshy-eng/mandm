class Challenge {
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

  Challenge({
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

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
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
  factory Challenge.fromDb(Map<String, dynamic> map) => Challenge(
    id: map['id'],
    name: map['name'],
    lat: map['lat'],
    lng: map['lng'],
    radius: map['radius'],
    image: map['image'],
    charImage: map['charImage'],
    guideImage: map['guideImage'],
    video: map['video'],
    order: map['challengeOrder'],
    timer: map['timer'],
    activityId: map['activityId'],
    type: map['type'],
    status: map['status'],
    description: map['description'],
    isUnlocked: map['isUnlocked'],
    isCompleted: map['isCompleted'],
    timeSpent: map['timeSpent'],
    userPoints: map['userPoints'],
  );

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
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

  Challenge copyWith({
    int? isUnlocked,
    int? isCompleted,
    int? timeSpent,
    int? userPoints,
  }) {
    return Challenge(
      id: id,
      name: name,
      lat: lat,
      lng: lng,
      radius: radius,
      image: image,
      charImage: charImage,
      guideImage: guideImage,
      video: video,
      order: order,
      timer: timer,
      activityId: activityId,
      type: type,
      status: status,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      timeSpent: timeSpent ?? this.timeSpent,
      userPoints: userPoints ?? this.userPoints,
    );
  }

}
