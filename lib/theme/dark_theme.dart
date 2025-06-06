import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:flutter/material.dart';

ThemeData dark = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: const Color.fromARGB(255, 213, 175, 5),
  secondaryHeaderColor: const Color(0xFF009f67),
  disabledColor: const Color(0xffa2a7ad),
  brightness: Brightness.dark,
  hintColor: const Color(0xFFbebebe),
  cardColor: const Color(0xFF30313C),
  scaffoldBackgroundColor: Colors.black, // Background color set to black
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color.fromARGB(255, 213, 175, 5),)),
  colorScheme: const ColorScheme.dark(
    primary: Color.fromARGB(255, 213, 175, 5),
    tertiary: Color(0xff6165D7),
    tertiaryContainer: Color(0xff171DB6),
    secondary: Color.fromARGB(255, 213, 175, 5),
    background: Colors.black, // Background color set to black
    error: Color(0xFFdd3135),
  ),
  popupMenuTheme: const PopupMenuThemeData(
      color: Color(0xFF29292D), surfaceTintColor: Color(0xFF29292D)),
  dialogTheme: const DialogTheme(surfaceTintColor: Colors.white10),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500))),
  bottomAppBarTheme: const BottomAppBarTheme(
    surfaceTintColor: Colors.black,
    height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),    
  ),
  dividerTheme: const DividerThemeData(
      thickness: 0.5, color: Color(0xFFA0A4A8)),
);
