import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:mandm/data/remote/url_api.dart';
import 'package:mandm/models/car_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../components/show_toast_app.dart';
import '../data/local/cache_helper.dart';
import '../providers/home_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_page.dart';
import 'map_page.dart';

class SetTripPage extends StatefulWidget {
  final Map<String, dynamic>
  initialFilters; // In case you want to load current filters
  const SetTripPage({super.key, this.initialFilters = const {}});

  @override
  _SetTripPageState createState() => _SetTripPageState();
}

class _SetTripPageState extends State<SetTripPage> {
  final _formKey = GlobalKey<FormState>();
  bool isModified = false;
  DateTime? lastServiceDate;
  List<String> carPhotos = [];
  String? idCardPhoto;
  TextEditingController nameController = TextEditingController();
/////////////////////////
  String? selectedCar;
  Car? selectedCarModel;
  int carId = 0;
  int userId = 0;

  DateTime? departureDate;
  TimeOfDay? selectedTime;

  LatLng? startPoint;
  LatLng? endPoint;
  String? startPlaceName;
  String? endPlaceName;

  TextEditingController seatController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  //////////////////////
  final List<String> carModels = ['Toyota', 'Honda', 'Ford', 'BMW', 'Mercedes'];
  final List<String> carColors = ['Red', 'Blue', 'Black', 'White', 'Silver'];

  Map<String, dynamic>? currentFilters;


  List<LatLng> points = [];

  String? nearestPoint;
  double? distanceToNearest;

  late HomeProvider mProvider;

