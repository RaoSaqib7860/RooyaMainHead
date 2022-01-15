import 'dart:async';
import 'dart:ui';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:rooya_app/ApiUtils/baseUrl.dart';
import 'package:rooya_app/Screens/Reel/ReelController.dart';

//import 'package:rooya_app/CreateReel/CreateReel.dart';
import 'package:rooya_app/Screens/VideoPlayerService/VideoPlayer.dart';
import 'package:rooya_app/ViewAllComments/ViewAllComments.dart';
import 'package:rooya_app/src/views/video_recorder.dart';
import 'package:rooya_app/utils/AppFonts.dart';
import 'package:rooya_app/utils/colors.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:math' as math;

import 'ReelCamera/RotateWidget.dart';

StreamController<double> controller = StreamController<double>.broadcast();

class ReelPage extends StatefulWidget {
  const ReelPage({Key? key}) : super(key: key);

  @override
  _ReelPageState createState() => _ReelPageState();
}

class _ReelPageState extends State<ReelPage> {
  final controller = Get.put(ReelController());
  List listofTag = [
    '#expo',
    '#dubaiexpo',
    '#expo2020',
    '#expo20',
    '#party',
    '#enjoy',
    '#expohype',
    '#expolove',
    '#expolive'
  ];
  String basePath = 'assets/videos/';

