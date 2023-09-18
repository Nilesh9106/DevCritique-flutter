import 'dart:convert';
import 'package:devcritique/service/projects/project_service.dart';
import 'package:flutter/material.dart';
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
  addProject() async {
    setState(() {
      loading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    var user = jsonDecode(pref.getString("user")!);
    var token = pref.getString("token")!;

    await ProjectService.addProject(
      link: linkController.text,
      author: user["_id"],
      token: token,
      description: descriptionController.text,
      tech: tagsController.text,
    );
    await ProjectService.fetchProjects();
    Navigator.pop(context);
    setState(() {
      loading = false;
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
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 50),
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
                        decoration: const InputDecoration(
                          hintText: "Link of Project",
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          hintText: "Description",
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: tagsController,
                        decoration: const InputDecoration(
                          hintText: "Tags",
                        ),
                      ),
                      const SizedBox(
                        height: 20,
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
              ));
  }
}
