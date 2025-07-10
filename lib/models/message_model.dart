import 'package:mandm/models/car_model.dart';
import 'package:mandm/models/driver_model.dart';
import 'package:mandm/models/user_model.dart';

class MessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final int rideId;
  final String message;
  int? isRead = 0;
  DateTime? createdAt;
  // final Car? car;
  // final Driver? user;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.rideId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    // required this.car,
    // required this.user,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      rideId: json['ride_id'],
      message: json['message'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
      // car: Car.fromJson(json["car"]),
      // user: Driver.fromJson(json["user"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'ride_id': rideId,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt?.toIso8601String(),
      // "car": car?.toJson(),
      // "user": user?.toJson(),
    };
  }
}
