import 'dart:async';
import 'dart:io';

import 'package:unicons/unicons.dart';
import 'package:mandm/data/remote/url_api.dart';
import 'package:mandm/models/brand_model.dart';
import 'package:mandm/models/car_model.dart';
import 'package:mandm/models/category_model.dart';
import 'package:mandm/pages/RegisterPage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:mandm/pages/my_cars_page.dart';

import '../components/show_toast_app.dart';
import '../data/local/cache_helper.dart';
import '../providers/home_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_page.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({Key? key}) : super(key: key);
  @override
  _AddCarPageState createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _formKey = GlobalKey<FormState>();
  BrandModel? selectedCarBrandModel;
  bool isModified = false;
  DateTime? lastServiceDate;

  TextEditingController brandWController = TextEditingController();
  TextEditingController modelWController = TextEditingController();
  TextEditingController seatsWController = TextEditingController();
  String? selectedCarYear;
  String? transmissionType;
  String? selectedCarColor;
  TextEditingController descriptionController = TextEditingController();

  final List<String> carColors = ['Red', 'Blue', 'Black', 'White', 'Silver'];
  List<String> carYears = List.generate(2025 - 2000 + 1, (index) => (2000 + index).toString());

  final ImagePicker _picker = ImagePicker();

  XFile? _singlePhoto;

  late HomeProvider mProvider;

  @override
  void initState() {
    requestPermissions();
    super.initState();
  }

  Future<void> requestPermissions() async {
    var status = await Permission.photos.request();
    if (status.isGranted) {
      print("Permission Granted!");
    } else {
      print("Permission Denied!");
    }
  }

  Future<void> _pickIdImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _singlePhoto = image;
      });
    }
  }

  void _removeIdImage() {
    setState(() {
      _singlePhoto = null;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_singlePhoto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please upload car photo')),
        );
        // return;
      }
    }
    if(CacheHelper.isHasKey(key: 'token')){
      postCar();
    }else{
      Timer(const Duration(milliseconds: 400),() {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterPage(),));
      },);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //check the size of device
    ThemeData themeData = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => HomeProvider()..loadPostCarInitData(),
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
          bottomNavigationBar: buildBottomNavBar(1, size, themeData),
          backgroundColor: themeData.scaffoldBackgroundColor,
          body: Consumer<HomeProvider>(
              builder: (context, provider, _){
                mProvider = provider;
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage.isNotEmpty) {
                  return Center(child: Text(provider.errorMessage));
                }
                return SafeArea(
                  child:Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 6),
                                TextField(
                                  controller: brandWController,
                                  decoration: InputDecoration(
                                    labelText: "Car Brand",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                                SizedBox(height: 12),
                                TextField(
                                  controller: modelWController,
                                  decoration: InputDecoration(
                                    labelText: "Car Model",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                                SizedBox(height: 12),
                                TextField(
                                  controller: seatsWController,
                                  decoration: InputDecoration(
                                    labelText: "Number Of Seats",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: "Car Year",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  value: selectedCarYear,
                                  items: carYears.map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
                                  onChanged: (value) => setState(() => selectedCarYear = value),
                                  validator: (value) => value == null ? 'Please select a car year' : null,
                                ),
                                SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: "Car Color",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  value: selectedCarColor,
                                  items: carColors.map((color) => DropdownMenuItem(value: color, child: Text(color))).toList(),
                                  onChanged: (value) => setState(() => selectedCarColor = value),
                                  validator: (value) => value == null ? 'Please select a car color' : null,
                                ),
                                SizedBox(height: 12),
                                Text("Transmission Type", style: TextStyle(fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile(
                                        title: Text("Automatic"),
                                        value: "Automatic",
                                        groupValue: transmissionType,
                                        onChanged: (value) => setState(() => transmissionType = value),
                                        isThreeLine: false,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile(
                                        title: Text("Manual"),
                                        value: "Manual",
                                        groupValue: transmissionType,
                                        onChanged: (value) => setState(() => transmissionType = value),
                                        isThreeLine: false,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                                Text("Photo", style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                _singlePhoto != null
                                    ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(_singlePhoto!.path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _removeIdImage,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.red,
                                          radius: 12,
                                          child: Icon(Icons.close, size: 16, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                    : ElevatedButton.icon(
                                  icon: Icon(Icons.upload),
                                  label: Text('Upload Car Photo'),
                                  onPressed: _pickIdImage,
                                ),
                                Divider(),
                                SizedBox(height: 12),
                                TextField(
                                  controller: descriptionController,
                                  decoration: InputDecoration(
                                    labelText: "Car Description",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  maxLines: 3,
                                ),
                                SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _submitForm,
                                    child: Text("Apply"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
          )
      )
    );
  }

  Future<void> postCar() async {
    try {
      var formData = FormData.fromMap({
        'brand': brandWController.text,
        'model': modelWController.text,
        'seats': int.parse(seatsWController.text),
        'Year': selectedCarYear,
        'trans_type': transmissionType,
        'color': selectedCarColor,
        'description': descriptionController.text,
      });

      if (_singlePhoto != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(_singlePhoto!.path, filename: _singlePhoto!.name),
        ));
      }
      var response = await Dio().post(
        postACar,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}'
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(),));

      } else {
        Timer(const Duration(milliseconds: 400),() {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(),));
        },);
      }
    } catch (e) {
      if (e is DioException && e.error is SocketException) {
      } else {
        print('errrrrrr: ${e}');
      }
    }
  }


}
