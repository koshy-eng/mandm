import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:mandm/models/ride_model.dart';
import 'package:mandm/pages/ride_book_mid_page.dart';
import 'package:mandm/pages/trip_ride_page.dart';

import '../data/local/cache_helper.dart';
import '../data/remote/url_api.dart';
import '../models/api_response.dart';
import '../models/ride_book_model.dart';

class FindRidesInMapPage extends StatefulWidget {
  final List<Ride>? remoteRides;
  const FindRidesInMapPage({Key? key, required this.remoteRides}) : super(key: key);
  @override
  _FindRidesInMapPageState createState() => _FindRidesInMapPageState();
}

class _FindRidesInMapPageState extends State<FindRidesInMapPage> {
  LatLng? selectedPoint;

  late List<Ride> remoteRides;
  final List<Ridee> rides = [
    Ridee(id: '1', driverName: 'Ahmed', destination: 'Nasr City', location: LatLng(30.0444, 31.2357)),
    Ridee(id: '2', driverName: 'Sara', destination: '6 October', location: LatLng(30.0333, 31.2333)),
    Ridee(id: '3', driverName: 'Hassan', destination: 'Maadi', location: LatLng(29.9792, 31.1342)),
    Ridee(id: '4', driverName: 'Yasmine', destination: 'Heliopolis', location: LatLng(30.0866, 31.3300)),
    Ridee(id: '5', driverName: 'Omar', destination: 'Zamalek', location: LatLng(30.0626, 31.2191)),
    Ridee(id: '6', driverName: 'Nour', destination: 'New Cairo', location: LatLng(30.0150, 31.4900)),
    Ridee(id: '7', driverName: 'Khaled', destination: 'El Marg', location: LatLng(30.1436, 31.3618)),
    Ridee(id: '8', driverName: 'Fatma', destination: 'Ain Shams', location: LatLng(30.1234, 31.3480)),
    Ridee(id: '9', driverName: 'Mohamed', destination: 'Downtown', location: LatLng(30.0500, 31.2430)),
    Ridee(id: '10', driverName: 'Layla', destination: 'Shubra', location: LatLng(30.0756, 31.2550)),
    Ridee(id: '11', driverName: 'Tamer', destination: 'Fifth Settlement', location: LatLng(30.0074, 31.4913)),
    Ridee(id: '12', driverName: 'Mona', destination: 'Obour City', location: LatLng(30.2286, 31.4914)),
    Ridee(id: '13', driverName: 'Adel', destination: 'Badr City', location: LatLng(30.1500, 31.7500)),
    Ridee(id: '14', driverName: 'Rana', destination: 'Mohandessin', location: LatLng(30.0488, 31.2000)),
    Ridee(id: '15', driverName: 'Samir', destination: 'Giza', location: LatLng(29.9870, 31.2118)),
    Ridee(id: '16', driverName: 'Heba', destination: 'Haram', location: LatLng(29.9964, 31.1500)),
    Ridee(id: '17', driverName: 'Alaa', destination: 'El Sayeda Zeinab', location: LatLng(30.0241, 31.2436)),
    Ridee(id: '18', driverName: 'Ibrahim', destination: 'Dokki', location: LatLng(30.0381, 31.2115)),
    Ridee(id: '19', driverName: 'Salma', destination: 'Abbassia', location: LatLng(30.0707, 31.2843)),
    Ridee(id: '20', driverName: 'Mostafa', destination: 'New Capital', location: LatLng(30.0275, 31.7381)),
  ];


  // Ridee? selectedRide;
  Ride? selectedRide;

  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    remoteRides = widget.remoteRides!;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //check the size of device
    ThemeData themeData = Theme.of(context);
    return Scaffold(
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
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
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
      backgroundColor: themeData.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  center: LatLng(30.0444, 31.2357), // Cairo
                  zoom: 13.0,
                  onTap: (tapPosition, point) {
                    setState(() {
                      selectedPoint = point;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),

                  // 🔵 Multiple static markers from the list
                  MarkerLayer(
                    markers: remoteRides.map((ride) {
                      return Marker(
                        width: 40.0,
                        height: 40.0,
                        point: LatLng(double.parse(ride.startLat), double.parse(ride.startLng)),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRide = ride;
                            });
                          },
                          child: Icon(Icons.location_on, color: Colors.blue, size: 35),
                        ),
                      );
                    }).toList(),
                  ),

                  if (selectedPoint != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: selectedPoint!,
                          child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                ],
              ),
              if (selectedRide != null)
                Positioned(
                  bottom: 150,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Driver: ${selectedRide?.user?.name}', style: TextStyle(fontSize: 16)),
                          Text('Destination: ${selectedRide!.destName}'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Navigator.pushNamed(context, '/register', arguments: selectedRide);
                              showBookDialog(context, selectedRide!.id, selectedRide!);
                            },
                            child: Text('Join this Ride'),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 130,
                child: Container(
                  color: Colors.white,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: remoteRides.length,
                    itemBuilder: (context, index) {
                      final ride = remoteRides[index];
                      return GestureDetector(
                        onTap: () {
                          mapController.move(LatLng(double.parse(ride.startLat), double.parse(ride.startLng)), 15); // center map on marker
                          setState(() {
                            selectedRide = ride;
                          });
                        },
                        child: Card(
                          margin: EdgeInsets.all(10),
                          child: Container(
                            width: 180,
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ride.startName, style: TextStyle(fontWeight: FontWeight.bold), maxLines: 3, overflow: TextOverflow.ellipsis,textDirection: TextDirection.rtl,),
                                Text('Driver: ${ride.user?.name}'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (selectedPoint != null)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, selectedPoint);
                    },
                    child: Text('Confirm Location'),
                  ),
                )
            ],
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
                      MaterialPageRoute(builder: (context) => RideBookMidPage(mRide: ride,)),
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

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TripRidePage(mRide: ride),
          ),
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
}

class Ridee {
  final String id;
  final String driverName;
  final String destination;
  final LatLng location;

  Ridee({required this.id, required this.driverName, required this.destination, required this.location});
}
