import 'package:mandm/models/car_model.dart';
import 'package:mandm/models/driver_model.dart';
import 'package:mandm/models/user_model.dart';

class Ride {
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
  final DateTime createdAt;
  final Car? car;
  final Driver? user;

  Ride({
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
    required this.createdAt,
    required this.car,
    required this.user,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'],
      userId: json['user_id'],
      carId: json['car_id'],
      departureDate: json['departure_date'],
      departureTime: json['departure_time'],
      startLat: json['start_lat'],
      startLng: json['start_lng'],
      startName: json['start_name'],
      destLat: json['dest_lat'],
      destLng: json['dest_lng'],
      destName: json['dest_name'],
      seats: int.parse(json['seats'].toString()),
      price: int.parse(json['price'].toString()),
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      car: Car.fromJson(json["car"]),
      user: Driver.fromJson(json["user"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'car_id': carId,
      'departure_date': departureDate,
      'departure_time': departureTime,
      'start_lat': startLat,
      'start_lng': startLng,
      'start_name': startName,
      'dest_lat': destLat,
      'dest_lng': destLng,
      'dest_name': destName,
      'seats': seats,
      'price': price,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      "car": car?.toJson(),
      "user": user?.toJson(),
    };
  }
}
