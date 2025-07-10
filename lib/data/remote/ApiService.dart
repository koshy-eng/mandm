import 'package:mandm/data/remote/url_api.dart';
import 'package:mandm/models/activity_model.dart';
import 'package:mandm/models/api_response.dart';
import 'package:mandm/models/brand_model.dart';
import 'package:mandm/models/car_model.dart';
import 'package:mandm/models/category_model.dart';
import 'package:dio/dio.dart';
import 'package:mandm/models/driver_model.dart';
import 'package:mandm/models/message_model.dart';
import 'package:mandm/models/ride_model.dart';

import '../../models/user_model.dart';
import '../local/cache_helper.dart';

class ApiService {
  final Dio _dio = Dio();

  /*Future<List<CategoryModel>> fetchCategories() async {
    try{
    final response = await _dio.get(
      getCategories,
      options: Options(
        headers: {
          'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
        },
      ),
    );
    return (response.data as List)
        .map((e) => CategoryModel.fromJson(e))
        .toList();
  } catch (e) {
  print("Error fetching cars: $e");
  return [];
  }
  }

  Future<List<BrandModel>> fetchBrands() async {
    try {
      final response = await _dio.get(getBrands);
      print('apizzzzzzzzzz: ${response.data.toString()}');
      List<BrandModel> brands = [];
      brands.add(
        BrandModel(
          id: 2,
          image: 'image',
          name: 'name',
          description: 'description',
          createdAt: 'createdAt',
        ),
      );
      return (response.data as List)
          .map((e) => BrandModel.fromJson(e))
          .toList();
    } catch (e) {
      print("Error fetching cars: $e");
      return [];
    }
  }*/


  Future<List<Car>> fetchCars(Map<String, dynamic>? filters) async {
    try {
      // Creating query parameters dynamically
      // Map<String, dynamic> queryParams = {};

      // if (search != null) queryParams['search'] = search;
      // if (transmission != null) queryParams['transmission'] = transmission;
      // if (color != null) queryParams['color'] = color;

      final response = await _dio.get(
        getCars,
        queryParameters: filters, // Sending only non-null parameters
      );

      return (response.data as List).map((e) => Car.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching cars: $e");
      return [];
    }
  }

  Future<List<Car>> fetchMyCars() async {
    try {
      final response = await _dio.get(
        myCars,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
          },
        ), // Sending only non-null parameters
      );

      return (response.data as List).map((e) => Car.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching cars: $e");
      return [];
    }
  }

  Future<ApiResponse<List<Activity>>?> fetchActivities() async {
    try {
      final response = await _dio.get(
        '$getActivities',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
          },
        ), // Sending only non-null parameters
      );

      return ApiResponse<List<Activity>>.fromJson(response.data, (data) => List<Activity>.from(data.map((x) => Activity.fromJson(x))));
    } catch (e) {
      print("Error fetching cars: $e");
      return null;
    }
  }

  Future<ApiResponse<List<MessageModel>>?> fetchMessages(int ride_id, int receiverId) async {
    try {
      final response = await _dio.get(
        '$getChatMessages/$ride_id/$receiverId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
          },
        ), // Sending only non-null parameters
      );

      return ApiResponse<List<MessageModel>>.fromJson(response.data, (data) => List<MessageModel>.from(data.map((x) => MessageModel.fromJson(x))));
    } catch (e) {
      print("Error fetching cars: $e");
      return null;
    }
  }

  Future<ApiResponse<List<Ride>>?> fetchRides() async {
    try {
      final response = await _dio.get(
        getRides,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
          },
        ), // Sending only non-null parameters
      );

      ApiResponse<List<Ride>> rr = ApiResponse<List<Ride>>.fromJson(response.data, (data) => List<Ride>.from(data.map((x) => Ride.fromJson(x))));
      return rr;
      print('zzzzzzzzx : ${rr.message.first.seats}');

      // return ApiResponse<List<Ride>>.fromJson(response.data, (data) => List<Ride>.from(data.map((x) => Ride.fromJson(x))));
    } catch (e) {
      print("Error fetching rides: ${e}");
      return null;
    }
  }



  Future<ApiResponse<Ride>?> fetchRide(int rideId) async {
    try {
      final response = await _dio.get(
        'getRides/$rideId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
          },
        ), // Sending only non-null parameters
      );

      return ApiResponse<Ride>.fromJson(
        response.data,
            (data) => Ride.fromJson(data),
      );
    } catch (e) {
      print("Error fetching rides: ${e}");
      return null;
    }
  }

  Future<ApiResponse<Driver>?> fetchProfile() async {
    try {
      final response = await _dio.get(
        getDriver,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
          },
        ), // Sending only non-null parameters
      );

      return ApiResponse<Driver>.fromJson(
        response.data,
            (data) => Driver.fromJson(data),
      );
    } catch (e) {
      print("Error fetching cars: $e");
      return null;
    }
  }
}
