import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:wakelock/wakelock.dart';
import 'ApiUtils/AuthUtils.dart';
import 'Screens/AuthScreens/sign_in_tabs_handle.dart';
import 'dashboard/BottomSheet/BottomSheet.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('token');
  }

  getPermission() async {
    await [
      Permission.location,
      Permission.storage,
      Permission.camera,
      Permission.manageExternalStorage,
      Permission.photos,
      Permission.mediaLibrary,
      Permission.accessMediaLocation,
    ].request();
   await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
  permission() async {
    // await FirebaseMessaging.instance.requestPermission(
    //   announcement: true,
    //   carPlay: true,
    //   criticalAlert: true,
    // );
    //Permission for camera...
    final cameraStatus = await Permission.camera.status;
    if (cameraStatus == PermissionStatus.denied) {
      await Permission.camera.request();
    } else if (cameraStatus == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }

    //Permission for storage...
    final storageStatus = await Permission.storage.status;
    if (storageStatus == PermissionStatus.denied) {
      await Permission.storage.request();
    } else if (storageStatus == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }

    //Permission for microphone...
    final microphoneStatus = await Permission.microphone.status;
    if (microphoneStatus == PermissionStatus.denied) {
      await Permission.microphone.request();
    } else if (microphoneStatus == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    getPermission();
    permission();
    Future.delayed(Duration(seconds: 3), () {
      getToken().then((token) {
        if (token != null) {
          Get.offAll(() => BottomSheetCustom());
        } else {
          Get.offAll(() => SignInTabsHandle());
        }
      });
    });
    Wakelock.enable();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xff5FFEBB),
        body: Center(
          child: Image.asset(
            'assets/images/logo.png',
            //fit: BoxFit.cover,
            height: 15.0.h,
            width: 15.0.h,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
