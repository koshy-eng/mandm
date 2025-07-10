import 'dart:math';

import 'package:mandm/data/cars.dart';
import 'package:mandm/pages/details_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unicons/unicons.dart';

Padding buildCar(int i, Size size, ThemeData themeData) {
  return Padding(
    padding: EdgeInsets.zero,  // Grid handles spacing, no need to add here
    child: Center(
      child: Container(
        decoration: BoxDecoration(
          color: themeData.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: size.width * 0.02),
          child: InkWell(
            onTap: () {
              Get.to(DetailsPage(
                carImage: cars[i]['carImage'],
                carClass: cars[i]['carClass'],
                carName: cars[i]['carName'],
                carPower: cars[i]['carPower'],
                people: cars[i]['people'],
                bags: cars[i]['bags'],
                carPrice: cars[i]['carPrice'],
                carRating: cars[i]['carRating'],
                isRotated: cars[i]['isRotated'],
              ));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car Image
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.01),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: cars[i]['isRotated']
                        ? Image.asset(
                      cars[i]['carImage'],
                      height: size.width * 0.25,
                      width: size.width * 0.4,  // Adjusted for grid
                      fit: BoxFit.contain,
                    )
                        : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(pi),
                      child: Image.asset(
                        cars[i]['carImage'],
                        height: size.width * 0.25,
                        width: size.width * 0.4,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Car Class
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.01),
                  child: Text(
                    cars[i]['carClass'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Color(0xff3c3c3c),
                      fontSize: size.width * 0.045, // Slightly smaller for grid
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Car Name
                Text(
                  cars[i]['carName'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Color(0xff3c3c3c),
                    fontSize: size.width * 0.03,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Price & Icon Row
                Row(
                  children: [
                    Text(
                      '${cars[i]['carPrice']}\$',
                      style: GoogleFonts.poppins(
                        color: Color(0xff3c3c3c),
                        fontSize: size.width * 0.05, // Slightly smaller
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '/per day',
                      style: GoogleFonts.poppins(
                        color: themeData.primaryColor.withOpacity(0.8),
                        fontSize: size.width * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.only(right: size.width * 0.02),
                      child: Container(
                        height: size.width * 0.1,
                        width: size.width * 0.1,
                        decoration: const BoxDecoration(
                          color: Color(0xff19c50d),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: const Icon(
                          UniconsLine.credit_card,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

