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
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromRGBO(15, 15, 15, 1)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: widget.user.profilePicture,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) => profilePicture(
                                image: widget.user.profilePicture,
                              ),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: CachedNetworkImageProvider(
                            widget.user.profilePicture,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.user.name ?? widget.user.username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "@${widget.user.username}",
                    style: const TextStyle(
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
                    child: LinearProgressIndicator(),
                  )
                : Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color.fromRGBO(15, 15, 15, 1)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Projects",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
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
    return projects.isEmpty
        ? const Text("No Projects")
        : Column(
            children: projects
                .map((e) => ProjectWidget(
                      project: e,
                      path: "profile",
                    ))
                .toList(),
          );
  }

  Widget _buildReviewList() {
    return const Text("data");
  }
}

class profilePicture extends StatelessWidget {
  final String image;
  const profilePicture({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.transparent,
        child: Center(
          child: Hero(
            tag: image,
            child: CircleAvatar(
              radius: 150,
              backgroundImage: CachedNetworkImageProvider(
                image,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
