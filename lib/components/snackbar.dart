import 'package:flutter/material.dart';

SnackBar MySnackBar(String content) {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(15),
    elevation: 1,
    padding: EdgeInsets.all(15),
    content: Text(content, style: TextStyle(fontSize: 16)),
  );
}
