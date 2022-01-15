import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rooya_app/splash.dart';
import 'package:rooya_app/src/routes.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import 'package:wakelock/wakelock.dart';
import 'Screens/Reel/ReelCamera/ReelCamera.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

RouteObserver<PageRoute> routeObservers = RouteObserver<PageRoute>();

bool isActiveFirstTab = true;
StreamController<double> streamController =
    StreamController<double>.broadcast();

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
List<CameraDescription> cameras = [];

T? ambiguate<T>(T? value) => value;

void main() async {
  // Fetch the available cameras before initializing the app.
  await GetStorage.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      //return LayoutBuilder
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ROOYA',
          onGenerateRoute: RouteGenerator.generateRoute,
          defaultTransition: Transition.cupertino,
          //transitionDuration: Duration(milliseconds: 700),
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            primarySwatch: Colors.deepPurple,
            accentColor: Colors.deepPurpleAccent,
          ),
          home: Splash(),
          // home: SignInTabsHandle(),
        );
      },
    );
  }
}
