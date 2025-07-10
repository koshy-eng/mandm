import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:unicons/unicons.dart';
import 'package:mandm/data/remote/url_api.dart';
import 'package:mandm/models/driver_model.dart';
import 'package:mandm/models/user_model.dart';
import 'package:mandm/pages/AccountStatusPage.dart';
import 'package:mandm/pages/Privacy_policy_page.dart';
import 'package:mandm/pages/my_cars_page.dart';
import 'package:mandm/pages/splash_page.dart';
import 'package:mandm/widgets/bottom_nav_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../components/show_toast_app.dart';
import '../data/local/cache_helper.dart';
import '../providers/home_provider.dart';
import '../widgets/homePage/most_rented_remote.dart';
import 'NotificationPage.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String userName = "Mohamed Salah"; // Fetch from backend
  final String userPhone = "01012345678";
  late HomeProvider mProvider;
  bool isProfileVerified = false;
  bool selectedImage = false;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  int egpAmount = 0;

  final ImagePicker _picker = ImagePicker();
  XFile? _idPhoto;

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
    return ChangeNotifierProvider(
      create: (_) => HomeProvider()..loadProfileData(),
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
          body: Consumer<HomeProvider>(
            builder: (context, provider, _) {
              mProvider = provider;
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.errorMessage.isNotEmpty) {
                return Center(child: Text(provider.errorMessage));
              }
              egpAmount = provider.driver!.message.coins;
              provider.egpAmountp = provider.driver!.message.coins;
              isProfileVerified = (provider.driver!.message.phone != null);
              return SafeArea(
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [Colors.green, Colors.blue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.logout,
                                              color: Colors.white,
                                            ),
                                            onPressed: () async {
                                              await CacheHelper.removeData(
                                                key: 'token',
                                              );
                                              await CacheHelper.removeData(
                                                key: 'id',
                                              );
                                              await CacheHelper.removeData(
                                                key: 'firstName',
                                              );
                                              await CacheHelper.removeData(
                                                key: 'lastName',
                                              );
                                              await CacheHelper.removeData(
                                                key: 'username',
                                              );
                                              await CacheHelper.removeData(
                                                key: 'email',
                                              );
                                              Timer(
                                                const Duration(milliseconds: 400),
                                                    () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                          SplashPage(),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              showEditDialog(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/icons/coin.png', // or use a network image
                                          width: 24,
                                          height: 24,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          // '${provider.driver?.message.coins}',
                                          '${provider.egpAmountp}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        8.0,
                                        0.0,
                                        8.0,
                                        0.0,
                                      ),
                                      child: CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.blue,
                                        child: Text(
                                          provider.driver!.message.name[0],
                                          // First letter of name
                                          style: TextStyle(
                                            fontSize: 32,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Flexible(child:
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [

                                        Text(
                                          '${provider.driver?.message.name}',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${provider.driver?.message.username}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                                  ],
                                )

                              ],
                            ),
                          ),
                          Column(
                            children: [
                              SizedBox(height: 16),
                              ListTile(
                                leading: Icon(Icons.info, color: Colors.green),
                                title: Text('State'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Navigate to Settings Page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AccountStatusPage()),
                                  );
                                },
                              ),
                              Divider(color: Color(0xffc6c6c6),),
                              ListTile(
                                leading: Icon(Icons.local_police, color: Colors.blue),
                                title: Text('Privacy Policy'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Navigate to Settings Page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
                                  );
                                },
                              ),
                              Divider(color: Color(0xffc6c6c6),),
                              ListTile(
                                leading: Icon(Icons.notifications_active, color: Colors.green),
                                title: Text('Notification'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => NotificationsPage()),
                                  );
                                },
                              ),
                              Divider(color: Color(0xffc6c6c6),),
                              ListTile(
                                leading: Icon(Icons.directions_car_filled, color: Colors.blue),
                                title: Text('My Cars'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => MyCarsPage()),
                                  );
                                },
                              ),
                              Divider(color: Color(0xffc6c6c6),),
                              ListTile(
                                leading: Icon(Icons.credit_card_sharp, color: Colors.green),
                                title: Text('Withdraw'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => WithdrawDialog(provider: provider,), // pass actual coin balance
                                  );
                                  // Navigate to Settings Page
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(builder: (context) => SettingsPage()),
                                  // );
                                },
                              ),
                              Divider(color: Color(0xffc6c6c6),),
                              ListTile(
                                leading: Icon(Icons.logout, color: Colors.red),
                                title: Text('Logout'),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  // Navigate to Settings Page
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(builder: (context) => SettingsPage()),
                                  // );
                                },
                              ),
                              Divider(color: Color(0xffc6c6c6),),
                            ],
                          )
                          /* SizedBox(height: 16),
                          buildMostRentedRemote(
                            size,
                            themeData,
                            provider.myCars,
                          ),*/
                        ],
                      ),
                    ),
                  ],
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
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  void showEditDialog(BuildContext context) {
    firstNameController.text = mProvider.driver!.message.name;
    lastNameController.text = mProvider.driver!.message.username;
    emailController.text = mProvider.driver!.message.email;
    phoneController.text = mProvider.driver!.message.phone;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Edit Your Data',
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
                        controller: firstNameController,
                        decoration: InputDecoration(
                          labelText: "First Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          labelText: "Last Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: "Your Username",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Your Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: "Your Phone Number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
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
                    await sendEditProfileRequest(
                      Driver(
                        id: 1,
                        name: firstNameController.text,
                        username: usernameController.text,
                        email: emailController.text,
                        coins: 0,
                        title: '',
                        isAdmin: 1,
                        type: 'xs',
                        updatedAt: '',
                        emailVerifiedAt: '',
                        // type: '1',
                        phone: phoneController.text,
                        createdAt: "createdAt",
                      ),
                    );
                    Navigator.pop(context); // Close dialog
                    // Get.back(); // Pop details page and go back to home
                    // } else {
                    //   showToastApp(text: 'Error: Please select both dates.', color: Colors.red);
                    // }
                  },
                  child: Text("Apply"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> sendEditProfileRequest(Driver usermodel) async {
    try {
      var formData = FormData.fromMap({
        'name': usermodel.name,
        'username': usermodel.username,
        'email': usermodel.email,
        'phone': usermodel.phone,
      });

      if (_idPhoto != null) {
        formData.files.add(
          MapEntry(
            'ImageFile', // The field name expected by your backend
            await MultipartFile.fromFile(
              _idPhoto!.path,
              filename: _idPhoto!.name,
            ),
          ),
        );
      }

      var response = await Dio().put(
        accountRentoPut, // Your API endpoint
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
          },
        ),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        setState(() {
          mProvider.driver!.message.phone = "";
          isProfileVerified = true;
        });
      } else {
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

class WithdrawDialog extends StatefulWidget {
  final HomeProvider provider; // e.g., 1000 coins

  const WithdrawDialog({super.key, required this.provider});

  @override
  State<WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends State<WithdrawDialog> {
  final TextEditingController _controller = TextEditingController();
  double? withdrawAmount;
  late double maxEgp;

  @override
  void initState() {
    super.initState();
    maxEgp = (widget.provider.driver!.message.coins * 0.05);
  }

  void _onWithdraw() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Withdrawing ${withdrawAmount?.toStringAsFixed(2)} EGP...')),
    );
    applyWithdraw(withdrawAmount!.round() * 20);
  }
  Future<void> applyWithdraw(int amount) async {
    try {

      var formData = json.encode({
        // 'ride_id': rideId,
        'amount': amount,
      });

      var response = await Dio().post(
        withdrawEP, // Your API endpoint
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
          },
        ),
      );

      if (response.statusCode == 200) {

        widget.provider.loadProfileData();
        widget.provider.egpAmountp = amount;
        Navigator.of(context).pop;
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
    return AlertDialog(
      title: const Text('Withdraw Coins'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('You have ${maxEgp.toStringAsFixed(2)} EGP available to withdraw.'),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Enter amount in EGP',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                withdrawAmount = double.tryParse(value);
              });
            },
          ),
          const SizedBox(height: 10),
          TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Enter Your Wallet Number',
              border: OutlineInputBorder(),
            ),
            /*onChanged: (value) {
              setState(() {
                withdrawAmount = double.tryParse(value);
              });
            },*/
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (withdrawAmount != null &&
              withdrawAmount! > 0 &&
              withdrawAmount! <= maxEgp)
              ? _onWithdraw
              : null,
          child: const Text('Withdraw'),
        ),
      ],
    );
  }
}
