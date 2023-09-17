import 'dart:convert';

import 'package:devcritique/model/model.dart';
import 'package:http/http.dart';
// import 'package:devcritique/service/mongodb.dart';
// import 'package:mongo_dart/mongo_dart.dart';

class ProjectService {
  static List<Project> projects = [];

  static Future<void> fetchProjects() async {
    final response =
        await get(Uri.parse("https://devcritique-api.vercel.app/api/projects"));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // print(decoded);
      projects = List.from(decoded)
          .map<Project>((project) => Project.fromJson(project))
          .toList();
    } else {
      throw Exception("failed to load projects");
    }
  }

  static Future<List<Project>> searchProject(String query) async {
    final response = await get(Uri.parse(
        "https://devcritique-api.vercel.app/api/search/description/$query"));

    if (response.statusCode == 200) {
      List<dynamic> decoded = jsonDecode(response.body);
      // print(decoded);
      var sprojects = List.from(decoded)
          .map<Project>((project) => Project.fromJson(project))
          .toList();
      return sprojects;
    } else {
      throw Exception("failed to search projects");
    }
  }
}
