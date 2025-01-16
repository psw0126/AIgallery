import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:example/view/camera_custom.dart';
// import 'package:example/dialog/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;

import '../router/routes_module.dart';

List<CameraDescription>? camerasList;

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key, required List<CameraDescription> cameras}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}



class _CameraPageState extends State<CameraPage> {
  File? image;
  List<String> imageFileList = <String>[];
  final ImagePicker picker = ImagePicker();
  late String imagePath;
  late CameraController _cameraController;
  double _animatedHeight = 0.0;
  String _errorMsg = '';
  late String filePath;
  late String dir;
  late String newName;

// 'uri' : "http://192.168.0.51:8081/gallery/gallery_list"
  // bool _isRearCameraSelected = true;

  void selectImages() async {
    final List<XFile> selectedImage = await picker.pickMultiImage();
    if(selectedImage!.isNotEmpty){
      imageFileList.addAll(selectedImage as Iterable<String>);
    }
    setState(() {

    });
  }



  
  
  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // _cameraController.initialize();
    initCamera();
    // initCamera(widget.cameras![0]);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  
  void initCamera() async {
    camerasList = await availableCameras();
    _cameraController = CameraController(camerasList![0], ResolutionPreset.medium);
    await _cameraController.initialize();
    if (mounted) {
      setState(() {});
    }
  }


  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if(pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30, width: double.infinity),
            _buildPhotoArea(),
            SizedBox(height: 20),
            _buildButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoArea() {
    return image != null
        ? Container(
      width: 300,
      child: Column(
        children: [
          Image.file(File(image!.path)),
        ]
      )
    )  : Container(
      width: 300,
      height: 300,
      color: Colors.grey,
    );
  }

  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xffFFE4B5),
            foregroundColor: Colors.black,
          ),
          onPressed: () async {
            PickedFile? pickFile = await ImagePicker().getImage(source: ImageSource.camera);
            await GallerySaver.saveImage(pickFile!.path);
            if(pickFile != null){
              print('파일 데이터');
              String fileName = pickFile.path.split('/').last;
              print(fileName);

              FormData data = FormData.fromMap({
                "files": await MultipartFile.fromFile(
                  pickFile.path,
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
                dio.post('http://192.168.0.75:3000/api/aiPro/uploadPictur',data: data).then((response) => print(response)).catchError((error) => print(error));
                //여기가 사진 보내는 post
              } catch (e) {
                print('POST 요청 오류 $e');
              }

              // var request = http.MultipartRequest('POST',Uri.parse('http://127.0.0.1:3000'));
              // request.files.add(await http.MultipartFile.fromPath('file', pickFile.path));
              // var response = await request.send();
              // if(response.statusCode == 200) {
              //   alert(context, '이미지 업로드 성공', '확인');
              // } else {
              //   alert(context, '이미지 전송 실패', '확인');
              // }
            }
            // Modular.to.pushNamed(RouteMap.AICAMERA.page);
             //getImage 함수를 호출해서 카메라로 찍은 사진 가져오기
          },
          child: Text("카메라"),
        ),
        SizedBox(width: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xffFFE4B5),
            foregroundColor: Colors.black,
          ),
          onPressed: () {
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
                            'uri' : "http://192.168.0.75:8081/gallery/gallery_list"
                            //여기가 ai갤러리 호출
                          };
                          Modular.to.pushNamed(RouteMap.WEB_BROWSER.page, arguments: params);
                          // Modular.to.pushNamed(RouteMap.AI.page);
                        },
                      ),
                    ],
                  );
                }
            ); //getImage 함수를 호출해서 갤러리에서 사진 가져오기
          },
          child: Text("선택 갤러리"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xffFFE4B5),
            foregroundColor: Colors.black,
          ),
          onPressed: () async {
            await availableCameras().then((value) => Navigator.push(context,
                MaterialPageRoute(builder: (_) => Camera_CustomPage(cameras: value))));
          },
          child: Text("다른 카메라"),
        ),
      ],
    );
  }
  // void _upload(File file) async {
  //   String fileName = file.path.split('/').last;
  //
  //   FormData data = FormData.fromMap({
  //     "file": await MultipartFile.fromFile(
  //       file.path,
  //       filename: fileName,
  //     ),
  //   });
  //   Dio dio = Dio();
  //   try{
  //     dio.options.contentType = 'multipart/form-data';
  //     dio.options.maxRedirects.isFinite;
  //
  //     dio.options.headers = {
  //       "Content-Type": "application/json",
  //       "Accept": "application/json"
  //     };
  //     dio.post('http://127.0.0.1:3000',data: data).then((response) => print(response)).catchError((error) => print(error));
  //   } catch (e) {
  //     print(e);
  //   }
  // }




}