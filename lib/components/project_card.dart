import 'dart:convert';
import 'package:devcritique/components/snackbar.dart';
import 'package:devcritique/components/user_detail.dart';
import 'package:devcritique/model/model.dart';
import 'package:devcritique/service/reviews/review_service.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectWidget extends StatelessWidget {
  final Project project;
  const ProjectWidget({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserDetail(user: project.author),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Text(project.description, textAlign: TextAlign.start),
            ),
            const SizedBox(
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
                          const Icon(Icons.error_outline),
                    ),
                    title: Text((project.ogDetails["title"]),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      project.ogDetails["description"],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : TextButton(
                    onPressed: () async {
                      if (!await launchUrl(
                        Uri.parse(project.link),
                        mode: LaunchMode.externalApplication,
                      )) {
                        print("could not fetch ${project.link}");
                      }
                    },
                    child: Text(project.link),
                  ),
            const SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.center,
              child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      ModalBottomSheetRoute(
                        builder: (context) => ReviewBottomSheet(
                          project: project,
                        ),
                        isScrollControlled: true,
                        constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.6),
                        elevation: 1,
                        showDragHandle: true,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color.fromRGBO(15, 15, 15, 1)
                                : Colors.grey[200],
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                      alignment: Alignment.center,
                      fixedSize: const Size(double.maxFinite, 30)),
                  icon: const Icon(Icons.rate_review_rounded),
                  label: const Text("Review")),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewBottomSheet extends StatefulWidget {
  final Project project;
  const ReviewBottomSheet({super.key, required this.project});

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  List<Review> reviews = [];
  bool loading = false;
  TextEditingController _textEditingController = new TextEditingController();

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

  addReview() async {
    setState(() {
      loading = true;
    });
    if (_textEditingController.text.trim().isEmpty) {
      return;
    }
    SharedPreferences pref = await SharedPreferences.getInstance();
    var user = jsonDecode(pref.getString("user")!);
    var token = pref.getString("token")!;

    try {
      await ReviewService.addReview(
        project: widget.project.id,
        author: user["_id"],
        text: _textEditingController.text,
        token: token,
      );
      await getReviews();
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        MySnackBar(e.toString()),
      );
    }
    _textEditingController.clear();
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getReviews();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Review",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                      hintText: "Write a review here",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      constraints: BoxConstraints(maxHeight: 40)),
                  maxLines: 5,
                  minLines: 1,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(85, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  addReview();
                },
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          loading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Expanded(
                  child: ReviewList(reviews: reviews),
                )
        ],
      ),
    );
  }
}

class ReviewList extends StatelessWidget {
  final List<Review> reviews;
  const ReviewList({
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
