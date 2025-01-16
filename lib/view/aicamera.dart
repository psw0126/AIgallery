import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription>? camerasList;

class AicameraPage extends StatefulWidget {
  const AicameraPage({Key? key}) : super(key: key);

  @override
  _AicameraState createState() => _AicameraState();
}

class _AicameraState extends State<AicameraPage> {
  late CameraController controller;
  List<String> imageList = <String>[];
  late String imagePath;
  double _animatedHeight = 0.0;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  void initCamera() async {
    camerasList = await availableCameras();
    controller = CameraController(camerasList![0], ResolutionPreset.medium);
    controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    // controller?.dispose();
  }

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    setState(() {
      _animatedHeight = 30.0;
      _errorMsg = message;
    });

    Future<void>.delayed(const Duration(seconds: 1), _hideErrorMsg);
  }

  void _hideErrorMsg() {
    setState(() {
      _animatedHeight = 0.0;
      _errorMsg = '';
    });
  }

  Future<String?> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final PermissionStatus writeAccess = await Permission.storage.request();

    Directory? extDir;
    if (writeAccess.isGranted) {
      extDir = await getExternalStorageDirectory();
    } else {
      extDir = await getApplicationDocumentsDirectory();
    }
    final String dirPath = '${extDir?.path}/Pictures/pics';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await controller.takePicture();
    } on CameraException catch (e) {
      print('Exception -> $e');
      return null;
    }
    final File makeFile = File(filePath);
    setState(() {
      imageList.add(makeFile.absolute.path);
    });
    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller)),
        Positioned(
          top: 30.0,
          right: 10.0,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.close,
              color: Colors.grey,
              size: 30.0,
            ),
          ),
        ),
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                height: 60.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext c, int i) {
                    return Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Image.asset(imageList[i]),
                    );
                  },
                  itemCount: imageList.length,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      final File galleryImagePath = ImagePicker().pickMultiImage() as File;
                      if (galleryImagePath != null) {
                        setState(() {
                          imageList.add(galleryImagePath.absolute.path);
                        });
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      child: Icon(
                        Icons.add_box,
                        color: Colors.white,
                        size: 40.0,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      takePicture();
                    },
                    child: const Icon(
                      Icons.camera,
                      color: Colors.blue,
                      size: 40.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(imageList);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: imageList.isEmpty ? Colors.grey : Colors.blue,
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: const Icon(Icons.done),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}