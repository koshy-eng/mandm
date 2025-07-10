import 'package:mandm/pages/home_page.dart';
import 'package:mandm/pages/set_trip_page.dart';
import 'package:mandm/widgets/bottom_nav_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';

import '../pages/profile_page.dart';

Widget buildBottomNavBar(int currIndex, Size size, ThemeData themeData) {
  return ClipRRect(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(24),
    ),
    child: Container(
      color: const Color(0xff562f41), // Your bottom nav background color
      child: BottomNavigationBar(
        iconSize: size.width * 0.07,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 0),
        unselectedLabelStyle: const TextStyle(fontSize: 0),
        currentIndex: currIndex,
        backgroundColor: Colors.transparent, // <== very important
        type: BottomNavigationBarType.fixed,
        selectedItemColor: themeData.brightness == Brightness.dark
            ? const Color(0xffb6869d)
            : const Color(0xffb6869d),
        unselectedItemColor: const Color(0xffffe7f4),
        onTap: (value) {
          if (value != currIndex) {
            if (value == 0) {
              Get.off(const HomePage());
            } else if (value == 1) {
              Get.off(const SetTripPage());
            } else if (value == 2) {
              Get.off(const ProfilePage());
            }
          }
        },
        items: [
          buildBottomNavItem(Icons.home_outlined, themeData, size),
          buildBottomNavItem(Icons.notifications_active_outlined, themeData, size),
          buildBottomNavItem(UniconsLine.user, themeData, size),
        ],
      ),
    ),
  );

}