  @override
  void initState() {
    super.initState();
    // currentFilters = widget.initialFilters;
    _checkLocationPermission();
    requestLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    await Geolocator.requestPermission();
    await Geolocator.getCurrentPosition();
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      throw Exception("Location permission not granted");
    }
  }

  Future<void> selectPoint(bool isStart) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapPage()),
    );
    // startPlaceName = await getPlaceName(startPoint!);

    // showToastApp(text: 'text: ${result is LatLng}');
    if (result != null && result is LatLng) {
      String placeName = await getPlaceName(result);
      setState(() {
        if (isStart) {
          startPoint = result;
          startPlaceName = placeName;
        } else {
          endPoint = result;
          endPlaceName = placeName;
        }
      });
    }
  }

  Future<String> getPlaceName(LatLng latLng) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?lat=${latLng.latitude}&lon=${latLng.longitude}&format=json';
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      return data['display_name'] ?? 'نقطة غير معروفة';
    } catch (e) {
      return 'غير قادر على جلب اسم المكان';
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //check the size of device
    ThemeData themeData = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => HomeProvider()..loadPostRideInitData(),
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
        bottomNavigationBar: buildBottomNavBar(1, size, themeData),
        backgroundColor: themeData.scaffoldBackgroundColor,
        body: Consumer<HomeProvider>(
          builder: (context, provider, _) {
            mProvider = provider;
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage.isNotEmpty) {
              return Center(child: Text(provider.errorMessage));
            }

            if (provider.myCars.isEmpty) {
              return Center(child: Text('You Do Not Have Any Car Yet'));
            }
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  Text(
                                    'Your Cars',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: "Your Cars",
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    value: selectedCar,
                                    // items: carModels.map((model) => DropdownMenuItem(value: model, child: Text(model))).toList(),
                                    items: provider.myCars.map((model) => DropdownMenuItem(value: model.id.toString(), child: Text(model.brand.toString()))).toList(),
                                    onChanged: (value) => setState(() {
                                      carId = value == null ? 0:int.parse(value);
                                      // selectedCar = value;
                                      // selectedCarModel = provider.firstWhere(
                                      //       (model)=> model.brand == selectedCar,
                                      //   // orElse: () =>null,
                                      // );
                                    }),
                                    validator: (value) => value == null ? 'Please select a car model' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Departure Details',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime.now(),
                                          );
                                      if (pickedDate != null) {
                                        setState(
                                          () => departureDate = pickedDate,
                                        );
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Departure Date',
                                        prefixIcon: const Icon(
                                          Icons.calendar_today,
                                        ),
                                        border: const OutlineInputBorder(),
                                      ),
                                      child: Text(
                                        departureDate != null
                                            ? '${departureDate}'
                                            : 'Departure Date',
                                        style: TextStyle(
                                          color:
                                              departureDate != null
                                                  ? Colors.black
                                                  : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () async {
                                      final TimeOfDay? pickedTime = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );

                                      if (pickedTime != null) {
                                        setState(() {
                                          selectedTime = pickedTime;
                                          // Log in AM/PM format
                                          final formattedTime = MaterialLocalizations.of(context).formatTimeOfDay(
                                            pickedTime,
                                            alwaysUse24HourFormat: false,
                                          );
                                          print('xxxxxxxxxxxxxxxx selectedTime: $formattedTime');
                                        });
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Departure Time',
                                        prefixIcon: const Icon(Icons.access_time),
                                        border: const OutlineInputBorder(),
                                      ),
                                      child: Text(
                                        selectedTime != null
                                            ? MaterialLocalizations.of(context).formatTimeOfDay(
                                          selectedTime!,
                                          alwaysUse24HourFormat: false,
                                        )
                                            : 'Departure Time',
                                        style: TextStyle(
                                          color: selectedTime != null
                                              ? Colors.black
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  //bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb

                                  // const SizedBox(height: 20),
                                  Text(
                                    'Route Information',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      selectPoint(true);
                                    },
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Start Point',
                                        prefixIcon: const Icon(
                                          Icons.location_on,
                                        ),
                                        border: const OutlineInputBorder(),
                                      ),
                                      child: Text(
                                        startPoint != null
                                            ? '${startPlaceName}'
                                            : 'Select Start Point',
                                        style: TextStyle(
                                          color:
                                              startPoint != null
                                                  ? Colors.black
                                                  : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  GestureDetector(
                                    onTap: () {
                                      selectPoint(false);
                                    },
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Destination Point',
                                        prefixIcon: const Icon(
                                          Icons.location_searching_outlined,
                                        ),
                                        border: const OutlineInputBorder(),
                                      ),
                                      child: Text(
                                        endPoint != null
                                            ? '${endPlaceName}'
                                            : 'Select Destination Point',
                                        style: TextStyle(
                                          color:
                                              endPoint != null
                                                  ? Colors.black
                                                  : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Ride Details',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: seatController,
                                    decoration: InputDecoration(
                                      labelText: 'Available Seats',
                                      hintText: 'Select number of seats',
                                      border: const OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: priceController,
                                    decoration: InputDecoration(
                                      labelText: 'Price',
                                      hintText: 'Enter the Price',
                                      border: const OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: descriptionController,
                                    decoration: InputDecoration(
                                      labelText: "Car Description",
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    maxLines: 3,
                                  ),
                                  // ElevatedButton(
                                  //   onPressed: () => selectPoint(true),
                                  //   child: Text('Select Start Point'),
                                  // ),
                                  // if (startPoint != null)
                                  //   Text(
                                  //     'Start: ${startPoint!.latitude}, ${startPoint!.longitude}',
                                  //   ),
                                  // if (startPoint != null)
                                  //   Text(
                                  //     'Start Point: ${startPlaceName ?? "Not selected"}',
                                  //   ),
                                  // SizedBox(height: 20),
                                  //
                                  // // if (startPoint != null)
                                  // ElevatedButton(
                                  //   onPressed: () => selectPoint(false),
                                  //   child: Text('Select End Point'),
                                  // ),
                                  // if (endPoint != null)
                                  //   Text(
                                  //     'End: ${endPoint!.latitude}, ${endPoint!.longitude}',
                                  //   ),
                                  // // if (endPoint != null)
                                  // Text(
                                  //   'End Point: ${endPlaceName ?? "Not selected"}',
                                  // ),
                                  SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.directions_car,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        "Apply",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        postRide();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> postRide() async {
    try {
      var formData = json.encode({
        'car_id': carId,
        'user_id': CacheHelper.getData(key: 'id'),
        'departure_date': DateFormat('yyyy-MM-dd').format(departureDate!),
        'departure_time': MaterialLocalizations.of(context).formatTimeOfDay(
          selectedTime!,
          alwaysUse24HourFormat: false,
        ),
        'start_lat': startPoint?.latitude,
        'start_lng': startPoint?.longitude,
        'start_name': startPlaceName,
        'dest_lat': endPoint?.latitude,
        'dest_lng': endPoint?.longitude,
        'dest_name': endPlaceName,
        'seats': seatController.text,
        'price': priceController.text,
        'description': descriptionController.text,
      });


      var response = await Dio().post(
        addRide,
        data: formData,
        options: Options(
          headers: {
            // 'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
          },
        ),
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        Timer(const Duration(milliseconds: 400), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        });
        // showToastApp(text: 'Error: Try again later.', color: Colors.red);
      }
    } catch (e) {
      if (e is DioException && e.error is SocketException) {
        // showToastApp(text: 'No Internet connection.', color: Colors.red);
      } else {
        print('errrrrrr: ${e}');
        // showToastApp(text: 'Error: Try again later please.', color: Colors.red);
      }
    }
  }
}

/*
Name:Mercedes-AMG C63 S Coupe
Color:Obsidian Black Metallic
Model:C205
Year:2021
Transmission:Automatic
PurchaseDate:2022-07-10
WeeklyRate:4950.00
DailyRate:198.00
Description:A high-performance coupe powered by a handcrafted twin-turbo V8 engine producing 503 hp, with a refined interior and advanced technology.
BrandId:1
CategoryId:1
*/

class RideCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const RideCard({required this.title, required this.children, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class DateTimeField extends StatelessWidget {
  final String label;
  final IconData icon;

  const DateTimeField({required this.label, required this.icon, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Select ${label.toLowerCase()}',
        suffixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class LocationField extends StatelessWidget {
  final String label;

  const LocationField({required this.label, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter ${label.toLowerCase()}',
        prefixIcon: const Icon(Icons.location_on),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class TimePickerExample extends StatefulWidget {
  @override
  _TimePickerExampleState createState() => _TimePickerExampleState();
}

class _TimePickerExampleState extends State<TimePickerExample> {
  TimeOfDay? _selectedTime;

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(), // or _selectedTime ?? TimeOfDay.now()
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Time')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _selectedTime != null
                  ? 'Selected Time: ${_selectedTime!.format(context)}'
                  : 'No Time Selected',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _pickTime, child: Text('Pick Time')),
          ],
        ),
      ),
    );
  }
}
