import 'dart:convert';

import 'package:devcritique/components/project_card.dart';
import 'package:devcritique/components/snackbar.dart';
import 'package:devcritique/components/user_detail.dart';
import 'package:devcritique/model/model.dart';
import 'package:devcritique/service/reviews/review_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectPage extends StatefulWidget {
  final Project project;
  const ProjectPage({super.key, required this.project});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
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
    return Scaffold(
        appBar: AppBar(
          title: const Text("Project"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ProjectWidget(project: widget.project, path: "project"),
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
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 0),
                            constraints: BoxConstraints(maxHeight: 40)),
                        maxLines: 5,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
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
                    : ReviewList(reviews: reviews)
              ],
            ),
          ),
        ));
  }
}

class ReviewList extends StatefulWidget {
  final List<Review> reviews;
  const ReviewList({
    Key? key,
    required this.reviews,
  }) : super(key: key);

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  Map<String, bool> upvoted = {};
  bool loading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      var user = jsonDecode(value.getString("user")!);
      widget.reviews.forEach((review) {
        setState(() {
          upvoted[review.id] = review.upVote.contains(user["_id"]);
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.reviews.isEmpty
        ? const Center(
            child: Text("No reviews yet", style: TextStyle(fontSize: 18)),
          )
        : Column(
            children:
                widget.reviews.map((e) => _buildReview(context, e)).toList(),
          );
  }

  Future handleUpvote(Review review) async {
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    var user = jsonDecode(pref.getString("user")!);
    var token = pref.getString("token")!;
    if (upvoted[review.id]!) {
      setState(() {
        upvoted[review.id] = false;
        review.upVote.remove(user["_id"]);
      });
      try {
        await ReviewService.downVote(
            review: review.id, author: user["_id"], token: token);
        setState(() {
          loading = false;
        });
      } on Exception catch (e) {
        setState(() {
          upvoted[review.id] = true;
          review.upVote.add(user["_id"]);
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          MySnackBar(e.toString()),
        );
      }
    } else {
      setState(() {
        upvoted[review.id] = true;
        review.upVote.add(user["_id"]);
      });
      try {
        await ReviewService.upVote(
            review: review.id, author: user["_id"], token: token);

        setState(() {
          loading = false;
        });
      } on Exception catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          MySnackBar(e.toString()),
        );
        setState(() {
          review.upVote.remove(user["_id"]);
          upvoted[review.id] = false;
          loading = false;
        });
      }
    }
  }

  Widget _buildReview(BuildContext context, Review review) {
    return Card(
      elevation: 0.5,
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
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                onPressed: () {
                  handleUpvote(review);
                },
                icon: Icon(
                  Icons.arrow_upward,
                  size: 24,
                  color: (upvoted[review.id] ?? false) ? Colors.green : null,
                ),
                label: Text("${review.upVote.length}"),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    ModalBottomSheetRoute(
                      builder: (context) => Comments(
                        review: review,
                      ),
                      isScrollControlled: true,
                      elevation: 1,
                      useSafeArea: true,
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
                icon: const Icon(
                  Icons.rate_review,
                  size: 24,
                ),
                label: Text("${review.comments.length}"),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}

class Comments extends StatefulWidget {
  final Review review;
  const Comments({super.key, required this.review});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  TextEditingController _textEditingController = new TextEditingController();
  List<dynamic> comments = [];
  bool loading = false;
  addComment() async {
    if (_textEditingController.text.trim().isEmpty) {
      return;
    }
    setState(() {
      loading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    var user = jsonDecode(pref.getString("user")!);
    var token = pref.getString("token")!;
    try {
      await ReviewService.addComment(
        review: widget.review.id,
        text: _textEditingController.text,
        token: token,
        username: user["username"],
      );
      setState(() {
        comments.add({
          "username": user["username"],
          "text": _textEditingController.text,
        });
        _textEditingController.clear();
        loading = false;
      });
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        MySnackBar(e.toString()),
      );
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    comments = widget.review.comments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                      hintText: "Write a Comment here",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      constraints: BoxConstraints(maxHeight: 40)),
                  maxLines: 5,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
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
                  addComment();
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
              : comments.isEmpty
                  ? const Center(
                      child: Text("No comments yet",
                          style: TextStyle(fontSize: 18)),
                    )
                  : Column(
                      children: (comments)
                          .map<Widget>((e) => Card(
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Text(e["username"] ?? ""),
                                      subtitle: Text(e["text"] ?? ""),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    )
        ],
      ),
    );
  }
}
