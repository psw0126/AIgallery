import 'dart:io';

import 'package:flutter/material.dart';
import 'package:example/view/captures_screen.dart';

class PreviewScreen extends StatelessWidget {
  final File pictureImage;
  final List<File> fileList;

  const PreviewScreen({
    required this.pictureImage,
    required this.fileList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => CapturesScreen(
                      imageFileList: fileList,
                    ),
                  ),
                );
              },
              child: Text('Go to all captures'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Image.file(pictureImage),
          ),
        ],
      ),
    );
  }
}
