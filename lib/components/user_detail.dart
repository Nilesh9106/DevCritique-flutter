import 'package:cached_network_image/cached_network_image.dart';
import 'package:devcritique/model/model.dart';
import 'package:devcritique/pages/profile_page.dart';
import 'package:flutter/material.dart';

class UserDetail extends StatelessWidget {
  final User user;
  const UserDetail({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Profile(
              user: user,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(
          user.profilePicture != '/user.png'
              ? user.profilePicture
              : "https://devcritique.vercel.app/user.png",
        ),
      ),
      title: Text(user.name ?? user.username),
      subtitle: Text("@${user.username}"),
    );
  }
}
