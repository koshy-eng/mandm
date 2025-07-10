import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mandm/data/remote/url_api.dart';
import 'package:mandm/models/ride_model.dart';
import 'package:mandm/pages/payment_pageTwo.dart';
import 'package:mandm/pages/trip_ride_page.dart';
import 'package:mandm/widgets/bottom_nav_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/local/cache_helper.dart';
import '../models/api_response.dart';
import '../models/ride_book_model.dart';
import '../providers/home_provider.dart';
import 'chat_utou_pageTwo.dart';
import 'home_page.dart';

class RideBookMidPage extends StatefulWidget {
  final Ride mRide;

  const RideBookMidPage({required this.mRide, Key? key}) : super(key: key);

  @override
  _RideBookMidPageState createState() => _RideBookMidPageState();
}

class _RideBookMidPageState extends State<RideBookMidPage> {
  final String carModel = "Toyota Corolla";
  final String carColor = "White";
  final String plateNumber = "ABC 1234";

  final String driverName = "Ahmed Mostafa";
  final String driverPhone = "+201234567890";
  final String driverImage = "https://i.pravatar.cc/150?img=11"; // Placeholder

  final String startLocation = "Nasr City, Cairo";
  final String endLocation = "Maadi, Cairo";
  final String distance = "12.4 km";
  final String duration = "25 mins";

  late HomeProvider mProvider;

  late Ride ride;

  String? paymentType;

  int showPurchaseBtn = 0;

  TextEditingController pointsController = TextEditingController();
  double moneyToPay = 0.0;
  double myMoney = 120.0; // Example: User has 120 EGP
  int currentPoints = 3000; // Example: User has 3000 points

  final double exchangeRate = 0.05; // 1000 points = 50 EGP → 1 point = 0.05 EGP
  @override
  void initState() {
    super.initState();
    ride = widget.mRide;
  }

  void _calculateMoneyToPay() {
    final enteredPoints = int.tryParse(pointsController.text) ?? 0;
    setState(() {
      moneyToPay = enteredPoints * exchangeRate;
    });
  }

  @override
  void dispose() {
    pointsController.dispose();
    super.dispose();
  }

