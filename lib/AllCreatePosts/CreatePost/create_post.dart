import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:reorderables/reorderables.dart';
import 'package:rooya_app/Screens/Reel/ReelCamera/ReelCamera.dart';
import 'package:rooya_app/dashboard/BottomSheet/BottomSheet.dart';
import 'package:rooya_app/dashboard/ProfileComponents/CreateMyEvent.dart';
import 'package:rooya_app/models/FileUploadModel.dart';
import 'package:rooya_app/models/HashTagModel.dart';
import 'package:rooya_app/models/MyEventModel.dart';
import 'package:rooya_app/models/UserTagModel.dart';
import 'package:rooya_app/rooya_post/CreateRooyaPostController.dart';
import 'package:rooya_app/story/create_story.dart';
import 'package:rooya_app/story/uploadStroy.dart';
import 'package:rooya_app/utils/AppFonts.dart';
import 'package:rooya_app/utils/ProgressHUD.dart';
import 'package:rooya_app/ApiUtils/baseUrl.dart';
import 'package:rooya_app/utils/SizedConfig.dart';
import 'package:rooya_app/utils/SnackbarCustom.dart';
import 'package:rooya_app/utils/colors.dart';
import 'package:rooya_app/widgets/EditImageGlobal.dart';
import 'package:rooya_app/widgets/VideoTrimGlobal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'add_hastags.dart';
import 'add_usertags.dart';

String newPathis = '';

class CreatePost extends StatefulWidget {
  final bool? fromEvent;
  final String? event_id;

  const CreatePost({this.fromEvent = false, this.event_id = '0'});

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  List<MyEventModel> myEvetModel = [];

  final ImagePicker _picker = ImagePicker();
  XFile? image;
  List<HashTagModel> selectedHashTags = [];
  List<UserTagModel> selectedUserTags = [];
  List hashTags = [];
  List usersTags = [];
  List usersTagsPic = [];
  bool isLoading = false;
  String? uploadedUrl;
  List<FileUploadModel> mPic = [];
  int selectedImageIndex = 0;
  double uploadPercent = 0;
  TextEditingController descriptionController = TextEditingController();
  var controller = Get.put(CreateRooyaPostController());
  var selectedEventId = '-1';
  var selectedEventtitle = '';
  String dropDownValue = 'Public';

  @override
  void initState() {
    controller.getFilesPath();
    getAllEvent();
    super.initState();
  }

  bool top = false;

