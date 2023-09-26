import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OgPreview extends StatelessWidget {
  final String link;
  const OgPreview({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade300,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnyLinkPreview(
        link: link,
        displayDirection: UIDirection.uiDirectionVertical,
        urlLaunchMode: LaunchMode.externalApplication,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Color.fromRGBO(25, 25, 25, 1)
            : Colors.grey[50],
        bodyMaxLines: 4,
        removeElevation: true,
        bodyTextOverflow: TextOverflow.ellipsis,
        previewHeight: 300,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        cache: Duration(days: 7),
      ),
    );
  }
}
