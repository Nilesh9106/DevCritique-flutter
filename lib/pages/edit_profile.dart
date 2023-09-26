import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:devcritique/model/model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  final User user;
  const EditProfile({super.key, required this.user});
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _nameController = TextEditingController();
  File? _image;
  bool laoding = false;
  String laodingText = "Uploading image...";

  updateUser() async {
    setState(() {
      laoding = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";
    if (_image != null) {
      setState(() {
        laodingText = "Uploading image...";
      });
      var request = MultipartRequest('POST',
          Uri.parse("https://devcritique-api.vercel.app/api/file/upload"));
      request.files.add(await MultipartFile.fromPath('file', _image!.path));
      request.headers.addAll({"Content-Type": "multipart/form-data"});
      var res = await request.send();
      var response = await Response.fromStream(res);
      var profilePicture = jsonDecode(response.body)["fileURL"];
      print(profilePicture);

      setState(() {
        laodingText = "Updating data...";
      });
      response = await put(
        Uri.parse(
            "https://devcritique-api.vercel.app/api/users/${widget.user.username}"),
        headers: {
          "authorization": token,
          "Content-Type": "application/json",
        },
        body: jsonEncode(
            {"name": _nameController.text, "profilePicture": profilePicture}),
      );
      if (response.statusCode == 200) {
        await prefs.setString(
            "user", jsonEncode(jsonDecode(response.body)["user"]));
      } else {
        print(response.body);
        print(response.statusCode);
      }
    } else {
      setState(() {
        laodingText = "Updating data...";
      });
      var response = await put(
        Uri.parse(
            "https://devcritique-api.vercel.app/api/users/${widget.user.username}"),
        headers: {
          "Content-Type": "application/json",
          "authorization": token,
        },
        body: jsonEncode({
          "name": _nameController.text,
        }),
      );
      if (response.statusCode == 200) {
        await prefs.setString(
            "user", jsonEncode(jsonDecode(response.body)["user"]));
      } else {
        print(response.body);
        print(response.statusCode);
      }
    }
    setState(() {
      laoding = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: laoding
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(laodingText),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _image == null
                      ? InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            showModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (context) {
                                return imageBottomSheet(context);
                              },
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                                widget.user.profilePicture),
                            radius: 50,
                          ),
                        )
                      : InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            showModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return imageBottomSheet(context);
                              },
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage: FileImage(_image!),
                            radius: 50,
                          ),
                        ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: _nameController,
                    textAlignVertical: TextAlignVertical.bottom,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      hintText: "Enter your name",
                      constraints: BoxConstraints(maxHeight: 50),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      updateUser();
                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(double.maxFinite, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        )),
                    child: const Text("Save", style: TextStyle(fontSize: 17)),
                  ),
                ],
              ),
            ),
    );
  }

  Container imageBottomSheet(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 15,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromRGBO(15, 15, 15, 1)
                  : Colors.white,
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () async {
                await _pickImageFromCamera();
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromRGBO(15, 15, 15, 1)
                  : Colors.white,
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () async {
                await _pickImageFromGalary();
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromRGBO(15, 15, 15, 1)
                  : Colors.white,
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: const Text(
                "Cancel",
                textAlign: TextAlign.center,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future _pickImageFromGalary() async {
    final returnedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedFile == null) return;
    setState(() {
      _image = File(returnedFile.path);
    });
  }

  Future _pickImageFromCamera() async {
    final returnedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnedFile == null) return;
    setState(() {
      _image = File(returnedFile.path);
    });
  }
}
