import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mandm/models/activity_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mandm/data/local/cache_helper.dart';
import 'package:mandm/data/remote/url_api.dart';
import 'package:mandm/models/api_response.dart';
import 'package:mandm/models/ride_book_model.dart';
import 'package:mandm/pages/HistoryPage.dart';
import 'package:mandm/pages/Rides_page.dart';
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

import '../models/ride_model.dart';
import 'PaymentDecisionPage.dart';
import 'PaymentWebViewPage.dart';
import 'map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();
  LatLng? startPoint;
  LatLng? endPoint;
  String? startPlaceName;
  String? endPlaceName;
  List<LatLng> points = [];
  String? nearestPoint;
  double? distanceToNearest;
  String? userName;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    requestLocationPermission();
    getUserName();
  }

  void getUserName() async {
    final name = await CacheHelper.getData(key: 'name');
    setState(() {
      userName = name;
    });
  }

  Future<void> _checkLocationPermission() async {
    await Geolocator.requestPermission();
    await Geolocator.getCurrentPosition();
  }

  final List<PopularPlace> popularPlaces = [
    PopularPlace(
      name: 'Pyramids',
      imageUrl:
          'https://betamedia.experienceegypt.eg/media/experienceegypt/img/Original/2022/8/7/2022_8_7_18_24_45_511.jpeg',
    ),
    PopularPlace(
      name: 'Karnak Temple',
      imageUrl:
          'https://betamedia.experienceegypt.eg/media/experienceegypt/img/Original/2025/1/19/2025_1_19_11_56_4_234.jpg',
    ),
    PopularPlace(
      name: 'Citadel',
      imageUrl:
          'https://betamedia.experienceegypt.eg/media/experienceegypt/img/Original/2022/7/23/2022_7_23_19_10_34_804.jpg',
    ),
    PopularPlace(
      name: 'Alex Library',
      imageUrl:
          'https://betamedia.experienceegypt.eg/media/experienceegypt/img/Original/2022/6/19/2022_6_19_17_30_49_149.png',
    ),
  ];

  String? selectedClub;
  String? selectedLocation;
  String? selectedDate;
  String? selectedTime;

  final List<Map<String, dynamic>> activities = [
    {
      'clubName': 'Club Name',
      'date': '2025-06-01',
      'time': '10:00 - 12:00',
      'seats': 3,
      'image':
          'https://www.mummytravels.com/wp-content/uploads/2014/10/cruise-oasis-seas-kids-club.jpg',
    },
    {
      'clubName': 'Club Name',
      'date': '2025-06-02',
      'time': '14:00 - 16:00',
      'seats': 0,
      'image':
          'https://passport-cdn.kiwicollection.com/blog/drive/uploads/2020/05/102272-14-Kids-Club-Grand-Velas-Los-Cabos-693x390.jpg',
    },
    {
      'clubName': 'Club Name',
      'date': '2025-06-03',
      'time': '09:00 - 11:00',
      'seats': 10,
      'image':
          'https://www.mummytravels.com/wp-content/uploads/2014/10/cruise-oasis-seas-kids-club.jpg',
    },
  ];

  final List<String> clubs = ['Club A', 'Club B', 'Club C'];
  final List<String> locations = ['Location 1', 'Location 2', 'Location 3'];
  final List<String> dates = ['2025-06-01', '2025-06-02', '2025-06-03'];
  final List<String> times = ['Morning', 'Afternoon', 'Evening'];

  void resetFilters() {
    setState(() {
      selectedClub = null;
      selectedLocation = null;
      selectedDate = null;
      selectedTime = null;
    });
  }

  Future<void> applyForActivity(Activity? activity) async {
    if(activity != null) {
      try {
        final bookingId = await createBooking(activity.id, activity.price);
        final paymentData = await initiatePayment(bookingId, activity.price);

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWebViewPage(
              paymentKey: paymentData['paymentKey'],
              iframeId: paymentData['iframeId'],
            ),
          ),
        );

        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم الدفع بنجاح')),
          );
          // ممكن تنتقل لصفحة شكر أو تحدث الشاشة
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم تكتمل عملية الدفع')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    }
  }
  Future<String> createBooking(int activityId, double? price) async {
    final dio = Dio();

    try {
      final response = await dio.post(
        'https://koshycoding.com/mandm/api/bookings/create',
        data: {
          'activity_id': activityId,
          'amount': price,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
            // 'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['booking_id'].toString();
      } else {
        throw Exception('فشل في إنشاء الحجز: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('خطأ في الحجز: $e');
    }
  }

  Future<Map<String, String>> initiatePayment(String bookingId, double? amount) async {
    final dio = Dio();

    try {
      final response = await dio.post(
        'https://koshycoding.com/mandm/api/paymob/initiate-booking-payment',
        data: {
          'booking_id': bookingId,
          'amount': amount,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          'paymentKey': response.data['payment_key'],
          'iframeId': response.data['iframe_id'].toString(),
        };
      } else {
        throw Exception('فشل في بدء عملية الدفع');
      }
    } catch (e) {
      throw Exception('خطأ في بدء الدفع: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //check the size of device
    ThemeData themeData = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => HomeProvider()..loadHomeData(),
      child: WillPopScope(
        onWillPop: () async {
          return await showExitConfirmDialog(context) ?? false;
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60.0), //appbar size
            child: AppBar(
              bottomOpacity: 0.0,
              elevation: 0.0,
              shadowColor: Colors.transparent,
              // backgroundColor: themeData.scaffoldBackgroundColor,
              backgroundColor: Color(0xff562f41),
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
                'assets/icons/mandm_logo.png', //logo
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
          bottomNavigationBar: buildBottomNavBar(0, size, themeData),
          // backgroundColor: themeData.scaffoldBackgroundColor,
          backgroundColor: Color(0xfff29520),
          body: Consumer<HomeProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.errorMessage.isNotEmpty) {
                return Center(child: Text(provider.errorMessage));
              }
              return SafeArea(
                child: Container(
                  clipBehavior: Clip.none,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/main-bg.png'),
                      // Your background image path
                      fit:
                          BoxFit
                              .cover, // Or BoxFit.fill / BoxFit.fitHeight etc.
                    ),
                  ),
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
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xffb37894),
                                    Color(0xff562f41),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      12.0,
                                      0.0,
                                      12.0,
                                      0.0,
                                    ),
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Color(0xffe6d9bf),
                                      child: Text(
                                        userName?[0] ?? '...',
                                        // First letter of name
                                        style: TextStyle(
                                          fontSize: 32,
                                          color: Color(0xff562f41),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Good morning,',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          userName ?? '...',
                                          style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Search Bar
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.message,
                                      color: Color(0xff562f41),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText:
                                              'Do You Have Any Questions?',
                                          hintStyle: TextStyle(
                                            color: Color(0xff5e5e5e),
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatbotPage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Send',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          16,
                                          0,
                                        ),
                                        backgroundColor: Color(0xff562f41),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Quick Actions
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'QUICK ACTIONS',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff292929),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  QuickActionButton(
                                    icon: Icons.qr_code,
                                    label: 'Qr Code',
                                  ),
                                  QuickActionButton(
                                    icon: Icons.share,
                                    label: 'Share',
                                    rides: provider.rides?.message,
                                  ),
                                  QuickActionButton(
                                    icon: Icons.emoji_events,
                                    label: 'Rank',
                                  ),
                                  QuickActionButton(
                                    icon: Icons.history,
                                    label: 'History',
                                  ),
                                ],
                              ),
                            ),

                            // Filters
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Club',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    value: selectedClub,
                                    items:
                                        clubs
                                            .map(
                                              (club) => DropdownMenuItem(
                                                value: club,
                                                child: Text(club),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedClub = value;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Location',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    value: selectedLocation,
                                    items:
                                        locations
                                            .map(
                                              (location) => DropdownMenuItem(
                                                value: location,
                                                child: Text(location),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedLocation = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Date',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    value: selectedDate,
                                    items:
                                        dates
                                            .map(
                                              (date) => DropdownMenuItem(
                                                value: date,
                                                child: Text(date),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedDate = value;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Time',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    value: selectedTime,
                                    items:
                                        times
                                            .map(
                                              (time) => DropdownMenuItem(
                                                value: time,
                                                child: Text(time),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedTime = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: resetFilters,
                                child: Text(
                                  "Reset Filters",
                                  style: TextStyle(color: Color(0xff562f41)),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            // Activity List
                            // Upcoming Rides
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Top Activities',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff272727),
                                ),
                              ),
                            ),
                            Container(
                              // color: Colors.white,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(8),
                                scrollDirection: Axis.vertical,
                                itemCount: provider.activities?.message.length,
                                itemBuilder: (context, index) {
                                  // final activity = activities[index];
                                  final activity = provider.activities?.message[index];
                                  final isFullyBooked = activity?.seats == 0;
                                  return Card(
                                    color: Color(0xffffe5bc),
                                    margin: EdgeInsets.only(bottom: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Image at the top, filling the width
                                        Image.network(
                                          'https://koshycoding.com/mandm/storage/app/public/${activity?.image}' ??'',
                                          // Replace with your image URL or asset
                                          width: double.infinity,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      activity?.name??'',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.calendar_today,
                                                          size: 16,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(activity?.date??''),
                                                      ],
                                                    ),
                                                    SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.access_time,
                                                          size: 16,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(activity?.time??''),
                                                      ],
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      isFullyBooked
                                                          ? 'Fully Booked'
                                                          : 'Available - ${activity?.seats} seats',
                                                      style: TextStyle(
                                                        color:
                                                            isFullyBooked
                                                                ? Colors.red
                                                                : Colors.green,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed:() {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => PaymentDecisionPage(
                                                        activity: activity,
                                                        amount: activity!.price!,
                                                      ),
                                                    ),
                                                  );

                                                }
                                                    /*() => applyForActivity(activity)*/,
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                child: Text("Apply"),
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

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Winners Trips',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(8),
                              itemCount: popularPlaces.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                  ),
                              itemBuilder: (context, index) {
                                final place = popularPlaces[index];
                                return GestureDetector(
                                  onTap: () {},
                                  child: Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(12),
                                              ),
                                          child: Image.network(
                                            place.imageUrl,
                                            width: double.infinity,
                                            height: 90,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            place.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RideBookMidPage(mRide: ride),
                      ),
                    );
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
      var formData = json.encode({'ride_id': rideId, 'seat_count': seats});

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

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TripRidePage(mRide: ride)),
        );
      } else {
        // showToastApp(text: 'Error: Try again later.', color: Colors.red);
      }
    } catch (e) {
      if (e is DioException && e.error is SocketException) {
        print('err DioException: ${e}');
        // showToastApp(text: 'No Internet connection.${e}', color: Colors.red);
      } else {
        print('err: ${e}');
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
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
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

  Widget QuickActionButton({
    required IconData icon,
    required String label,
    List<Ride>? rides,
  }) {
    return GestureDetector(
      onTap: () {
        if (label == "Offer Ride") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RidesPage()),
          );
        } else if (label == "History") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Historypage()),
          );
        } else if (label == "Find Ride") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FindRidesInMapPage(remoteRides: rides),
            ),
          );
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
              // color: Colors.blue[50],
              color: Color(0xffffe9f2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Color(0xff562f41)),
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
