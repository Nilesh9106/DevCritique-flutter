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

  static Future<void> addReview(
      {required String project,
      required String author,
      required String text,
      required String token}) async {
    var url = Uri.parse('https://devcritique-api.vercel.app/api/reviews/');
    var response = await post(url,
        headers: {"Content-Type": "application/json", "authorization": token},
        body: jsonEncode({"project": project, "author": author, "text": text}));

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 201) {
    } else {
      throw Exception(decoded["message"]);
    }
  }

  static Future<void> upVote({
    required String review,
    required String author,
    required String token,
  }) async {
    var url = Uri.parse(
        'https://devcritique-api.vercel.app/api/reviews/upvote/$review');
    var response = await post(url,
        headers: {"Content-Type": "application/json", "authorization": token},
        body: jsonEncode({
          "userId": author,
        }));

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    // print(decoded);
    print("upvoted");
    if (response.statusCode == 200) {
    } else {
      throw Exception(decoded["message"]);
    }
  }

  static Future<void> downVote({
    required String review,
    required String author,
    required String token,
  }) async {
    var url = Uri.parse(
        'https://devcritique-api.vercel.app/api/reviews/downvote/$review');
    var response = await post(url,
        headers: {"Content-Type": "application/json", "authorization": token},
        body: jsonEncode({
          "userId": author,
        }));

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    // print(decoded);
    print("downvoted");
    if (response.statusCode == 200) {
    } else {
      throw Exception(decoded["message"]);
    }
  }
}
