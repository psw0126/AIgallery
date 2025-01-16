import 'package:camera/camera.dart';
import 'package:example/screens/home_page.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../view/aicamera.dart';
import '../view/camera.dart';
import '../view/splash.dart';
import '../view/webview.dart';

List<CameraDescription>? camerasList;
late CameraController _cameraController;

class RoutesModule extends Module {
  @override
  List<ModularRoute> routes = [
    ModuleRoute('/', module: BasicRouteModule(), transition: TransitionType.noTransition),
  ];

}


class BasicRouteModule extends Module {
  @override
  final List<ModularRoute>  routes = [
    ChildRoute(RouteMap.SPLASH.page, child: (_, args) => SplashPage()),
    ChildRoute(RouteMap.CAMERA.page, child: (_, args) => CameraPage(cameras: [],)),
    ChildRoute(RouteMap.AICAMERA.page, child: (_, args) => AicameraPage()),
    ChildRoute(RouteMap.WEB_BROWSER.page, child: (_, args) => WebBrowserCommunityPage(args: args.data)),
    ChildRoute(RouteMap.REELS.page, child: (_, args) => ReelsPage()),
  ];
}

enum RouteMap {
  SPLASH,
  CAMERA,
  AICAMERA,
  WEB_BROWSER,
  REELS
}

extension RouteMapExtension on RouteMap {
  String get page {
    switch (this) {
    case RouteMap.SPLASH:
      return '/';
    case RouteMap.CAMERA:
      return '/camera';
    case RouteMap.AICAMERA:
      return '/aicamera';
    case RouteMap.WEB_BROWSER:
      return '/web';
    case RouteMap.REELS:
      return'/reels';
    }
  }
}
