import 'package:devcritique/model/model.dart' as models;
import 'package:devcritique/service/mongodb.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ReviewService {
  static Future<List<models.Review>> getReviewsByProject(String id) async {
    try {
      final pipeline = AggregationPipelineBuilder()
          .addStage(Match(
              where.eq('project', ObjectId.fromHexString(id)).map['\$query']))
          .addStage(Lookup(
              from: 'users',
              localField: 'author',
              foreignField: '_id',
              as: 'author'))
          .build();
      var reviews = await Mongo.review.aggregateToStream(pipeline).toList();
      return List.from(reviews)
          .map<models.Review>((review) => models.Review.fromJson(review))
          .toList();
    } on Exception catch (e) {
      print(e);
      return [];
    }
  }
}
