import 'package:cached_network_image/cached_network_image.dart';
import 'package:devcritique/model/model.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  final User user;
  const EditProfile({super.key, required this.user});
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _nameController = TextEditingController();

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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(widget.user.profilePicture),
                radius: 50,
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  constraints: BoxConstraints(maxHeight: 40),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, widget.user);
                },
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(double.maxFinite, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    )),
                child: const Text("Save"),
              ),
            ],
          ),
        ));
  }
}
