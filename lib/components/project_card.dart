import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:devcritique/components/og_detail.dart';
import 'package:devcritique/components/snackbar.dart';
import 'package:devcritique/components/user_detail.dart';
import 'package:devcritique/pages/project_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:devcritique/model/model.dart';
import 'package:devcritique/service/projects/project_service.dart';
import 'package:devcritique/service/reviews/review_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectWidget extends StatefulWidget {
  final Project project;
  final String path;
  const ProjectWidget({super.key, required this.project, required this.path});

  @override
  State<ProjectWidget> createState() => _ProjectWidgetState();
}

class _ProjectWidgetState extends State<ProjectWidget> {
  SharedPreferences? pref;
  bool? isliked;
  bool loading = false;

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      var user = jsonDecode(value.getString("user")!);
      setState(() {
        isliked = widget.project.like.contains(user["_id"]);
        // debugPrint("isliked: $isliked");
      });
    });
    super.initState();
  }

  Future handleLike() async {
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    var user = jsonDecode(pref.getString("user")!);
    var token = pref.getString("token")!;
    if (isliked!) {
      setState(() {
        isliked = false;
        widget.project.like.remove(user["_id"]);
      });
      try {
        await ProjectService.dislike(
            project: widget.project.id, author: user["_id"], token: token);
        setState(() {
          loading = false;
        });
      } on Exception catch (e) {
        setState(() {
          isliked = true;
          widget.project.like.add(user["_id"]);
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          MySnackBar(e.toString()),
        );
      }
    } else {
      setState(() {
        isliked = true;
        widget.project.like.add(user["_id"]);
      });
      try {
        await ProjectService.like(
            project: widget.project.id, author: user["_id"], token: token);

        setState(() {
          loading = false;
        });
      } on Exception catch (e) {
        setState(() {
          widget.project.like.remove(user["_id"]);
          isliked = false;
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          MySnackBar(e.toString()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.path != "project") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectPage(project: widget.project),
            ),
          );
        }
      },
      child: Card(
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserDetail(user: widget.project.author),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: Text(widget.project.description,
                    textAlign: TextAlign.start),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: Row(
                    children: widget.project.technologies
                        .map(
                          (e) => Text(
                            "#$e ",
                            textAlign: TextAlign.start,
                            style: const TextStyle(color: Colors.blue),
                          ),
                        )
                        .toList(),
                  )),
              const SizedBox(
                height: 5,
              ),
              widget.project.images.isNotEmpty
                  ? Column(
                      children: [
                        TextButton(
                            onPressed: () async {
                              //goto link using url launcher
                              await launchUrl(Uri.parse(widget.project.link));
                            },
                            child: Text(widget.project.link)),
                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.project.images.length,
                            itemBuilder: (context, index) => GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    fullscreenDialog: true,
                                    builder: (context) => ImagePreview(
                                        link: widget.project.images[index],
                                        path: widget.path)),
                              ),
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Hero(
                                  tag: widget.project.images[index] +
                                      widget.path,
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => const Center(
                                      child: Icon(Icons.image, size: 50),
                                    ),
                                    imageUrl: widget.project.images[index],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : OgPreview(link: widget.project.link),
              const SizedBox(
                height: 10,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                SizedBox(
                  width: 25,
                ),
                TextButton.icon(
                  onPressed: handleLike,
                  icon: Icon(
                    (isliked ?? false)
                        ? Icons.favorite
                        : Icons.favorite_outline,
                    color: (isliked ?? false) ? Colors.red : null,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  label: Text("${widget.project.like.length}"),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class ImagePreview extends StatelessWidget {
  final String link;
  final String path;
  const ImagePreview({super.key, required this.link, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Center(
        child: Hero(
          tag: link + path,
          child: CachedNetworkImage(
            alignment: Alignment.center,
            placeholder: (context, url) => const Center(
              child: Icon(Icons.image, size: 50),
            ),
            imageUrl: link,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
