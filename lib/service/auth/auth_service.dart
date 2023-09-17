import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<void> login(
      {required String email, required String password}) async {
    print("in login $email $password");
    var url = Uri.parse('https://devcritique-api.vercel.app/api/sign-in');
    var response = await post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}));
    final decoded = jsonDecode(response.body) as Map;
    if (response.statusCode == 200) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      print("Success");
      prefs.setString('token', decoded["token"]);
      prefs.setString('user', jsonEncode(decoded["user"]));
      prefs.setBool("isAuthenticated", true);
    } else {
      throw Exception(decoded["message"]);
    }
  }

  static Future<bool> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    prefs.remove("user");
    prefs.clear();
    prefs.setBool("isAuthenticated", false);
    return true;
  }

  static Future<void> signup(
      {required String username,
      required String email,
      required String password}) async {
    print("in login $email $password");
    var url = Uri.parse('https://devcritique-api.vercel.app/api/sign-up');
    var response = await post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"email": email, "password": password, "username": username}));
    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    final decoded = jsonDecode(response.body) as Map;
    if (response.statusCode == 200) {
    } else {
      throw Exception(decoded["message"]);
    }
  }
}
