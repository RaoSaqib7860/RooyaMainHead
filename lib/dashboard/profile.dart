import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rooya_app/AllCreatePosts/CreatePost/create_post.dart';
import 'package:rooya_app/AppThemes/AppThemes.dart';
import 'package:rooya_app/ChatModule/Home/chat_screen.dart';
import 'package:rooya_app/Screens/Reel/ReelCamera/ReelCamera.dart';
import 'package:rooya_app/Screens/Settings/Settings.dart';
import 'package:rooya_app/events/Models/UpCommingEventModel.dart';
import 'package:rooya_app/models/MyEventModel.dart';
import 'package:rooya_app/models/ProfileInfoModel.dart';
import 'package:rooya_app/dashboard/Home/Models/RooyaPostModel.dart';
import 'package:rooya_app/models/RooyaSouqModel.dart';
import 'package:rooya_app/models/UserStoryModel.dart';
import 'package:rooya_app/rooya_souq/create_souq.dart';
import 'package:rooya_app/rooya_souq/rooya_ad_display.dart';
import 'package:rooya_app/src/repositories/user_repository.dart';
import 'package:rooya_app/utils/AppFonts.dart';
import 'package:rooya_app/ApiUtils/baseUrl.dart';
import 'package:rooya_app/utils/ShimmerEffect.dart';
import 'package:rooya_app/utils/SizedConfig.dart';
import 'package:rooya_app/utils/SnackbarCustom.dart';
import 'package:rooya_app/dashboard/Home/HomeComponents/user_post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:sliver_header_delegate/sliver_header_delegate.dart';
import '../Screens/ProfileData/AllFolowFolowers.dart';
import '../SharePost.dart';
import '../view_pic.dart';
import '../view_story.dart';
import 'Home/home.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'ProfileComponents/CreateMyEvent.dart';
import 'ProfileComponents/EditMyEventsCard.dart';

class Profile extends StatefulWidget {
  final String? userID;

  const Profile({Key? key, this.userID}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool isLoading = false;
  bool isLoadingProfile = false;
  List<MyEventModel> myEvetModel = [];
  List<RooyaPostModel> mRooyaPostsList = [];
  List<RooyaPostModel> myEventPostsList = [];
  List<RooyaSouqModel> mRooyaSouqList = [];
  List<UpComingEventsModel> listofUpcommingEvents = [];
  ProfileInfoModel? profileInfoModel;
  UserStoryModel? userStoryModel;
  UserStoryModel? myEventStoryModel = UserStoryModel(items: []);
  List<Items>? listofStoryItem;
  String? userID = '';
  String displayName = '';
  int selectedValue = 0;
  bool isFOlow = false;
  String folowStatus = '4';

  Future<bool> getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user_firstname = await prefs.getString('user_firstname');
    String? user_lastname = await prefs.getString('user_lastname');
    displayName = user_firstname! + ' ' + user_lastname!;
    userID = await prefs.getString('user_id');
    print('user id = ${widget.userID} and $userID');
    setState(() {});
    return true;
  }

  //https://apis.rooya.com/Alphaapis/getRooyaMyEventByLimite?code=ROOYA-5574499
  Future<void> createEvent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    String? userId = await prefs.getString('user_id');
    final response = await http.post(
        Uri.parse('${baseUrl}getRooyaMyEventByLimite$code'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({
          "page_size": 100,
          "page_number": 0,
          "profile_id": widget.userID,
          "user_id": userId,
        }));
    print('response is = ${response.body}');
    var data = jsonDecode(response.body);
    listofUpcommingEvents = List<UpComingEventsModel>.from(
        data['data'].map((model) => UpComingEventsModel.fromJson(model)));
    setState(() {});
  }

