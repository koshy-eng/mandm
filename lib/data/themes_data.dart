import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightModeTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xfff8f8f8),
  primaryColor: Colors.black,
  colorScheme: ColorScheme.light(
    primary: Colors.black,
    secondary: const Color(0xff12ce31),
  ),
  textTheme: TextTheme(
    bodyMedium: GoogleFonts.poppins(color: Colors.black),
  ),
  cardColor: Colors.white,
);

ThemeData darkModeTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xff06090d),
  primaryColor: Colors.white,
  colorScheme: ColorScheme.dark(
    primary: Colors.white,
    secondary: Colors.white,
  ),
  textTheme: TextTheme(
    bodyMedium: GoogleFonts.poppins(color: Colors.white),
  ),
  cardColor: const Color(0xff070606),
);