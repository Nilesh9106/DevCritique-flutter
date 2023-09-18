import 'dart:convert';

import 'package:devcritique/model/model.dart';
import 'package:http/http.dart';

class UserService {
  Future<Map<String, List<dynamic>>> getUser({required String username}) async {
    final response = await get(
        Uri.parse("https://devcritique-api.vercel.app/api/users/$username"));

    if (response.statusCode == 200) {
      var decoded = jsonDecode(response.body);
      List<dynamic> reviews = decoded['reviews'];
      List<dynamic> projects = decoded['projects'];

      reviews = List.from(reviews)
          .map<Review>((review) => Review.fromJson(review))
          .toList();
      projects = List.from(projects)
          .map<Project>((project) => Project.fromJson(project))
          .toList();

      return {'reviews': reviews, 'projects': projects};
    } else {
      throw Exception("Something went wrong");
    }
  }
}
