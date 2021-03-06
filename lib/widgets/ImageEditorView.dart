import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rooya_app/utils/SizedConfig.dart';
import 'package:rooya_app/utils/colors.dart';
import 'package:screenshot/screenshot.dart';
import 'package:stickereditor/constants_value.dart';
import 'package:stickereditor/stickereditor.dart';

class StickerEditingView extends StatefulWidget {
  final List<String> fonts;
  Function(String)? imageFile;
  List<Color>? palletColor;

  List<String>? assetList;

  bool isnetwork;

  String imgUrl;

  double? height;

  double? width;

  StickerEditingView(
      {Key? key,
      required this.fonts,
      this.palletColor,
      this.imageFile,
      this.height,
      this.width,
      required this.isnetwork,
      required this.imgUrl,
      required this.assetList})
      : super(key: key);

  @override
  _StickerEditingViewState createState() => _StickerEditingViewState();
}

class _StickerEditingViewState extends State<StickerEditingView> {
  ScreenshotController screenshotController = ScreenshotController();
  String fileName = '';
  String imagePath = '';
  File? file;

  // offset
  double x = 120.0;
  double y = 160.0;
  double x1 = 100.0;
  double y1 = 50.0;

  // selected text perameter
  double selectedFontSize = 18;
  TextStyle selectedTextstyle =
      const TextStyle(color: Colors.black, fontSize: 18, fontFamily: "Lato");
  String selectedFont = "Lato";
  TextAlign selectedtextAlign = TextAlign.left;
  int selectedTextIndex = -1;
  String selectedtextToShare = "Happy ${weekDays[today - 1]}!";

  // new String and Image List
  RxList<TextModel> newStringList = <TextModel>[].obs;
  RxList<PictureModel> newimageList = <PictureModel>[].obs;