  void _callDriver(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    }
  }

  void _openChat(BuildContext context) {
    // Navigate to chat page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChatPage(
              currentUserId: CacheHelper.getData(key: 'id').toString(),
              otherUserId: ride.userId.toString(),
              tripId: ride.id.toString(),
            ),
      ),
    );
  }

  /*void _goToMapPage(BuildContext context, Ride ride) {
    // Navigate to the map page to start the ride
    // Navigator.push(context, MaterialPageRoute(builder: (_) => MapPageInner()));

  }*/
  Future<void> _goToMapPage(int rideId, String seats, Ride ride) async {
    try {

      var formData = json.encode({
        'ride_id': rideId,
        'seat_count': seats,
        'amount':  ride.price,
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //check the size of device
    ThemeData themeData = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => HomeProvider()..loadProfileData(),
      child: WillPopScope(
        onWillPop: () async {
          return await showExitConfirmDialog(context) ?? false;
        },
        child: Scaffold(
          // appBar: AppBar(title: Text("Register Your Car")),
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
          bottomNavigationBar: buildBottomNavBar(2, size, themeData),
          // backgroundColor: themeData.scaffoldBackgroundColor,
          body: Consumer<HomeProvider>(
            builder: (context, provider, _) {
              mProvider = provider;
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // return Center(child: Text(provider.driver!.message.name));

              if (provider.errorMessage.isNotEmpty) {
                // Future.delayed(Duration(seconds: 3), () async {
                //   await CacheHelper.removeData(key: 'token');
                //   await CacheHelper.removeData(key: 'id');
                //   await CacheHelper.removeData(key: 'firstName');
                //   await CacheHelper.removeData(key: 'lastName');
                //   await CacheHelper.removeData(key: 'username');
                //   await CacheHelper.removeData(key: 'email');
                //
                //   Timer(Duration(milliseconds: 400), () {
                //     Navigator.pushReplacement(
                //       context,
                //       MaterialPageRoute(builder: (context) => SplashPage()),
                //     );
                //   });
                // });

                return Center(child: Text(provider.errorMessage));
              }
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Driver Info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(driverImage),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  CacheHelper.getData(key: 'name'),
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  ride.user!.phone,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.phone, color: Colors.green),
                              onPressed: () => _callDriver(driverPhone),
                            ),
                          ],
                        ),
                        Divider(height: 32),

                        // Car Info
                        ListTile(
                          leading: Icon(Icons.directions_car),
                          title: Text('${ride.car?.brand} - ${ride.car?.color}'),
                          subtitle: Text('Seats: ${ride.car?.seats}'),
                        ),

                        // Ride Info
                        ListTile(
                          leading: Icon(Icons.location_on),
                          title: Text("From: ${ride.startName}"),
                          subtitle: Text("To: ${ride.destName}"),
                        ),
                        ListTile(
                          leading: Icon(Icons.timeline),
                          title: Text("Distance: $distance"),
                          subtitle: Text("Estimated Time: $duration"),
                        ),

                        SizedBox(height: 16),
                        /*Text("Payment Type", style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile(
                                title: Text("Cash Pay"),
                                value: "Cash_Pay",
                                groupValue: paymentType,
                                onChanged: (value) => setState(() => paymentType = value),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile(
                                title: Text("Visa"),
                                value: "Visa",
                                groupValue: paymentType,
                                onChanged: (value) => setState(() => paymentType = value),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),*/

                        if(provider.driver?.message.coins != 0)
                        ListTile(
                          leading: Icon(Icons.monetization_on_outlined),
                          title: Text('Money to Pay: ${moneyToPay.toStringAsFixed(2)} EGP'),
                          subtitle: Text('Your Money: ${myMoney.toStringAsFixed(2)} EGP'),
                        ),
                        if(provider.driver?.message.coins != 0)
                        SizedBox(height: 8),
                        if(provider.driver?.message.coins != 0)
                        Text('Current Points: ${provider.driver?.message.coins}'),
                        if(provider.driver?.message.coins != 0)
                        SizedBox(height: 8),
                        if(provider.driver?.message.coins != 0)
                        TextField(
                          controller: pointsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Points to Use",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (val) {
                            final points = int.tryParse(val) ?? 0;
                            setState(() {
                              moneyToPay = (points * 50 / 1000);
                            });
                          },
                        ),

                        SizedBox(height: 16),
                        if (showPurchaseBtn == 0)
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                               /* final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymobPaymentPage(rideFee: 100),
                                  ),
                                );
                                if (result != null) {
                                  setState(() {
                                    showPurchaseBtn = 1;
                                  });
                                }*/

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => PaymobPaymentPage(rideFee: 100)),
                                );
                              },
                              icon: Icon(Icons.credit_card_outlined),
                              label: Text("Purchase"),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _openChat(context),
                              icon: Icon(Icons.chat),
                              label: Text("Chat"),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _callDriver(driverPhone),
                              icon: Icon(Icons.phone),
                              label: Text("Call"),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Ride canceled")),
                                );
                              },
                              icon: Icon(Icons.cancel, color: Colors.red),
                              label: Text(
                                "Cancel",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _goToMapPage(widget.mRide.id, '3', widget.mRide),
                              icon: Icon(Icons.check_circle),
                              label: Text("Driver Reached"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );

            },
          ),
        ),
      ),
    );
  }

  Future<bool?> showExitConfirmDialog(BuildContext context) {
    return Navigator.pushReplacement(
      context,
      // MaterialPageRoute(builder: (context) => LoginPage()),
      MaterialPageRoute(builder: (context) => HomePage()),
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

        // if(craftType == "craft"){
        // Timer(const Duration(milliseconds: 400),() {
        //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(),));
        // },);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TripRidePage(mRide: ride)),
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
}

// Dummy pages for navigation
class ChatPageInner extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: Text("Chat")));
}

class MapPageInner extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: Text("Ride Map")));
}
