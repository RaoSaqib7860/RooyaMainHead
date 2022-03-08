import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crop/crop.dart';
import 'package:flutter/material.dart';
import 'package:image_cropping/image_cropping.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rooya_app/utils/SizedConfig.dart';
import 'package:rooya_app/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import 'package:uri_to_file/uri_to_file.dart';

class CropImageClass extends StatefulWidget {
  final String? path;
  final Function(String)? imageFile;

  const CropImageClass({Key? key, this.path, this.imageFile}) : super(key: key);

  @override
  _CropImageClassState createState() => _CropImageClassState();
}

class _CropImageClassState extends State<CropImageClass> {
  final controller = CropController(aspectRatio: 1000 / 667.0);
  double _rotation = 0;
  BoxShape shape = BoxShape.rectangle;

  void _cropImage() async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cropped = await controller.crop(pixelRatio: pixelRatio);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text('Crop Result'),
            centerTitle: true,
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () async {
                    final status = await Permission.storage.request();
                    if (status == PermissionStatus.granted) {
                      await _saveScreenShot(cropped);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Saved to gallery.'),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          body: Center(
            child: RawImage(
              image: cropped,
            ),
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: height,
          width: width,
          color: Colors.black,
          padding: EdgeInsets.all(8),
          child: Crop(
            onChanged: (decomposition) {
              if (_rotation != decomposition.rotation) {
                setState(() {
                  _rotation = ((decomposition.rotation + 180) % 360) - 180;
                });
              }
              print(
                  "Scale : ${decomposition.scale}, Rotation: ${decomposition.rotation}, translation: ${decomposition.translation}");
            },
            controller: controller,
            shape: shape,
            child: Image.file(
              File('${widget.path}'),
              fit: BoxFit.cover,
            ),
            foreground: IgnorePointer(
              child: Container(
                alignment: Alignment.bottomRight,
                child: Text(
                  '',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            helper: shape == BoxShape.rectangle
                ? Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  )
                : null,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.undo,
                    color: Colors.white,
                  ),
                  tooltip: 'Undo',
                  onPressed: () {
                    controller.rotation = 0;
                    controller.scale = 1;
                    controller.offset = Offset.zero;
                    setState(() {
                      _rotation = 0;
                    });
                  },
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData.fromPrimaryColors(
                        primaryColor: primaryColor,
                        primaryColorDark: primaryColor,
                        primaryColorLight: primaryColor,
                        valueIndicatorTextStyle:
                            TextStyle(fontSize: 14, color: Colors.white)),
                    child: Slider(
                      divisions: 360,
                      value: _rotation,
                      min: -180,
                      max: 180,
                      label: '$_rotation°',
                      onChanged: (n) {
                        setState(() {
                          _rotation = n.roundToDouble();
                          controller.rotation = _rotation;
                        });
                      },
                    ),
                  ),
                ),
                PopupMenuButton<BoxShape>(
                  icon: Icon(
                    Icons.crop_free,
                    color: Colors.white,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text("Box"),
                      value: BoxShape.rectangle,
                    ),
                    PopupMenuItem(
                      child: Text("Oval"),
                      value: BoxShape.circle,
                    ),
                  ],
                  tooltip: 'Crop Shape',
                  onSelected: (x) {
                    setState(() {
                      shape = x;
                    });
                  },
                ),
                PopupMenuButton<double>(
                  icon: Icon(
                    Icons.aspect_ratio,
                    color: Colors.white,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text("Original"),
                      value: 1000 / 667.0,
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      child: Text("16:9"),
                      value: 16.0 / 9.0,
                    ),
                    PopupMenuItem(
                      child: Text("4:3"),
                      value: 4.0 / 3.0,
                    ),
                    PopupMenuItem(
                      child: Text("1:1"),
                      value: 1,
                    ),
                    PopupMenuItem(
                      child: Text("3:4"),
                      value: 3.0 / 4.0,
                    ),
                    PopupMenuItem(
                      child: Text("9:16"),
                      value: 9.0 / 16.0,
                    ),
                  ],
                  tooltip: 'Aspect Ratio',
                  onSelected: (x) {
                    controller.aspectRatio = x;
                    setState(() {});
                  },
                ),
                InkWell(
                  onTap: () async {
                    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
                    final cropped =
                        await controller.crop(pixelRatio: pixelRatio);
                    final status = await Permission.storage.request();
                    if (status == PermissionStatus.granted) {
                      await _saveScreenShot(cropped);
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    margin: EdgeInsets.only(right: width * 0.030),
                    child: Center(
                      child: Text(
                        'Done',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: primaryColor),
                  ),
                )
              ],
            ),
          ),
        ),
        // Align(
        //   alignment: Alignment.bottomRight,
        //   child: InkWell(
        //     onTap: () async {
        //       final pixelRatio = MediaQuery.of(context).devicePixelRatio;
        //       final cropped = await controller.crop(pixelRatio: pixelRatio);
        //       final status = await Permission.storage.request();
        //       if (status == PermissionStatus.granted) {
        //         await _saveScreenShot(cropped);
        //       }
        //     },
        //     child: Container(
        //       height: 40,
        //       width: 40,
        //       margin: EdgeInsets.only(bottom: 15, right: width * 0.030),
        //       child: Center(
        //         child: Text(
        //           'Done',
        //           style: TextStyle(color: Colors.white, fontSize: 12),
        //         ),
        //       ),
        //       padding: EdgeInsets.all(5),
        //       decoration:
        //           BoxDecoration(shape: BoxShape.circle, color: primaryColor),
        //     ),
        //   ),
        // )
      ],
    );
  }

  Future _saveScreenShot(ui.Image img) async {
    var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    var buffer = byteData!.buffer.asUint8List();
    final result =
        await ImageGallerySaver.saveImage(buffer, isReturnImagePathOfIOS: true);
    print('saveScreenShot  = $result');
    File file = await toFile(result['filePath']);
    widget.imageFile!(file.path);
  }
}

void openImagePicker({File? filePath, BuildContext? context,Function(String)? donePath}) async {
  Uint8List? imageBytes;
  imageBytes = await filePath!.readAsBytes();
  String path = await getFilePath();
  if (imageBytes != null) {
    ImageCropping.cropImage(
      context: context!,
      imageBytes: imageBytes,
      onImageDoneListener: (data) async{
        File file = await File('$path').writeAsBytes(data);
        donePath!.call('${file.path}');
        // setState(
        //   () {
        //     imageBytes = data;
        //   },
        // );
      },
      // onImageStartLoading: showLoader,
      // onImageEndLoading: hideLoader,
      selectedImageRatio: ImageRatio.RATIO_1_1,
      visibleOtherAspectRatios: true,
      squareBorderWidth: 2,
      // squareCircleColor: AppColors.red,
      // defaultTextColor: AppColors.black,
      // selectedTextColor: AppColors.orange,
      // colorForWhiteSpace: AppColors.white,
    );
  }
}

var rng = Random();
Future<String> getFilePath() async {
  Directory storageDirectory = await getApplicationDocumentsDirectory();
  String sdPath = storageDirectory.path + "/images";
  var d = Directory(sdPath);
  if (!d.existsSync()) {
    d.createSync(recursive: true);
  }
  return sdPath + "/test_${rng.nextInt(100)}.png";
}


