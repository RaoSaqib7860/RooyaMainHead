import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_cropping/image_cropping.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/filters/filters.dart';
import 'package:photofilters/widgets/photo_filter.dart';
import 'package:rooya_app/ApiUtils/baseUrl.dart';
import 'package:rooya_app/GlobalClass/TextFieldsCustom.dart';
import 'package:rooya_app/dashboard/BottomSheet/BottomSheet.dart';
import 'package:rooya_app/dashboard/ProfileComponents/CreateMyEvent.dart';
import 'package:rooya_app/models/MyEventModel.dart';
import 'package:rooya_app/story/uploadStroy.dart';
import 'package:rooya_app/utils/AppFonts.dart';
import 'package:rooya_app/utils/ProgressHUD.dart';
import 'package:rooya_app/utils/ShimmerEffect.dart';
import 'package:rooya_app/utils/SizedConfig.dart';
import 'package:rooya_app/utils/SnackbarCustom.dart';
import 'package:rooya_app/utils/colors.dart';
import 'package:rooya_app/widgets/CropImageClass.dart';
import 'package:rooya_app/widgets/ImageEditorView.dart';
import 'package:rooya_app/widgets/ImageFilterView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'CropYourImagePlugin.dart';
import 'EditImageWithRedoUndo.dart';

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
  List<MyEventModel> myEvetModel = [];
  TextEditingController controller = TextEditingController();
  bool isLoading = false;

  bool isCropMode = false;
  String? imagePath = '';

  String dropDownValue = 'Public';
  var selectedEventId = '-1';
  var selectedEventtitle = '';

  @override
  void initState() {
    loading = false;
    _filter = widget.filters[0];
    filename = widget.filename;
    image = widget.image;
    imagePath = widget.imagePath;
    getAllEvent();
    super.initState();
  }

  int selected_Icon = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ProgressHUD(
        inAsyncCall: isLoading,
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
                icon: Icon(CupertinoIcons.back, color: Colors.black)),
            actions: [
              InkWell(
                onTap: () {
                  previewPost(
                      onclick: () async {
                        setState(() {
                          isLoading = true;
                        });
                        List listofurl = [];
                        String value = await createStory(imagePath!);
                        listofurl.add(value);
                        print('listofurl= $listofurl');
                        if (selectedEventtitle == '') {
                          await uploadStoryData(
                              text: controller.text, listOfUrl: listofurl);
                        } else {
                          await uploadStoryData(
                              text: controller.text,
                              listOfUrl: listofurl,
                              myEventid: '$selectedEventId');
                        }
                        setState(() {
                          isLoading = false;
                        });
                        snackBarSuccess('Story post successfully');
                        Future.delayed(Duration(seconds: 2), () {
                          Get.offAll(() => BottomSheetCustom());
                        });
                      },
                      context: context);
                },
                child: Center(
                  child: Text(
                    'Preview',
                    style: TextStyle(
                        fontSize: 14,
                        color: primaryColor,
                        fontFamily: 'segoeui'),
                  ),
                ),
              ),
              SizedBox(
                width: width * 0.030,
              )
            ],
          ),
          body: Stack(
            children: [
              imageViewReturn(selected_Icon, context),
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
                          color:
                              selected_Icon == 0 ? primaryColor : Colors.white,
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
                          color:
                              selected_Icon == 1 ? primaryColor : Colors.white,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          imageBytes = await File(imagePath!).readAsBytes();
                          newFilePath = await getFilePath();
                          setState(() {
                            selected_Icon = 2;
                          });
                        },
                        child: Icon(
                          Icons.crop,
                          color:
                              selected_Icon == 2 ? primaryColor : Colors.white,
                        ),
                      ),
                      SvgPicture.asset('assets/svg/filter.svg'),
                      InkWell(
                        child: SvgPicture.asset(
                          'assets/svg/magic.svg',
                          color:
                              selected_Icon == 3 ? primaryColor : Colors.white,
                        ),
                        onTap: () {
                          setState(() {
                            selected_Icon = 3;
                          });
                        },
                      ),
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
      ),
    );
  }

  Future<void> CreateMyEvent(String title) async {
    var dt = DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    String? userId = await prefs.getString('user_id');
    final response = await http.post(
        Uri.parse('${baseUrl}postRooyaMyEvent$code'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({
          "event_privacy": 'public',
          "event_maker": userId,
          "event_title": title,
          "event_location": '',
          "event_hashtag": [],
          "event_tag_peoples": [],
          "event_description": '',
          "event_date_on": '${dt.year}-${dt.month}-${dt.day}'
        }));
    print(' ${response.body}');
  }

  Uint8List? imageBytes;
  String? newFilePath;
  Widget imageViewReturn(int index, BuildContext context) {
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
      return CropSample();
      // final _controller = CropController();
      // return Crop(
      //     image: imageBytes!,
      //     controller: _controller,
      //     onCropped: (newImage) async {
      //       String path = await getFilePath();
      //       File file = await File('$path').writeAsBytes(newImage);
      //       imagePath = file.path;
      //       setState(() {
      //         selected_Icon = 100;
      //       });
      //     },
      //     // aspectRatio: 4 / 3,
      //     initialSize: 0.5,
      //     // initialArea: Rect.fromLTWH(240, 212, 800, 600),
      //     // withCircleUi: true,
      //     baseColor: Colors.blue.shade900,
      //     maskColor: Colors.white.withAlpha(100),
      //     onMoved: (newRect) {
      //       // do something with current cropping area.
      //     },
      //     onStatusChanged: (status) {
      //       // do something with current CropStatus
      //     },
      //     cornerDotBuilder: (size, edgeAlignment) => const DotControl(color: Colors.blue),
      //     );

      // return CropImageClass(
      //   path: imagePath,
      //   imageFile: (value) async {
      //     imagePath = value;
      //     setState(() {});
      //     cachedFilters = {};
      //     String name = '';
      //     name = basename(imagePath!);
      //     var img = imageLib.decodeImage(await File(imagePath!).readAsBytes());
      //     img = imageLib.copyResize(img!, width: 600);
      //     filename = name;
      //     image = img;
      //     setState(() {
      //       selected_Icon = 100;
      //     });
      //   },
      // );
    } else if (index == 3) {
      return FlutterPainterExample(
        filePath: imagePath,
        path: (String v) {
          setState(() {
            imagePath = v;
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

  Future<void> getAllEvent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    String? userId = await prefs.getString('user_id');
    final response = await http.post(
        Uri.parse('${baseUrl}getRooyaMyPerEventByLimite${code}'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode(
            {"page_size": 100, "page_number": 0, "event_admin": userId}));
    print(response.request);
    print(response.statusCode);
    print('${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] == 'success') {
        setState(() {
          myEvetModel = List<MyEventModel>.from(
              data['data'].map((model) => MyEventModel.fromJson(model)));
        });
      } else {
        setState(() {});
      }
    }
  }

  previewPost({Function()? onclick, BuildContext? context}) {
    showDialog(
        context: context!,
        builder: (BuildContext context) {
          return Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)), //this right here
            child: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  height: height,
                  child: Stack(
                    children: [
                      Container(
                        height: height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Image.file(
                                File(imagePath!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                            SizedBox(
                              height: Get.height * 0.030,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: TextFieldsProfile(
                                controller: controller,
                                hint: 'Write your comment'.tr,
                                uperhint: 'Write your comment'.tr,
                                width: Get.width,
                              ),
                            ),
                            SizedBox(
                              height: Get.height * 0.030,
                            ),
                            SizedBox(
                              height: Get.height * 0.030,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: height * 0.045,
                                    width: width * 0.210,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.025),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Colors.grey[100]!.withOpacity(0.5),
                                    ),
                                    child: DropdownButton<String>(
                                      items: <String>[
                                        'Public',
                                        'My Followers',
                                        'Only Me'
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: AppFonts.segoeui),
                                          ),
                                        );
                                      }).toList(),
                                      underline: SizedBox(),
                                      isExpanded: true,
                                      hint: Text(
                                        '$dropDownValue',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: AppFonts.segoeui),
                                      ),
                                      onChanged: (value) {
                                        dropDownValue = value!;
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      var textController =
                                          TextEditingController().obs;
                                      showCupertinoModalBottomSheet(
                                        expand: false,
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) {
                                          return StatefulBuilder(
                                              builder: (context, setState) {
                                            return Container(
                                              height: height * 0.6,
                                              child: Scaffold(
                                                body: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Select Event',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    AppFonts
                                                                        .segoeui),
                                                          ),
                                                          InkWell(
                                                            onTap: () async {
                                                              showCupertinoModalBottomSheet(
                                                                expand: false,
                                                                context:
                                                                    context,
                                                                enableDrag:
                                                                    true,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                builder:
                                                                    (context) {
                                                                  return Container(
                                                                    height:
                                                                        height *
                                                                            0.6,
                                                                    child:
                                                                        CreateMyEvet(
                                                                      onCreateCall:
                                                                          () async {
                                                                        getAllEvent();
                                                                        setState(
                                                                            () {});
                                                                      },
                                                                    ),
                                                                  );
                                                                },
                                                              ).then(
                                                                  (value) async {
                                                                await getAllEvent();
                                                                setState(() {});
                                                              });
                                                            },
                                                            child: Container(
                                                              height: height *
                                                                  0.045,
                                                              width:
                                                                  width * 0.3,
                                                              child: Center(
                                                                child: Text(
                                                                  'Create Event',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          AppFonts
                                                                              .segoeui,
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30)),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: height * 0.020,
                                                      ),
                                                      Expanded(
                                                        child: ListView.builder(
                                                          itemBuilder: (c, i) {
                                                            return InkWell(
                                                              onTap: () {
                                                                selectedEventId =
                                                                    '${myEvetModel[i].eventId}';
                                                                selectedEventtitle =
                                                                    '${myEvetModel[i].eventTitle}';
                                                                textController
                                                                    .value
                                                                    .text = '';
                                                                setState(() {});
                                                              },
                                                              child: Container(
                                                                height: height *
                                                                    0.050,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            10),
                                                                decoration: BoxDecoration(
                                                                    color: selectedEventId ==
                                                                            '${myEvetModel[i].eventId}'
                                                                        ? primaryColor
                                                                        : Colors
                                                                            .blueGrey[50]!
                                                                            .withOpacity(0.5)),
                                                                child: Center(
                                                                  child: Text(
                                                                    '${myEvetModel[i].eventTitle}',
                                                                    style: TextStyle(
                                                                        color: selectedEventId ==
                                                                                '${myEvetModel[i].eventId}'
                                                                            ? Colors.white
                                                                            : Colors.black),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          itemCount: myEvetModel
                                                              .length,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: height * 0.020,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: width * 0.2,
                                      height: height * 0.040,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4),
                                      child: Center(
                                        child: Text(
                                          selectedEventtitle == ''
                                              ? 'Event'
                                              : selectedEventtitle,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: AppFonts.segoeui,
                                          ),
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.blueGrey[50]!
                                              .withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                    ),
                                  ),
                                  Container(
                                    width: width * 0.2,
                                    height: height * 0.040,
                                    child: Center(
                                      child: Text(
                                        'Preview',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: AppFonts.segoeui),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                        color: Colors.blueGrey[50]!
                                            .withOpacity(0.5),
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      onclick!.call();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 7, horizontal: 30),
                                      decoration: BoxDecoration(
                                          color: Colors.blueGrey[50]!
                                              .withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                      child: Text(
                                        'Post',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: AppFonts.segoeui),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: Get.height * 0.030,
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          );
        });
  }
}
