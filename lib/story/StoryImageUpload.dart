import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/filters/filters.dart';
import 'package:photofilters/widgets/photo_filter.dart';
import 'package:rooya_app/GlobalClass/TextFieldsCustom.dart';
import 'package:rooya_app/dashboard/BottomSheet/BottomSheet.dart';
import 'package:rooya_app/story/uploadStroy.dart';
import 'package:rooya_app/utils/AppFonts.dart';
import 'package:rooya_app/utils/ShimmerEffect.dart';
import 'package:rooya_app/utils/SizedConfig.dart';
import 'package:rooya_app/utils/SnackbarCustom.dart';
import 'package:rooya_app/utils/colors.dart';
import 'package:rooya_app/widgets/CropImageClass.dart';
import 'package:rooya_app/widgets/ImageEditorView.dart';
import 'package:rooya_app/widgets/ImageFilterView.dart';

class StoryImageUpload extends StatefulWidget {
  final Widget title;
  final Color appBarColor;
  final List<Filter> filters;
  final imageLib.Image image;
  final Widget loader;
  final BoxFit fit;
  final String filename;
  final bool circleShape;
  final String? imagePath;

  const StoryImageUpload({
    Key? key,
    required this.title,
    required this.filters,
    required this.image,
    this.appBarColor = Colors.blue,
    this.loader = const Center(child: CircularProgressIndicator()),
    this.fit = BoxFit.fill,
    required this.filename,
    this.circleShape = false,
    this.imagePath,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _StoryImageUploadState();
}

class _StoryImageUploadState extends State<StoryImageUpload> {
  String? filename;
  Map<String, List<int>?> cachedFilters = {};
  Filter? _filter;
  imageLib.Image? image;
  late bool loading;

  TextEditingController controller = TextEditingController();
  bool isLoading = false;

  bool isCropMode = false;
  String? imagePath = '';

  @override
  void initState() {
    loading = false;
    _filter = widget.filters[0];
    filename = widget.filename;
    image = widget.image;
    imagePath = widget.imagePath;
    super.initState();
  }

  int selected_Icon = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Post Story',
            style: TextStyle(
                fontSize: 16, color: Colors.black, fontFamily: 'segoeui'),
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back, color: Colors.black)),
        ),
        body: Stack(
          children: [
            imageViewReturn(selected_Icon),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: height * 0.380,
                width: width * 0.130,
                padding: EdgeInsets.symmetric(vertical: height * 0.030),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          selected_Icon = 0;
                        });
                      },
                      child: Icon(
                        Icons.filter_list,
                        color: selected_Icon == 0 ? primaryColor : Colors.white,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          selected_Icon = 1;
                        });
                      },
                      child: Icon(
                        Icons.text_fields,
                        color: selected_Icon == 1 ? primaryColor : Colors.white,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          selected_Icon = 2;
                        });
                      },
                      child: Icon(
                        Icons.crop,
                        color: selected_Icon == 2 ? primaryColor : Colors.white,
                      ),
                    ),
                    SvgPicture.asset('assets/svg/filter.svg'),
                    SvgPicture.asset('assets/svg/magic.svg'),
                    SvgPicture.asset('assets/svg/time.svg'),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
                margin: EdgeInsets.only(
                    bottom: height * 0.150, right: width * 0.030),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget imageViewReturn(int index) {
    if (index == 0) {
      return Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // TextFieldsProfile(
              //   controller: controller,
              //   hint: 'Write your comment'.tr,
              //   uperhint: 'Write your comment'.tr,
              //   width: Get.width,
              // ),
              // SizedBox(
              //   height: Get.height * 0.010,
              // ),
              Expanded(
                child: _buildFilteredImage(
                  _filter,
                  image,
                  filename,
                ),
              ),
              // InkWell(
              //   onTap: () async {
              //     setState(() {
              //       loading = true;
              //     });
              //     File imageFile = await saveFilteredImage();
              //     List listofurl = [];
              //     String value = await createStory(imageFile.path);
              //     listofurl.add(value);
              //     print('listofurl= $listofurl');
              //     await uploadStoryData(
              //         text: controller.text, listOfUrl: listofurl);
              //     setState(() {
              //       isLoading = false;
              //     });
              //     snackBarSuccess('Story post successfully');
              //     Future.delayed(Duration(seconds: 2), () {
              //       Get.offAll(() => BottomSheetCustom());
              //     });
              //   },
              //   child: Container(
              //     padding:
              //         EdgeInsets.symmetric(vertical: 7, horizontal: 40),
              //     decoration: BoxDecoration(
              //         color: primaryColor,
              //         borderRadius: BorderRadius.circular(25)),
              //     child: Text(
              //       'POST',
              //       style: TextStyle(
              //           color: Colors.white,
              //           fontFamily: AppFonts.segoeui),
              //     ),
              //   ),
              // ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height * 0.120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.filters.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    child: Container(
                      padding: EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _buildFilterThumbnail(widget.filters[index], image,
                              filename, widget.filters[index].name),
                        ],
                      ),
                    ),
                    onTap: () async {
                      setState(() {
                        _filter = widget.filters[index];
                      });
                      File imageFile = await saveFilteredImage();
                      String oldPath = imagePath!;
                      imagePath = imageFile.path;
                      File('$oldPath').delete();
                      setState(() {});
                    },
                  );
                },
              ),
            ),
          ),
        ],
      );
    } else if (index == 1) {
      return StickerEditingView(
        isnetwork: true,
        height: height,
        width: width,
        imgUrl: '$imagePath',
        fonts: const [
          'segmdl2',
          'segoepr',
          'segoeprb',
          'segoesc',
          'segoescb',
          'segoeui',
          'segoeuib',
          'segoeuii',
          'segoeuil',
          'segoeuisl',
          'segoeuiz',
          'seguibl',
          'seguibli',
          'seguiemj',
          'seguihis',
          'seguili',
          'seguisb',
          'seguisli',
          'seguisym'
        ],
        palletColor: const [
          Colors.red,
          Colors.yellow,
          Colors.black,
          Colors.green,
          Colors.blue,
          Colors.blueGrey,
          Colors.brown,
          Colors.deepOrangeAccent,
          Colors.cyanAccent,
          Colors.purpleAccent,
          Colors.teal,
          Colors.indigo,
          Colors.lightGreenAccent,
          Colors.pinkAccent,
          Colors.deepPurple,
        ],
        assetList: const [
          'assets/images/sticker-1.png',
          'assets/images/sticker-2.png',
          'assets/images/sticker-3.png'
        ],
        imageFile: (value) async {
          print('new current path is = $value');
          imagePath = value;
          setState(() {});
          cachedFilters = {};
          String name = '';
          name = basename(imagePath!);
          var img = imageLib.decodeImage(await File(imagePath!).readAsBytes());
          img = imageLib.copyResize(img!, width: 600);
          filename = name;
          image = img;
          setState(() {
            selected_Icon = 100;
          });
        },
      );
    } else if (index == 2) {
      return CropImageClass(
        path: imagePath,
        imageFile: (value) async {
          imagePath = value;
          setState(() {});
          cachedFilters = {};
          String name = '';
          name = basename(imagePath!);
          var img = imageLib.decodeImage(await File(imagePath!).readAsBytes());
          img = imageLib.copyResize(img!, width: 600);
          filename = name;
          image = img;
          setState(() {
            selected_Icon = 100;
          });
        },
      );
    } else {
      return Container(
        height: height,
        width: width,
        child: Image.file(
          File(imagePath!),
          fit: BoxFit.cover,
        ),
      );
    }
  }

  _buildFilterThumbnail(Filter filter, imageLib.Image? image, String? filename,
      String? filterName) {
    if (cachedFilters[filter.name] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return CircleAvatar(
                radius: 30.0,
                child: Center(
                  child: widget.loader,
                ),
                backgroundColor: Colors.white,
              );
            case ConnectionState.done:
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              cachedFilters[filter.name] = snapshot.data;
              return Container(
                height: height * 0.090,
                width: width * 0.180,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.memory(
                        snapshot.data as dynamic,
                        fit: BoxFit.cover,
                        height: height * 0.090,
                        width: width * 0.180,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: width * 0.180,
                        padding: EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5)),
                        ),
                        child: Text(
                          filterName!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontFamily: 'segoeui'),
                        ),
                      ),
                    )
                  ],
                ),
              );
          }
          // unreachable
        },
      );
    } else {
      return Container(
        height: height * 0.090,
        width: width * 0.180,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.memory(
                cachedFilters[filter.name] as dynamic,
                fit: BoxFit.cover,
                height: height * 0.090,
                width: width * 0.180,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: width * 0.180,
                padding: EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5)),
                ),
                child: Text(
                  filterName!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 8, color: Colors.white, fontFamily: 'segoeui'),
                ),
              ),
            )
          ],
        ),
      );
      // return CircleAvatar(
      //   radius: 30.0,
      //   backgroundImage: MemoryImage(
      //     cachedFilters[filter.name] as dynamic,
      //   ),
      //   backgroundColor: Colors.white,
      // );
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/filtered_${_filter?.name ?? "_"}_$filename');
  }

  Future<File> saveFilteredImage() async {
    var imageFile = await _localFile;
    await imageFile.writeAsBytes(cachedFilters[_filter?.name ?? "_"]!);
    return imageFile;
  }

  Widget _buildFilteredImage(
      Filter? filter, imageLib.Image? image, String? filename) {
    if (cachedFilters[filter?.name ?? "_"] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return widget.loader;
            case ConnectionState.active:
            case ConnectionState.waiting:
              return widget.loader;
            case ConnectionState.done:
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              cachedFilters[filter?.name ?? "_"] = snapshot.data;
              return widget.circleShape
                  ? SizedBox(
                      height: MediaQuery.of(context).size.width / 3,
                      width: MediaQuery.of(context).size.width / 3,
                      child: Center(
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.width / 3,
                          backgroundImage: MemoryImage(
                            snapshot.data as dynamic,
                          ),
                        ),
                      ),
                    )
                  : Image.memory(
                      snapshot.data as dynamic,
                      fit: BoxFit.cover,
                    );
          }
          // unreachable
        },
      );
    } else {
      return widget.circleShape
          ? SizedBox(
              height: width / 3,
              width: width / 3,
              child: Center(
                child: CircleAvatar(
                  radius: width / 3,
                  backgroundImage: MemoryImage(
                    cachedFilters[filter?.name ?? "_"] as dynamic,
                  ),
                ),
              ),
            )
          : Image.memory(
              cachedFilters[filter?.name ?? "_"] as dynamic,
              fit: widget.fit,
            );
    }
  }

/////////////
}
