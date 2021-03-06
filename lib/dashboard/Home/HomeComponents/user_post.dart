import 'dart:convert';
import 'dart:developer';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rooya_app/ViewAllComments/ViewAllComments.dart';
import 'package:rooya_app/dashboard/Home/EditPost/EditPost.dart';
import 'package:rooya_app/dashboard/Home/HomeComponents/PostWith1Image.dart';
import 'package:rooya_app/dashboard/Home/HomeComponents/PostWith2Images.dart';
import 'package:rooya_app/dashboard/Home/HomeComponents/PostWith3Images.dart';
import 'package:rooya_app/dashboard/Home/HomeComponents/PostWith4Images.dart';
import 'package:rooya_app/dashboard/Home/HomeComponents/PostWith5Images.dart';
import 'package:rooya_app/dashboard/Home/Models/RooyaPostModel.dart';
import 'package:rooya_app/ApiUtils/baseUrl.dart';
import 'package:rooya_app/dashboard/Home/OpenSinglePost/OpenSinglePost.dart';
import 'package:rooya_app/utils/AppFonts.dart';
import 'package:rooya_app/utils/SizedConfig.dart';
import 'package:rooya_app/utils/SnackbarCustom.dart';
import 'package:rooya_app/utils/colors.dart';
import 'package:rooya_app/view_pic.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../profile.dart';

DateFormat sdf2 = DateFormat("hh:mm aa");
TextEditingController mCommentController = TextEditingController();

class UserPost extends StatefulWidget {
  RooyaPostModel? rooyaPostModel;
  Function()? onPostLike;
  Function()? onPostUnLike;
  Function()? comment;
  bool? fromEvent;
  bool? viewFullText;

  UserPost(
      {Key? key,
      this.rooyaPostModel,
      this.onPostLike,
      this.onPostUnLike,
      this.fromEvent = false,
      this.comment,
      this.viewFullText = false})
      : super(key: key);

  @override
  _UserPostState createState() => _UserPostState();
}