  GetStorage storage = GetStorage();

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 5);
    print('widget.userID = ${widget.userID}');
    getProfile();
    getProfileInfo();
    getRooyaPost();
    getRooyaSouqbyLimit();
    getStories();
    createEvent();
    getAllEvent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoadingProfile
          ? ShimerEffect(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      height: 29.0.h,
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl:
                                'https://thumbs.dreamstime.com/b/nature-web-banner-concept-design-vector-illustration-theme-ecology-environment-natural-products-natural-healthy-life-94337908.jpg',
                            imageBuilder: (context, imageProvider) => Container(
                              height: 25.0.h,
                              width: 100.0.w,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      fit: BoxFit.fill, image: imageProvider)),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 2.0.h),
                                  child: Text(
                                    'ABC acc',
                                    style: TextStyle(
                                      fontFamily: AppFonts.segoeui,
                                      fontSize: 16.0.sp,
                                      color: const Color(0xffffffff),
                                      fontWeight: FontWeight.w600,
                                      shadows: [
                                        Shadow(
                                          color: const Color(0x47000000),
                                          offset: Offset(0, 3),
                                          blurRadius: 6,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            placeholder: (context, url) => Container(
                                height: 15.0.h,
                                width: 100.0.w,
                                child:
                                    Center(child: CircularProgressIndicator())),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.0.w, vertical: 1.0.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(0.8.h),
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 1.0.w),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white),
                                  child: Icon(
                                    Icons.notifications,
                                    color: appThemes,
                                    size: 2.5.h,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(0.8.h),
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 1.0.w),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white),
                                  child: Icon(
                                    Icons.edit,
                                    color: appThemes,
                                    size: 2.5.h,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(0.8.h),
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 1.0.w),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white),
                                  child: Icon(
                                    Icons.settings,
                                    color: appThemes,
                                    size: 2.5.h,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(0.8.h),
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 1.0.w),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white),
                                  child: Icon(
                                    Icons.voicemail,
                                    color: appThemes,
                                    size: 2.5.h,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              margin: EdgeInsets.only(left: width * 0.090),
                              child: CircularProfileAvatar(
                                'https://www.gravatar.com/avatar/test@test.com.jpg?s=200&d=mm',
                                radius: 35,
                                borderColor: appThemes,
                                elevation: 10,
                                borderWidth: 1,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontFamily: AppFonts.segoeui,
                              fontSize: 12,
                              color: const Color(0xff0bab0d),
                            ),
                            children: [
                              TextSpan(
                                text: '23',
                                style: TextStyle(
                                  fontFamily: AppFonts.segoeui,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              TextSpan(
                                text: 'Following',
                                style: TextStyle(
                                  fontFamily: AppFonts.segoeui,
                                  color: const Color(0xff5a5a5a),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          width: 4.0.w,
                        ),
                        Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontFamily: AppFonts.segoeui,
                              fontSize: 12,
                              color: const Color(0xff0bab0d),
                            ),
                            children: [
                              TextSpan(
                                text: '12',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  fontFamily: AppFonts.segoeui,
                                ),
                              ),
                              TextSpan(
                                text: 'Followers',
                                style: TextStyle(
                                  color: const Color(0xff5a5a5a),
                                  fontSize: 13,
                                  fontFamily: AppFonts.segoeui,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          width: 4.0.w,
                        ),
                        Text.rich(
                          TextSpan(
                            style: TextStyle(
                              color: const Color(0xff5a5a5a),
                              fontSize: 12,
                              fontFamily: AppFonts.segoeui,
                            ),
                            children: [
                              TextSpan(
                                text: '32',
                                style: TextStyle(
                                  color: appThemes,
                                  fontSize: 15,
                                  fontFamily: AppFonts.segoeui,
                                ),
                              ),
                              TextSpan(
                                text: 'Posts',
                                style: TextStyle(
                                  color: const Color(0xff5a5a5a),
                                  fontSize: 13,
                                  fontFamily: AppFonts.segoeui,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 2.0.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.0.w),
                      child: Text(
                        'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.',
                        style: TextStyle(
                          fontFamily: AppFonts.segoeui,
                          fontSize: 11,
                          color: const Color(0xff5a5a5a),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: 2.0.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ALL',
                                  style: TextStyle(
                                    fontFamily: AppFonts.segoeui,
                                    fontSize: 9.0.sp,
                                    fontWeight: FontWeight.w600,
                                    color: selectedValue == 0
                                        ? appThemes
                                        : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Container(
                                  width: 1,
                                  height: 2.0.h,
                                  color: Colors.grey[500],
                                ),
                                Text(
                                  'ROOYA',
                                  style: TextStyle(
                                    fontFamily: AppFonts.segoeui,
                                    fontSize: 9.0.sp,
                                    fontWeight: FontWeight.w600,
                                    color: selectedValue == 1
                                        ? appThemes
                                        : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Container(
                                  width: 1,
                                  height: 2.0.h,
                                  color: Colors.grey[500],
                                ),
                                Text(
                                  'STORY',
                                  style: TextStyle(
                                    fontFamily: AppFonts.segoeui,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 9.0.sp,
                                    color: selectedValue == 2
                                        ? appThemes
                                        : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Container(
                                  width: 1,
                                  height: 2.0.h,
                                  color: Colors.grey[500],
                                ),
                                Text(
                                  'MY EVENTS',
                                  style: TextStyle(
                                    fontFamily: AppFonts.segoeui,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 9.0.sp,
                                    color: selectedValue == 3
                                        ? appThemes
                                        : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Container(
                                  width: 1,
                                  height: 2.0.h,
                                  color: Colors.grey[500],
                                ),
                                Text(
                                  'ROOYA SOUQ',
                                  style: TextStyle(
                                    fontFamily: AppFonts.segoeui,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 9.0.sp,
                                    color: selectedValue == 4
                                        ? appThemes
                                        : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 2.0.w,
                          ),
                          // Image.asset(
                          //   'assets/icons/history.png',
                          //   height: 4.0.h,
                          //   width: 4.0.h,
                          // )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                DefaultTabController(
                  length: 5,
                  child: NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: FlexibleHeaderDelegate(
                            statusBarHeight: MediaQuery.of(context).padding.top,
                            background: MutableBackground(
                              expandedWidget: Stack(
                                children: [
                                  InkWell(
                                    child: CachedNetworkImage(
                                      imageUrl: profileInfoModel!.userCover ==
                                              null
                                          ? 'https://thumbs.dreamstime.com/b/nature-web-banner-concept-design-vector-illustration-theme-ecology-environment-natural-products-natural-healthy-life-94337908.jpg'
                                          : '$baseImageUrl${profileInfoModel!.userCover}',
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: imageProvider)),
                                      ),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          ShimerEffect(
                                        child: Container(
                                          height: 15.0.h,
                                          width: 100.0.w,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      height: 200,
                                      width: width,
                                    ),
                                    onTap: () {
                                      print('click on image');
                                      if (profileInfoModel!.userCover != null) {
                                        Attachment atachments = Attachment(
                                            attachment:
                                                '${profileInfoModel!.userCover}',
                                            photoId: 1,
                                            type: 'abc');
                                        Get.to(ViewPic(
                                          attachment: [atachments],
                                        ));
                                      } else {
                                        Attachment atachments = Attachment(
                                            attachment:
                                                'https://thumbs.dreamstime.com/b/nature-web-banner-concept-design-vector-illustration-theme-ecology-environment-natural-products-natural-healthy-life-94337908.jpg',
                                            photoId: 1,
                                            type: '');
                                        Get.to(ViewPic(
                                          attachment: [atachments],
                                        ));
                                      }
                                    },
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (profileInfoModel!.userCover != null) {
                                        Attachment atachments = Attachment(
                                            attachment:
                                                '${profileInfoModel!.userCover}',
                                            photoId: 1,
                                            type: 'abc');
                                        Get.to(ViewPic(
                                          attachment: [atachments],
                                        ));
                                      } else {
                                        Attachment atachments = Attachment(
                                            attachment:
                                                'https://thumbs.dreamstime.com/b/nature-web-banner-concept-design-vector-illustration-theme-ecology-environment-natural-products-natural-healthy-life-94337908.jpg',
                                            photoId: 1,
                                            type: '');
                                        Get.to(ViewPic(
                                          attachment: [atachments],
                                        ));
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                            Colors.white.withOpacity(0),
                                            Colors.white.withOpacity(1),
                                          ],
                                              stops: [
                                            0.3,
                                            0.8,
                                          ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter)),
                                      height: double.infinity,
                                      width: double.infinity,
                                      margin: EdgeInsets.only(bottom: 90),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      height: 55,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Center(
                                            child: CircularProfileAvatar(
                                              '',
                                              radius: 15,
                                              child: SvgPicture.asset(
                                                'assets/images/mLogo.svg',
                                                height: 24,
                                              ),
                                              onTap: () {
                                                pushNewScreen(
                                                  context,
                                                  screen: ChatScreen(),
                                                  withNavBar:
                                                      false, // OPTIONAL VALUE. True by default.
                                                  pageTransitionAnimation:
                                                      PageTransitionAnimation
                                                          .cupertino,
                                                );
                                              },
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(0.8.h),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 1.0.w),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white),
                                            child: Icon(
                                              CupertinoIcons.search,
                                              color: appThemes,
                                              size: 2.5.h,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Get.to(() => Settings());
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(0.8.h),
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 1.0.w),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white),
                                              child: Icon(
                                                Icons.settings,
                                                color: appThemes,
                                                size: 2.5.h,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          color: Colors.white,
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      print('abc1');
                                                      if (widget.userID ==
                                                          storage
                                                              .read('userID')) {
                                                        Get.to(AllFolowFolowers(
                                                          folowers: false,
                                                          owner: true,
                                                          userID: widget.userID,
                                                          userName:
                                                              '${profileInfoModel!.userFirstname} ${profileInfoModel!.userLastname}',
                                                        ))!
                                                            .then((value) {
                                                          getProfileInfo(
                                                              load: false);
                                                        });
                                                      } else {
                                                        if (profileInfoModel!
                                                                .private_account !=
                                                            '1') {
                                                          Get.to(AllFolowFolowers(
                                                            folowers: false,
                                                            userID:
                                                                widget.userID,
                                                            userName:
                                                                '${profileInfoModel!.userFirstname} ${profileInfoModel!.userLastname}',
                                                          ))!
                                                              .then((value) {
                                                            getProfileInfo(
                                                                load: false);
                                                          });
                                                        }
                                                      }
                                                    },
                                                    child: Text.rich(
                                                      TextSpan(
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AppFonts.segoeui,
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                '${profileInfoModel!.totalFollowers}\n',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 15,
                                                              fontFamily:
                                                                  AppFonts
                                                                      .segoeui,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: 'Followers',
                                                            style: TextStyle(
                                                              color: const Color(
                                                                  0xff5a5a5a),
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  AppFonts
                                                                      .segoeui,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 4.0.w,
                                                  ),
                                                  InkWell(
                                                    onTap: () async {
                                                      print('abc2');
                                                      if (widget.userID ==
                                                          storage
                                                              .read('userID')) {
                                                        print('abc2');
                                                        Get.to(AllFolowFolowers(
                                                          folowers: true,
                                                          userID: widget.userID,
                                                          owner: true,
                                                          userName:
                                                              '${profileInfoModel!.userFirstname} ${profileInfoModel!.userLastname}',
                                                        ))!
                                                            .then((value) {
                                                          getProfileInfo(
                                                              load: false);
                                                        });
                                                      } else {
                                                        if (profileInfoModel!
                                                                .private_account !=
                                                            '1') {
                                                          print('abc3');
                                                          Get.to(AllFolowFolowers(
                                                            folowers: true,
                                                            userID:
                                                                widget.userID,
                                                            userName:
                                                                '${profileInfoModel!.userFirstname} ${profileInfoModel!.userLastname}',
                                                          ))!
                                                              .then((value) {
                                                            getProfileInfo(
                                                                load: false);
                                                          });
                                                        }
                                                      }
                                                    },
                                                    child: Text.rich(
                                                      TextSpan(
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AppFonts.segoeui,
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                '${profileInfoModel!.totalFollowings}\n',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppFonts
                                                                      .segoeui,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: 'Following',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppFonts
                                                                      .segoeui,
                                                              color: const Color(
                                                                  0xff5a5a5a),
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 4.0.w,
                                                  ),
                                                  Text.rich(
                                                    TextSpan(
                                                      style: TextStyle(
                                                        color: const Color(
                                                            0xff5a5a5a),
                                                        fontSize: 12,
                                                        fontFamily:
                                                            AppFonts.segoeui,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              '${profileInfoModel!.totalPosts}\n',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                            fontFamily: AppFonts
                                                                .segoeui,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: 'Posts',
                                                          style: TextStyle(
                                                            color: const Color(
                                                                0xff5a5a5a),
                                                            fontSize: 13,
                                                            fontFamily: AppFonts
                                                                .segoeui,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(
                                                    width: width * 0.070,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: width * 0.4,
                                                    height: height * 0.045,
                                                    child: Center(
                                                      child: profileInfoModel!
                                                                  .already_requested ==
                                                              'true'
                                                          ? Container(
                                                              // width: width * 0.4,
                                                              // height: height * 0.055,
                                                              child: userID !=
                                                                      widget
                                                                          .userID
                                                                  ? Center(
                                                                      child:
                                                                          Text(
                                                                        'REQUESTED',
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize:
                                                                                12,
                                                                            fontFamily:
                                                                                AppFonts.segoeui),
                                                                      ),
                                                                    )
                                                                  : SizedBox(),
                                                              decoration: BoxDecoration(
                                                                  color: userID !=
                                                                          widget
                                                                              .userID
                                                                      ? appThemes
                                                                      : offWhiteColor2,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5)),
                                                            )
                                                          : userID !=
                                                                  widget.userID
                                                              ? InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    if (profileInfoModel!
                                                                        .isFollow!) {
                                                                      print(
                                                                          'unFolow Call');
                                                                      await unfolow();
                                                                      getProfileInfo(
                                                                          load:
                                                                              false);
                                                                      getRooyaPost();
                                                                      getStories();
                                                                      getRooyaSouqbyLimit();
                                                                      createEvent();
                                                                    } else {
                                                                      print(
                                                                          'Folow Call');
                                                                      if (profileInfoModel!.private_account ==
                                                                              '0' ||
                                                                          profileInfoModel!.private_account!.trim() ==
                                                                              '') {
                                                                        await folow();
                                                                        getProfileInfo(
                                                                            load:
                                                                                false);
                                                                        getRooyaPost();
                                                                        getStories();
                                                                        getRooyaSouqbyLimit();
                                                                        createEvent();
                                                                      } else {
                                                                        await allowfollowers();
                                                                        getProfileInfo(
                                                                            load:
                                                                                false);
                                                                      }
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    // width: width * 0.4,
                                                                    // height: height * 0.045,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        !profileInfoModel!.isFollow!
                                                                            ? 'FOLLOW'
                                                                            : profileInfoModel!.private_account == '0' || profileInfoModel!.private_account!.trim() == ''
                                                                                ? 'FOLLOWING'
                                                                                : profileInfoModel!.already_requested == 'false'
                                                                                    ? 'FOLLOWING'
                                                                                    : 'REQUESTED',
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize:
                                                                                12,
                                                                            fontFamily:
                                                                                AppFonts.segoeui),
                                                                      ),
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                        color: userID != widget.userID
                                                                            ? appThemes
                                                                            : offWhiteColor2,
                                                                        borderRadius:
                                                                            BorderRadius.circular(5)),
                                                                  ),
                                                                )
                                                              : Center(
                                                                  child: Text(
                                                                      'View Profile')),
                                                    ),
                                                    margin: EdgeInsets.only(
                                                        right: 30),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color:
                                                                Colors.black12,
                                                            width: 1)),
                                                  ),
                                                ],
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                          ),
                                          padding: EdgeInsets.only(
                                              bottom: 0, top: 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            expandedHeight: 300,
                            collapsedHeight: 60,
                            actions: [
                              Center(
                                child: CircularProfileAvatar(
                                  '',
                                  radius: 15,
                                  child: SvgPicture.asset(
                                    'assets/images/mLogo.svg',
                                    height: 24,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(0.8.h),
                                margin: EdgeInsets.symmetric(horizontal: 1.0.w),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white),
                                child: Icon(
                                  CupertinoIcons.search,
                                  color: appThemes,
                                  size: 2.5.h,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Get.to(() => Settings());
                                },
                                child: Container(
                                  padding: EdgeInsets.all(0.8.h),
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 1.0.w),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white),
                                  child: Icon(
                                    Icons.settings,
                                    color: appThemes,
                                    size: 2.5.h,
                                  ),
                                ),
                              ),
                            ],
                            leading: SizedBox(),
                            // leading: Center(
                            //   child: InkWell(
                            //     onTap: () {
                            //       Navigator.of(context).pop();
                            //     },
                            //     child: Container(
                            //       padding: EdgeInsets.all(5),
                            //       decoration: BoxDecoration(
                            //         shape: BoxShape.circle,
                            //         color: Colors.teal,
                            //       ),
                            //       child: Icon(
                            //         Icons.arrow_back_ios_outlined,
                            //         color: Colors.black,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            children: [
                              FlexibleTextItem(
                                text: 'Mountains',
                                expandedMargin:
                                    EdgeInsets.only(left: 10, bottom: 10),
                                // collapsedStyle: collapsedStyle,
                                // expandedStyle: expandedStyle,
                                url:
                                    '$baseImageUrl${profileInfoModel!.userPicture!}',
                                onTap: () {
                                  print('Call on tap');
                                  Attachment atachments = Attachment(
                                      attachment:
                                          '${profileInfoModel!.userPicture!}',
                                      photoId: 1,
                                      type: 'abc');
                                  Get.to(ViewPic(
                                    attachment: [atachments],
                                  ));
                                },
                                anotherChild:
                                    profileInfoModel!.userPicture == null
                                        ? CircularProfileAvatar(
                                            '',
                                            child: Image.asset(
                                                'assets/images/logo.png'),
                                            radius: 45,
                                            elevation: 5,
                                          )
                                        : CircularProfileAvatar(
                                            '$baseImageUrl${profileInfoModel!.userPicture!}',
                                            radius: 55,
                                            elevation: 5,
                                            onTap: () {
                                              Attachment atachments = Attachment(
                                                  attachment:
                                                      '${profileInfoModel!.userPicture!}',
                                                  photoId: 1,
                                                  type: 'abc');
                                              Get.to(ViewPic(
                                                attachment: [atachments],
                                              ));
                                            },
                                          ),
                                expandedAlignment: Alignment.bottomLeft,
                                collapsedAlignment: Alignment.center,
                                // expandedPadding: padding,
                              ),
                            ],
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 30,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${profileInfoModel!.userFirstname} ${profileInfoModel!.userLastname}',
                                      style: TextStyle(
                                        fontFamily: AppFonts.segoeui,
                                        fontSize: 17,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '@${profileInfoModel!.userName}',
                                      style: TextStyle(
                                        fontFamily: AppFonts.segoeui,
                                        fontSize: 12,
                                        color: Colors.black26,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: width * 0.020,
                                ),
                                profileInfoModel!.user_verified == '1'
                                    ? Container(
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle),
                                        child: Icon(
                                          Icons.check,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      )
                                    : SizedBox()
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            height: 10,
                            width: width,
                            decoration: BoxDecoration(color: Colors.white),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            height: 0.1,
                            width: width,
                            decoration: BoxDecoration(color: Colors.black),
                            padding: EdgeInsets.only(top: 10),
                          ),
                        ),
                        SliverPersistentHeader(
                          delegate: _SliverAppBarDelegate(
                            TabBar(
                              labelColor: appThemes,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: appThemes,
                              isScrollable: true,
                              controller: _tabController,
                              tabs: [
                                Tab(
                                  text: 'All',
                                ),
                                Tab(
                                  text: 'ROOYA',
                                ),
                                Tab(
                                  text: 'STORY',
                                ),
                                Tab(
                                  text: 'MY EVENTS',
                                ),
                                Tab(
                                  text: 'ROOYA SOUQ',
                                )
                              ],
                            ),
                          ),
                          pinned: true,
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            height: 0.5,
                            color: Colors.black12,
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          key: PageStorageKey('key1'),
                          children: [
                            Flexible(
                                child: ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: mRooyaPostsList.length,
                                    itemBuilder: (context, index) {
                                      if (mRooyaPostsList[index].origin_id !=
                                          '0') {
                                        return Column(
                                          children: [
                                            Row(
                                              children: [
                                                mRooyaPostsList[index]
                                                            .userPicture ==
                                                        null
                                                    ? CircularProfileAvatar(
                                                        '',
                                                        child: Image.asset(
                                                            'assets/images/logo.png'),
                                                        elevation: 5,
                                                        radius: 23,
                                                        onTap: () {
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (c) =>
                                                                      Profile(
                                                                        userID:
                                                                            '${mRooyaPostsList[index].userPosted}',
                                                                      )));
                                                        },
                                                        borderColor: appThemes,
                                                        borderWidth: 1,
                                                      )
                                                    : CircularProfileAvatar(
                                                        '$baseImageUrl${mRooyaPostsList[index].userPicture}',
                                                        elevation: 5,
                                                        radius: 23,
                                                        onTap: () {
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (c) =>
                                                                      Profile(
                                                                        userID:
                                                                            '${mRooyaPostsList[index].userPosted}',
                                                                      )));
                                                        },
                                                        borderColor: appThemes,
                                                        borderWidth: 1,
                                                      ),
                                                SizedBox(
                                                  width: 4.0.w,
                                                ),
                                                Expanded(
                                                    child: InkWell(
                                                  onTap: () {
                                                    print('Click on profile');
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (c) =>
                                                                Profile(
                                                                  userID:
                                                                      '${mRooyaPostsList[index].userPosted}',
                                                                )));
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                              '${mRooyaPostsList[index].userfullname}',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    AppFonts
                                                                        .segoeui,
                                                                fontSize: 13,
                                                                color: const Color(
                                                                    0xff000000),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              )),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                  ' Shared a ${mRooyaPostsList[index].pre_user_name} post',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        AppFonts
                                                                            .segoeui,
                                                                    fontSize:
                                                                        11,
                                                                    color: Colors
                                                                        .black38,
                                                                  )),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        '@${mRooyaPostsList[index].userName}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AppFonts.segoeui,
                                                          fontSize: 10,
                                                          color: const Color(
                                                              0xff000000),
                                                        ),
                                                        textAlign:
                                                            TextAlign.left,
                                                      )
                                                    ],
                                                  ),
                                                )),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 10),
                                                  child: Text(
                                                    '${timeago.format(DateTime.parse(mRooyaPostsList[index].time!), locale: 'en_short')} ago',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppFonts.segoeui,
                                                      fontSize: 10,
                                                      color: const Color(
                                                          0xff000000),
                                                      height: 1.8,
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 1.0.h,
                                            ),
                                            SharePost(
                                              rooyaPostModel:
                                                  mRooyaPostsList[index],
                                            ),
                                            SizedBox(
                                              height: height * 0.020,
                                            )
                                          ],
                                        );
                                      } else {
                                        return UserPost(
                                          rooyaPostModel:
                                              mRooyaPostsList[index],
                                        );
                                      }
                                    }))
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          key: PageStorageKey('key2'),
                          children: [
                            Flexible(
                                child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.0.w),
                              child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: mRooyaPostsList.length,
                                  itemBuilder: (context, index) {
                                    return UserPost(
                                      rooyaPostModel: mRooyaPostsList[index],
                                    );
                                  }),
                            ))
                          ],
                        ),
                        Column(
                          key: PageStorageKey('key3'),
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            userID == widget.userID
                                ? Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          fromHomeStory = '0';
                                          Get.to(CameraApp(
                                            fromStory: true,
                                          ))!
                                              .then((value) {
                                            fromHomeStory = '0';
                                            getStories();
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                              color: Color(0xff57D8A3),
                                              border: Border.all(
                                                  color: Colors.black12,
                                                  width: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          constraints: BoxConstraints(
                                              minWidth: width * 0.2),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 10),
                                          child: Center(
                                            child: Text(
                                              'Create',
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  letterSpacing: 0.5,
                                                  fontFamily: AppFonts.segoeui,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.end,
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: height * 0.010,
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              itemCount: userStoryModel == null
                                  ? 0
                                  : userStoryModel!.items!.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      childAspectRatio: 0.8,
                                      // crossAxisSpacing: 5.0.w,
                                      mainAxisSpacing: 2.0.w,
                                      crossAxisCount: 4),
                              itemBuilder: (BuildContext context, int index) {
                                return Stack(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Get.to(ViewStory(
                                          model: userStoryModel,
                                          index: index,
                                        ))!
                                            .then((value) {
                                          if (value is int) {
                                            userStoryModel!.items!
                                                .removeAt(value);
                                            setState(() {});
                                          }
                                        });
                                      },
                                      child: Container(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: userStoryModel!
                                                      .items![index].type ==
                                                  'photo'
                                              ? CachedNetworkImage(
                                                  imageUrl:
                                                      '$baseImageUrl${userStoryModel!.items![index].src}',
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                  progressIndicatorBuilder:
                                                      (context, url,
                                                              downloadProgress) =>
                                                          ShimerEffect(
                                                    child: Image.asset(
                                                      'assets/images/home_banner.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Image.asset(
                                                    'assets/images/home_banner.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Container(
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.play_circle_fill,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  decoration: BoxDecoration(
                                                      color: Colors.black),
                                                ),
                                        ),
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 0.8.h),
                                      ),
                                    ),
                                    // Container(
                                    //   padding: EdgeInsets.only(left: 8, top: 5),
                                    //   width: 20.0.w,
                                    //   child: Row(
                                    //     children: [
                                    //       CircularProfileAvatar(
                                    //         '',
                                    //         child: CachedNetworkImage(
                                    //           imageUrl: userStoryModel!
                                    //                       .userPicture ==
                                    //                   null
                                    //               ? 'https://www.gravatar.com/avatar/test@test.com.jpg?s=200&d=mm'
                                    //               : "$baseImageUrl${userStoryModel!.userPicture}",
                                    //           fit: BoxFit.cover,
                                    //           progressIndicatorBuilder:
                                    //               (context, url,
                                    //                       downloadProgress) =>
                                    //                   ShimerEffect(
                                    //             child: Image.asset(
                                    //               'assets/images/home_banner.png',
                                    //               fit: BoxFit.cover,
                                    //             ),
                                    //           ),
                                    //           errorWidget:
                                    //               (context, url, error) =>
                                    //                   Image.asset(
                                    //             'assets/images/home_banner.png',
                                    //             fit: BoxFit.cover,
                                    //           ),
                                    //         ),
                                    //         borderColor: appThemes,
                                    //         elevation: 5,
                                    //         borderWidth: 1,
                                    //         radius: 10,
                                    //       ),
                                    //       SizedBox(
                                    //         width: 3,
                                    //       ),
                                    //       Expanded(
                                    //         child: Text(
                                    //           '${userStoryModel!.userFirstname} ${userStoryModel!.userLastname}',
                                    //           maxLines: 2,
                                    //           overflow: TextOverflow.ellipsis,
                                    //           style: TextStyle(
                                    //               color: Colors.white,
                                    //               fontSize: 8),
                                    //         ),
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        Column(
                          key: PageStorageKey('key4'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: height * 0.050,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: ListView.builder(
                                itemBuilder: (c, i) {
                                  return InkWell(
                                    onTap: () {
                                      if (selected_event_id !=
                                          '${myEvetModel[i].eventId}') {
                                        selected_event_id =
                                            '${myEvetModel[i].eventId}';
                                        loadEvent = false;
                                        setState(() {});
                                        getMyEventPosts(
                                            '${myEvetModel[i].eventId}');
                                        getMyEventStories(
                                            '${myEvetModel[i].eventId}');
                                      }
                                    },
                                    onLongPress: () {
                                      if (userID == widget.userID) {
                                        showCupertinoModalBottomSheet(
                                          expand: false,
                                          context: context,
                                          enableDrag: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) {
                                            return Material(
                                              child: Container(
                                                height: height * 0.2,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 15,
                                                    horizontal: 5),
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .blueGrey[
                                                                          50]!
                                                                      .withOpacity(
                                                                          0.5)),
                                                          child: Center(
                                                            child: Text(
                                                              'Edit Event',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      AppFonts
                                                                          .segoeui),
                                                            ),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          showCupertinoModalBottomSheet(
                                                            expand: false,
                                                            context: context,
                                                            enableDrag: true,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            builder: (context) {
                                                              return Container(
                                                                height: height *
                                                                    0.7,
                                                                child:
                                                                    EditMyEventCard(
                                                                  onCreateCall:
                                                                      () async {
                                                                    myEventStoryModel =
                                                                        UserStoryModel(
                                                                            items: []);
                                                                    await getAllEvent();
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  model:
                                                                      myEvetModel[
                                                                          i],
                                                                ),
                                                              );
                                                            },
                                                          ).then((value) {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () async {
                                                          await deleteMyEvent(
                                                              '${myEvetModel[i].eventId}');
                                                          myEvetModel
                                                              .removeAt(i);
                                                          myEventStoryModel =
                                                              UserStoryModel(
                                                                  items: []);
                                                          await getAllEvent();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .blueGrey[
                                                                          50]!
                                                                      .withOpacity(
                                                                          0.5)),
                                                          child: Center(
                                                            child: Text(
                                                                'Delete Event',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        AppFonts
                                                                            .segoeui)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                decoration: BoxDecoration(
                                                    color: Colors.white),
                                              ),
                                            );
                                          },
                                        ).then((value) {
                                          setState(() {});
                                        });
                                      }
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                          color: selected_event_id ==
                                                  '${myEvetModel[i].eventId}'
                                              ? Color(0xffC4F7E2)
                                              : Colors.transparent,
                                          border: Border.all(
                                              color: Colors.black12,
                                              width: 0.5),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      constraints:
                                          BoxConstraints(minWidth: width * 0.2),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      child: Center(
                                        child: Text(
                                          '${myEvetModel[i].eventTitle}',
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: AppFonts.segoeui,
                                              fontSize: 14,
                                              fontWeight: selected_event_id ==
                                                      '${myEvetModel[i].eventId}'
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              color: selected_event_id !=
                                                      '${myEvetModel[i].eventId}'
                                                  ? Colors.black
                                                  : appThemes),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: myEvetModel.length,
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    activeMenuprofile.value = true;
                                    setState(() {});
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                        color: Color(0xff57D8A3),
                                        border: Border.all(
                                            color: Colors.black12, width: 0.5),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    constraints:
                                        BoxConstraints(minWidth: width * 0.2),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 10),
                                    child: Center(
                                      child: Text(
                                        'Create',
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            letterSpacing: 0.5,
                                            fontFamily: AppFonts.segoeui,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            // Visibility(
                            //   visible: userID == widget.userID ? true : false,
                            //   child: CreateEvetCards(
                            //     addTimeLineButton: () {
                            //       showCupertinoModalBottomSheet(
                            //         expand: false,
                            //         context: context,
                            //         enableDrag: true,
                            //         backgroundColor: Colors.transparent,
                            //         builder: (context) {
                            //           return Container(
                            //             height: height * 0.6,
                            //             child: CreateMyEvet(
                            //               onCreateCall: () async {
                            //                 getAllEvent();
                            //                 setState(() {});
                            //               },
                            //             ),
                            //           );
                            //         },
                            //       );
                            //     },
                            //     addPostButton: () {
                            //       Get.to(CreatePost());
                            //     },
                            //     addStoryButton: () {
                            //       fromHomeStory = '0';
                            //       Get.to(CameraApp(
                            //         fromStory: true,
                            //       ))!
                            //           .then((value) {
                            //         fromHomeStory = '0';
                            //       });
                            //     },
                            //     showCreate: myEvetModel.isEmpty ? false : true,
                            //   ),
                            // ),
                            myEventStoryModel == null ||
                                    myEventStoryModel!.items!.isEmpty
                                ? SizedBox()
                                : Column(
                                    children: [
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        height: height * 0.170,
                                        width: width,
                                        padding: EdgeInsets.only(right: 5),
                                        child: ListView.builder(
                                          itemBuilder: (context, index) {
                                            return Stack(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Get.to(ViewStory(
                                                      model: myEventStoryModel,
                                                      index: index,
                                                    ))!
                                                        .then((value) {
                                                      if (value is int) {
                                                        myEventStoryModel!
                                                            .items!
                                                            .removeAt(value);
                                                        setState(() {});
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    height: height * 0.170,
                                                    width: width * 0.230,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: myEventStoryModel!
                                                                  .items![index]
                                                                  .type ==
                                                              'photo'
                                                          ? CachedNetworkImage(
                                                              imageUrl:
                                                                  '$baseImageUrl${myEventStoryModel!.items![index].src}',
                                                              width: double
                                                                  .infinity,
                                                              height: double
                                                                  .infinity,
                                                              fit: BoxFit.cover,
                                                              progressIndicatorBuilder:
                                                                  (context, url,
                                                                          downloadProgress) =>
                                                                      ShimerEffect(
                                                                child:
                                                                    Image.asset(
                                                                  'assets/images/home_banner.png',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Image.asset(
                                                                'assets/images/home_banner.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            )
                                                          : Container(
                                                              child: Center(
                                                                child: Icon(
                                                                  Icons
                                                                      .play_circle_fill,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color: Colors
                                                                          .black),
                                                            ),
                                                    ),
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 0.8.h),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      left: 8, top: 5),
                                                  width: 20.0.w,
                                                  child: Row(
                                                    children: [
                                                      // CircularProfileAvatar(
                                                      //   '',
                                                      //   child:
                                                      //       CachedNetworkImage(
                                                      //     imageUrl: myEventStoryModel!
                                                      //                 .userPicture ==
                                                      //             null
                                                      //         ? 'https://www.gravatar.com/avatar/test@test.com.jpg?s=200&d=mm'
                                                      //         : "$baseImageUrl${myEventStoryModel!.userPicture}",
                                                      //     fit: BoxFit.cover,
                                                      //     progressIndicatorBuilder:
                                                      //         (context, url,
                                                      //                 downloadProgress) =>
                                                      //             ShimerEffect(
                                                      //       child: Image.asset(
                                                      //         'assets/images/home_banner.png',
                                                      //         fit: BoxFit.cover,
                                                      //       ),
                                                      //     ),
                                                      //     errorWidget: (context,
                                                      //             url, error) =>
                                                      //         Image.asset(
                                                      //       'assets/images/home_banner.png',
                                                      //       fit: BoxFit.cover,
                                                      //     ),
                                                      //   ),
                                                      //   borderColor: appThemes,
                                                      //   elevation: 5,
                                                      //   borderWidth: 1,
                                                      //   radius: 10,
                                                      // ),
                                                      SizedBox(
                                                        width: 3,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          '${userProfile.value.username}',
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 8),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                          itemCount: myEventStoryModel == null
                                              ? 0
                                              : myEventStoryModel!
                                                  .items!.length,
                                          scrollDirection: Axis.horizontal,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  ),
                            !loadEvent
                                ? SizedBox(
                                    height: height / 3,
                                    width: width,
                                  )
                                : myEventPostsList.isEmpty
                                    ? SizedBox(
                                        height: height / 3,
                                        width: width,
                                        child: Center(
                                          child: Text('Empty'),
                                        ),
                                      )
                                    : Flexible(
                                        child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 2.0.w),
                                        child: ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: myEventPostsList.length,
                                            itemBuilder: (context, index) {
                                              return UserPost(
                                                rooyaPostModel:
                                                    myEventPostsList[index],
                                              );
                                            }),
                                      )),
                          ],
                        ),
                        Column(
                          key: PageStorageKey('key5'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            userID == widget.userID
                                ? InkWell(
                                    onTap: () {
                                      Get.to(() => CreateSouq());
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.add_circle,
                                          color: appThemes,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'ROOYA SOUQ',
                                          style: TextStyle(
                                            fontFamily: AppFonts.segoeui,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 9.0.sp,
                                            color: selectedValue == 4
                                                ? appThemes
                                                : Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 10,
                            ),
                            Flexible(
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: mRooyaSouqList.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisSpacing: 5.0.w,
                                        mainAxisSpacing: 2.0.w,
                                        crossAxisCount: 2),
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      Get.to(() => RooyaAdDisplay(
                                                rooyaSouqModel:
                                                    mRooyaSouqList[index],
                                              ))!
                                          .then((value) {
                                        if (value is bool) {
                                          getRooyaSouqbyLimit();
                                        }
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 15.0.h,
                                          width: 100.0.w,
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                '$baseImageUrl${mRooyaSouqList[index].images![0].attachment}',
                                            fit: BoxFit.cover,
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                ShimerEffect(
                                              child: Image.asset(
                                                'assets/images/home_banner.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              'assets/images/home_banner.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 0.5.h,
                                        ),
                                        Text(
                                          '${mRooyaSouqList[index].name} (${mRooyaSouqList[index].categoryName})',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Segoe UI',
                                            fontSize: 9,
                                            color: const Color(0xff000000),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(
                                          height: 0.5.h,
                                        ),
                                        Text(
                                          '${mRooyaSouqList[index].text}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: 'Segoe UI',
                                            fontSize: 9,
                                            color: const Color(0xff000000),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Text(
                                                      'AED ${mRooyaSouqList[index].price}',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: appThemes,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 8.0.sp)),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Icon(
                                                    mRooyaSouqList[index]
                                                            .isLike!
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: appThemes,
                                                    size: 2.0.h,
                                                  )
                                                ],
                                              ),
                                            ),
                                            Text(
                                                '${mRooyaSouqList[index].status}',
                                                style: TextStyle(
                                                  fontFamily: 'Segoe UI',
                                                  fontSize: 8.0.sp,
                                                  color:
                                                      const Color(0xff5a5a5a),
                                                ))
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 10, top: 15),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_outlined,
                        color: appThemes,
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => activeMenuprofile.value
                      ? Center(
                          child: InkWell(
                            onTap: () {
                              activeMenuprofile.value = false;
                            },
                            child: Stack(
                              children: [
                                Container(
                                  height: height,
                                  width: width,
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 1.0, sigmaY: 1.0),
                                    child: Container(
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: height,
                                  width: width,
                                  child: Center(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 10.0,
                                        sigmaY: 10.0,
                                      ),
                                      child: Container(
                                        height: height / 3.50,
                                        width: width / 2.30,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () {
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
                                                        onCreateCall: () async {
                                                          await getAllEvent();
                                                          setState(() {});
                                                        },
                                                      ),
                                                    );
                                                  },
                                                );
                                                activeMenuprofile.value = false;
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'My Event',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            AppFonts.segoeui,
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Icon(
                                                    Icons.add_box_outlined,
                                                    color: Colors.black,
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 0.2,
                                              width: double.infinity,
                                              color: Colors.black,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                fromHomeStory = '0';
                                                Get.to(CameraApp(
                                                  fromStory: true,
                                                ))!
                                                    .then((value) async {
                                                  fromHomeStory = '0';
                                                  await getStories();
                                                  setState(() {});
                                                });
                                                activeMenuprofile.value = false;
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Story',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            AppFonts.segoeui,
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Icon(
                                                    Icons.add_box_outlined,
                                                    color: Colors.black,
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 0.2,
                                              width: double.infinity,
                                              color: Colors.black,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Get.to(CreatePost())!
                                                    .then((value) async {
                                                  await createEvent();
                                                  setState(() {});
                                                });
                                                activeMenuprofile.value = false;
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Rooya',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            AppFonts.segoeui,
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Icon(
                                                    Icons.add_box_outlined,
                                                    color: Colors.black,
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 0.2,
                                              width: double.infinity,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(),
                )
              ],
            ),
    );
  }

  bool loadEvent = false;
  String selected_event_id = '';

  Future<void> deleteMyEvent(String event_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    String? userId = await prefs.getString('user_id');
    final response = await http.post(
        Uri.parse('${baseUrl}RemoveRooyaMyEvent$code'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({"event_admin": userId, "event_id": event_id}));
    print(response.request);
    print(response.statusCode);
    print('deleteMyEvent all data  = ${response.body}');
  }

  Future<void> getMyEventStories(String event_id) async {
    print('Event story call');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    String? userId = await prefs.getString('user_id');
    final response = await http.post(
        Uri.parse('${baseUrl}getMyEventStories$code'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({"user_id": widget.userID, "my_event_id": event_id}));
    print(response.request);
    print(response.statusCode);
    print('getMyEventStories all data  = ${response.body}');
    log(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] == 'success') {
        myEventStoryModel = UserStoryModel.fromJson(data['data'][0], false);
        setState(() {
          List<UserStoryModel> storystory = List<UserStoryModel>.from(
              data['data']
                  .map((model) => UserStoryModel.fromJson(model, true)));
          for (var i in storystory) {
            myEventStoryModel!.items!.addAll(i.items!);
          }
        });
      } else {
        myEventStoryModel!.items = [];
      }
      setState(() {});
    }
  }

  Future<void> getMyEventPosts(String event_id) async {
    print('event id = $event_id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    String? userId = await prefs.getString('user_id');
    final response = await http.post(
        Uri.parse('${baseUrl}getRooyaMyEventPostByLimite$code'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode(
            {"my_event_id": event_id, "page_size": 100, "page_number": 0}));

    setState(() {
      loadEvent = true;
    });

    print('Event posts is = ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] == 'success') {
        setState(() {
          myEventPostsList = List<RooyaPostModel>.from(
              data['data'].map((model) => RooyaPostModel.fromJson(model)));
        });
      } else {
        myEventPostsList = [];
        setState(() {});
      }
    } else {
      myEventPostsList = [];
      setState(() {});
    }
  }

  Future<void> getAllEvent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    String? userId = await prefs.getString('user_id');
    final response = await http.post(
        Uri.parse('${baseUrl}getRooyaMyPerEventByLimite${code}'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({
          "page_size": 100,
          "page_number": 0,
          "event_admin": widget.userID
        }));
    print('myEvent ids = ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] == 'success') {
        setState(() {
          myEvetModel = List<MyEventModel>.from(
              data['data'].map((model) => MyEventModel.fromJson(model)));
          selected_event_id = myEvetModel[0].eventId.toString();
        });
        getMyEventPosts(myEvetModel[0].eventId.toString());
        getMyEventStories(myEvetModel[0].eventId.toString());
      } else {
        setState(() {});
      }
    }
  }

  Future<void> getRooyaPost() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    String? userId = await prefs.getString('user_id');
    final response = await http.post(
        Uri.parse('${baseUrl}getRooyaProfilePosts${code}'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({
          "page_size": 100,
          "page_number": 0,
          "user_id": userId,
          "profile_id": widget.userID
        }));

    setState(() {
      isLoading = false;
    });

    print(response.request);
    print(response.statusCode);
    print('${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] == 'success') {
        setState(() {
          mRooyaPostsList = List<RooyaPostModel>.from(
              data['data'].map((model) => RooyaPostModel.fromJson(model)));
        });
      } else {
        setState(() {});
      }
    }
  }

  Future<void> getRooyaSouqbyLimit() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    String? userId = await prefs.getString('user_id');
    final response = await http.post(
        Uri.parse('${baseUrl}getProfileSouqProducts${code}'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({
          "user_id": userId,
          "page_size": 100,
          "page_number": 0,
          "profile_id": widget.userID
        }));

    setState(() {
      isLoading = false;
    });

    print(response.request);
    print(response.statusCode);
    print('getRooyaSouqbyLimit = ${response.body}');
    log('getRooyaSouqbyLimit = ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] == 'success') {
        setState(() {
          mRooyaSouqList = List<RooyaSouqModel>.from(
              data['data'].map((model) => RooyaSouqModel.fromJson(model)));
        });
      } else {
        setState(() {});
      }
    }
  }

  Future<void> getStories() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    String? userId = await prefs.getString('user_id');
    final response = await http.post(Uri.parse('${baseUrl}getStories${code}'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({"user_id": userId, "profile_id": widget.userID}));
    setState(() {
      isLoading = false;
    });

    print(response.request);
    print(response.statusCode);
    print('getStories all data  = ${response.body}');
    log(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] == 'success') {
        setState(() {
          userStoryModel = UserStoryModel.fromJson(data['data'][0], false);
          List<UserStoryModel> storystory = List<UserStoryModel>.from(
              data['data']
                  .map((model) => UserStoryModel.fromJson(model, true)));
          for (var i in storystory) {
            userStoryModel!.items!.addAll(i.items!);
          }
        });
      } else {
        userStoryModel!.items = [];
        setState(() {});
      }
    }
  }

  Future<void> folow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = await prefs.getString('user_id');
    String? token = await prefs.getString('token');
    final response = await http.post(Uri.parse('${baseUrl}ProfileFollow$code'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({'following_id': widget.userID, "user_id": userId}));
    isFOlow = true;
    profileInfoModel!.isFollow = true;
    setState(() {});
    var data = jsonDecode(response.body);
    snackBarSuccess('${data['message']}');
    print(response.request);
    print(response.statusCode);
    log(response.body);
  }

//https://apis.rooya.com/Alphaapis/allowfollowers?code=ROOYA-5574499
  Future<void> allowfollowers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = await prefs.getString('user_id');
    String? token = await prefs.getString('token');
    final response = await http.post(Uri.parse('${baseUrl}allowfollowers$code'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({'request_sender': widget.userID, "user_id": userId}));
    isFOlow = true;
    profileInfoModel!.isFollow = true;
    setState(() {});
    var data = jsonDecode(response.body);
    snackBarSuccess('${data['message']}');
    print(response.request);
    print(response.statusCode);
    log('allowfollowers = ${response.body}');
  }

  Future<void> checkAlreadySend() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = await prefs.getString('user_id');
    String? token = await prefs.getString('token');
    final response = await http.post(
        Uri.parse('${baseUrl}checkAlreadySend$code'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({"user_id": userId, "request_sender": widget.userID}));
    var data = jsonDecode(response.body);
    if (data['result'] == 'success') {
      if (data['data'][0]['allow'] == '0') {
        folowStatus = '2';
      } else if (data['data'][0]['allow'] == '1') {
        folowStatus = '1';
      }
    } else {
      folowStatus = '3';
    }
    setState(() {});
    print('checkAlreadySend data is = $data');
  }

  Future<void> unfolow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = await prefs.getString('user_id');
    String? token = await prefs.getString('token');
    final response = await http.post(
        Uri.parse('${baseUrl}ProfileUnFollow$code'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({'follow_id': widget.userID, "user_id": userId}));
    isFOlow = false;
    profileInfoModel!.isFollow = false;
    setState(() {});
    var data = jsonDecode(response.body);
    snackBarSuccess('${data['message']}');
    setState(() {});
    print(response.request);
    print(response.statusCode);
    log(response.body);
  }

  Future<void> getProfileInfo({bool? load = true}) async {
    setState(() {
      isLoadingProfile = load!;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = await prefs.getString('user_id');
    String? token = await prefs.getString('token');
    final response = await http.post(
        Uri.parse('${baseUrl}getProfileInfo${code}'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({"profile_id": widget.userID, "user_id": userId}));

    setState(() {
      isLoadingProfile = false;
    });

    print(response.request);
    print(response.statusCode);
    log('getProfileInfo = ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] == 'success') {
        setState(() {
          profileInfoModel = ProfileInfoModel.fromJson(data['data'][0]);
        });
      } else {
        setState(() {});
      }
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      decoration: BoxDecoration(color: Colors.white),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
