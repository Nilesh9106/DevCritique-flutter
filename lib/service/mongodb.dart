import 'package:devcritique/service/constants.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Mongo {
  static Db? db;
  static final DbCollection project = db!.collection("projects");
  static final DbCollection user = db!.collection("users");
  static final DbCollection review = db!.collection("reviews");

  static connect() async {
    db = await Db.create(MONGO_URI);
    await db!.open();
  }

  static close() async {
    await db!.close();
  }
}
