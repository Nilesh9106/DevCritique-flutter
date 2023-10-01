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

  static Future<void> addProject(
      {required String link,
      required String author,
      required String description,
      required String token,
      required String tech,
      required List<String> images}) async {
    List<String> techs = tech.trim().split(",");

    var url = Uri.parse('https://devcritique-api.vercel.app/api/projects/');
    var response = await post(url,
        headers: {"Content-Type": "application/json", "authorization": token},
        body: jsonEncode({
          "link": link,
          "author": author,
          "description": description,
          "technologies": techs,
          "images": images
        }));

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 201) {
    } else {
      throw Exception(decoded["message"]);
    }
  }

  static Future<void> like({
    required String project,
    required String author,
    required String token,
  }) async {
    var url = Uri.parse(
        'https://devcritique-api.vercel.app/api/projects/like/$project');
    var response = await post(url,
        headers: {"Content-Type": "application/json", "authorization": token},
        body: jsonEncode({
          "userId": author,
        }));

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    // print(decoded);
    print("liked");
    if (response.statusCode == 200) {
    } else {
      throw Exception(decoded["message"]);
    }
  }

  static Future<void> dislike({
    required String project,
    required String author,
    required String token,
  }) async {
    var url = Uri.parse(
        'https://devcritique-api.vercel.app/api/projects/dislike/$project');
    var response = await post(url,
        headers: {"Content-Type": "application/json", "authorization": token},
        body: jsonEncode({
          "userId": author,
        }));

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    // print(decoded);
    print("disliked");
    if (response.statusCode == 200) {
    } else {
      throw Exception(decoded["message"]);
    }
  }
}
