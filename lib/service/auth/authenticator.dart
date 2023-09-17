import 'package:devcritique/pages/home_page.dart';
import 'package:devcritique/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authenticator extends StatelessWidget {
  const Authenticator({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data?.getBool("isAuthenticated") == true) {
          return const Home();
        } else if (snapshot.hasData &&
            snapshot.data?.getBool("isAuthenticated") == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return const Login();
        }
      },
    );
  }
}
