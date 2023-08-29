// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class MyTheme {
  static ThemeData lightTheme(BuildContext context) => ThemeData(
      appBarTheme: const AppBarTheme(
        elevation: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(elevation: 0.8)),
      primarySwatch: Colors.deepPurple,
      useMaterial3: true,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepPurple[700],
        unselectedItemColor: Colors.black,
        selectedIconTheme: IconThemeData(size: 40),
        unselectedIconTheme: IconThemeData(size: 35),
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ));

  static ThemeData darkTheme(BuildContext context) => ThemeData(
      colorScheme: ColorScheme.dark(
          primary: Color.fromARGB(255, 202, 172, 253),
          primaryContainer: Colors.deepPurple[200]),
      useMaterial3: true,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black87,
        selectedItemColor: Colors.deepPurple[200],
        unselectedItemColor: Colors.white,
        selectedIconTheme: IconThemeData(size: 40),
        unselectedIconTheme: IconThemeData(size: 35),
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ));
}
