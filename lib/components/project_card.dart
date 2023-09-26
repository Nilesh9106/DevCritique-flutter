import 'dart:convert';
import 'package:devcritique/components/og_detail.dart';
import 'package:devcritique/components/snackbar.dart';
import 'package:devcritique/components/user_detail.dart';
import 'package:devcritique/model/model.dart';
import 'package:devcritique/service/projects/project_service.dart';
import 'package:devcritique/service/reviews/review_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectWidget extends StatefulWidget {
  final Project project;
  const ProjectWidget({super.key, required this.project});

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
      });
    });
    super.initState();
  }

  Future handleLike() async {
    if (loading) {
      print("aleady loading");
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
    return Card(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child:
                  Text(widget.project.description, textAlign: TextAlign.start),
            ),
            const SizedBox(
              height: 5,
            ),
            OgPreview(link: widget.project.link),
            const SizedBox(
              height: 10,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              TextButton.icon(
                onPressed: handleLike,
                icon: Icon(
                  (isliked ?? false) ? Icons.favorite : Icons.favorite_outline,
                  color: (isliked ?? false) ? Colors.red : null,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                label: Text("${widget.project.like.length}"),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    ModalBottomSheetRoute(
                      builder: (context) => ReviewBottomSheet(
                        project: widget.project,
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
                icon: const Icon(Icons.rate_review_rounded),
              ),
            ]),
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
              : Expanded(
                  child: ReviewList(reviews: reviews),
                )
        ],
      ),
    );
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
        : ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: widget.reviews.length,
            itemBuilder: (context, index) =>
                _buildReview(context, widget.reviews[index]),
          );
  }

  Future handleUpvote(Review review) async {
    if (loading) {
      print("aleady loading");
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
        ],
      ),
    );
  }
}
