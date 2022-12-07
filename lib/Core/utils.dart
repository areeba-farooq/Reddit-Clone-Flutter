import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:reddit_clone/main.dart';

void showSnackBar(String text) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
  // ..hideCurrentSnackBar()
  // ..showSnackBar(
  //   SnackBar(
  //     content: Text(text),
  //   ),
  // );
}

Future<FilePickerResult?> pickImage() async {
  final image = await FilePicker.platform.pickFiles(type: FileType.image);
  return image;
}
