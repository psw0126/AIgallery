import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:example/dialog/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_shutter_sound/native_shutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:example/view/preview_screen.dart';
import 'package:http/http.dart' as http;

import '../router/routes_module.dart';

class Camera_CustomPage extends StatefulWidget {
  const Camera_CustomPage({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription>? cameras;

  @override
  State<Camera_CustomPage> createState() => _CameraCoustomPageState();
}

class _CameraCoustomPageState extends State<Camera_CustomPage> {
  late CameraController _cameraController;
  VideoPlayerController? videoController;

  bool _isRearCameraSelected = true;
  bool _isFlashSelect = true;
  bool _isVideoCameraSelected = false;
  bool _isRecordingInProgress = false;
  double _minZoom = 1.0;
  double _maxZoom = 8.0;
  double _currentZoom = 1.0;
  final ImagePicker picker = ImagePicker();
  File? image;
  File? pictureImage;
  File? _videoFile;
  File? _imageFile;
  List<File> allFileList = [];
  late final List<XFile?> _pickedImages;
  var formData = FormData();
  List<dynamic> reels = [];

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);

  }




  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if(pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> _startVideoPlayer() async {
    if (_videoFile != null) {
      videoController = VideoPlayerController.file(_videoFile!);
      await videoController!.initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized,
        // even before the play button has been pressed.
        setState(() {});
      });
      await videoController!.setLooping(true);
      await videoController!.play();
    }
  }


  Future<void> startVideoRecording() async {
    final CameraController? cameraController = _cameraController;

    if (_cameraController!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      await cameraController!.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
        print(_isRecordingInProgress);
      });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (_cameraController == null) {
      return;
    }
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    _cameraController!.setExposurePoint(offset);
    _cameraController!.setFocusPoint(offset);
  }


  Future getMultiImage(ImageSource imageSource) async {
    final pickedFiles = await picker.pickMultiImage();

    if(pickedFiles != null) {
      for (var i = 0; i < pickedFiles.length; i++) {
        // String fileName = pickedFiles[i].path.split('/').last;
        final List<MultipartFile> _images = pickedFiles.map((image) => MultipartFile.fromFileSync(image.path)).toList();
        FormData data = FormData.fromMap({
          "files": await MultipartFile.fromFile(
            File(pickedFiles[i].path).readAsBytes().asStream() as String,
            filename: pickedFiles[i].path.split('/').last,
          ),
        });
        Dio dio = Dio();
        try{
          dio.options.contentType = 'multipart/form-data';
          dio.options.maxRedirects.isFinite;

          dio.options.headers = {
            "Content-Type": "application/json",
            "Accept": "application/json"
          };
          dio.post('http://192.168.0.128:3000/api/aiPro/uploadPictur',data: data).then((response) => print(response)).catchError((error) => print(error));
        } catch (e) {
          print('POST 요청 오류 $e');
        }

      }
      setState(()  {
        if(pickedFiles.isNotEmpty) {


        } else {
          alert(context, '선택된 사진이 없습니다.', '확인');
        }
      });
    }
  }



  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      pictureImage = File(picture!.path);
      await GallerySaver.saveImage(picture!.path);
      if(picture != null){
        print('파일 데이터');
        String fileName = picture.path.split('/').last;
        print(fileName);

        FormData data = FormData.fromMap({
          "files": await MultipartFile.fromFile(
            picture.path,
            filename: fileName,
          ),
        });
        Dio dio = Dio();
        try{
          dio.options.contentType = 'multipart/form-data';
          dio.options.maxRedirects.isFinite;

          dio.options.headers = {
            "Content-Type": "application/json",
            "Accept": "application/json"
          };
          dio.post('http://192.168.0.128:3000/api/aiPro/uploadPictur',data: data).then((response) => print(response)).catchError((error) => print(error));
        } catch (e) {
          print('POST 요청 오류 $e');
        }
      }
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high, );
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!_cameraController!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }

    try {
      XFile file = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
      });
      return file;
    } on CameraException catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  refreshAlreadyCapturedImages() async {
    final directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> fileList = await directory.list().toList();
    allFileList.clear();
    List<Map<int, dynamic>> fileNames = [];

    fileList.forEach((file) {
      if (file.path.contains('.jpg') || file.path.contains('.mp4')) {
        allFileList.add(File(file.path));

        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    });

    if (fileNames.isNotEmpty) {
      final recentFile =
      fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
      String recentFileName = recentFile[1];
      if (recentFileName.contains('.mp4')) {
        _videoFile = File('${directory.path}/$recentFileName');
        _imageFile = null;
        _startVideoPlayer();
      } else {
        _imageFile = File('${directory.path}/$recentFileName');
        _videoFile = null;
      }

      setState(() {});
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(children: [
        (_cameraController.value.isInitialized)
            ? CameraPreview(
              _cameraController,
                    child: LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) =>
                      onViewFinderTap(details, constraints),
                );
              }),
            )
            : Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator()
                )
            ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.13,
            decoration: BoxDecoration(
              color: Colors.black,),
            child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Expanded(
                //   child: IconButton(
                //     iconSize: 40,
                //     padding: EdgeInsets.zero,
                //     constraints: const BoxConstraints(),
                //     icon: Icon(
                //       _isFlashSelect
                //       ? Icons.flash_off
                //       : Icons.flash_on, color: Colors.white),
                //     onPressed: () {
                //       setState(() {
                //         _isFlashSelect = !_isFlashSelect;
                //         _isFlashSelect == true
                //         ? _cameraController.setFlashMode(FlashMode.always)
                //         : _cameraController.setFlashMode(FlashMode.off);
                //       });
                //     },
                //   )
                // ),
                // InkWell(
                //   onTap: _isVideoCameraSelected
                //       ? () async {
                //     if (_isRecordingInProgress) {
                //       XFile? rawVideo =
                //       await stopVideoRecording();
                //       File videoFile =
                //       File(rawVideo!.path);
                //
                //       int currentUnix = DateTime.now().millisecondsSinceEpoch;
                //
                //       final directory = await getApplicationDocumentsDirectory();
                //
                //       String fileFormat = videoFile
                //           .path
                //           .split('.')
                //           .last;
                //
                //       _videoFile = await videoFile.copy('${directory.path}/$currentUnix.$fileFormat',);
                //
                //       _startVideoPlayer();
                //     } else {
                //       await startVideoRecording();
                //     }
                //   }
                //       : () async {
                //     XFile? rawImage =
                //     await takePicture();
                //     File imageFile =
                //     File(rawImage!.path);
                //
                //     int currentUnix = DateTime.now()
                //         .millisecondsSinceEpoch;
                //
                //     final directory =
                //     await getApplicationDocumentsDirectory();
                //
                //     String fileFormat = imageFile
                //         .path
                //         .split('.')
                //         .last;
                //
                //     print(fileFormat);
                //
                //     await imageFile.copy(
                //       '${directory.path}/$currentUnix.$fileFormat',
                //     );
                //
                //     refreshAlreadyCapturedImages();
                //   },
                //   child: Stack(
                //     alignment: Alignment.center,
                //     children: [
                //       Icon(
                //         Icons.circle,
                //         color: _isVideoCameraSelected
                //             ? Colors.white
                //             : Colors.white38,
                //         size: 80,
                //       ),
                //       Icon(
                //         Icons.circle,
                //         color: _isVideoCameraSelected
                //             ? Colors.red
                //             : Colors.white,
                //         size: 65,
                //       ),
                //       _isVideoCameraSelected &&
                //           _isRecordingInProgress
                //           ? Icon(
                //         Icons.stop_rounded,
                //         color: Colors.white,
                //         size: 32,
                //       )
                //           : Container(),
                //     ],
                //   ),
                // ),
              ],
            )
          ),
        ),

        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.20,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  color: Colors.black),
              child:
                  Column(
                    children: [
                      Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _currentZoom,
                                min: _minZoom,
                                max: _maxZoom,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white30,
                                onChanged: (value) async {
                                  setState(() {
                                    _currentZoom = value;
                                  });
                                  await _cameraController!.setZoomLevel(value);
                                },
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  _currentZoom.toStringAsFixed(1) + 'x',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          ]
                      ),
                      Row(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
              IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 30,
                  icon: Icon(
                  _isRearCameraSelected
                      ? CupertinoIcons.switch_camera
                      : CupertinoIcons.switch_camera_solid,
                  color: Colors.white),
                                      onPressed: () {
                setState(
                    () => _isRearCameraSelected = !_isRearCameraSelected);
                initCamera(widget.cameras![_isRearCameraSelected ? 0 : 1]);
                                      },
                                ),
                Expanded(
                        child: IconButton(
                      onPressed: () {
                          takePicture();
                          // NativeShutterSound.play(); //셔터 사운드
                        },
                      iconSize: 80,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.circle, color: Colors.white),
                      )),
                      InkWell(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            image: pictureImage != null ? DecorationImage(
                              image: FileImage(pictureImage!),
                              fit: BoxFit.cover,
                            ) : null,
                          ),
                          // child: videoController != null && videoController!.value.isInitialized ? ClipRRect(
                          //   borderRadius: BorderRadius.circular(8.0),
                          //   child: AspectRatio(
                          //     aspectRatio:
                          //     videoController!.value.aspectRatio,
                          //     child: VideoPlayer(videoController!),
                          //   ),
                          // ) : null,
                        ),
                        onTap: () {
                          print('터치 작동');
                          showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext ctx) {
                                return AlertDialog(
                                  content: Text('갤러리 선택'),
                                  actions: [
                                    TextButton(
                                      child: Text('기본 갤러리'),
                                      onPressed: () {
                                        // Modular.to.pushNamed(RouteMap.IMAGESEND.page);
                                        Navigator.of(context).pop();
                                        getImage(ImageSource.gallery);
                                      },
                                    ),
                                    TextButton(
                                      child: Text('AI 갤러리'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Map params = {
                                          'token' : null,
                                          // 'uri' : "http://192.168.0.75:8081/gallery/gallery_list"
                                          // 'uri' : "http://192.168.0.53:8081/gallery/gallery_list"
                                          'uri' : "http://192.168.0.128:8081/gallery/gallery_list"
                                          // 'uri' : "http://192.168.152.140:8081/gallery/gallery_list"
                                        };
                                        Modular.to.pushNamed(RouteMap.WEB_BROWSER.page, arguments: params);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.movie_filter_outlined),
                                      onPressed: () {
                                        // reelsImage();
                                        Modular.to.pushNamed(RouteMap.REELS.page);
                                      }
                                    )
                                  ],
                                );
                              }
                          );
                        },
                      ),
                // const Spacer(),
              ]),
                    ],
                  ),
            )),
      ]),
    ));
  }

  Widget _gridPhoto() {
    return Expanded(
      child: _pickedImages.isNotEmpty ?
      GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4,),
        children:
              _pickedImages
              .where((element) => element != null)
              .map((e) => _gridPhotoItem(e!))
              .toList(),) : const SizedBox(),
      );
  }

  Widget _gridPhotoItem(XFile e){
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: Stack(
        children: [
          Positioned.fill(
              child: Image.file(
                File(e.path),
                fit: BoxFit.cover,
              ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _pickedImages.remove(e);
                });
              },
              child: const Icon(
                Icons.cancel_rounded,
                color: Colors.black87,
              ),
            ),
          )
        ],
      ),
    );
  }

}


