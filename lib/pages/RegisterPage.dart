import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mandm/data/remote/url_api.dart';
import 'package:mandm/pages/LoginPage.dart';
import 'package:mandm/pages/home_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unicons/unicons.dart';

import '../components/show_toast_app.dart';
import '../data/local/cache_helper.dart';
import '../models/user_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String? idCardPhoto;
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool _termsAccepted = false;
  bool _isObscure = true;
  bool _isCObscure = true;

  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //check the size of device
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      /*appBar: PreferredSize(
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
      ),*/
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Container(
          clipBehavior: Clip.none,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/main-bg.png'),
              // Your background image path
              fit: BoxFit.cover, // Or BoxFit.fill / BoxFit.fitHeight etc.
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 72, 16, 16),
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Card(
                    color: Color(0xffffe5bc),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12),
                              Center(
                                child: Text(
                                  "Create Account",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              Center(
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.grey[300],
                                      backgroundImage:
                                          _image != null
                                              ? FileImage(_image!)
                                              : null,
                                      child:
                                          _image == null
                                              ? Icon(
                                                Icons.person,
                                                size: 50,
                                                color: Colors.grey[600],
                                              )
                                              : null,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: _pickImage,
                                        child: CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Color(0xff562f41),
                                          child: Icon(
                                            Icons.edit,
                                            size: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12),
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: "Name",
                                  fillColor: Color(0xfffff2de),
                                  filled: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Color(0xff919898),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Color(0xffFF9800),
                                      width: 2,
                                    ), // Orange highlight
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Color(0xff919898),
                                    ), // fallback
                                  ),
                                ),
                              ),

                              SizedBox(height: 12),
                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              TextField(
                                controller: phoneController,
                                decoration: InputDecoration(
                                  labelText: "Phone",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              SizedBox(height: 12),
                              TextFormField(
                                controller: passwordController,
                                obscureText: _isObscure,
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isObscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure = !_isObscure;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              TextFormField(
                                controller: confirmPasswordController,
                                obscureText: _isCObscure,
                                decoration: InputDecoration(
                                  labelText: "Confirm Password",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isCObscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isCObscure = !_isCObscure;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 3),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _termsAccepted,
                                    onChanged: (value) {
                                      setState(() {
                                        _termsAccepted = value ?? false;
                                      });
                                    },
                                  ),
                                  Text(
                                    "I agree to the ",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: Row(
                                                children: [
                                                  Icon(
                                                    Icons.warning,
                                                    color: Colors.orange,
                                                  ),
                                                  SizedBox(width: 8),

                                                  Text(
                                                    "Terms and Conditions",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              content: SingleChildScrollView(
                                                child: Text(
                                                  "By using this app, you agree to the following terms:\n\n"
                                                  "1. You will not use this app for any illegal activities.\n"
                                                  "2. You are responsible for maintaining the confidentiality of your account.\n"
                                                  "3. We may update these terms at any time without prior notice.\n\n"
                                                  "Please contact support if you have any questions.",
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: Text("Close"),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        /*Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.orange.withOpacity(0.2),
                                    ),
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.warning, size: 16, color: Colors.orange),
                                  ),
                                  SizedBox(width: 4),*/
                                        Text(
                                          "Terms and Conditions",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xff562f41),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 3),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _termsAccepted &&
                                              _formKey.currentState!.validate()
                                          ? () async {
                                            await register();
                                          }
                                          : null,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: const Color(0xff562f41),
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: Text(
                                    "Create",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              Center(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "I already have an account",
                                    style: TextStyle(color: Color(0xff562f41)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -105,
                    left: (size.width * 0.9 - 160) / 2,
                    // Centered assuming image width ~180
                    child: Image.asset(
                      'assets/images/mm-top-char.png',
                      width: 160,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> register() async {
    try {
      var formData = json.encode({
        'name': nameController.text,
        'username': usernameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'password': passwordController.text,
        // 'type': '1',
      });

      var response = await Dio().post(
        registerRento, // Your API endpoint
        data: formData,
      );

      if (response.statusCode == 200) {
        RegisterModel userModel = RegisterModel.fromJson(response.data);
        await CacheHelper.saveData(key: 'token', value: userModel.token);
        await CacheHelper.saveData(key: 'id', value: userModel.user.id);
        await CacheHelper.saveData(key: 'name', value: userModel.user.name);
        await CacheHelper.saveData(
          key: 'username',
          value: userModel.user.username,
        );
        await CacheHelper.saveData(key: 'email', value: userModel.user.email);

        Timer(const Duration(milliseconds: 400), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        });

        // showToastApp(text: 'account created successfully : ${userModel.user.name}', color: Colors.green);
      } else {
        // showToastApp(text: 'Error: Try again later.', color: Colors.red);
      }
    } catch (e) {
      if (e is DioException && e.error is SocketException) {
        print('DioException: ${e}');
        // showToastApp(text: 'No Internet connection.${e}', color: Colors.red);
      } else {
        print('err: ${e}');
        // showToastApp(text: 'Error: Try again later please.${e}', color: Colors.red);
      }
    }
  }
}
