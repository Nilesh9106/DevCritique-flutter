import 'dart:convert';
import 'package:devcritique/model/model.dart';
import 'package:http/http.dart';

class ReviewService {
  static Future<List<Review>> getReviewsByProjectId(String id) async {
    final response = await get(
        Uri.parse("https://devcritique-api.vercel.app/api/projects/$id"));

    if (response.statusCode == 200) {
      var decoded = jsonDecode(response.body);
      decoded = decoded['reviews'];
      // print(decoded);
      return List.from(decoded)
          .map<Review>((review) => Review.fromJson(review))
          .toList();
    } else {
      throw Exception("failed to load projects");
    }
  }
}
