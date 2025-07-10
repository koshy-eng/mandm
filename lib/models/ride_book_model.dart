class RideBook {
  final int id;
  final int rideId;
  final int userId;
  final String seatCount;
  final String createdAt;

  RideBook({
    required this.id,
    required this.rideId,
    required this.userId,
    required this.seatCount,
    required this.createdAt,
  });

  factory RideBook.fromJson(Map<String, dynamic> json) {
    return RideBook(
      id: json['id'],
      rideId: json['ride_id'],
      userId: json['user_id'],
      seatCount: json['seat_count'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_id': rideId,
      'user_id': userId,
      'seat_count': seatCount,
      'created_at': createdAt,
    };
  }
}
