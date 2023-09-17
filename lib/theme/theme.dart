import 'package:flutter/material.dart';

class MyTheme {
  static ThemeData lightTheme(BuildContext context) => ThemeData(
        appBarTheme: const AppBarTheme(
          elevation: 0.3,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: ColorScheme.light(
          primary: Colors.deepPurple[400]!,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          hoverColor: Colors.grey[300],
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.deepPurple[200]!,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.grey[100],
          elevation: 0.8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(elevation: 0.8)),
        // useMaterial3: true,

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple[700],
          unselectedItemColor: Colors.black,
          selectedIconTheme: const IconThemeData(size: 40),
          unselectedIconTheme: const IconThemeData(size: 35),
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
      );

  static ThemeData darkTheme(BuildContext context) => ThemeData(
        drawerTheme: const DrawerThemeData(
          elevation: 0,
          backgroundColor: Color.fromRGBO(20, 20, 20, 1),
        ),
        colorScheme: ColorScheme.dark(
            background: const Color.fromRGBO(16, 16, 16, 1),
            primary: const Color.fromARGB(255, 202, 172, 253),
            primaryContainer: Colors.deepPurple[200]),
        // useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          filled: true,
          fillColor: Colors.grey[900],
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey[800]!,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.deepPurple[200]!,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        cardTheme: CardTheme(
          color: const Color.fromRGBO(22, 22, 22, 1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black87,
          selectedItemColor: Colors.deepPurple[200],
          unselectedItemColor: Colors.white,
          selectedIconTheme: const IconThemeData(size: 40),
          unselectedIconTheme: const IconThemeData(size: 35),
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
      );
}
