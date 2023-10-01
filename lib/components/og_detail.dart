import 'package:flutter/material.dart';
import 'package:link_preview_generator/link_preview_generator.dart';

class OgPreview extends StatelessWidget {
  final String link;
  const OgPreview({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade300,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: LinkPreviewGenerator(
        bodyMaxLines: 2,
        link: link,
        linkPreviewStyle: LinkPreviewStyle.large,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromRGBO(25, 25, 25, 1)
            : Colors.grey[50]!,
        bodyTextOverflow: TextOverflow.ellipsis,
        removeElevation: true,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
    );
  }
}
