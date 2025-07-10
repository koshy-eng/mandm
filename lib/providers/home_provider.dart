

import 'package:mandm/models/activity_model.dart';
import 'package:mandm/models/brand_model.dart';
import 'package:mandm/models/car_model.dart';
import 'package:mandm/models/category_model.dart';
import 'package:mandm/models/driver_model.dart';
import 'package:mandm/models/message_model.dart';
import 'package:mandm/models/ride_model.dart';
import 'package:mandm/models/user_model.dart';
import 'package:flutter/cupertino.dart';

import '../data/remote/ApiService.dart';
import '../models/api_response.dart';

class HomeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Car> cars = [];
  ApiResponse<Driver>? driver;
  ApiResponse<List<Ride>>? rides;
  ApiResponse<Ride>? ride;
  ApiResponse<List<MessageModel>>? messages;
  ApiResponse<List<Activity>>? activities;

  int egpAmountp = 0;

  // late User userdata;
  List<Car> myCars = [];

  bool isLoading = true;
  String errorMessage = '';

  Future<void> loadHomeData({Map<String, dynamic>? filters}) async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      // rides = await _apiService.fetchRides();
      activities = await _apiService.fetchActivities();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load data: $e';
      notifyListeners();
    }
  }
  Future<void> loadMyCars() async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      myCars = await _apiService.fetchMyCars();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load data: $e';
      notifyListeners();
    }
  }


  Future<void> loadProfileData() async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      driver = (await _apiService.fetchProfile())!;


      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load data: $e';
      notifyListeners();
    }
  }

  Future<void> loadBookMidDataData(int rideId) async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      driver = (await _apiService.fetchProfile())!;
      ride = await _apiService.fetchRide(rideId);


      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load data: $e';
      notifyListeners();
    }
  }



  Future<void> loadPostCarInitData() async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load data: $e';
      notifyListeners();
    }
  }
  Future<void> loadPostRideInitData() async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      myCars = await _apiService.fetchMyCars();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load data: $e';
      notifyListeners();
    }
  }

  Future<void> loadMessagesInitData(int ride_id, int receiverId) async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      messages = await _apiService.fetchMessages(ride_id, receiverId);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load data: $e';
      notifyListeners();
    }
  }
}