// ignore_for_file: prefer_const_constructors

import 'package:devcritique/model/model.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  final User user;
  const Profile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
      ),
      body: Center(
        child: Text("Profile page"),
      ),
    );
  }
}
