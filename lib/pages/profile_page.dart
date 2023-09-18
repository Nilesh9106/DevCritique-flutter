// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:devcritique/components/project_card.dart';
import 'package:devcritique/model/model.dart';
import 'package:devcritique/service/user/user_service.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  final User user;
  const Profile({super.key, required this.user});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  List<Project> projects = [];
  List<Review> reviews = [];
  late TabController _tabController;
  bool loading = false;
  getData() async {
    setState(() {
      loading = true;
    });
    var ans = await UserService().getUser(username: widget.user.username);
    setState(() {
      projects = ans['projects'] as List<Project>;
      reviews = ans['reviews'] as List<Review>;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.username),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Color.fromRGBO(15, 15, 15, 1)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: CachedNetworkImageProvider(
                      widget.user.profilePicture,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.user.name ?? widget.user.username,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "@${widget.user.username}",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ),
            loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Color.fromRGBO(15, 15, 15, 1)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Projects",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        _buildProjectList(),
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }

  Widget _buildProjectList() {
    return Column(
      children: projects.map((e) => ProjectWidget(project: e)).toList(),
    );
  }

  Widget _buildReviewList() {
    return Text("data");
  }
}
