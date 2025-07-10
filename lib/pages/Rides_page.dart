import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mandm/components/show_toast_app.dart';
import 'package:mandm/data/local/cache_helper.dart';
import 'package:mandm/data/remote/url_api.dart';
import 'package:mandm/models/api_response.dart';
import 'package:mandm/models/ride_book_model.dart';
import 'package:mandm/models/ride_model.dart';
import 'package:mandm/pages/chatbot_page.dart';
import 'package:mandm/pages/find_rides_in_map_page.dart';
import 'package:mandm/pages/ride_book_mid_page.dart';
import 'package:mandm/pages/set_trip_page.dart';
import 'package:mandm/pages/trip_ride_page.dart';

import 'package:mandm/providers/home_provider.dart';
import 'package:mandm/widgets/bottom_nav_bar.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

import 'map_page.dart';

class RidesPage extends StatefulWidget {
  const RidesPage({Key? key}) : super(key: key);

  @override
  _RidesPageState createState() => _RidesPageState();
}

class _RidesPageState extends State<RidesPage> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    requestLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    await Geolocator.requestPermission();
    await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //check the size of device
    ThemeData themeData = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => HomeProvider()..loadHomeData(),
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60.0), //appbar size
            child: AppBar(
              bottomOpacity: 0.0,
              elevation: 0.0,
              shadowColor: Colors.transparent,
              backgroundColor: themeData.scaffoldBackgroundColor,
              leading: Padding(
                padding: EdgeInsets.only(left: size.width * 0.05),
                child: SizedBox(
                  height: size.width * 0.1,
                  width: size.width * 0.1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeData.scaffoldBackgroundColor.withAlpha(
                        (0.03 * 255).toInt(),
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Icon(
                      UniconsLine.bars,
                      color: themeData.secondaryHeaderColor,
                      size: size.height * 0.025,
                    ),
                  ),
                ),
              ),
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              leadingWidth: size.width * 0.15,
              title: Image.asset(
                'assets/icons/wheely_colored.png', //logo
                height: size.height * 0.06,
                width: size.width * 0.35,
              ),
              centerTitle: true,
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: size.width * 0.05),
                  child: SizedBox(
                    height: size.width * 0.1,
                    width: size.width * 0.1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: themeData.scaffoldBackgroundColor.withAlpha(
                          (0.03 * 255).toInt(),
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Icon(
                        UniconsLine.search,
                        color: themeData.secondaryHeaderColor,
                        size: size.height * 0.025,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          extendBody: true,
          extendBodyBehindAppBar: true,
          // bottomNavigationBar: buildBottomNavBar(0, size, themeData),
          backgroundColor: themeData.scaffoldBackgroundColor,
          body: Consumer<HomeProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.errorMessage.isNotEmpty) {
                return Center(child: Text(provider.errorMessage));
              }

              return SafeArea(
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: size.height * 0.01,
                        left: size.width * 0.05,
                        right: size.width * 0.05,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Upcoming Rides
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'All Rides',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff272727),
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.white,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(8),
                              scrollDirection: Axis.vertical,
                              itemCount: provider.rides?.message.length,
                              itemBuilder: (context, index) {
                                final ride = provider.rides?.message[index];
                                bool showImage =(ride?.car?.carImageUrl != null);
                                return Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        if (ride?.car?.carImageUrl != null)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              'https://link-to-your-car-image.jpg', // Replace with asset if needed
                                              width: 80,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        if (showImage) const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("${ride?.car?.brand}",
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 16, fontWeight: FontWeight.bold)),
                                              Text("Left Seats: ${ride?.seats}", style: TextStyle(color: Colors.grey[700])),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(Icons.circle, size: 10, color: Colors.red),
                                                  SizedBox(width: 4),
                                                  Expanded(child: Text("${ride?.startName}")),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Icon(Icons.circle, size: 10, color: Colors.amber),
                                                  SizedBox(width: 4),
                                                  Expanded(child: Text("${ride?.destName}")),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              padding:
                                              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[100],
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                "${ride?.departureTime}",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 12, fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Icon(Icons.favorite_border, color: Colors.grey),
                                            // const SizedBox(height: 8),
                                            ElevatedButton(
                                              onPressed: () {
                                                showBookDialog(context, ride!.id, ride);
                                              },
                                              child: Text('Book'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.symmetric(horizontal: 16),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

    );
  }
  void showBookDialog(BuildContext context, int rideId, Ride ride) {
    TextEditingController seatsController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Enter Ride Booking Data',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 12),
                      TextField(
                        controller: seatsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "seats",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // if (startDate != null && endDate != null) {
                    // bookRide(rideId,seatsController.text, ride);
                    // Navigator.pop(context); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RideBookMidPage(mRide: ride,)),
                    );
                    // Get.back(); // Pop details page and go back to home
                    // } else {
                    //   showToastApp(text: 'Error: Please select both dates.', color: Colors.red);
                    // }
                  },
                  child: Text("Book"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  Future<void> bookRide(int rideId, String seats, Ride ride) async {
    try {

      var formData = json.encode({
        'ride_id': rideId,
        'seat_count': seats,
      });

      var response = await Dio().post(
        rideBook, // Your API endpoint
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
          },
        ),
      );

      if (response.statusCode == 200) {
        ApiResponse<RideBook> userModel = ApiResponse<RideBook>.fromJson(
          response.data,
              (data) => RideBook.fromJson(data),
        );

        // if(craftType == "craft"){
        // Timer(const Duration(milliseconds: 400),() {
        //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(),));
        // },);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TripRidePage(mRide: ride),
          ),
        );

        /*}else if(craftType == "customer"){
          Timer(const Duration(milliseconds: 400),() {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home(),));
          },);
        }*/

        // showToastApp(text: 'Ride Booked Successfully', color: Colors.green);
      } else {
        // showToastApp(text: 'Error: Try again later.', color: Colors.red);
      }
    } catch (e) {
      if (e is DioException && e.error is SocketException) {
        print('errrrrrr DioException: ${e}');
        // showToastApp(text: 'No Internet connection.${e}', color: Colors.red);
      } else {
        print('errrrrrr: ${e}');
        // showToastApp(text: 'Error: Try again later please.${e}', color: Colors.red);
      }
    }
  }

  Future<String> myname() async {
    return await CacheHelper.getData(key: 'name');
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      throw Exception("Location permission not granted");
    }
  }

  Future<bool?> showExitConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Exit App"),
            content: Text("Are you sure you want to exit the app?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                // Stay in the app
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                // Exit the app
                child: Text("Exit"),
              ),
            ],
          ),
    );
  }

  OutlineInputBorder textFieldBorder() {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.0),
    );
  }

  Widget QuickActionButton({required IconData icon, required String label}) {
    return GestureDetector(
      onTap: () {
        if (label == "Cases") {
          /*Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CasesPage()),
          );*/
        } else if (label == "Requests") {
          /*Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RequestsPage()),
          );*/
        } else if (label == "Find Ride") {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => FindRidesInMapPage()),
          // );
        } else if (label == "Schedule") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SetTripPage()),
          );
        }
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class PopularPlace {
  final String name;
  final String imageUrl;

  PopularPlace({required this.name, required this.imageUrl});
}
