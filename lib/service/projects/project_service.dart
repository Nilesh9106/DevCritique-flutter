import 'package:devcritique/model/model.dart' as models;
import 'package:devcritique/service/mongodb.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ProjectService {
  static Future<List<models.Project>> getProjects() async {
    try {
      final pipeline = AggregationPipelineBuilder()
          .addStage(Lookup(
              from: 'users',
              localField: 'author',
              foreignField: '_id',
              as: 'author'))
          .build();
      var projects = await Mongo.project.aggregateToStream(pipeline).toList();
      return List.from(projects)
          .map<models.Project>((project) => models.Project.fromJson(project))
          .toList();
    } on Exception catch (e) {
      print(e);
      return [];
    }
  }
}