class _UserPostState extends State<UserPost> {
  bool isLikeLoading = false;
  bool isCommentLoading = false;

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      padding: EdgeInsets.only(left: width * 0.030, top: 10),
      margin: EdgeInsets.only(
        bottom: 7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 5,
              ),
              widget.rooyaPostModel!.userPicture == null
                  ? CircularProfileAvatar(
                      '',
                      child: Image.asset('assets/images/logo.png'),
                      elevation: 5,
                      radius: 23,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (c) => Profile(
                                  userID:
                                      '${widget.rooyaPostModel!.userPosted}',
                                )));
                      },
                      borderColor: appThemes,
                      borderWidth: 1,
                    )
                  : CircularProfileAvatar(
                      '$baseImageUrl${widget.rooyaPostModel!.userPicture}',
                      elevation: 5,
                      radius: 23,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (c) => Profile(
                                  userID:
                                      '${widget.rooyaPostModel!.userPosted}',
                                )));
                      },
                      borderColor: appThemes,
                      borderWidth: 1,
                    ),
              SizedBox(
                width: 4.0.w,
              ),
              InkWell(
                onTap: () {
                  print('Click on profile');
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (c) => Profile(
                            userID: '${widget.rooyaPostModel!.userPosted}',
                          )));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('${widget.rooyaPostModel!.userfullname}',
                            style: TextStyle(
                              fontFamily: AppFonts.segoeui,
                              fontSize: 13,
                              color: const Color(0xff000000),
                              fontWeight: FontWeight.w600,
                            )),
                        // Row(
                        //   children: [
                        //     SizedBox(
                        //       width: 5,
                        //     ),
                        //     Text(
                        //         '  ${widget.rooyaPostModel!.event_id == '0' ? 'Add a post' : 'Add post in a Event ${widget.rooyaPostModel!.event_name}'}',
                        //         style: TextStyle(
                        //           fontFamily: AppFonts.segoeui,
                        //           fontSize: 11,
                        //           color: Colors.black38,
                        //         )),
                        //   ],
                        // ),
                      ],
                    ),
                    Text(
                      '@${widget.rooyaPostModel!.userName}',
                      maxLines: 2,
                      style: TextStyle(
                        fontFamily: AppFonts.segoeui,
                        fontSize: 10,
                        color: const Color(0xff000000),
                      ),
                      textAlign: TextAlign.left,
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Container(
                margin: EdgeInsets.only(top: height * 0.020),
                child: Text(
                  '${sdf2.format(DateTime.parse("${widget.rooyaPostModel!.time!}").toUtc().toLocal())} ${DateTime.parse("${widget.rooyaPostModel!.time!}").day} ${DateFormat.yMMM().format(DateTime.parse("${widget.rooyaPostModel!.time!}")).toString().split(' ')[0]} ${DateTime.parse("${widget.rooyaPostModel!.time!}").year}',
                  //'${sdf2.format(DateTime.parse("${widget.rooyaPostModel!.time!}").toUtc().toLocal())}',
                  style: TextStyle(
                    fontFamily: AppFonts.segoeui,
                    fontSize: 10,
                    color: const Color(0xff000000),
                    height: 1.8,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                width: 40,
              )
            ],
          ),
          SizedBox(
            height: 1.0.h,
          ),
          Container(
            // padding: EdgeInsets.symmetric(horizontal: width * 0.030),
            child: widget.rooyaPostModel!.post_postion == '1'
                ? Padding(
                    padding: EdgeInsets.only(
                      right: width * 0.250,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(
                              OpenSinglePost(
                                postId:
                                    widget.rooyaPostModel!.postId.toString(),
                                model: widget.rooyaPostModel!,
                                containData: true,
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 3),
                            child: Text(
                              '${widget.rooyaPostModel!.text}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: widget.viewFullText! ? 50 : 4,
                              style: TextStyle(
                                fontFamily: AppFonts.segoeui,
                                fontSize: 12,
                                color: const Color(0xff000000),
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        widget.rooyaPostModel!.attachment!.length > 0
                            ? widget.rooyaPostModel!.attachment!.length == 1
                                ? PostWith1Image(
                                    rooyaPostModel: widget.rooyaPostModel,
                                  )
                                : widget.rooyaPostModel!.attachment!.length == 2
                                    ? PostWith2Images(
                                        rooyaPostModel: widget.rooyaPostModel,
                                      )
                                    : widget.rooyaPostModel!.attachment!
                                                .length ==
                                            3
                                        ? PostWith3Images(
                                            rooyaPostModel:
                                                widget.rooyaPostModel,
                                          )
                                        : widget.rooyaPostModel!.attachment!
                                                    .length ==
                                                4
                                            ? PostWith4Images(
                                                rooyaPostModel:
                                                    widget.rooyaPostModel,
                                              )
                                            : PostWith5Images(
                                                rooyaPostModel:
                                                    widget.rooyaPostModel,
                                              )
                            : Container(),
                        // widget.rooyaPostModel!.posthashtags!.isNotEmpty
                        //     ? widget.rooyaPostModel!.posthashtags!.length == 1 &&
                        //             widget
                        //                 .rooyaPostModel!.posthashtags![0].hashtag
                        //                 .toString()
                        //                 .trim()
                        //                 .isEmpty
                        //         ? SizedBox()
                        //         : Container(
                        //             width: 100.0.w,
                        //             padding: EdgeInsets.symmetric(
                        //                 horizontal: 2.0.w, vertical: 2.0.w),
                        //             child: Wrap(
                        //               children: widget
                        //                   .rooyaPostModel!.posthashtags!
                        //                   .map((hashTag) {
                        //                 return InkWell(
                        //                   onTap: () {
                        //                     // print('${'${widget.rooyaPostModel!.postId}'}');
                        //                     // Navigator.of(context)
                        //                     //     .push(MaterialPageRoute(
                        //                     //         builder: (c) => Profile(
                        //                     //               userID:
                        //                     //                   '${widget.rooyaPostModel!.postId}',
                        //                     //             )));
                        //                   },
                        //                   child: Container(
                        //                     margin: EdgeInsets.symmetric(
                        //                         horizontal: 1.0.w),
                        //                     child: Text('${hashTag.hashtag}',
                        //                         style: TextStyle(
                        //                           fontFamily: AppFonts.segoeui,
                        //                           fontSize: 12,
                        //                           color: const Color(0xff5a5a5a),
                        //                         )),
                        //                   ),
                        //                 );
                        //               }).toList(),
                        //             ),
                        //           )
                        //     : Container(),
                        SizedBox(
                          height:
                              !widget.rooyaPostModel!.postusertags!.isNotEmpty
                                  ? 0
                                  : 1.0.h,
                        ),
                        widget.rooyaPostModel!.postusertags!.isNotEmpty
                            ? Container(
                                width: 100.0.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(1.5.h),
                                      bottomRight: Radius.circular(1.5.h)),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.0.w, vertical: 2.0.w),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 0,
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 4.0.h,
                                        width: 4.0.h,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft:
                                                  Radius.circular(1.5.h),
                                              bottomRight:
                                                  Radius.circular(1.5.h)),
                                        ),
                                        child: ListView.builder(
                                          itemBuilder: (c, i) {
                                            return Container(
                                              margin: EdgeInsets.only(right: 5),
                                              child: widget
                                                              .rooyaPostModel!
                                                              .postusertags![i]
                                                              .userPicture !=
                                                          null &&
                                                      widget
                                                              .rooyaPostModel!
                                                              .postusertags![i]
                                                              .userPicture !=
                                                          ''
                                                  ? CircularProfileAvatar(
                                                      '$baseImageUrl${widget.rooyaPostModel!.postusertags![i].userPicture}',
                                                      radius: 15,
                                                      onTap: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (c) =>
                                                                    Profile(
                                                                      userID:
                                                                          '${widget.rooyaPostModel!.postusertags![i].userId}',
                                                                    )));
                                                      },
                                                    )
                                                  : CircularProfileAvatar(
                                                      '',
                                                      child: Image.asset(
                                                          'assets/images/logo.png'),
                                                      radius: 15,
                                                      onTap: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (c) =>
                                                                    Profile(
                                                                      userID:
                                                                          '${widget.rooyaPostModel!.postusertags![i].userId}',
                                                                    )));
                                                      },
                                                    ),
                                            );
                                          },
                                          itemCount: widget.rooyaPostModel!
                                              .postusertags!.length,
                                          scrollDirection: Axis.horizontal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        // SizedBox(height: 2.0.h,),
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.only(
                      right: width * 0.250,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.rooyaPostModel!.attachment!.length > 0
                            ? widget.rooyaPostModel!.attachment!.length == 1
                                ? PostWith1Image(
                                    rooyaPostModel: widget.rooyaPostModel,
                                  )
                                : widget.rooyaPostModel!.attachment!.length == 2
                                    ? PostWith2Images(
                                        rooyaPostModel: widget.rooyaPostModel,
                                      )
                                    : widget.rooyaPostModel!.attachment!
                                                .length ==
                                            3
                                        ? PostWith3Images(
                                            rooyaPostModel:
                                                widget.rooyaPostModel,
                                          )
                                        : widget.rooyaPostModel!.attachment!
                                                    .length ==
                                                4
                                            ? PostWith4Images(
                                                rooyaPostModel:
                                                    widget.rooyaPostModel,
                                              )
                                            : PostWith5Images(
                                                rooyaPostModel:
                                                    widget.rooyaPostModel,
                                              )
                            : Container(),
                        InkWell(
                          onTap: () {
                            Get.to(
                              OpenSinglePost(
                                postId:
                                    widget.rooyaPostModel!.postId.toString(),
                                model: widget.rooyaPostModel!,
                                containData: true,
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 3),
                            child: Text(
                              '${widget.rooyaPostModel!.text}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: widget.viewFullText! ? 50 : 4,
                              style: TextStyle(
                                fontFamily: AppFonts.segoeui,
                                fontSize: 12,
                                color: const Color(0xff000000),
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        // widget.rooyaPostModel!.posthashtags!.isNotEmpty
                        //     ? widget.rooyaPostModel!.posthashtags!.length == 1 &&
                        //             widget
                        //                 .rooyaPostModel!.posthashtags![0].hashtag
                        //                 .toString()
                        //                 .trim()
                        //                 .isEmpty
                        //         ? SizedBox()
                        //         : Container(
                        //             width: 100.0.w,
                        //             padding: EdgeInsets.symmetric(
                        //                 horizontal: 2.0.w, vertical: 2.0.w),
                        //             child: Wrap(
                        //               children: widget
                        //                   .rooyaPostModel!.posthashtags!
                        //                   .map((hashTag) {
                        //                 return InkWell(
                        //                   onTap: () {
                        //                     // print('${'${widget.rooyaPostModel!.postId}'}');
                        //                     // Navigator.of(context)
                        //                     //     .push(MaterialPageRoute(
                        //                     //         builder: (c) => Profile(
                        //                     //               userID:
                        //                     //                   '${widget.rooyaPostModel!.postId}',
                        //                     //             )));
                        //                   },
                        //                   child: Container(
                        //                     margin: EdgeInsets.symmetric(
                        //                         horizontal: 1.0.w),
                        //                     child: Text('${hashTag.hashtag}',
                        //                         style: TextStyle(
                        //                           fontFamily: AppFonts.segoeui,
                        //                           fontSize: 12,
                        //                           color: const Color(0xff5a5a5a),
                        //                         )),
                        //                   ),
                        //                 );
                        //               }).toList(),
                        //             ),
                        //           )
                        //   : Container(),
                        SizedBox(
                          height:
                              !widget.rooyaPostModel!.postusertags!.isNotEmpty
                                  ? 0
                                  : 1.0.h,
                        ),
                        widget.rooyaPostModel!.postusertags!.isNotEmpty
                            ? Container(
                                width: 100.0.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(1.5.h),
                                      bottomRight: Radius.circular(1.5.h)),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.0.w, vertical: 2.0.w),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 0,
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 4.0.h,
                                        width: 4.0.h,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft:
                                                  Radius.circular(1.5.h),
                                              bottomRight:
                                                  Radius.circular(1.5.h)),
                                        ),
                                        child: ListView.builder(
                                          itemBuilder: (c, i) {
                                            return Container(
                                              margin: EdgeInsets.only(right: 5),
                                              child: widget
                                                              .rooyaPostModel!
                                                              .postusertags![i]
                                                              .userPicture !=
                                                          null &&
                                                      widget
                                                              .rooyaPostModel!
                                                              .postusertags![i]
                                                              .userPicture !=
                                                          ''
                                                  ? CircularProfileAvatar(
                                                      '$baseImageUrl${widget.rooyaPostModel!.postusertags![i].userPicture}',
                                                      radius: 15,
                                                      onTap: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (c) =>
                                                                    Profile(
                                                                      userID:
                                                                          '${widget.rooyaPostModel!.postusertags![i].userId}',
                                                                    )));
                                                      },
                                                    )
                                                  : CircularProfileAvatar(
                                                      '',
                                                      child: Image.asset(
                                                          'assets/images/logo.png'),
                                                      radius: 15,
                                                      onTap: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (c) =>
                                                                    Profile(
                                                                      userID:
                                                                          '${widget.rooyaPostModel!.postusertags![i].userId}',
                                                                    )));
                                                      },
                                                    ),
                                            );
                                          },
                                          itemCount: widget.rooyaPostModel!
                                              .postusertags!.length,
                                          scrollDirection: Axis.horizontal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        // SizedBox(height: 2.0.h,),
                      ],
                    ),
                  ),
          ),
          SizedBox(
            height: 0.50.w,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: 2.0.w, horizontal: width * 0.030),
            child: Row(
              children: [
                InkWell(
                  onTap: () async {
                    if (!isLikeLoading) {
                      isLikeLoading = true;
                      if (widget.rooyaPostModel!.islike!) {
                        await rooyaPostUnLike();
                      } else {
                        await rooyaPostLike();
                      }
                      isLikeLoading = false;
                    }
                  },
                  child: Row(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 3, right: 5),
                          child: SvgPicture.asset(
                            'assets/BottomTabSVG/Like.svg',
                            height: 30,
                            color: widget.rooyaPostModel!.islike!
                                ? appThemes
                                : Colors.black54,
                          )
                          // Icon(
                          //                       widget.rooyaPostModel!.islike!
                          //                           ? CupertinoIcons.heart_fill
                          //                           : CupertinoIcons.heart,
                          //                       color: widget.rooyaPostModel!.islike!
                          //                           ? appThemes
                          //                           : Colors.black54,
                          //                       size: 23,
                          //                     ),
                          ),
                      Text(
                        '${widget.rooyaPostModel!.likecount}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontFamily: AppFonts.segoeui),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 4.0.w,
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 3, right: 5),
                      child: InkWell(
                        onTap: () {
                          Get.to(ViewAllComments(
                            comments: widget.rooyaPostModel!.commentsText,
                            postID: widget.rooyaPostModel!.postId.toString(),
                          ))!
                              .then((value) {
                            widget.comment!.call();
                          });
                        },
                        child: SvgPicture.asset(
                          'assets/BottomTabSVG/Comment.svg',
                          height: 19,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.rooyaPostModel!.comments}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontFamily: AppFonts.segoeui),
                    ),
                  ],
                ),
                SizedBox(
                  width: 4.0.w,
                ),
                InkWell(
                  child: SvgPicture.asset(
                    'assets/svg/SavePost.svg',
                    height: 27,
                  ),
                  onTap: () {
                    SharePost();
                  },
                ),
                SizedBox(
                  width: 4.0.w,
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 15,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        Share.share(
                                            'https://fm.dynamicstech.net/posts/${widget.rooyaPostModel!.postId}');
                                      },
                                      child: Container(
                                        height: height * 0.055,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: width * 0.030),
                                        width: width,
                                        child: Row(
                                          children: [
                                            Text(
                                              'Share',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              width: width * 0.030,
                                            ),
                                            Icon(
                                              Icons.share,
                                              size: 20,
                                            )
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                        ),
                                        decoration: BoxDecoration(
                                            color: Colors.blueGrey[50],
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(
                                            text:
                                                "https://fm.dynamicstech.net/posts/${widget.rooyaPostModel!.postId}"));
                                        snackBarSuccess(
                                            'Link copy Successfully');
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        height: height * 0.055,
                                        width: width,
                                        child: Row(
                                          children: [
                                            Text(
                                              'Copy link',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              width: width * 0.030,
                                            ),
                                            Icon(
                                              Icons.copy,
                                              size: 20,
                                            )
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                        ),
                                        margin: EdgeInsets.symmetric(
                                            horizontal: width * 0.030),
                                        decoration: BoxDecoration(
                                            color: Colors.blueGrey[50],
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      child: SvgPicture.asset(
                        'assets/svg/SharePost.svg',
                        height: 20,
                      ),
                    ),
                  ],
                ),
                // Expanded(
                //   child: Row(
                //     children: [
                //       InkWell(
                //         child: SvgPicture.asset(
                //           'assets/svg/SharePost.svg',
                //           height: 18,
                //         ),
                //         onTap: () {
                //           SharePost();
                //         },
                //       )
                //     ],
                //     mainAxisAlignment: MainAxisAlignment.end,
                //   ),
                // ),
                SizedBox(
                  width: Get.width * 0.030,
                )
              ],
            ),
          ),
          SizedBox(
            height: 0.50.w,
          ),
          // InkWell(
          //   onTap: () {
          //     Get.to(ViewAllComments(
          //       comments: widget.rooyaPostModel!.commentsText,
          //       postID: widget.rooyaPostModel!.postId.toString(),
          //     ))!
          //         .then((value) {
          //       widget.comment!.call();
          //     });
          //   },
          //   child: Container(
          //     height: height * 0.055,
          //     margin: EdgeInsets.symmetric(horizontal: width * 0.030),
          //     width: width,
          //     decoration: BoxDecoration(
          //         border: Border.all(color: appThemes, width: 1),
          //         borderRadius: BorderRadius.circular(25)),
          //     child: CommentPostFields(
          //       enable: false,
          //       sendCommit: (text) {
          //         rooyaPostComment(text: text);
          //       },
          //     ),
          //   ),
          // ),

          // Flexible(
          //     fit: FlexFit.loose,
          //     child: ListView.builder(
          //         physics: NeverScrollableScrollPhysics(),
          //         shrinkWrap: true,
          //         itemCount: widget.rooyaPostModel!.commentsText!.length > 3
          //             ? 3
          //             : widget.rooyaPostModel!.commentsText!.length,
          //         itemBuilder: (context, index) {
          //           return Container(
          //             margin: EdgeInsets.symmetric(
          //                 vertical: 2.0.h, horizontal: 3.0.w),
          //             child: Row(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 InkWell(
          //                   child: widget.rooyaPostModel!.commentsText![index]
          //                                   .profileImg !=
          //                               null &&
          //                           widget.rooyaPostModel!.commentsText![index]
          //                                   .profileImg !=
          //                               ''
          //                       ? CircularProfileAvatar(
          //                           '$baseImageUrl${widget.rooyaPostModel!.commentsText![index].profileImg}',
          //                           radius: 18,
          //                         )
          //                       : CircularProfileAvatar(
          //                           '',
          //                           child:
          //                               Image.asset('assets/images/logo.png'),
          //                           radius: 18,
          //                         ),
          //                   onTap: () {
          //                     Navigator.of(context).push(MaterialPageRoute(
          //                         builder: (c) => Profile(
          //                               userID:
          //                                   '${widget.rooyaPostModel!.commentsText![index].userId}',
          //                             )));
          //                   },
          //                 ),
          //                 SizedBox(
          //                   width: 2.0.w,
          //                 ),
          //                 Expanded(
          //                     child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   children: [
          //                     SizedBox(
          //                       height: 5,
          //                     ),
          //                     InkWell(
          //                       onTap: () {
          //                         Navigator.of(context).push(MaterialPageRoute(
          //                             builder: (c) => Profile(
          //                                   userID:
          //                                       '${widget.rooyaPostModel!.commentsText![index].userId}',
          //                                 )));
          //                       },
          //                       child: Text(
          //                           '${widget.rooyaPostModel!.commentsText![index].userfullname}',
          //                           style: TextStyle(
          //                               fontFamily: AppFonts.segoeui,
          //                               fontSize: 9.0.sp,
          //                               color: Colors.black,
          //                               fontWeight: FontWeight.bold)),
          //                     ),
          //                     InkWell(
          //                       child: Text(
          //                           '${timeago.format(DateTime.parse(widget.rooyaPostModel!.commentsText![index].time!), locale: 'en_short')} ago',
          //                           style: TextStyle(
          //                             fontFamily: AppFonts.segoeui,
          //                             fontSize: 8.0.sp,
          //                             color: const Color(0xff000000),
          //                           )),
          //                       onTap: () {
          //                         Navigator.of(context).push(MaterialPageRoute(
          //                             builder: (c) => Profile(
          //                                   userID:
          //                                       '${widget.rooyaPostModel!.commentsText![index].userId}',
          //                                 )));
          //                       },
          //                     ),
          //                     SizedBox(
          //                       height: 0.5.h,
          //                     ),
          //                     Text(
          //                         '${widget.rooyaPostModel!.commentsText![index].text}',
          //                         style: TextStyle(
          //                           fontFamily: AppFonts.segoeui,
          //                           fontSize: 10.0.sp,
          //                           color: const Color(0xff000000),
          //                         )),
          //                     SizedBox(
          //                       height: 1.0.h,
          //                     ),
          //                     Row(
          //                       children: [
          //                         Text(
          //                             '${widget.rooyaPostModel!.commentsText![index].numbersOfLikes}',
          //                             style: TextStyle(
          //                               fontFamily: AppFonts.segoeui,
          //                               fontSize: 12.0.sp,
          //                               color: const Color(0xff5a5a5a),
          //                             )),
          //                         SizedBox(
          //                           width: 1.0.w,
          //                         ),
          //                         InkWell(
          //                           onTap: () {
          //                             if (widget.rooyaPostModel!
          //                                 .commentsText![index].islike!) {
          //                               postCommentsUnLike(
          //                                   comment_id: widget.rooyaPostModel!
          //                                       .commentsText![index].commentId
          //                                       .toString());
          //                             } else {
          //                               postCommentsLike(
          //                                   comment_id: widget.rooyaPostModel!
          //                                       .commentsText![index].commentId
          //                                       .toString());
          //                             }
          //                           },
          //                           child: Image.asset(
          //                             'assets/icons/like.png',
          //                             height: 2.0.h,
          //                             color: widget.rooyaPostModel!
          //                                     .commentsText![index].islike!
          //                                 ? appThemes
          //                                 : Colors.black54,
          //                           ),
          //                         ),
          //                         SizedBox(
          //                           width: 2.0.w,
          //                         ),
          //                         Text(
          //                             '${widget.rooyaPostModel!.commentsText![index].replies}',
          //                             style: TextStyle(
          //                               fontFamily: AppFonts.segoeui,
          //                               fontSize: 12.0.sp,
          //                               color: const Color(0xff5a5a5a),
          //                             )),
          //                         SizedBox(
          //                           width: 1.0.w,
          //                         ),
          //                         InkWell(
          //                           child: Image.asset(
          //                             'assets/icons/comment.png',
          //                             height: 2.0.h,
          //                             color: Colors.black54,
          //                           ),
          //                         ),
          //                       ],
          //                     )
          //                   ],
          //                 ))
          //               ],
          //             ),
          //           );
          //         })),
          // widget.rooyaPostModel!.commentsText!.length >= 1
          //     ? Center(
          //         child: InkWell(
          //           onTap: () {
          //             Get.to(ViewAllComments(
          //               comments: widget.rooyaPostModel!.commentsText,
          //               postID: widget.rooyaPostModel!.postId.toString(),
          //             ))!
          //                 .then((value) {
          //               widget.comment!.call();
          //             });
          //           },
          //           child: Text(
          //             'View all',
          //             style:
          //                 TextStyle(color: Colors.blueGrey[200], fontSize: 13),
          //           ),
          //         ),
          //       )
          //     : SizedBox()
        ],
      ),
    );
  }

  Future<void> rooyaPostLike() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    String? userId = await prefs.getString('user_id');
    print('userid=$userId');
    final response = await http.post(Uri.parse('${baseUrl}postLike$code'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode(
            {"post_id": widget.rooyaPostModel!.postId, "user_id": userId}));
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] == 'success') {
        widget.onPostLike!.call();
      } else {
        setState(() {});
      }
    }
  }

  Future<void> rooyaPostUnLike() async {
    print('Unlike call now');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    String? userId = await prefs.getString('user_id');
    final response = await http.post(Uri.parse('${baseUrl}postUnLike$code'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode(
            {"post_id": widget.rooyaPostModel!.postId, "user_id": userId}));
    log('${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] == 'success') {
        widget.onPostUnLike!.call();
      }
    }
  }

  Future<void> rooyaPostComment({String? text}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    String? userId = await prefs.getString('user_id');
    final response = await http.post(Uri.parse('${baseUrl}postComments$code'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({
          "post_id": widget.rooyaPostModel!.postId,
          "post_type": "post",
          "user_id": userId,
          "user_type": "user",
          "text": text
        }));
    widget.comment!.call();
    print('data iss = ${response.body}');
  }

  Future<void> postCommentsLike({String? comment_id}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    String? userId = await prefs.getString('user_id');
    final response = await http.post(
        Uri.parse('${baseUrl}postCommentsLike$code'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({
          "user_id": userId,
          "comment_id": comment_id,
        }));
    widget.comment!.call();
    print('data iss = ${response.body}');
  }

  Future<void> postCommentsUnLike({String? comment_id}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    String? userId = await prefs.getString('user_id');
    final response = await http.post(
        Uri.parse('${baseUrl}postCommentsUnLike$code'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({
          "user_id": userId,
          "comment_id": comment_id,
        }));
    widget.comment!.call();
    print('data iss = ${response.body}');
  }

//https://apis.rooya.com/Alphaapis/sharePost?code=ROOYA-5574499
  Future<void> sharePost({String? text}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    String? userId = await prefs.getString('user_id');
    final response = await http.post(Uri.parse('${baseUrl}sharePost$code'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({
          "post_type": "shared",
          "user_type": "user",
          "user_id": userId,
          "privacy": "public",
          "post_description": text,
          "origin_id": widget.rooyaPostModel!.postId,
          "event_approved": widget.rooyaPostModel!.event_id,
          "in_wall": "1"
        }));
    print('data iss = ${response.body}');
    widget.comment!.call();
  }

  SharePost() {
    var height = MediaQuery.of(Get.context!).size.height;
    var width = MediaQuery.of(Get.context!).size.width;
    showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return Dialog(
            elevation: 0,
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: width / 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            child: Container(
              height: height / 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Post on your timeline',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: height * 0.055,
                    width: width,
                    margin: EdgeInsets.symmetric(
                        horizontal: width * 0.030, vertical: 5),
                    decoration: BoxDecoration(
                        border: Border.all(color: appThemes, width: 1),
                        borderRadius: BorderRadius.circular(25)),
                    child: CommentPostFields(
                      initialText: '',
                      sendCommit: (text) async {
                        sharePost(text: text);
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              ),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
            ),
          );
        });
  }
}

class CommentPostFields extends StatefulWidget {
  final Function(String)? sendCommit;
  final String? initialText;
  final bool? enable;

  const CommentPostFields(
      {Key? key, this.sendCommit, this.initialText = '', this.enable = true})
      : super(key: key);

  @override
  _CommentPostFieldsState createState() => _CommentPostFieldsState();
}

class _CommentPostFieldsState extends State<CommentPostFields> {
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    commentController.text = widget.initialText!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
            controller: commentController,
            cursorColor: Colors.black,
            textAlign: TextAlign.start,
            enabled: widget.enable,
            autofocus: true,
            keyboardType: TextInputType.text,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              isDense: true,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 15, right: 15),
              hintText: '',
              hintStyle: TextStyle(
                fontFamily: AppFonts.segoeui,
                fontSize: 13,
                color: const Color(0xff1e1e1e),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            if (commentController.text.trim().isNotEmpty) {
              widget.sendCommit!.call('${commentController.text}');
              commentController.clear();
            }
          },
          icon: Icon(
            Icons.send,
            size: 20,
            color: appThemes,
          ),
        )
      ],
    );
  }
}
