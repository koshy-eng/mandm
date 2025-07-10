import 'dart:async';

import 'package:mandm/pages/AddCar.dart';
import 'package:mandm/providers/home_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import '../widgets/homePage/most_rented_remote.dart';


class MyCarsPage extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;
  MyCarsPage({this.initialFilters, Key? key}): super(key: key);
  @override
  _MyCarsPageState createState() => _MyCarsPageState();
}

class _MyCarsPageState extends State<MyCarsPage> {
  final Dio dio = Dio();
  List<dynamic> cars = [];

  bool isLoading = true;
  String errorMessage = '';
  Map<String, dynamic>? currentFilters;

  TextEditingController searchController = TextEditingController();
  late HomeProvider mProvider;
  @override
  void initState() {
    super.initState();;
    currentFilters = widget.initialFilters ?? {};
    // loadHomeData();
  }

  void applySearch(Map<String, dynamic>? filters) {
    mProvider = Provider.of<HomeProvider>(context, listen: false);
    mProvider.loadHomeData(filters: filters);
    // Here you call your search API or filter your local data
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //check the size of device
    ThemeData themeData = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => HomeProvider()..loadMyCars(),
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
          builder: (context, provider, _){
            mProvider = provider;
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.errorMessage.isNotEmpty) {
              return Center(child: Text(provider.errorMessage));
            }
            return SafeArea(
              child: Scaffold(
                body: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: size.width * 0.05,
                        right: size.width * 0.05,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(15),
                          ),
                          color: themeData.cardColor, // section bg color
                        ),
                        child: Column(
                          children: [],
                        ),
                      ),
                    ),
                    buildMostRentedRemote(size, themeData, provider.myCars, 'My Cars'),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddCarPage()),
                      );
                  },
                  backgroundColor: Color(0xFF0D69C5), // Customize color
                  child: const Icon(Icons.add), // Icon for adding a car
                  tooltip: 'Add Car',
                ),
              ),
            );
          },
        ),
      )
    );
  }

  OutlineInputBorder textFieldBorder() {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.0),
    );
  }
}
