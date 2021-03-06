import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:photofilters/filters/preset_filters.dart';
import 'package:photofilters/widgets/photo_filter.dart';
import 'package:rooya_app/AllCreatePosts/CreatePost/create_post.dart';
import 'package:rooya_app/GlobalClass/SpiKitGlobal.dart';
import 'package:rooya_app/GlobalClass/TextFieldsCustom.dart';
import 'package:image/image.dart' as imageLib;
import 'package:rooya_app/VideoEditor/VideoEditor.dart';
import 'package:rooya_app/dashboard/BottomSheet/BottomSheet.dart';
import 'package:rooya_app/story/StoryImageUpload.dart';
import 'package:rooya_app/story/uploadStroy.dart';
import 'package:rooya_app/utils/AppFonts.dart';
import 'package:rooya_app/utils/ProgressHUD.dart';
import 'package:rooya_app/utils/ShimmerEffect.dart';
import 'package:rooya_app/utils/SizedConfig.dart';
import 'package:rooya_app/utils/SnackbarCustom.dart';
import 'package:rooya_app/utils/colors.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../main.dart';
import 'ReelCameraController.dart';

bool fromStrory = false;

class CameraExampleHome extends StatefulWidget {
  final bool? fromStroy;

  const CameraExampleHome({Key? key, this.fromStroy}) : super(key: key);

  @override
  _CameraExampleHomeState createState() {
    return _CameraExampleHomeState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
    default:
      throw ArgumentError('Unknown lens direction');
  }
}

void logError(String code, String? message) {
  if (message != null) {
    print('Error: $code\nError Message: $message');
  } else {
    print('Error: $code');
  }
}

