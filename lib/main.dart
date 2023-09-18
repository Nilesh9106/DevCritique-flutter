import 'package:devcritique/service/auth/authenticator.dart';
import 'package:devcritique/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((value) => {
        if (value.getBool("isAuthenticated") == null)
          {value.setBool("isAuthenticated", false)}
      });
  runApp(const DevCritique());
}

class DevCritique extends StatelessWidget {
  const DevCritique({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dev Critique",
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: MyTheme.lightTheme(context),
      darkTheme: MyTheme.darkTheme(context),
      home: Authenticator(),
    );
  }
}