  // genearting Image
  bool showProgressOnGenerate = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Obx(
        () => Stack(
          children: <Widget>[
            Positioned(
              child: Screenshot(
                controller: screenshotController,
                child: SizedBox(
                  height: widget.height ?? height * .40,
                  width: widget.width ?? width * .78,
                  child: Stack(
                    children: [
                      widget.isnetwork
                          ? Image.file(
                              File('${widget.imgUrl}'),
                              height: widget.height ?? height * .40,
                              width: widget.width ?? width * .78,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              widget.imgUrl,
                              height: widget.height ?? height * .40,
                              width: widget.width ?? width * .78,
                              fit: BoxFit.cover,
                            ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            for (var element in newStringList) {
                              element.isSelected = false;
                            }
                            for (var e in newimageList) {
                              e.isSelected = false;
                            }
                          });
                        },
                      ),
                      ...newStringList.map((v) {
                        return TextEditingBox(
                            isSelected: v.isSelected,
                            onTap: () {
                              if (!v.isSelected) {
                                setState(() {
                                  for (var element in newStringList) {
                                    element.isSelected = false;
                                  }
                                  for (var e in newimageList) {
                                    e.isSelected = false;
                                  }
                                  v.isSelected = true;
                                });
                              } else {
                                setState(() {
                                  v.isSelected = false;
                                });
                              }
                            },
                            onCancel: () {
                              int index = newStringList
                                  .indexWhere((element) => v == element);

                              newStringList.removeAt(index);
                            },
                            palletColor: widget.palletColor,
                            fonts: widget.fonts,
                            newText: v,
                            boundWidth: width * .78 - width * .20,
                            boundHeight: height * .40 - height * .07);
                      }).toList(),
                      ...newimageList.map((v) {
                        return StickerEditingBox(
                            onCancel: () {
                              int index = newimageList
                                  .indexWhere((element) => v == element);

                              newimageList.removeAt(index);
                            },
                            onTap: () {
                              if (!v.isSelected) {
                                setState(() {
                                  for (var element in newStringList) {
                                    element.isSelected = false;
                                  }
                                  for (var e in newimageList) {
                                    e.isSelected = false;
                                  }
                                  v.isSelected = true;
                                });
                              } else {
                                setState(() {
                                  v.isSelected = false;
                                });
                              }
                            },
                            boundWidth: width * .70,
                            boundHeight: height * .30,
                            pictureModel: v);
                      }),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomeWidgets.customButton(
                    btnName: 'Text',
                    onPressed: () async {
                      await showEditBox(
                        context: context,
                        textModel: TextModel(
                            name: selectedtextToShare,
                            textStyle: const TextStyle(),
                            top: 50,
                            isSelected: false,
                            textAlign: TextAlign.center,
                            scale: 1,
                            left: 50),
                      );
                    },
                  ),
                  CustomeWidgets.customButton(
                    btnName: 'Stickers',
                    onPressed: () {
                      selectedTextIndex = -1;

                      stickerWidget(context);
                    },
                  ),
                  CustomeWidgets.customButton(
                    btnName: 'Done',
                    onPressed: () async {
                      setState(() {
                        for (var e in newStringList) {
                          e.isSelected = false;
                        }
                        for (var e in newimageList) {
                          e.isSelected = false;
                        }
                      });
                      Future.delayed(const Duration(milliseconds: 200),
                          () async {
                        imagePath = '';
                        if (Platform.isMacOS) {
                          imagePath = (await getApplicationDocumentsDirectory())
                              .path
                              .trim(); //from path_provide package
                        } else if (Platform.isAndroid) {
                          imagePath = (await getExternalStorageDirectory())!
                              .path
                              .trim(); //from path_provide package

                        } else if (Platform.isIOS) {
                          imagePath = (await getApplicationDocumentsDirectory())
                              .path
                              .trim();
                        }

                        Random().nextInt(15000);
                        fileName = '${Random().nextInt(15000)}.png';

                        await screenshotController.captureAndSave(imagePath,
                            //set path where screenshot will be saved
                            fileName: fileName);
                        file = await File('$imagePath/$fileName')
                            .create(recursive: true);
                        widget.imageFile!(file!.path);
                        setState(() {});
                      });
                    },
                  ),
                ],
              ),
            ),
            // _previewDownloadedImage(),
            showProgressOnGenerate
                ? const Center(child: CircularProgressIndicator())
                : Column(),
          ],
        ),
      ),
    );
  }

  Future showEditBox({BuildContext? context, TextModel? textModel}) {
    return showDialog(
        context: context!,
        builder: (context) {
          final dailogTextController =
              TextEditingController(text: selectedtextToShare);
          return AlertDialog(
            backgroundColor: const Color.fromARGB(240, 200, 200, 200),
            title: const Text('Edit Text'),
            content: TextField(
                controller: dailogTextController,
                maxLines: 6,
                minLines: 1,
                autofocus: true,
                decoration: InputDecoration(hintText: selectedtextToShare)),
            actions: [
              ElevatedButton(
                  child: const Text('Done'),
                  onPressed: () {
                    setState(() {
                      for (var e in newimageList) {
                        e.isSelected = false;
                      }
                      for (var e in newStringList) {
                        e.isSelected = false;
                      }
                      textModel!.isSelected = true;
                      textModel.name = dailogTextController.text.trim();
                      newStringList.add(textModel);
                    });
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  //preview Image
  Widget _previewDownloadedImage() {
    return imagePath != ''
        ? Positioned(
            bottom: 10,
            left: 5,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0)),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 10,
                            offset: Offset(0.3, 0.6))
                      ],
                      image: DecorationImage(
                          image: FileImage(file!), fit: BoxFit.cover)),
                ),
                InkWell(
                    onTap: () => setState(() => imagePath = ''),
                    child: const Icon(Icons.cancel)),
              ],
            ),
          )
        : Container();
  }

  // Sticker widget
  Future stickerWidget(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    selectedTextIndex = -1;
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Material(
            elevation: 15,
            child: SizedBox(
              height: height * .4,
              width: width,
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4),
                  itemCount: widget.assetList!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        for (var e in newimageList) {
                          e.isSelected = false;
                        }
                        for (var e in newStringList) {
                          e.isSelected = false;
                        }
                        newimageList.add(PictureModel(
                            isNetwork: false,
                            stringUrl: widget.assetList![index],
                            top: y1 + 10 < 300 ? y1 + 10 : 300,
                            isSelected: true,
                            angle: 0.0,
                            scale: 1,
                            left: x1 + 10 < 300 ? x1 + 10 : 300));
                        x1 = x1 + 10 < 200 ? x1 + 10 : 200;
                        y1 = y1 + 10 < 200 ? y1 + 10 : 200;
                        Navigator.pop(context);
                        setState(() {});
                      },
                      child: Image.asset(widget.assetList![index],
                          height: 50, width: 50),
                    );
                  }),
            ),
          );
        });
  }
}

class CustomeWidgets {
  static Widget customButton({
    required String btnName,
    required void Function() onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 50,
        margin: EdgeInsets.only(bottom: 15),
        child: Center(
          child: Text(
            '$btnName',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(shape: BoxShape.circle, color: appThemes),
      ),
    );
  }
}
