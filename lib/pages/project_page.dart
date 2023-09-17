import 'package:cached_network_image/cached_network_image.dart';
import 'package:devcritique/components/user_detail.dart';
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
  bool loading = false;

  getReviews() async {
    setState(() {
      loading = true;
    });
    reviews = await ReviewService.getReviewsByProjectId(widget.project.id);
    setState(() {
      loading = false;
    });
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
          UserDetail(user: widget.project.author),
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
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.grey.shade300,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Write a review",
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    maxLines: 5,
                    minLines: 1,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(80, 45),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
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
      physics: const BouncingScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) => _buildReview(reviews[index]),
    );
  }

  Widget _buildReview(Review review) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserDetail(user: review.author),
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
        ],
      ),
    );
  }
}
