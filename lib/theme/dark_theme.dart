import 'package:flutter/material.dart';
import 'package:word_wall/constants.dart';

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
    ),
    colorScheme: ColorScheme.dark(
      background: Colors.black,
      primary: Colors.grey[900]!,
      secondary: Colors.grey[800]!,
      tertiary: Colors.grey[800]!,
      onTertiary: Colors.grey[200]!,
    ));
