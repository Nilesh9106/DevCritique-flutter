import 'dart:convert';
import 'dart:io';
import 'package:devcritique/components/snackbar.dart';
import 'package:devcritique/service/image.dart';
import 'package:devcritique/service/projects/project_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostCreate extends StatefulWidget {
  const PostCreate({super.key});

  @override
  State<PostCreate> createState() => _PostCreateState();
}

class _PostCreateState extends State<PostCreate> {
  TextEditingController linkController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController tagsController = TextEditingController();
  bool loading = false;
  String loadingText = "";
  List<File> images = [];
  addProject() async {
    setState(() {
      loading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    var user = jsonDecode(pref.getString("user")!);
    var token = pref.getString("token")!;

    try {
      var imagesUrls = <String>[];
      if (images.isNotEmpty) {
        setState(() {
          loadingText = "Uploading Images";
        });
        for (var element in images) {
          var url = await ImageService.uploadImage(element);
          imagesUrls.add(url);
          debugPrint(url);
        }
      }
      setState(() {
        loadingText = "Adding Project";
      });
      await ProjectService.addProject(
        link: linkController.text,
        author: user["_id"],
        token: token,
        description: descriptionController.text,
        tech: tagsController.text,
        images: imagesUrls,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        MySnackBar(
          "Project Added successfully",
        ),
      );
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        MySnackBar(
          e.toString(),
        ),
      );
    }

    await ProjectService.fetchProjects();
    Navigator.pop(context);
    setState(() {
      loading = false;
      loadingText = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        centerTitle: true,
      ),
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(loadingText),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Create Post",
                      style: TextStyle(fontSize: 25),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: linkController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        hintText: "Link of Project",
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: descriptionController,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: "Description",
                      ),
                      scrollPhysics: const BouncingScrollPhysics(),
                      maxLines: 6,
                      minLines: 1,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: tagsController,
                      decoration: const InputDecoration(
                        hintText: "Tags separated by comma",
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    // button for adding images
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.add_a_photo_rounded,
                        size: 20,
                      ),
                      onPressed: () {
                        if (images.length >= 3) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            MySnackBar(
                              "You can only add 3 images",
                            ),
                          );
                          return;
                        }
                        showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return imageBottomSheet(context);
                          },
                        );
                      },
                      label: const Text(
                        "Add Image",
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    images.isEmpty
                        ? const SizedBox.shrink()
                        : SizedBox(
                            height: 300,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.file(
                                            images[index],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            images.removeAt(index);
                                          });
                                        },
                                        style: IconButton.styleFrom(),
                                        icon: const Icon(
                                          Icons.delete,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              itemCount: images.length,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                            ),
                          ),
                    ElevatedButton(
                      onPressed: () {
                        addProject();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ],
                ),
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
      images.add(File(returnedFile.path));
    });
  }

  Future _pickImageFromCamera() async {
    final returnedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnedFile == null) return;
    setState(() {
      images.add(File(returnedFile.path));
    });
  }
}
