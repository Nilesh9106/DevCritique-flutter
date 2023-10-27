import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:devcritique/model/model.dart';
import 'package:devcritique/pages/edit_profile.dart';
import 'package:devcritique/pages/login_page.dart';
import 'package:devcritique/pages/profile_page.dart';
import 'package:devcritique/service/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  User? user;

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      final userData = json.decode(prefs.getString("user")!);
      setState(() {
        user = User.fromJson(userData);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          UserAccountsDrawerHeader(
            onDetailsPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(
                    user: user!,
                  ),
                ),
              );
            },
            decoration: const BoxDecoration(color: Colors.transparent),
            accountName: Text(
              user?.name ?? user?.username ?? "Loading...",
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black),
            ),
            accountEmail: Text(
              user?.email ?? "Loading...",
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                user?.profilePicture != "/user.png"
                    ? (user?.profilePicture ??
                        "https://devcritique.vercel.app/user.png")
                    : "https://devcritique.vercel.app/user.png",
              ),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditProfile(
                            user: user!,
                          )));
            },
            leading: const Icon(Icons.edit),
            title: const Text("Edit Profile"),
          ),
          ListTile(
            onTap: () async {
              await AuthService.logout();
              // ignore: use_build_context_synchronously
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Login(),
                  ),
                  (route) => false);
            },
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
