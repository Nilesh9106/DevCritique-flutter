import 'package:flutter/material.dart';

SnackBar MySnackBar(String content) {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(15),
    elevation: 1,
    padding: const EdgeInsets.all(15),
    content: Text(content, style: const TextStyle(fontSize: 16)),
  );
}
