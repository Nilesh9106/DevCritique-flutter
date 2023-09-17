// ignore_for_file: prefer_const_constructors
import 'package:devcritique/components/user_detail.dart';
import 'package:devcritique/model/model.dart';
import 'package:devcritique/pages/project_page.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectWidget extends StatelessWidget {
  final Project project;
  const ProjectWidget({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
      child: GestureDetector(
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectPage(project: project),
            ),
          )
        },
        child: Card(
          elevation: 0.5,
          margin: EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserDetail(user: project.author),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: Text(project.description, textAlign: TextAlign.start),
                ),
                SizedBox(
                  height: 5,
                ),
                project.ogDetails['title'] != null &&
                        project.ogDetails['title'] != ""
                    ? ListTile(
                        onTap: () async {
                          if (!await launchUrl(
                            Uri.parse(project.link),
                            mode: LaunchMode.externalApplication,
                          )) {
                            print("could not fetch ${project.link}");
                          }
                        },
                        dense: true,
                        leading: CachedNetworkImage(
                          imageUrl: project.ogDetails['image'],
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                        title: Text((project.ogDetails["title"]),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          project.ogDetails["description"],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : Text(project.link),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
