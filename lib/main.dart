import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:example/router/routes_module.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:uni_links/uni_links.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  uriLinkStream.listen((Uri? uri) {
    log("uri: $uri");
    print(uri);
  }, onError: (Object err){
    log("err: $err");
  });
  runApp(
      ModularApp(module: RoutesModule(), child: const MyApp())
  );
}

class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}

class MyApp extends StatelessWidget {
  bool get isAndroid => foundation.defaultTargetPlatform == foundation.TargetPlatform.android;

  const MyApp({super.key});

  @override
  void initState() {
    initDeepLinks();
  }

  Future<void> initDeepLinks() async {
    // 딥링크 이벤트 수신을 위한 리스너 등록
    getLinksStream().listen((String? link) {
      if (link != null && link.isNotEmpty) {
        // 딥링크가 수신되었을 때 처리할 로직 추가
        Modular.to.pushNamed(RouteMap.SPLASH.page);
        print("Received deep link: $link");
        // 여기에서 딥링크를 파싱하고 필요한 작업을 수행하세요.
      }
    }, onError: (error) {
      print("Error receiving deep link: $error");
    });

    // 앱이 최초 실행될 때 기존 딥링크를 처리하려면 다음과 같이 수행할 수 있습니다.
    // String? initialLink = await getInitialLink();
    // if (initialLink != null && initialLink.isNotEmpty) {
    //   print("Initial deep link: $initialLink");
    //   // 여기에서 초기 딥링크를 처리하세요.
    // }
  }

  @override
  Widget build(BuildContext context) {
    if (this.isAndroid){
      return MaterialApp(
        // debugShowMaterialGrid: false,
        // scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
          title: 'Flutter Demo',
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('ko', 'KR'),
          ],
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          )
      ).modular();
    } else {
      return CupertinoApp(
          title: 'Flutter Demo',
          localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
          Locale('ko', 'KR'),
          ],
          debugShowCheckedModeBanner: false,
      ).modular();
    }
  }
}