  @override
  void initState() {
    controller.getReelData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = Get.height;
    var width = Get.width;
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() => Stack(
            children: [
              Container(
                height: height,
                width: width,
                child: controller.listofReels.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : PageView.builder(
                        itemBuilder: (c, i) {
                          return Stack(
                            children: [
                              Container(
                                height: height,
                                width: width,
                                child: VideoApp(
                                  assetsPath:
                                      '$baseReelPath${controller.listofReels[i].videoAttachment![0].attachment}',
                                ),
                                decoration: BoxDecoration(color: Colors.black),
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: width,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.050),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircularProfileAvatar(
                                              '$baseReelPath${controller.listofReels[i].userPicture}',
                                              // child: Image.asset(
                                              //   'assets/images/model.jpeg',
                                              //   fit: BoxFit.cover,
                                              // ),
                                              borderColor: Colors.white,
                                              borderWidth: 1,
                                              elevation: 2,
                                              radius: 20,
                                            ),
                                            SizedBox(
                                              width: width * 0.040,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${controller.listofReels[i].userName}',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          AppFonts.segoeui,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontSize: 14),
                                                ),
                                                Text(
                                                  '${timeago.format(DateTime.parse(controller.listofReels[i].time!), locale: 'en_short')} ago',
                                                  style: TextStyle(
                                                      fontFamily:
                                                          AppFonts.segoeui,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          '${controller.listofReels[i].text!}'
                                              .replaceAll('\n', ' ')
                                              .trim()
                                              .toString(),
                                          style: TextStyle(
                                              fontFamily: AppFonts.segoeui,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        // Padding(
                                        //   padding: EdgeInsets.only(right: width * 0.1),
                                        //   child: Wrap(
                                        //     children: listofTag.map((e) {
                                        //       return Padding(
                                        //         padding: EdgeInsets.only(
                                        //             right: width * 0.030,
                                        //             bottom: height * 0.008),
                                        //         child: Text(
                                        //           '$e',
                                        //           style: TextStyle(
                                        //               color: Colors.white,
                                        //               fontWeight: FontWeight.w200,
                                        //               fontSize: 13),
                                        //         ),
                                        //       );
                                        //     }).toList(),
                                        //   ),
                                        // ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                RotateWidget(
                                                  child: controller
                                                              .listofReels[i]
                                                              .attachment![0]
                                                              .musicCover ==
                                                          ''
                                                      ? CircularProfileAvatar(
                                                          '',
                                                          child: Image.asset(
                                                              'assets/images/logo.png'),
                                                          radius: 15,
                                                          borderColor:
                                                              primaryColor,
                                                          borderWidth: 1,
                                                        )
                                                      : CircularProfileAvatar(
                                                          '${controller.listofReels[i].attachment![0].musicCover}',
                                                          borderColor:
                                                              Colors.white,
                                                          borderWidth: 1,
                                                          elevation: 2,
                                                          radius: 15,
                                                        ),
                                                ),
                                                SizedBox(
                                                  width: width * 0.010,
                                                ),
                                                Icon(
                                                  Icons.music_note,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                SizedBox(
                                                  width: width * 0.010,
                                                ),
                                                Text(
                                                  '${controller.listofReels[i].attachment![0].musicName}'
                                                      .replaceAll('Null', '')
                                                      .trim(),
                                                  style: TextStyle(
                                                      fontFamily:
                                                          AppFonts.segoeui,
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                )
                                              ],
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Get.to(VideoRecorder(
                                                  isInnitial: true,
                                                ));
                                              },
                                              child: Container(
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                ),
                                                padding: EdgeInsets.all(7),
                                                decoration: BoxDecoration(
                                                    color: greenColor,
                                                    shape: BoxShape.circle),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.010,
                                  ),
                                  Container(
                                    height: height * 0.080,
                                    width: width,
                                    // padding:
                                    //     EdgeInsets.symmetric(horizontal: width * 0.060),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 10.0,
                                          sigmaY: 10.0,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: width * 0.060),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              bottomIcon(
                                                  text:
                                                      '${controller.listofReels[i].shares}',
                                                  svg: 'share'),
                                              InkWell(
                                                child: bottomIcon(
                                                    text:
                                                        '${controller.listofReels[i].comments}',
                                                    svg: 'message'),
                                                onTap: () {
                                                  Get.to(
                                                          ViewAllComments(
                                                            comments: controller
                                                                .listofReels[i]
                                                                .commentsText,
                                                            postID: controller
                                                                .listofReels[i]
                                                                .postId
                                                                .toString(),
                                                          ),
                                                          transition: Transition
                                                              .downToUp)!
                                                      .then((value) {
                                                    controller.getReelData();
                                                  });
                                                },
                                              ),
                                              bottomIcon(
                                                  text:
                                                      '${controller.listofReels[i].likecount}',
                                                  svg: 'like'),
                                              bottomIcon(
                                                  text:
                                                      '${controller.listofReels[i].views}',
                                                  svg: 'watch'),
                                              SvgPicture.asset(
                                                  'assets/svg/more.svg'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    margin: EdgeInsets.symmetric(
                                        horizontal: width * 0.090),
                                  ),
                                  SizedBox(
                                    height: height * 0.020,
                                  )
                                ],
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                              ),
                            ],
                          );
                        },
                        itemCount: controller.listofReels.length,
                        scrollDirection: Axis.vertical,
                      ),
              ),
              Padding(
                padding: EdgeInsets.only(top: height * 0.030),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Following',
                      style: TextStyle(
                        fontFamily: AppFonts.segoeui,
                        color: Colors.white,
                        letterSpacing: 0.7,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 1,
                      height: 15,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'For You',
                      style: TextStyle(
                          fontFamily: AppFonts.segoeui,
                          color: Colors.white.withOpacity(0.5),
                          letterSpacing: 0.7,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    )
                  ],
                ),
              )
            ],
          )),
    ));
  }

  Widget bottomIcon({String? svg, String? text}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/svg/$svg.svg'),
        SizedBox(
          height: 7,
        ),
        Text(
          '$text',
          style: TextStyle(
              fontFamily: AppFonts.segoeui, color: Colors.white, fontSize: 12),
        )
      ],
    );
  }

  Widget _rotateAnimationWidget(BuildContext context, Widget child) {
    List<int> angleList = [10, 20, 10, -30, 0, 20, -30, 40, 10, 10, 30];
    Widget? transform;
    int i = 0;

    do {
      transform = Transform.rotate(
          angle: angleList[i] * math.pi / 180, child: transform);
      i++;
    } while (i < angleList.length - 1);

    transform =
        Transform.rotate(angle: angleList.last * math.pi / 180, child: child);

    return SizedBox(height: 200, width: 200, child: transform);
  }
}