  @override
  Widget build(BuildContext context) {
    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        Map map = controller.listOfSelectedfiles.removeAt(oldIndex);
        controller.listOfSelectedfiles.insert(newIndex, map);
      });
      setState(() {});
    }

    var listofColum = [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              children: [
                // Row(
                //   children: [
                //     Expanded(
                //       child: Obx(
                //         () => controller.listOfSelectedfiles.isEmpty
                //             ? SizedBox()
                //             : controller.listOfSelectedfiles.length == 1
                //                 ? Container(
                //                     height: height * 0.250,
                //                     width: width,
                //                     child: returnCard(
                //                         controller.listOfSelectedfiles[0]),
                //                   )
                //                 : controller.listOfSelectedfiles.length == 2
                //                     ? Row(
                //                         children: [
                //                           Expanded(
                //                             child: Container(
                //                               height: height * 0.250,
                //                               width: width,
                //                               child: returnCard(controller
                //                                   .listOfSelectedfiles[0]),
                //                             ),
                //                           ),
                //                           SizedBox(
                //                             width: 1,
                //                           ),
                //                           Expanded(
                //                             child: Container(
                //                               height: height * 0.250,
                //                               width: width,
                //                               child: returnCard(controller
                //                                   .listOfSelectedfiles[1]),
                //                             ),
                //                           )
                //                         ],
                //                       )
                //                     : controller.listOfSelectedfiles.length == 3
                //                         ? Row(
                //                             children: [
                //                               Expanded(
                //                                 child: Container(
                //                                   height: height * 0.250,
                //                                   width: width,
                //                                   child: returnCard(controller
                //                                       .listOfSelectedfiles[0]),
                //                                 ),
                //                               ),
                //                               SizedBox(
                //                                 width: 1,
                //                               ),
                //                               Expanded(
                //                                 child: Container(
                //                                   height: height * 0.250,
                //                                   width: width,
                //                                   child: returnCard(controller
                //                                       .listOfSelectedfiles[1]),
                //                                 ),
                //                               ),
                //                               SizedBox(
                //                                 width: 1,
                //                               ),
                //                               Expanded(
                //                                 child: Container(
                //                                   height: height * 0.250,
                //                                   width: width,
                //                                   child: returnCard(controller
                //                                       .listOfSelectedfiles[2]),
                //                                 ),
                //                               )
                //                             ],
                //                           )
                //                         : controller.listOfSelectedfiles
                //                                     .length ==
                //                                 4
                //                             ? Column(
                //                                 children: [
                //                                   Row(
                //                                     children: [
                //                                       Expanded(
                //                                         child: Container(
                //                                           height:
                //                                               height * 0.125,
                //                                           width: width,
                //                                           child: returnCard(
                //                                               controller
                //                                                   .listOfSelectedfiles[0]),
                //                                         ),
                //                                       ),
                //                                       SizedBox(
                //                                         width: 1,
                //                                       ),
                //                                       Expanded(
                //                                         child: Container(
                //                                           height:
                //                                               height * 0.125,
                //                                           width: width,
                //                                           child: returnCard(
                //                                               controller
                //                                                   .listOfSelectedfiles[1]),
                //                                         ),
                //                                       )
                //                                     ],
                //                                   ),
                //                                   SizedBox(
                //                                     height: 1,
                //                                   ),
                //                                   Row(
                //                                     children: [
                //                                       Expanded(
                //                                         child: Container(
                //                                           height:
                //                                               height * 0.125,
                //                                           width: width,
                //                                           child: returnCard(
                //                                               controller
                //                                                   .listOfSelectedfiles[2]),
                //                                         ),
                //                                       ),
                //                                       SizedBox(
                //                                         width: 1,
                //                                       ),
                //                                       Expanded(
                //                                         child: Container(
                //                                           height:
                //                                               height * 0.125,
                //                                           width: width,
                //                                           child: returnCard(
                //                                               controller
                //                                                   .listOfSelectedfiles[3]),
                //                                         ),
                //                                       )
                //                                     ],
                //                                   ),
                //                                 ],
                //                               )
                //                             : Column(
                //                                 children: [
                //                                   Row(
                //                                     children: [
                //                                       Expanded(
                //                                         child: Container(
                //                                           height:
                //                                               height * 0.125,
                //                                           width: width,
                //                                           child: returnCard(
                //                                               controller
                //                                                   .listOfSelectedfiles[0]),
                //                                         ),
                //                                       ),
                //                                       SizedBox(
                //                                         width: 1,
                //                                       ),
                //                                       Expanded(
                //                                         child: Container(
                //                                           height:
                //                                               height * 0.125,
                //                                           width: width,
                //                                           child: returnCard(
                //                                               controller
                //                                                   .listOfSelectedfiles[1]),
                //                                         ),
                //                                       )
                //                                     ],
                //                                   ),
                //                                   SizedBox(
                //                                     height: 1,
                //                                   ),
                //                                   Row(
                //                                     children: [
                //                                       Expanded(
                //                                         child: Container(
                //                                           height:
                //                                               height * 0.125,
                //                                           width: width,
                //                                           child: returnCard(
                //                                               controller
                //                                                   .listOfSelectedfiles[2]),
                //                                         ),
                //                                       ),
                //                                       SizedBox(
                //                                         width: 1,
                //                                       ),
                //                                       Expanded(
                //                                         child: Stack(
                //                                           children: [
                //                                             Container(
                //                                               height: height *
                //                                                   0.125,
                //                                               width: width,
                //                                               child: returnCard(
                //                                                   controller
                //                                                       .listOfSelectedfiles[3]),
                //                                             ),
                //                                             Container(
                //                                               height: height *
                //                                                   0.125,
                //                                               color: Colors
                //                                                   .black
                //                                                   .withOpacity(
                //                                                       0.5),
                //                                               child: Center(
                //                                                   child: Text(
                //                                                 '+${controller.listOfSelectedfiles.length - 4}',
                //                                                 style: TextStyle(
                //                                                     fontSize:
                //                                                         18.0.sp,
                //                                                     color: Colors
                //                                                         .white),
                //                                               )),
                //                                             )
                //                                           ],
                //                                         ),
                //                                       )
                //                                     ],
                //                                   ),
                //                                 ],
                //                               ),
                //       ),
                //     ),
                //     SizedBox(
                //       width: 10,
                //     ),
                //     Obx(() => controller.listOfSelectedfiles.isEmpty
                //         ? SizedBox()
                //         : Icon(Icons.menu))
                //   ],
                // ),
                // SizedBox(
                //   height: height * 0.010,
                // ),
                SizedBox(
                  height: 7,
                ),
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: ReorderableRow(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(
                                controller.listOfSelectedfiles.length, (index) {
                                  print('File path is == ${controller.listOfSelectedfiles[index]}');
                              Map value = controller.listOfSelectedfiles[index];
                              return Container(
                                key: UniqueKey(),
                                height: 10.0.h,
                                width: 10.0.h,
                                margin: EdgeInsets.only(right: 10),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 10.0.h,
                                      width: 10.0.h,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: value.containsKey('image')
                                            ? Image.file(
                                                File(controller
                                                        .listOfSelectedfiles[
                                                    index]['image']),
                                                fit: BoxFit.cover,
                                              )
                                            : Thumbnails(
                                                thumb: controller
                                                        .listOfSelectedfiles[
                                                    index]['video'],
                                              ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                        child: Icon(
                                          Icons.cancel,
                                          color: primaryColor,
                                        ),
                                        onTap: () {
                                          controller.listOfSelectedfiles
                                              .removeAt(index);
                                        },
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: InkWell(
                                        child: Container(
                                          child: Icon(
                                            Icons.edit,
                                            size: 15,
                                            color: primaryColor,
                                          ),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle),
                                          padding: EdgeInsets.all(3),
                                          margin: EdgeInsets.all(3),
                                        ),
                                        onTap: () {
                                          if (value.containsKey('image')) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (c) =>
                                                        EditImageGlobal(
                                                          path: controller
                                                                  .listOfSelectedfiles[
                                                              index]['image'],
                                                        ))).then((value) {
                                              if (value.toString().length > 5) {
                                                controller.listOfSelectedfiles[
                                                    index] = {
                                                  'image': '$value'
                                                };
                                                setState(() {});
                                              }
                                            });
                                          } else {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (c) =>
                                                        TrimmerViewGlobal(
                                                          file: File(controller
                                                                  .listOfSelectedfiles[
                                                              index]['video']),
                                                        ))).then((value) {
                                              if (value.toString().length > 5) {
                                                controller.listOfSelectedfiles[
                                                    index] = {
                                                  'video': '$value'
                                                };
                                                setState(() {});
                                              }
                                            });
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                            onReorder: _onReorder,
                          ),
                        ),
                      ),
                      Obx(() => controller.listOfSelectedfiles.isEmpty
                          ? SizedBox()
                          : Icon(Icons.menu))
                    ],
                  ),
                ),
              ],
              key: UniqueKey(),
            ),
          ),
        ],
        key: UniqueKey(),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 20),
              key: UniqueKey(),
              decoration:
                  BoxDecoration(color: Colors.grey[100]!.withOpacity(0.5)),
              child: TextFormField(
                key: UniqueKey(),
                controller: descriptionController,
                cursorColor: Colors.black,
                keyboardType: TextInputType.multiline,
                // expands: true,
                minLines: 10,
                maxLines: 10,
                style: TextStyle(fontSize: 14),
                decoration: new InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 12),
                  disabledBorder: InputBorder.none,
                  hintText: 'Write Your Rooya',
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 15, right: 15),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          // Icon(
          //   Icons.menu,
          // )
        ],
        key: UniqueKey(),
      )
    ].obs;
    return SafeArea(
      child: ProgressHUD(
          inAsyncCall: isLoading,
          opacity: 0.7,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: Text(
                widget.fromEvent! ? 'Create Event' : 'Create Rooya',
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
              // actions: [
              //   InkWell(
              //     onTap: () {
              //       controller.gallarypress();
              //     },
              //     child: Icon(
              //       Icons.photo_outlined,
              //       size: 30,
              //       color: primaryColor,
              //     ),
              //   ),
              //   SizedBox(
              //     width: width * 0.010,
              //   ),
              //   InkWell(
              //     onTap: () {
              //       // controller.selectLocation(context);
              //       Get.to(CameraApp())!.then((value) {
              //         print('path is = $newPathis');
              //         if (newPathis.isNotEmpty) {
              //           if (newPathis.contains('mp4')) {
              //             if (!controller.listOfSelectedfiles
              //                 .contains('$newPathis')) {
              //               controller.listOfSelectedfiles
              //                   .add({'video': '$newPathis'});
              //             }
              //           } else {
              //             if (!controller.listOfSelectedfiles
              //                 .contains('$newPathis')) {
              //               controller.listOfSelectedfiles
              //                   .add({'image': '$newPathis'});
              //             }
              //           }
              //           newPathis = '';
              //         }
              //       });
              //     },
              //     child: Icon(
              //       Icons.camera_alt_outlined,
              //       size: 30,
              //       color: primaryColor,
              //     ),
              //   ),
              //   SizedBox(
              //     width: width * 0.030,
              //   ),
              // ],
            ),
            body: SafeArea(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 2.5.w),
                child: Column(
                  // keyboardDismissBehavior:
                  //     ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Expanded(
                      child: ReorderableColumn(
                        children: listofColum,
                        ignorePrimaryScrollController: true,
                        onReorder: (a, b) {
                          var row = listofColum.removeAt(a);
                          listofColum.insert(b, row);
                          print('Changed row now');
                          top = !top;
                        },
                      ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //       //border: Border.all(color: Colors.grey),
                      //       borderRadius: BorderRadius.circular(1.5.h)),
                      //   child: Column(
                      //     children: [
                      //       ReorderableColumn(
                      //         children: listofColum,
                      //         onReorder: (a, b) {
                      //           var row = listofColum.removeAt(a);
                      //           listofColum.insert(b, row);
                      //           print('Changed row now');
                      //           top = !top;
                      //         },
                      //       ),
                      //       SizedBox(
                      //         height: 10,
                      //       ),
                      //       // hashTags.length == 0
                      //       //     ? SizedBox()
                      //       //     : Container(
                      //       //         width: 100.0.w,
                      //       //         padding: EdgeInsets.symmetric(
                      //       //             vertical: 10, horizontal: 5),
                      //       //         color: Colors.grey[100]!.withOpacity(0.5),
                      //       //         child: Text(
                      //       //           '${hashTags.toString().replaceAll('[', '').replaceAll(']', '')}',
                      //       //           style:
                      //       //               TextStyle(fontFamily: AppFonts.segoeui),
                      //       //         ),
                      //       //       ),
                      //       // SizedBox(
                      //       //   height: 2.0.w,
                      //       // ),
                      //       // usersTags.length == 0
                      //       //     ? SizedBox()
                      //       //     : Container(
                      //       //         width: 95.0.w,
                      //       //         padding: EdgeInsets.symmetric(
                      //       //             vertical: 5, horizontal: 5),
                      //       //         decoration: BoxDecoration(
                      //       //             color: Colors.grey[100]!.withOpacity(0.5),
                      //       //             borderRadius: BorderRadius.only(
                      //       //                 bottomRight: Radius.circular(10),
                      //       //                 bottomLeft: Radius.circular(10))),
                      //       //         child: Wrap(
                      //       //           children: usersTagsPic
                      //       //               .map((item) => Container(
                      //       //                     height: 4.0.h,
                      //       //                     width: 4.0.h,
                      //       //                     margin: EdgeInsets.symmetric(
                      //       //                         horizontal: 1),
                      //       //                     decoration: BoxDecoration(
                      //       //                         shape: BoxShape.circle,
                      //       //                         image: DecorationImage(
                      //       //                             image: NetworkImage(
                      //       //                                 '$baseImageUrl$item'),
                      //       //                             fit: BoxFit.cover)),
                      //       //                   ))
                      //       //               .toList()
                      //       //               .cast<Widget>(),
                      //       //         ),
                      //       //       )
                      //     ],
                      //   ),
                      // ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Row(
                    //   children: [
                    //     InkWell(
                    //       onTap: () {
                    //         // controller.selectLocation(context);
                    //         Get.to(CameraApp())!.then((value) {
                    //           print('path is = $newPathis');
                    //           if (newPathis.isNotEmpty) {
                    //             if (newPathis.contains('mp4')) {
                    //               if (!controller.listOfSelectedfiles
                    //                   .contains('$newPathis')) {
                    //                 controller.listOfSelectedfiles
                    //                     .add({'video': '$newPathis'});
                    //               }
                    //             } else {
                    //               if (!controller.listOfSelectedfiles
                    //                   .contains('$newPathis')) {
                    //                 controller.listOfSelectedfiles
                    //                     .add({'image': '$newPathis'});
                    //               }
                    //             }
                    //             newPathis = '';
                    //           }
                    //         });
                    //       },
                    //       child: Icon(
                    //         Icons.camera_alt_outlined,
                    //         size: 40,
                    //         color: primaryColor,
                    //       ),
                    //     ),
                    //     SizedBox(
                    //       width: width * 0.010,
                    //     ),
                    //     InkWell(
                    //       onTap: () {
                    //         controller.gallarypress();
                    //       },
                    //       child: Icon(
                    //         Icons.photo_outlined,
                    //         size: 40,
                    //         color: primaryColor,
                    //       ),
                    //     ),
                    //     SizedBox(
                    //       width: width * 0.010,
                    //     ),
                    //     Expanded(
                    //       child: Obx(
                    //         () => Container(
                    //           height: height * 0.060,
                    //           margin: EdgeInsets.symmetric(
                    //               horizontal: width * 0.030),
                    //           child: ListView.separated(
                    //             itemBuilder: (c, i) {
                    //               return InkWell(
                    //                 onTap: () {
                    //                   if (!controller.listOfSelectedfiles
                    //                           .contains(controller
                    //                               .listOfVidoeFilea[i]) &&
                    //                       controller
                    //                               .listOfSelectedfiles.length <
                    //                           8) {
                    //                     controller.listOfSelectedfiles.add(
                    //                         controller.listOfVidoeFilea[i]);
                    //                   }
                    //                 },
                    //                 child: ClipRRect(
                    //                   borderRadius: BorderRadius.circular(8),
                    //                   child: Container(
                    //                     height: height * 0.060,
                    //                     width: width * 0.120,
                    //                     child: Stack(
                    //                       children: [
                    //                         Container(
                    //                           height: height * 0.060,
                    //                           width: width * 0.120,
                    //                           child: Thumbnails(
                    //                             thumb: controller
                    //                                     .listOfVidoeFilea[i]
                    //                                 ['video'],
                    //                           ),
                    //                         ),
                    //                         Center(
                    //                           child: Icon(
                    //                             Icons.play_circle_fill,
                    //                             size: 20,
                    //                             color: Colors.white,
                    //                           ),
                    //                         )
                    //                       ],
                    //                     ),
                    //                   ),
                    //                 ),
                    //               );
                    //             },
                    //             scrollDirection: Axis.horizontal,
                    //             separatorBuilder:
                    //                 (BuildContext context, int index) {
                    //               return SizedBox(
                    //                 width: 10,
                    //               );
                    //             },
                    //             itemCount: controller.listOfVidoeFilea.length,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    //   crossAxisAlignment: CrossAxisAlignment.end,
                    // ),
                    // SizedBox(
                    //   height: 15,
                    // ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            // controller.selectLocation(context);
                            Get.to(CameraApp())!.then((value) {
                              print('path is = $newPathis');
                              if (newPathis.isNotEmpty) {
                                if (newPathis.contains('mp4')) {
                                  if (!controller.listOfSelectedfiles
                                      .contains('$newPathis')) {
                                    controller.listOfSelectedfiles
                                        .add({'video': '$newPathis'});
                                  }
                                } else {
                                  if (!controller.listOfSelectedfiles
                                      .contains('$newPathis')) {
                                    controller.listOfSelectedfiles
                                        .add({'image': '$newPathis'});
                                  }
                                }
                                newPathis = '';
                              }
                            });
                          },
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          width: width * 0.010,
                        ),
                        InkWell(
                          onTap: () {
                            controller.gallarypress();
                          },
                          child: Icon(
                            Icons.photo_outlined,
                            size: 40,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          width: width * 0.010,
                        ),
                        Expanded(
                          child: Obx(
                            () => Container(
                              height: height * 0.060,
                              margin: EdgeInsets.symmetric(
                                  horizontal: width * 0.030),
                              child: ListView.separated(
                                itemBuilder: (c, i) {
                                  return FutureBuilder(
                                    builder: (ctx, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (controller.assetsEntity[i].type ==
                                            AssetType.image) {
                                          return InkWell(
                                            onTap: () {
                                              print(
                                                  '${controller.listOfSelectedfiles}');
                                              File file =
                                                  snapshot.data! as File;
                                              if (!controller
                                                      .listOfSelectedfiles
                                                      .contains({
                                                    'image':
                                                        file.path.toString()
                                                  }) &&
                                                  controller.listOfSelectedfiles
                                                          .length <
                                                      8) {
                                                controller.listOfSelectedfiles
                                                    .add({
                                                  'image': file.path.toString()
                                                });
                                              }
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Container(
                                                height: height * 0.060,
                                                width: width * 0.120,
                                                child: Image.file(
                                                  snapshot.data! as File,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          if (controller.assetsEntity[i].type ==
                                              AssetType.video){
                                            File file = snapshot.data! as File;
                                            return InkWell(
                                              onTap: () {
                                                File file =
                                                snapshot.data! as File;
                                                if (!controller
                                                    .listOfSelectedfiles
                                                    .contains({
                                                  'video': file.path
                                                }) &&
                                                    controller.listOfSelectedfiles
                                                        .length <
                                                        8) {
                                                  controller.listOfSelectedfiles
                                                      .add({'video': file.path});
                                                }
                                              },
                                              child: ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(8),
                                                child: Container(
                                                  height: height * 0.060,
                                                  width: width * 0.120,
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        height: height * 0.060,
                                                        width: width * 0.120,
                                                        child: Thumbnails(
                                                          thumb: file.path,
                                                        ),
                                                      ),
                                                      Center(
                                                        child: Icon(
                                                          Icons.play_circle_fill,
                                                          size: 20,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }else{
                                            return SizedBox();
                                          }
                                        }
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    },
                                    // Future that needs to be resolved
                                    // inorder to display something on the Canvas
                                    future: controller.assetsEntity[i].file,
                                  );
                                  // return InkWell(
                                  //   onTap: () {
                                  //     if (!controller.listOfSelectedfiles
                                  //             .contains(controller
                                  //                 .listOfImageFilea[i]) &&
                                  //         controller
                                  //                 .listOfSelectedfiles.length <
                                  //             8) {
                                  //       controller.listOfSelectedfiles.add(
                                  //           controller.listOfImageFilea[i]);
                                  //     }
                                  //   },
                                  //   child: ClipRRect(
                                  //     borderRadius: BorderRadius.circular(8),
                                  //     child: Container(
                                  //       height: height * 0.060,
                                  //       width: width * 0.120,
                                  //       child: Image.file(
                                  //         File(controller.assetsEntity[i].file),
                                  //         fit: BoxFit.cover,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // );
                                },
                                scrollDirection: Axis.horizontal,
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return SizedBox(
                                    width: 10,
                                  );
                                },
                                itemCount: controller.assetsEntity.length,
                              ),
                            ),
                          ),
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.end,
                    ),
                    SizedBox(
                      height: 13,
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            userTagBottomSheet(context);
                          },
                          child: Text(
                            '@',
                            style: TextStyle(fontSize: 30, color: Colors.black),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            hashTagBottomSheet(context);
                          },
                          child: Text(
                            '#',
                            style: TextStyle(fontSize: 30, color: Colors.black),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.location_on,
                          color: Colors.black,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 3.w,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: height * 0.045,
                          width: width * 0.210,
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.025),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.grey[100]!.withOpacity(0.5),
                          ),
                          child: DropdownButton<String>(
                            items: <String>['Public', 'My Followers', 'Only Me']
                                .map((String value) {
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
                                  fontSize: 12, fontFamily: AppFonts.segoeui),
                            ),
                            onChanged: (value) {
                              dropDownValue = value!;
                              setState(() {});
                            },
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            var textController = TextEditingController().obs;
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
                                            horizontal: 10, vertical: 10),
                                        child: Column(
                                          children: [
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Select Event',
                                                  style: TextStyle(
                                                      fontFamily:
                                                          AppFonts.segoeui),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    showCupertinoModalBottomSheet(
                                                      expand: false,
                                                      context: context,
                                                      enableDrag: true,
                                                      backgroundColor:
                                                      Colors.transparent,
                                                      builder: (context) {
                                                        return Container(
                                                          height: height * 0.6,
                                                          child: CreateMyEvet(
                                                            onCreateCall:
                                                                () async {
                                                              getAllEvent();
                                                              setState(() {});
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) async{
                                                      await getAllEvent();
                                                      setState(() {});
                                                    });
                                                  },
                                                  child: Container(
                                                    height: height * 0.045,
                                                    width: width * 0.3,
                                                    child: Center(
                                                      child: Text(
                                                        'Create Event',
                                                        style: TextStyle(
                                                            fontFamily: AppFonts
                                                                .segoeui,
                                                            fontSize: 13,fontWeight: FontWeight.bold
                                                            ),
                                                      ),
                                                    ),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30)),
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
                                                          .value.text = '';
                                                      setState(() {});
                                                    },
                                                    child: Container(
                                                      height: height * 0.050,
                                                      margin: EdgeInsets.only(
                                                          bottom: 10),
                                                      decoration: BoxDecoration(
                                                          color: selectedEventId ==
                                                                  '${myEvetModel[i].eventId}'
                                                              ? primaryColor
                                                              : Colors
                                                                  .blueGrey[50]!
                                                                  .withOpacity(
                                                                      0.5)),
                                                      child: Center(
                                                        child: Text(
                                                          '${myEvetModel[i].eventTitle}',
                                                          style: TextStyle(
                                                              color: selectedEventId ==
                                                                      '${myEvetModel[i].eventId}'
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                itemCount: myEvetModel.length,
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
                            padding: EdgeInsets.symmetric(horizontal: 4),
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
                                color: Colors.blueGrey[50]!.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                        Container(
                          width: width * 0.2,
                          height: height * 0.040,
                          child: Center(
                            child: Text(
                              'Preview',
                              style: TextStyle(
                                  fontSize: 12, fontFamily: AppFonts.segoeui),
                            ),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.blueGrey[50]!.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        InkWell(
                          onTap: () async {
                            setState(() {
                              isLoading = true;
                            });
                            List listofurl = [];
                            for (var i in controller.listOfSelectedfiles) {
                              Map mapdata = i;
                              String value;
                              if (mapdata.containsKey('image')) {
                                if (i['image'].contains('(') ||
                                    i['image'].contains(')')) {
                                  File f = await File(i['image']).copy(
                                      i['image']
                                          .toString()
                                          .replaceAll('(', '')
                                          .replaceAll(')', '')
                                          .trim());
                                  value = await createStory(f.path);
                                } else {
                                  value = await createStory(i['image']);
                                }
                              } else {
                                if (i['video'].contains('(') ||
                                    i['video'].contains(')')) {
                                  File f = await File(i['video']).copy(
                                      i['video']
                                          .toString()
                                          .replaceAll('(', '')
                                          .replaceAll(')', '')
                                          .trim());
                                  value = await createStory(f.path);
                                } else {
                                  value = await createStory(i['video']);
                                }
                              }
                              listofurl.add(value);
                            }
                            print('listofurl= $listofurl');
                            await createPost(listofurl);
                            setState(() {
                              isLoading = false;
                            });
                            if (!widget.fromEvent!) {
                              snackBarSuccess('Create post successfully');
                            } else {
                              snackBarSuccess('Create Event successfully');
                            }
                            Future.delayed(Duration(seconds: 2), () {
                              Get.offAll(() => BottomSheetCustom());
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 7, horizontal: 30),
                            decoration: BoxDecoration(
                                color: Colors.blueGrey[50]!.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(25)),
                            child: Text(
                              'Post',
                              style: TextStyle(
                                  fontSize: 12, fontFamily: AppFonts.segoeui),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          )),
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

  void userTagBottomSheet(context) {
    showCupertinoModalBottomSheet(
      expand: false,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: height * 0.6,
          child: AddUserTags(
            selectedUserTags: selectedUserTags,
            onAddUserTag: (List<UserTagModel> selectedUserTagList) {
              setState(() {
                selectedUserTags = selectedUserTagList;
                usersTags = [];
                usersTagsPic = [];
                selectedUserTags.forEach((element) {
                  usersTags.add(element.userId);
                  usersTagsPic.add(element.userPicture);
                });
              });
            },
          ),
        );
      },
    );
  }

  void hashTagBottomSheet(context) {
    showCupertinoModalBottomSheet(
      expand: false,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: height * 0.6,
          child: AddHashTags(
            selectedHashTags: selectedHashTags,
            onAddHashTag: (List<HashTagModel> selectedHashTagList) {
              setState(() {
                selectedHashTags = selectedHashTagList;
                hashTags = [];
                selectedHashTags.forEach((element) {
                  hashTags.add(element.hashtag);
                });
              });
            },
          ),
        );
      },
    );
  }

  Widget returnCard(Map data) {
    if (data.containsKey('image')) {
      return Image.file(
        File(data['image']),
        fit: BoxFit.cover,
      );
    } else {
      return Thumbnails(
        thumb: data['video'],
      );
    }
  }

  Future<void> createPost(List files) async {
    print('files paths = $files');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = await prefs.getString('user_id');
    String? token = await prefs.getString('token');
    print('$userId and $hashTags and $usersTags');
    // print(jsonEncode({
    //   "post_type": "photos",
    //   "user_type": "user",
    //   "user_id": userId,
    //   "privacy": dropDownValue == 'Public' ? "public" :dropDownValue == 'My Followers'?'friends': "me",
    //   "post_description": descriptionController.text,
    //   "hashtag": hashTags,
    //   "tagusers": usersTags,
    //   "files": files
    // }));
    if (selectedEventtitle == '') {
      final response = await http.post(
          Uri.parse(
              '$baseUrl${widget.fromEvent! ? 'addpostNewEvent' : 'addpostNew'}$code'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": token!
          },
          body: widget.fromEvent!
              ? jsonEncode({
                  "post_type": "photos",
                  "user_type": "user",
                  "event_id": widget.event_id,
                  "in_event": "1",
                  "user_id": int.parse(userId!),
                  "privacy": dropDownValue == 'Public'
                      ? "public"
                      : dropDownValue == 'My Followers'
                          ? 'friends'
                          : "me",
                  "post_description": descriptionController.text,
                  "hashtag": hashTags,
                  "tagusers": usersTags,
                  "files": files,
                  "post_postion": top ? '1' : '0'
                })
              : jsonEncode({
                  "post_type": "photos",
                  "user_type": "user",
                  "user_id": int.parse(userId!),
                  "privacy": dropDownValue == 'Public'
                      ? "public"
                      : dropDownValue == 'My Followers'
                          ? 'friends'
                          : "me",
                  "post_description": descriptionController.text,
                  "hashtag": hashTags,
                  "tagusers": usersTags,
                  "files": files,
                  "post_postion": top ? '1' : '0'
                }));
      print('response is = ${response.body}');
    } else {
      final response = await http.post(
          Uri.parse(
              '${baseUrl}${widget.fromEvent! ? 'addpostNewEvent' : 'addpostNewMyEvent'}$code'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": token!
          },
          body: widget.fromEvent!
              ? jsonEncode({
                  "post_type": "photos",
                  "user_type": "user",
                  "event_id": widget.event_id,
                  "in_event": "1",
                  "user_id": int.parse(userId!),
                  "privacy": dropDownValue == 'Public'
                      ? "public"
                      : dropDownValue == 'My Followers'
                          ? 'friends'
                          : "me",
                  "post_description": descriptionController.text,
                  "hashtag": hashTags,
                  "tagusers": usersTags,
                  "files": files,
                  "post_postion": top ? '1' : '0'
                })
              : jsonEncode({
                  "post_type": "photos",
                  "my_event_id": selectedEventId,
                  "user_type": "user",
                  "user_id": int.parse(userId!),
                  "privacy": dropDownValue == 'Public'
                      ? "public"
                      : dropDownValue == 'My Followers'
                          ? 'friends'
                          : "me",
                  "post_description": descriptionController.text,
                  "hashtag": hashTags,
                  "tagusers": usersTags,
                  "files": files,
                  "post_postion": top ? '1' : '0'
                }));
      print('response is = ${response.body}');
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
}
