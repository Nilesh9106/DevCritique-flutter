import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

class ImageService {
  static Future<String> uploadImage(File image) async {
    var request = MultipartRequest('POST',
        Uri.parse("https://devcritique-api.vercel.app/api/file/upload"));
    request.files.add(await MultipartFile.fromPath('file', image.path));
    request.headers.addAll({"Content-Type": "multipart/form-data"});
    var res = await request.send();
    var response = await Response.fromStream(res);
    var profilePicture = jsonDecode(response.body)["fileURL"];
    return profilePicture;
  }
}
