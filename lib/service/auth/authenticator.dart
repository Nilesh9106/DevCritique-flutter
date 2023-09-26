import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:devcritique/pages/home_page.dart';
import 'package:devcritique/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authenticator extends StatefulWidget {
  const Authenticator({super.key});

  @override
  State<Authenticator> createState() => _AuthenticatorState();
}

class _AuthenticatorState extends State<Authenticator> {
  late var subscription;
  @override
  void initState() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            content: const Text("No Internet Connection"),
            actions: [
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                },
                child: const Text("Dismiss"),
              )
            ],
          ),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

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