class _CameraExampleHomeState extends State<CameraExampleHome>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  late AnimationController _flashModeControlRowAnimationController;
  late Animation<double> _flashModeControlRowAnimation;
  late AnimationController _exposureModeControlRowAnimationController;
  late Animation<double> _exposureModeControlRowAnimation;
  late AnimationController _focusModeControlRowAnimationController;
  late Animation<double> _focusModeControlRowAnimation;
  double _minAvailableZoom = 0.0;
  double _maxAvailableZoom = 0.0;
  double _currentScale = 0.0;
  double _baseScale = 0.0;
  bool isfirstCam = true;
  int cam = 0;
  bool isrecordingStart = false;
  Timer? _timer;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  //timer
  Stopwatch watch = Stopwatch();
  Timer? timer;
  bool startStop = false;

  String elapsedTime = '';

  updateTime(Timer timer) {
    if (watch.isRunning) {
      setState(() {
        print("startstop Inside=$startStop");
        elapsedTime = transformMilliSeconds(watch.elapsedMilliseconds);
      });
    }
  }

  startOrStop() {
    if (startStop) {
      startWatch();
    } else {
      stopWatch();
    }
  }

  startWatch() {
    setState(() {
      startStop = false;
      watch.start();
      timer = Timer.periodic(Duration(milliseconds: 100), updateTime);
    });
  }

  stopWatch() {
    setState(() {
      startStop = true;
      watch.stop();
      setTime();
    });
  }

  bool onVideoMode = false;

  setTime() {
    var timeSoFar = watch.elapsedMilliseconds;
    setState(() {
      elapsedTime = transformMilliSeconds(timeSoFar);
    });
  }

  transformMilliSeconds(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  //
  final reelcontroller = Get.put(ReelCameraController());

  @override
  void initState() {
    super.initState();
    fromStrory = widget.fromStroy!;
    ambiguate(WidgetsBinding.instance)?.addObserver(this);

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimation = CurvedAnimation(
      parent: _focusModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    onCameraint();
  }

  @override
  void dispose() {
    ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    controller!.dispose();
    watch.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool istorchOn = false;

  @override
  Widget build(BuildContext context) {
    var height = Get.height;
    var width = Get.width;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: [
            Container(
              height: height,
              width: width,
              child: Column(
                children: <Widget>[
                  Container(
                    height: height * 0.070,
                    width: width,
                    padding: EdgeInsets.symmetric(horizontal: width * 0.030),
                    decoration: BoxDecoration(color: Colors.black),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              child: Icon(
                                CupertinoIcons.back,
                                size: 20,
                                color: Colors.white,
                              ),
                              onTap: () {
                                Get.back();
                              },
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            InkWell(
                              onTap: () {
                                if (!istorchOn) {
                                  onSetFlashModeButtonPressed(FlashMode.torch);
                                  setState(() {
                                    istorchOn = true;
                                  });
                                } else {
                                  onSetFlashModeButtonPressed(FlashMode.off);
                                  setState(() {
                                    istorchOn = false;
                                  });
                                }
                              },
                              child: Icon(
                                !istorchOn ? Icons.flash_off : Icons.flash_on,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            // SizedBox(
                            //   width: 15,
                            // ),
                            // Icon(
                            //   Icons.settings,
                            //   size: 20,
                            //   color: Colors.white,
                            // ),
                          ],
                        ),
                        // Container(
                        //   height: height * 0.040,
                        //   width: width * 0.2,
                        //   child: Center(
                        //     child: Text(
                        //       'Preview',
                        //       style:
                        //           TextStyle(color: Colors.white, fontSize: 12),
                        //     ),
                        //   ),
                        //   decoration: BoxDecoration(
                        //       color: appThemes,
                        //       borderRadius: BorderRadius.circular(30)),
                        // )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          child: _cameraPreviewWidget(),
                          decoration: BoxDecoration(color: Colors.black),
                          height: double.infinity,
                          width: double.infinity,
                        ),
                        !isrecordingStart
                            ? SizedBox()
                            : Align(
                                child: Container(
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: appThemes,
                                      shape: BoxShape.circle),
                                  child: IconButton(
                                    icon: controller != null &&
                                            controller!.value.isRecordingPaused
                                        ? Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                          )
                                        : Icon(
                                            Icons.pause,
                                            color: Colors.white,
                                          ),
                                    color: Colors.blue,
                                    onPressed: controller != null &&
                                            controller!.value.isInitialized &&
                                            controller!.value.isRecordingVideo
                                        ? (controller!.value.isRecordingPaused)
                                            ? onResumeButtonPressed
                                            : onPauseButtonPressed
                                        : null,
                                  ),
                                ),
                                alignment: Alignment.bottomLeft,
                              ),
                      ],
                    ),
                  ),
                  Container(
                    height: height * 0.150,
                    width: width,
                    padding: EdgeInsets.symmetric(horizontal: width * 0.030),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          child: SvgPicture.asset(
                            'assets/svg/gallary.svg',
                          ),
                          onTap: () async {
                            try {
                              final FilePickerResult? pickedFile;
                              pickedFile = await FilePicker.platform.pickFiles(
                                type: FileType.media,
                                allowMultiple: false,
                              );
                              print('pickedFile = ${pickedFile!.paths}');
                              ambiguate(WidgetsBinding.instance)
                                  ?.removeObserver(this);
                              _flashModeControlRowAnimationController.dispose();
                              _exposureModeControlRowAnimationController
                                  .dispose();
                              String path = '${pickedFile.paths[0]}';
                              print('path of video is = $path');
                              if (path.contains('mp4')) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (c) => VideoEditor(
                                              file: File('$path'),
                                            )));
                              } else {
                                uploadImage(path, context);
                              }
                            } catch (e) {}
                          },
                        ),
                        Listener(
                          onPointerDown: (_) => _pointers++,
                          onPointerUp: (_) => _pointers--,
                          child: InkWell(
                            onTap: () {
                              if (!controller!.value.isRecordingVideo) {
                                ambiguate(WidgetsBinding.instance)
                                    ?.removeObserver(this);
                                _flashModeControlRowAnimationController
                                    .dispose();
                                _exposureModeControlRowAnimationController
                                    .dispose();
                                onTakePictureButtonPressed(context);
                              } else {
                                doneVideo(context);
                              }
                            },
                            onLongPress: () {
                              onVideoMode = true;
                              setState(() {});
                              controller != null &&
                                      controller!.value.isInitialized &&
                                      !controller!.value.isRecordingVideo
                                  ? onVideoRecordButtonPressed()
                                  : doneVideo(context);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                onVideoMode
                                    ? Container(
                                        height: height * 0.090,
                                        width: width * 0.180,
                                        child: !isrecordingStart
                                            ? Padding(
                                                padding: EdgeInsets.all(10.0),
                                                child: SvgPicture.asset(
                                                    'assets/svg/VideoIcon.svg'),
                                              )
                                            : Container(
                                                height: double.infinity,
                                                width: double.infinity,
                                                child: Center(
                                                  child: Text(
                                                    '$elapsedTime',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12),
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                    color: appThemes,
                                                    shape: BoxShape.circle),
                                              ),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle),
                                      )
                                    : Container(
                                        height: height * 0.090,
                                        width: width * 0.180,
                                        child: Icon(
                                          Icons.camera_enhance_sharp,
                                          color: appThemes,
                                          size: 40,
                                        ),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle),
                                      ),
                                SizedBox(
                                  height: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (onVideoMode) {
                                        onVideoMode = false;
                                      } else {
                                        onVideoMode = true;
                                      }
                                    });
                                  },
                                  child: Text(
                                    !onVideoMode
                                        ? 'Long press to create video'
                                        : '',
                                    style: TextStyle(
                                        fontFamily: AppFonts.segoeui,
                                        fontSize: 12,
                                        color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          child: SvgPicture.asset(
                            'assets/svg/camSwitch.svg',
                          ),
                          onTap: () {
                            setState(() {
                              if (isfirstCam) {
                                isfirstCam = false;
                              }
                            });
                            Future.delayed(Duration(milliseconds: 100), () {
                              onCameraint();
                            });
                          },
                        )
                      ],
                    ),
                    decoration: BoxDecoration(color: Colors.black),
                  ),
                  // _captureControlRowWidget(),
                  // _modeControlRowWidget(),
                  // Padding(
                  //   padding: const EdgeInsets.all(5.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     children: <Widget>[
                  //       _cameraTogglesRowWidget(),
                  //       // _thumbnailWidget(),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
            // Align(
            //   alignment: Alignment.bottomRight,
            //   child: Container(
            //     height: height * 0.380,
            //     width: width * 0.130,
            //     padding: EdgeInsets.symmetric(vertical: height * 0.030),
            //     child: Column(
            //       children: [
            //         SvgPicture.asset('assets/svg/sound.svg'),
            //         SvgPicture.asset('assets/svg/speed.svg'),
            //         SvgPicture.asset('assets/svg/speedX.svg'),
            //         SvgPicture.asset('assets/svg/filter.svg'),
            //         SvgPicture.asset('assets/svg/magic.svg'),
            //         SvgPicture.asset('assets/svg/time.svg'),
            //       ],
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //     ),
            //     margin: EdgeInsets.only(
            //         bottom: height * 0.150, right: width * 0.030),
            //     decoration: BoxDecoration(
            //         color: Colors.black.withOpacity(0.5),
            //         borderRadius: BorderRadius.circular(30)),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return spinKitGlobal(size: 50);
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller!,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onTapDown: (details) => onViewFinderTap(details, constraints),
            );
          }),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }
    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    final VideoPlayerController? localVideoController = videoController;

    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            localVideoController == null && imageFile == null
                ? Container()
                : SizedBox(
                    child: (localVideoController == null)
                        ? Image.file(File(imageFile!.path))
                        : Container(
                            child: Center(
                              child: AspectRatio(
                                  aspectRatio:
                                      localVideoController.value.size != null
                                          ? localVideoController
                                              .value.aspectRatio
                                          : 1.0,
                                  child: VideoPlayer(localVideoController)),
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.pink)),
                          ),
                    width: 64.0,
                    height: 64.0,
                  ),
          ],
        ),
      ),
    );
  }

  /// Display a bar with buttons to change the flash and exposure modes
  Widget _modeControlRowWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.flash_on),
              color: Colors.blue,
              onPressed: controller != null ? onFlashModeButtonPressed : null,
            ),
            IconButton(
              icon: Icon(Icons.exposure),
              color: Colors.blue,
              onPressed:
                  controller != null ? onExposureModeButtonPressed : null,
            ),
            IconButton(
              icon: Icon(Icons.filter_center_focus),
              color: Colors.blue,
              onPressed: controller != null ? onFocusModeButtonPressed : null,
            ),
            IconButton(
              icon: Icon(enableAudio ? Icons.volume_up : Icons.volume_mute),
              color: Colors.blue,
              onPressed: controller != null ? onAudioModeButtonPressed : null,
            ),
            IconButton(
              icon: Icon(controller?.value.isCaptureOrientationLocked ?? false
                  ? Icons.screen_lock_rotation
                  : Icons.screen_rotation),
              color: Colors.blue,
              onPressed: controller != null
                  ? onCaptureOrientationLockButtonPressed
                  : null,
            ),
          ],
        ),
        _flashModeControlRowWidget(),
        _exposureModeControlRowWidget(),
        _focusModeControlRowWidget(),
      ],
    );
  }

  Widget _flashModeControlRowWidget() {
    return SizeTransition(
      sizeFactor: _flashModeControlRowAnimation,
      child: ClipRect(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            IconButton(
              icon: Icon(Icons.flash_off),
              color: controller?.value.flashMode == FlashMode.off
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.off)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.flash_auto),
              color: controller?.value.flashMode == FlashMode.auto
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.auto)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.flash_on),
              color: controller?.value.flashMode == FlashMode.always
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.always)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.highlight),
              color: controller?.value.flashMode == FlashMode.torch
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.torch)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _exposureModeControlRowWidget() {
    final ButtonStyle styleAuto = TextButton.styleFrom(
      primary: controller?.value.exposureMode == ExposureMode.auto
          ? Colors.orange
          : Colors.blue,
    );
    final ButtonStyle styleLocked = TextButton.styleFrom(
      primary: controller?.value.exposureMode == ExposureMode.locked
          ? Colors.orange
          : Colors.blue,
    );

    return SizeTransition(
      sizeFactor: _exposureModeControlRowAnimation,
      child: ClipRect(
        child: Container(
          color: Colors.grey.shade50,
          child: Column(
            children: [
              Center(
                child: Text("Exposure Mode"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextButton(
                    child: Text('AUTO'),
                    style: styleAuto,
                    onPressed: controller != null
                        ? () =>
                            onSetExposureModeButtonPressed(ExposureMode.auto)
                        : null,
                    onLongPress: () {
                      if (controller != null) {
                        controller!.setExposurePoint(null);
                        showInSnackBar('Resetting exposure point');
                      }
                    },
                  ),
                  TextButton(
                    child: Text('LOCKED'),
                    style: styleLocked,
                    onPressed: controller != null
                        ? () =>
                            onSetExposureModeButtonPressed(ExposureMode.locked)
                        : null,
                  ),
                  TextButton(
                    child: Text('RESET OFFSET'),
                    style: styleLocked,
                    onPressed: controller != null
                        ? () => controller!.setExposureOffset(0.0)
                        : null,
                  ),
                ],
              ),
              Center(
                child: Text("Exposure Offset"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(_minAvailableExposureOffset.toString()),
                  Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    label: _currentExposureOffset.toString(),
                    onChanged: _minAvailableExposureOffset ==
                            _maxAvailableExposureOffset
                        ? null
                        : setExposureOffset,
                  ),
                  Text(_maxAvailableExposureOffset.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _focusModeControlRowWidget() {
    final ButtonStyle styleAuto = TextButton.styleFrom(
      primary: controller?.value.focusMode == FocusMode.auto
          ? Colors.orange
          : Colors.blue,
    );
    final ButtonStyle styleLocked = TextButton.styleFrom(
      primary: controller?.value.focusMode == FocusMode.locked
          ? Colors.orange
          : Colors.blue,
    );

    return SizeTransition(
      sizeFactor: _focusModeControlRowAnimation,
      child: ClipRect(
        child: Container(
          color: Colors.grey.shade50,
          child: Column(
            children: [
              Center(
                child: Text("Focus Mode"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextButton(
                    child: Text('AUTO'),
                    style: styleAuto,
                    onPressed: controller != null
                        ? () => onSetFocusModeButtonPressed(FocusMode.auto)
                        : null,
                    onLongPress: () {
                      if (controller != null) controller!.setFocusPoint(null);
                      showInSnackBar('Resetting focus point');
                    },
                  ),
                  TextButton(
                    child: Text('LOCKED'),
                    style: styleLocked,
                    onPressed: controller != null
                        ? () => onSetFocusModeButtonPressed(FocusMode.locked)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    final onChanged = (CameraDescription? description) {
      if (description == null) {
        return;
      }
      onNewCameraSelected(description);
    };

    if (cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in cameras) {
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged:
                  controller != null && controller!.value.isRecordingVideo
                      ? null
                      : onChanged,
            ),
          ),
        );
      }
    }
    return Row(children: toggles);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onCameraint() async {
    if (controller != null) {
      await controller!.dispose();
    }
    int totalCam = cameras.length;
    if (cam + 1 == totalCam) {
      cam = 0;
    } else {
      if (!isfirstCam) {
        cam++;
      }
    }
    final CameraController cameraController = CameraController(
      cameras[cam],
      ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed(BuildContext context) {
    takePicture().then((XFile? file) {
      if (mounted) {
        setState(() {
          imageFile = file;
          videoController?.dispose();
          videoController = null;
        });
        uploadImage(file!.path, context);
        // if (file != null) showInSnackBar('Picture saved to ${file.path}');
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (c) => EditImage(
        //               path: file!.path,
        //             ))).then((value) {
        //   Get.back();
        // });
      }
    });
  }

  uploadImage(String path, BuildContext context) async {
    File imageFile;
    String fileName;
    imageFile = new File(path);
    fileName = basename(imageFile.path);
    var image = imageLib.decodeImage(await imageFile.readAsBytes());
    image = imageLib.copyResize(image!, width: 600);
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new StoryImageUpload(
          title: Text("Rooya Editor"),
          image: image!,
          filters: presetFiltersList,
          filename: fileName,
          imagePath: path,
          loader: Center(
              child: ShimerEffect(
            child: Container(
              color: Colors.blueGrey,
            ),
          )),
          fit: BoxFit.cover,
        ),
      ),
    ).then((value) {
      Get.back();
    });
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
      _exposureModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onExposureModeButtonPressed() {
    if (_exposureModeControlRowAnimationController.value == 1) {
      _exposureModeControlRowAnimationController.reverse();
    } else {
      _exposureModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onFocusModeButtonPressed() {
    if (_focusModeControlRowAnimationController.value == 1) {
      _focusModeControlRowAnimationController.reverse();
    } else {
      _focusModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _exposureModeControlRowAnimationController.reverse();
    }
  }

  void onAudioModeButtonPressed() {
    enableAudio = !enableAudio;
    if (controller != null) {
      onNewCameraSelected(controller!.description);
    }
  }

  void onCaptureOrientationLockButtonPressed() async {
    if (controller != null) {
      final CameraController cameraController = controller!;
      if (cameraController.value.isCaptureOrientationLocked) {
        await cameraController.unlockCaptureOrientation();
        showInSnackBar('Capture orientation unlocked');
      } else {
        await cameraController.lockCaptureOrientation();
        showInSnackBar(
            'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
      }
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {});
  }

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    setExposureMode(mode).then((_) {});
  }

  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {});
  }

  void onVideoRecordButtonPressed() {
    if (!isrecordingStart) {
      startWatch();
      setState(() {
        isrecordingStart = true;
      });
      startVideoRecording().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  void doneVideo(BuildContext context) {
    stopWatch();
    onStopButtonPressed(context);
  }

  void onStopButtonPressed(BuildContext context) {
    stopVideoRecording().then((file) {
      if (mounted) setState(() {});
      if (file != null) {
        videoFile = file;
        _startVideoPlayer(context);
      }
    });
  }

  Future<void> onPausePreviewButtonPressed() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isPreviewPaused) {
      await cameraController.resumePreview();
    } else {
      await cameraController.pausePreview();
    }

    if (mounted) setState(() {});
  }

  void onPauseButtonPressed() {
    stopWatch();
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
    });
  }

  void onResumeButtonPressed() {
    startWatch();
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setExposureMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureOffset(double offset) async {
    if (controller == null) {
      return;
    }

    setState(() {
      _currentExposureOffset = offset;
    });
    try {
      offset = await controller!.setExposureOffset(offset);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFocusMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer(BuildContext context) async {
    if (videoFile == null) {
      return;
    }
    ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => VideoEditor(
                  file: File('${videoFile!.path}'),
                )));
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

class CameraApp extends StatelessWidget {
  final bool? fromStory;

  const CameraApp({Key? key, this.fromStory = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CameraExampleHome(
      fromStroy: fromStory,
    );
  }
}

Future<String> cropImage(String path) async {
  File? croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        title: 'Cropper',
      ));
  if (croppedFile != null) {
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (c) => VideoAppFile(
    //               filePath: croppedFile.path,
    //               spinSize: 50,
    //               isimage: true,
    //             )));
    return croppedFile.path;
  } else {
    return '';
  }
}

Future<String> filterImage(context, String path) async {
  File imageFile;
  String fileName;
  imageFile = new File(path);
  fileName = basename(imageFile.path);
  var image = imageLib.decodeImage(await imageFile.readAsBytes());
  image = imageLib.copyResize(image!, width: 600);
  Map imagefile = await Navigator.push(
    context,
    new MaterialPageRoute(
      builder: (context) => new PhotoFilterSelector(
        title: Text("Rooya Editor"),
        image: image!,
        filters: presetFiltersList,
        filename: fileName,
        loader: Center(
            child: ShimerEffect(
          child: Container(
            color: Colors.blueGrey,
          ),
        )),
        fit: BoxFit.contain,
      ),
    ),
  );
  print('imageFile path is = ${imageFile.path}');
  if (imagefile != null && imagefile.containsKey('image_filtered')) {
    imageFile = imagefile['image_filtered'];
    return imageFile.path;
  } else {
    return '';
  }
}

class EditImage extends StatefulWidget {
  final String? path;

  const EditImage({Key? key, this.path}) : super(key: key);

  @override
  _EditImageState createState() => _EditImageState();
}

class _EditImageState extends State<EditImage> {
  String path = '';

  @override
  void initState() {
    path = widget.path!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (c) => VideoAppFile(
                          filePath: path,
                          spinSize: 50,
                          isimage: true,
                        )));
          },
          backgroundColor: appThemes,
          child: Icon(
            CupertinoIcons.forward,
            color: Colors.white,
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Edit Image',
            style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontFamily: AppFonts.segoeui),
          ),
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(CupertinoIcons.back, color: Colors.black)),
        ),
        body: Column(
          children: [
            SizedBox(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.030),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        String value = await cropImage(path);
                        if (value != '') {
                          setState(() {
                            path = value;
                          });
                        }
                      },
                      child: Container(
                        child: Row(
                          children: [
                            Text(
                              'Cropping',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: AppFonts.segoeui),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.crop,
                              color: Colors.white,
                            )
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                            color: appThemes,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: Offset(3, 3),
                                  blurRadius: 5)
                            ],
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        String value = await filterImage(context, path);
                        print('filter path is = $value');
                        if (value != '') {
                          setState(() {
                            path = value;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: Offset(3, 3),
                                  blurRadius: 5)
                            ],
                            color: appThemes,
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          children: [
                            Text(
                              'Filters',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: AppFonts.segoeui),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.api,
                              color: Colors.white,
                            )
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: Image.file(File(path)))
          ],
        ),
      ),
    );
  }
}

class VideoAppFile extends StatefulWidget {
  final double? spinSize;
  final String? filePath;
  final bool? isimage;

  const VideoAppFile(
      {Key? key, this.spinSize = 40.0, this.filePath, this.isimage = false})
      : super(key: key);

  @override
  _VideoAppFileState createState() => _VideoAppFileState();
}

class _VideoAppFileState extends State<VideoAppFile> {
  VideoPlayerController? _controller;
  bool? initialize = false;

  @override
  void initState() {
    if (!widget.isimage!) {
      print('video path is = ${widget.filePath}');
      super.initState();
      _controller = VideoPlayerController.file(File('${widget.filePath}'))
        ..setLooping(true)
        ..initialize().then((_) {
          _controller!.play();
          setState(() {
            initialize = true;
          });
        });
      streamController.stream.listen((event) {
        if (event == 10.0) {
          _controller!.pause();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (!widget.isimage!) {
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  void deactivate() {
    print('Widget is deactive');
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        return false;
      },
      child: VisibilityDetector(
        key: Key('my-widget-key'),
        onVisibilityChanged: (visibilityInfo) {
          if (!widget.isimage!) {
            var visiblePercentage = visibilityInfo.visibleFraction * 100;
            debugPrint(
                'onVisibilityChanged ${visibilityInfo.key} is ${visiblePercentage}% visible');
            if (visiblePercentage == 0.0) {
              setState(() {
                _controller!.pause();
              });
            }
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: Icon(CupertinoIcons.back),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (fromStrory) {
                newPathis = '';
                if (!widget.isimage!) {
                  Get.to(TrimmerViewforVideo(
                    file: File('${widget.filePath}'),
                    isImage: widget.isimage,
                  ));
                } else {
                  Get.to(TrimmerView(
                    file: File('${widget.filePath}'),
                    isImage: widget.isimage,
                  ));
                }
              } else {
                newPathis = '${widget.filePath}';
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            },
            backgroundColor: appThemes,
            child: Center(
              child: Icon(
                Icons.play_arrow_sharp,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          body: Stack(
            children: [
              !widget.isimage!
                  ? Center(
                      child: _controller!.value.isInitialized
                          ? InkWell(
                              onTap: () {
                                setState(() {
                                  _controller!.value.isPlaying
                                      ? _controller!.pause()
                                      : _controller!.play();
                                });
                              },
                              child: AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              ),
                            )
                          : Container(
                              child: spinKitGlobal(size: widget.spinSize),
                              decoration: BoxDecoration(color: Colors.black),
                            ),
                    )
                  : Center(child: Image.file(File(widget.filePath!))),
              !widget.isimage!
                  ? _controller!.value.isPlaying
                      ? SizedBox()
                      : !initialize!
                          ? SizedBox()
                          : InkWell(
                              onTap: () {
                                setState(() {
                                  _controller!.play();
                                });
                              },
                              child: Center(
                                child: Icon(
                                  Icons.play_arrow,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            )
                  : SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}

class TrimmerView extends StatefulWidget {
  final File? file;
  final bool? isImage;

  TrimmerView({this.file, this.isImage});

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  TextEditingController controller = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      inAsyncCall: isLoading,
      opacity: 0.5,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            List listofurl = [];
            String value = await createStory(widget.file!.path);
            listofurl.add(value);
            print('listofurl= $listofurl');
            await uploadStoryData(text: controller.text, listOfUrl: listofurl);
            setState(() {
              isLoading = false;
            });
            snackBarSuccess('Story post successfully');
            Future.delayed(Duration(seconds: 2), () {
              Get.offAll(() => BottomSheetCustom());
            });
          },
          backgroundColor: appThemes,
          child: Center(
            child: Text(
              'Post',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: Builder(
          builder: (context) => Center(
            child: Container(
              width: Get.width,
              height: Get.height,
              padding: EdgeInsets.symmetric(horizontal: Get.width * 0.030),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: Get.height * 0.010,
                    ),
                    TextFieldsProfile(
                      controller: controller,
                      hint: 'Write your comment'.tr,
                      uperhint: 'Write your comment'.tr,
                      width: Get.width,
                    ),
                    SizedBox(
                      height: Get.height * 0.030,
                    ),
                    Container(
                      child: Image.file(
                        widget.file!,
                        fit: BoxFit.cover,
                      ),
                      height: Get.height * 0.5,
                      width: Get.width,
                    ),
                    SizedBox(
                      height: Get.height * 0.050,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TrimmerViewforVideo extends StatefulWidget {
  final File? file;
  final bool? isImage;

  TrimmerViewforVideo({this.file, this.isImage});

  @override
  _TrimmerViewforVideoState createState() => _TrimmerViewforVideoState();
}

class _TrimmerViewforVideoState extends State<TrimmerViewforVideo> {
  // final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  // Future<String?> _saveVideo() async {
  //   setState(() {
  //     _progressVisibility = true;
  //   });
  //
  //   String? _value;
  //
  //   await _trimmer
  //       .saveTrimmedVideo(startValue: _startValue, endValue: _endValue)
  //       .then((value) {
  //     setState(() {
  //       _progressVisibility = false;
  //       _value = value;
  //     });
  //   });
  //
  //   return _value;
  // }
  //
  // void _loadVideo() {
  //   _trimmer.loadVideo(videoFile: widget.file!);
  // }

  @override
  void initState() {
    super.initState();
    // _loadVideo();
  }

  TextEditingController controller = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      inAsyncCall: isLoading,
      opacity: 0.5,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // _saveVideo().then((outputPath) async {
            //   setState(() {
            //     isLoading = true;
            //   });
            //   List listofurl = [];
            //   String value = await createStory(outputPath!);
            //   listofurl.add(value);
            //   print('listofurl= $listofurl');
            //   await uploadStoryData(
            //       text: controller.text, listOfUrl: listofurl);
            //   setState(() {
            //     isLoading = false;
            //   });
            //   snackBarSuccess('Story post successfully');
            //   Future.delayed(Duration(seconds: 2), () {
            //     Get.offAll(() => BottomSheetCustom());
            //   });
            // });
          },
          backgroundColor: appThemes,
          child: Center(
            child: Text(
              'Post',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: Builder(
          builder: (context) => Center(
              // child: Container(
              //   width: Get.width,
              //   height: Get.height,
              //   padding: EdgeInsets.symmetric(horizontal: Get.width * 0.030),
              //   child: SingleChildScrollView(
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: <Widget>[
              //         Visibility(
              //           visible: _progressVisibility,
              //           child: LinearProgressIndicator(
              //             backgroundColor: appThemes,
              //           ),
              //         ),
              //         SizedBox(
              //           height: Get.height * 0.010,
              //         ),
              //         TextFieldsProfile(
              //           controller: controller,
              //           hint: 'Write your comment'.tr,
              //           uperhint: 'Write your comment'.tr,
              //           width: Get.width,
              //         ),
              //         SizedBox(
              //           height: Get.height * 0.030,
              //         ),
              //         Container(
              //           height: Get.height * 0.5,
              //           width: Get.width,
              //           child: VideoViewer(
              //              // trimmer: _trimmer
              //           ),
              //         ),
              //         Center(
              //           child: TrimEditor(
              //             //trimmer: _trimmer,
              //             viewerHeight: 50.0,
              //             circlePaintColor: appThemes,
              //             scrubberPaintColor: appThemes,
              //             borderPaintColor: appThemes,
              //             viewerWidth: MediaQuery.of(context).size.width -
              //                 Get.width * 0.030,
              //             maxVideoLength: Duration(seconds: 10),
              //             onChangeStart: (value) {
              //               _startValue = value;
              //             },
              //             onChangeEnd: (value) {
              //               _endValue = value;
              //             },
              //             onChangePlaybackState: (value) {
              //               setState(() {
              //                 _isPlaying = value;
              //               });
              //             },
              //           ),
              //         ),
              //         SizedBox(
              //           height: Get.height * 0.030,
              //         ),
              //         Container(
              //           decoration: BoxDecoration(
              //               color: appThemes, shape: BoxShape.circle),
              //           child: TextButton(
              //             child: _isPlaying
              //                 ? Icon(
              //                     Icons.pause,
              //                     size: 40.0,
              //                     color: Colors.white,
              //                   )
              //                 : Icon(
              //                     Icons.play_arrow,
              //                     size: 40.0,
              //                     color: Colors.white,
              //                   ),
              //             onPressed: () async {
              //               bool playbackState =
              //                   await _trimmer.videPlaybackControl(
              //                 startValue: _startValue,
              //                 endValue: _endValue,
              //               );
              //               setState(() {
              //                 _isPlaying = playbackState;
              //               });
              //             },
              //           ),
              //         ),
              //         SizedBox(
              //           height: Get.height * 0.050,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              ),
        ),
      ),
    );
  }
}
