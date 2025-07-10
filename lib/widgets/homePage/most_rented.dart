import 'package:mandm/data/cars.dart';
import 'package:mandm/widgets/homePage/car.dart';
import 'package:mandm/widgets/homePage/category.dart';
import 'package:flutter/material.dart';

Widget buildMostRented(Size size, ThemeData themeData) {
  return Column(
    children: [
      buildCategory('Most Rented', size, themeData),
      Padding(
        padding: EdgeInsets.only(
          top: size.height * 0.015,
          left: size.width * 0.03,
          right: size.width * 0.03,
        ),
        child: GridView.builder(
          primary: false,
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,                // 2 items per row
            mainAxisSpacing: size.height * 0.02, // vertical spacing
            crossAxisSpacing: size.width * 0.03, // horizontal spacing
            childAspectRatio: 0.75,             // controls height/width balance
          ),
          itemCount: cars.length,
          itemBuilder: (context, i) {
            return buildCar(i, size, themeData);
          },
        ),
      ),


    ],
  );
}
