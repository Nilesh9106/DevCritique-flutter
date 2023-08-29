// ignore_for_file: prefer_const_constructors

import 'package:devcritique/service/auth/authenticator.dart';
import 'package:devcritique/service/mongodb.dart';
import 'package:devcritique/theme/theme.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Mongo.connect();
  runApp(const DevCritique());
}

class DevCritique extends StatelessWidget {
  const DevCritique({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dev Critique",
      debugShowCheckedModeBanner: false,
      theme: MyTheme.lightTheme(context),
      darkTheme: MyTheme.darkTheme(context),
      home: Authenticator(),
    );
  }
}
