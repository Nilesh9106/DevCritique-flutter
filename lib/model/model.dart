class User {
  final String id;
  final String? name;
  final String email;
  final String username;
  final int points;
  final String profilePicture;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.points,
    required this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['_id']),
      email: json['email'],
      name: json['name'] == null || json['name'] == ""
          ? json["username"]
          : json["name"],
      username: json['username'],
      points: json['points'],
      profilePicture: json['profilePicture'] ?? "/user.png",
    );
  }
}

class Project {
  final String id;
  final String link;
  final String description;
  final User author;
  List<String> technologies;
  Map<dynamic, dynamic> ogDetails;

  Project(
      {required this.id,
      required this.link,
      required this.description,
      required this.author,
      required this.technologies,
      required this.ogDetails});

  factory Project.fromJson(Map<String, dynamic> json) {
    // print(json);
    return Project(
      id: json['_id'].toString(),
      link: json['link'],
      description: json['description'],
      author: User.fromJson(
          (json['author'] is List ? json['author'][0] : json['author'])),
      technologies: json['technologies'].cast<String>(),
      ogDetails: json['ogDetails'] ?? <dynamic, dynamic>{},
    );
  }
}

class Review {
  final String id;
  final User author;
  final String text;
  final int? rating;
  final String status;
  final List<dynamic> comments;

  Review({
    required this.id,
    // required this.project,
    required this.author,
    required this.text,
    required this.rating,
    required this.status,
    required this.comments,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'].toString(),
      author: User.fromJson((json['author'])),
      text: json['text'],
      rating: json['rating'],
      status: json['status'],
      comments: json['comments'],
    );
  }
}
