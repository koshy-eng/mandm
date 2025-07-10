import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:unicons/unicons.dart';
import 'package:mandm/data/local/dbTablesHelpers/RideDb.dart';
import 'package:mandm/data/local/dbTablesHelpers/dbModels/db_models.dart';
import 'package:mandm/models/ride_model.dart';

import '../data/local/cache_helper.dart';
import '../data/remote/url_api.dart';
import 'home_page.dart';

class TripRidePage extends StatefulWidget {
  final Ride mRide;

  const TripRidePage({Key? key, required this.mRide}) : super(key: key);

  @override
  State<TripRidePage> createState() => _TripRidePageState();
}

class _TripRidePageState extends State<TripRidePage> {
  final MapController _mapController = MapController();
  final String _apiKey =
      '5b3ce3597851110001cf6248224595d7ae7c4e41949f7a5a47e866eb';

  bool isTripStarted = false;
  bool isTripEnded = false;

  late LatLng startPoint;
  late LatLng destPoint;
  List<LatLng> roadPoints = [];

  @override
  void initState() {
    super.initState();
    startPoint = LatLng(
      double.parse(widget.mRide.startLat),
      double.parse(widget.mRide.startLng),
    );
    destPoint = LatLng(
      double.parse(widget.mRide.destLat),
      double.parse(widget.mRide.destLng),
    );
    _prepareRoute();
    // _fetchRoute(startPoint, destPoint);
  }

  Future<void> _prepareRoute() async {
    final nearestStart = await _getNearestPoint(startPoint);
    final nearestEnd = await _getNearestPoint(destPoint);
    if (nearestStart != null && nearestEnd != null) {
      startPoint = nearestStart;
      destPoint = nearestEnd;
      roadPoints = await _fetchRoute(nearestStart, nearestEnd);
      setState(() {});
    }
  }

  Future<LatLng?> _getNearestPoint(LatLng point) async {
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/snap/driving-car?api_key=$_apiKey&point=${point.longitude},${point.latitude}',
    );
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final coords =
          jsonDecode(res.body)['features'][0]['geometry']['coordinates'];
      return LatLng(coords[1], coords[0]);
    }
    print('Nearest error: ${res.body}');
    return null;
  }

  Future<List<LatLng>> _fetchRoute(LatLng start, LatLng end) async {
    const apiKey = '5b3ce3597851110001cf6248224595d7ae7c4e41949f7a5a47e866eb';
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car',
    );

    final body = jsonEncode({
      'coordinates': [
        [start.longitude, start.latitude],
        [end.longitude, end.latitude],
      ],
    });

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': apiKey, 'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords = data['features'][0]['geometry']['coordinates'] as List;
        return coords
            .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
            .toList();
      } else {
        print('❌ Failed to fetch route: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception in getRoutePoints: $e');
    }

    return [];
  }

  double _calculateDistance() {
    return const Distance().as(LengthUnit.Kilometer, startPoint, destPoint);
  }

  Widget _buildAppBar(ThemeData theme, Size size) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      leadingWidth: size.width * 0.15,
      leading: _iconBox(UniconsLine.bars, size, theme),
      title: Image.asset(
        'assets/icons/wheely_colored.png',
        height: size.height * 0.06,
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: size.width * 0.05),
          child: _iconBox(UniconsLine.search, size, theme),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon, Size size, ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.03),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
      ),
      width: size.width * 0.1,
      height: size.width * 0.1,
      child: Icon(
        icon,
        size: size.height * 0.025,
        color: theme.secondaryHeaderColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final routePoints =
        roadPoints.isNotEmpty ? roadPoints : [startPoint, destPoint];
    print('EEEEEEEEEEEEEEE roadPoints: ${roadPoints.length} points');

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: _buildAppBar(theme, size),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            _buildMap(routePoints),
            _buildDistanceCard(),
            _buildTripButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(List<LatLng> points) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(center: startPoint, zoom: 13),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 40,
              height: 40,
              point: startPoint,
              child: const Icon(
                Icons.location_pin,
                color: Colors.green,
                size: 40,
              ),
            ),
            Marker(
              width: 40,
              height: 40,
              point: destPoint,
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
        PolylineLayer(
          polylines: [
            Polyline(points: points, strokeWidth: 4, color: Colors.blueAccent),
          ],
        ),
      ],
    );
  }

  Widget _buildDistanceCard() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Card(
        color: Colors.white.withOpacity(0.9),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.route, color: Colors.black),
              const SizedBox(width: 10),
              Text(
                "Distance: ${NumberFormat("##0.00").format(_calculateDistance())} km",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripButton() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            if (isTripEnded) {
              tripFinished();
            }
            if (!isTripStarted) {
              isTripStarted = true;
            } else {
              isTripEnded = true;
            }
          });
        },
        icon: Icon(
          isTripEnded
              ? Icons.home
              : isTripStarted
              ? Icons.stop
              : Icons.play_arrow,
        ),
        label: Text(
          isTripEnded
              ? 'Go to Home'
              : isTripStarted
              ? 'Stop Trip'
              : 'Start Trip',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isTripEnded
                  ? Colors.green
                  : isTripStarted
                  ? Colors.red
                  : Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Future<void> tripFinished() async {
    try {
      var formData = json.encode({
        /*'ride_id': rideId,
        'seat_count': seats,*/
      });

      var response = await Dio().post(
        setTripFinished, // Your API endpoint
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
          },
        ),
      );

      if (response.statusCode == 200) {
        final rideDb = RideDb();
        await rideDb.insertItem(
          RideItem(
            id: widget.mRide.id,
            carId: widget.mRide.carId,
            userId: widget.mRide.userId,
            description: widget.mRide.car!.brand,
            departureDate: widget.mRide.departureDate,
            departureTime: widget.mRide.departureTime,
            destLat: widget.mRide.destLat,
            destLng: widget.mRide.destLng,
            destName: widget.mRide.destName,
            price: widget.mRide.price,
            seats: widget.mRide.seats,
            startLat: widget.mRide.startLat,
            startLng: widget.mRide.startLng,
            startName: widget.mRide.startName,
          ),
        );
        Timer(const Duration(milliseconds: 400), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        });
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
