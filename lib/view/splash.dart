import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:uni_links/uni_links.dart';

import '../dialog/alert.dart';
import '../router/routes_module.dart';
import 'camera_custom.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}
class _SplashPageState extends State<SplashPage> {
  StreamSubscription? connection;
  bool isoffline = false;
  late CameraController _cameraController;


  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();


  }

  void initCamera() async {
    camerasList = await availableCameras();
    _cameraController = CameraController(camerasList![0], ResolutionPreset.medium);
    await _cameraController.initialize();
    if (mounted) {
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkConnectionStatus(),
      builder: (context, snapshot) {
        if(snapshot.data == ConnectivityResult.wifi || snapshot.data == ConnectivityResult.mobile){
          Timer(Duration(seconds: 3), () async {
            linkStream.listen((event) {
              print('데이터확인');
              print(event);
            });
            await availableCameras().then((value) => Navigator.push(context,
                MaterialPageRoute(builder: (_) => Camera_CustomPage(cameras: value))));
          });
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              color: Color(0xffFFE4B5),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('AI', style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              color: Color(0xffFFE4B5),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CustomAlert("인터넷 연결을 확인 해주세요", "확인"),
                  // CustomAlert("오프라인으로 진행하시겠습니까?", "확인", onTap: () => Modular.to.pushNamed(RouteMap.HOME.page)),
                ],
              ),
            ),
          );
          // return
        }
      },
    );
  }
}

Future checkConnectionStatus() async {
  var result = await (Connectivity().checkConnectivity());
  if (result == ConnectivityResult.none) {
    throw new SocketException("인터넷 연결 상태를 확인해 주세요.");
  }
  return result;  // wifi, mobile
}