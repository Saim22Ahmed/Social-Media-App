import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
  ),
  colorScheme: ColorScheme.light(
    background: Colors.grey[100]!,
    primary: Colors.white,
    secondary: Color(0xffCAF0F8),
    onSecondary: Colors.grey[600]!,
    tertiary: Color(0xff00B4D8),
    onTertiary: Color(0xff00B4D8),
    inversePrimary: Colors.grey[900]!,
  ),
  hintColor: Colors.grey[300],
  shadowColor: Colors.white70,
);



// ThemeData lightTheme = ThemeData(
//     brightness: Brightness.light,
//     appBarTheme: AppBarTheme(
//       backgroundColor: Colors.transparent,
//     ),
//     colorScheme: ColorScheme.light(
//       background: Color(0xffE3D5CA),
//       primary: Color(0xffF5EBE0),
//       secondary: Color(0xffE3D5CA),
//       tertiary: Color(0xffD5BDAF),
//     ));
