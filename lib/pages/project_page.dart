// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:devcritique/model/model.dart';
import 'package:devcritique/service/reviews/review_service.dart';

class ProjectPage extends StatefulWidget {
  final Project project;

  const ProjectPage({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  List<Review> reviews = [];

  getReviews() async {
    reviews = await ReviewService.getReviewsByProject(widget.project.id);
    setState(() {});
    print(reviews);
  }

  @override
  void initState() {
    getReviews();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Project"),
        centerTitle: true,
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                  widget.project.author.profilePicture != '/user.png'
                      ? widget.project.author.profilePicture
                      : "https://devcritique.vercel.app/user.png"),
            ),
            title: Text(widget.project.author.name),
            subtitle: Text("@${widget.project.author.username}"),
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Text(
              widget.project.description,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          widget.project.ogDetails['title'] != null &&
                  widget.project.ogDetails['title'] != ""
              ? ListTile(
                  onTap: () async {
                    if (!await launchUrl(
                      Uri.parse(widget.project.link),
                      mode: LaunchMode.externalApplication,
                    )) {
                      print("could not fetch ${widget.project.link}");
                    }
                  },
                  style: ListTileStyle.list,
                  leading: CachedNetworkImage(
                    imageUrl: widget.project.ogDetails['image'],
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  title: Text((widget.project.ogDetails["title"]),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    widget.project.ogDetails["description"],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : Text(widget.project.link),
          Divider(
            height: 60,
            color: Colors.grey.shade900,
          ),
          Expanded(
            child: ReviewItem(reviews: reviews),
          )
        ],
      ),
    );
  }
}

class ReviewItem extends StatelessWidget {
  final List<Review> reviews;
  const ReviewItem({
    Key? key,
    required this.reviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (context, index) => _buildReview(reviews[index]),
    );
  }

  Widget _buildReview(Review review) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.grey.shade800,
          width: 0.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                  review.author.profilePicture != '/user.png'
                      ? review.author.profilePicture
                      : "https://devcritique.vercel.app/user.png"),
            ),
            title: Text(review.author.name),
            subtitle: Text("@${review.author.username}"),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              review.text,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.comment,
              size: 20,
            ),
            label: const Text("Discuss"),
          ),
        ],
      ),
    );
  }
}
