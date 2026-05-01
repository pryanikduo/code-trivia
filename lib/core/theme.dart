import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final darkTheme = ThemeData(
    useMaterial3: true,
    // brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      surface: Color.fromRGBO(33, 40, 68, 1.0),
    ),
    scaffoldBackgroundColor: Color.fromRGBO(33, 40, 68, 1.0),
    textTheme: GoogleFonts.jetBrainsMonoTextTheme(
      ThemeData.dark().textTheme.apply(
        bodyColor: Color.fromRGBO(240, 232, 213, 1.0),
      )
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromRGBO(240, 232, 213, 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(vertical: 13),
      ),
    ),
  );
}