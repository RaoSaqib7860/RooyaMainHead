import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rooya_app/ApiUtils/AuthUtils.dart';
import 'package:rooya_app/AppThemes/AppThemes.dart';
import 'package:rooya_app/ChatModule/Home/chat_screen.dart';
import 'package:rooya_app/RooyaExplore/RooyaExplore.dart';
import 'package:rooya_app/Screens/Reel/ReelCamera/ReelCamera.dart';
import 'package:rooya_app/AllCreatePosts/CreateAllView/create_all.dart';
import 'package:rooya_app/dashboard/Home/HomeController/HomeController.dart';
import 'package:rooya_app/dashboard/Home/Models/RooyaPostModel.dart';
import 'package:rooya_app/dashboard/Home/OpenSinglePost/OpenSinglePost.dart';
import 'package:rooya_app/dashboard/profile.dart';
import 'package:rooya_app/utils/AppFonts.dart';
import 'package:rooya_app/ApiUtils/baseUrl.dart';
import 'package:rooya_app/utils/ShimmerEffect.dart';
import 'package:rooya_app/utils/SizedConfig.dart';
import 'package:rooya_app/dashboard/Home/HomeComponents/user_post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../SharePost.dart';
import 'HomeComponents/StoryViews.dart';
import 'package:timeago/timeago.dart' as timeago;

var activeMenu = false.obs;
var activeMenuprofile = false.obs;
DateFormat sdf2 = DateFormat("hh.mm aa");

ScrollController scrollController = ScrollController();
String fromHomeStory = '0';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = false;
  List<RooyaPostModel> mRooyaPostsList = [];
  final controller = Get.put(HomeController());
  var searchText = ''.obs;

  @override
  void initState() {
    AuthUtils.getAllStoriesAPI(controller: controller);
    AuthUtils.getgetHomeBanner(controller: controller);
    AuthUtils.getgetRooyaPostByLimite(controller: controller);
    debounce(searchText, (value) {
      print('Search value is =$value');
      if (value.toString().isEmpty) {
        controller.listofSearch.value = [];
        setState(() {});
      } else {
        AuthUtils.getgetRooyaSearchPostByLimite(
            controller: controller, word: value.toString());
      }
    }, time: Duration(milliseconds: 600));
    super.initState();
  }

  SharedPreferences? prefs;

  GetStorage storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    print('image path = $baseImageUrl${storage.read('user_picture')}');
    return Scaffold(
      backgroundColor: offWhiteColor,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await AuthUtils.getgetRooyaPostByLimite(controller: controller);
              AuthUtils.getAllStoriesAPI(controller: controller);
            },
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 1.0.h, vertical: 1.10.h),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            SharedPreferences? prefs =
                                await SharedPreferences.getInstance();
                            String? userId = await prefs.getString('user_id');
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (c) => Profile(
                                      userID: userId,
                                    )));
                          },
                          child: storage.read('user_picture') == null ||
                                  storage.read('user_picture') == ''
                              ? CircularProfileAvatar(
                                  '',
                                  child: Image.asset('assets/images/logo.png'),
                                  radius: 15,
                                  borderColor: appThemes,
                                  borderWidth: 1,
                                )
                              : CircularProfileAvatar(
                                  '$baseImageUrl${storage.read('user_picture')}',
                                  radius: 15,
                                  borderColor: appThemes,
                                  borderWidth: 1,
                                ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Get.to(RooyaExplore());
                            },
                            child: Container(
                              height: 4.50.h,
                              margin: EdgeInsets.symmetric(horizontal: 2.0.w),
                              padding: EdgeInsets.symmetric(horizontal: 2.5.w),
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(25)),
                              child: TextFormField(
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                enabled: false,
                                onChanged: (v) {
                                  searchText.value = v;
                                },
                                decoration: new InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintText: 'Search',
                                  hintStyle: TextStyle(
                                    fontFamily: AppFonts.segoeui,
                                    fontSize: 11.0.sp,
                                    color: const Color(0xff5a5a5a),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 2.w,
                        ),
                        InkWell(
                          onTap: () {
                            //  Get.to(() => CreateAll());
                            activeMenu.value = true;
                          },
                          child: SvgPicture.asset(
                            'assets/BottomTabSVG/Create.svg',
                            height: 24,
                          ),
                        ),
                        SizedBox(
                          width: 2.w,
                        ),
                        CircularProfileAvatar(
                          '',
                          radius: 13,
                          child: SvgPicture.asset(
                            'assets/BottomTabSVG/Notification.svg',
                            height: 24,
                          ),
                        ),
                        SizedBox(
                          width: 2.w,
                        ),
                        InkWell(
                          onTap: () {
                            // Navigator.of(context).push(
                            //     MaterialPageRoute(builder: (c) => ChatScreen()));
                            pushNewScreen(
                              context,
                              screen: ChatScreen(),
                              withNavBar:
                                  false, // OPTIONAL VALUE. True by default.
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          child: CircularProfileAvatar(
                            '',
                            radius: 15,
                            borderWidth: 1,
                            backgroundColor: Colors.black,
                            child: SvgPicture.asset(
                              'assets/images/mLogo.svg',
                              height: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 7,
                ),
                Expanded(
                  child: Obx(
                    () => CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Container(
                            height: height * 0.240,
                            width: width,
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Obx(
                              () => controller.listofbanner.isEmpty
                                  ? ShimerEffect(
                                      child: Image.asset(
                                        'assets/images/home_banner.png',
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(13),
                                      child: CarouselSlider(
                                          items:
                                              controller.listofbanner.map((e) {
                                            int index = controller.listofbanner
                                                .indexOf(e);
                                            return CachedNetworkImage(
                                              imageUrl:
                                                  "$baseImageUrl${controller.listofbanner[index].bannerImage}",
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
                                            );
                                          }).toList(),
                                          options: CarouselOptions(
                                            height: height * 0.280,
                                            aspectRatio: 16 / 9,
                                            viewportFraction: 1,
                                            initialPage: 0,
                                            enableInfiniteScroll: true,
                                            reverse: false,
                                            autoPlay: true,
                                            autoPlayInterval:
                                                Duration(seconds: 10),
                                            autoPlayAnimationDuration:
                                                Duration(seconds: 2),
                                            autoPlayCurve: Curves.fastOutSlowIn,
                                            enlargeCenterPage: true,
                                            scrollDirection: Axis.horizontal,
                                          )),
                                    ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                            child: SizedBox(
                          height: 7,
                        )),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          sliver: SliverToBoxAdapter(
                            child: Obx(
                              () => Container(
                                decoration: BoxDecoration(color: Colors.white),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: InkWell(
                                          onTap: () {
                                            controller.isForyou.value = true;
                                            AuthUtils.getgetRooyaPostByLimite(
                                                controller: controller);
                                          },
                                          child: Center(
                                              child: Text(
                                            'For you',
                                            style: TextStyle(
                                              fontFamily: AppFonts.segoeui,
                                              fontSize: 14,
                                              color: controller.isForyou.value
                                                  ? appThemes
                                                  : Colors.black38,
                                            ),
                                            textAlign: TextAlign.center,
                                          )),
                                        )),
                                    Container(
                                      height: 3.50.h,
                                      width: 1,
                                      color: Colors.grey,
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: InkWell(
                                          onTap: () {
                                            controller.isForyou.value = false;
                                            AuthUtils.getRooyaPostByFollowing(
                                                controller: controller);
                                          },
                                          child: Center(
                                              child: Text(
                                            'Following',
                                            style: TextStyle(
                                              fontFamily: AppFonts.segoeui,
                                              fontSize: 14,
                                              color: !controller.isForyou.value
                                                  ? appThemes
                                                  : Colors.black38,
                                            ),
                                            textAlign: TextAlign.center,
                                          )),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 2.0.h,
                                  ),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     Text(
                                  //       'Stories',
                                  //       style: TextStyle(
                                  //         fontFamily: AppFonts.segoeui,
                                  //         fontSize: 16,
                                  //         color: const Color(0xff000000),
                                  //         fontWeight: FontWeight.w700,
                                  //       ),
                                  //       textAlign: TextAlign.left,
                                  //     ),
                                  //     Icon(
                                  //       Icons.arrow_forward,
                                  //       size: 20,
                                  //       color: appThemes,
                                  //     )
                                  //   ],
                                  // ),
                                  SizedBox(
                                    height: 1.0.h,
                                  ),
                                  Container(
                                    height: 14.0.h,
                                    width: width,
                                    child: Row(
                                      children: [
                                        InkWell(
                                          child: Container(
                                            height: 14.0.h,
                                            width: 20.0.w,
                                            child: Center(
                                              child: Icon(
                                                Icons.add_circle,
                                                color: appThemes,
                                                size: 30,
                                              ),
                                            ),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 0.5.h),
                                            decoration: BoxDecoration(
                                              color: Colors.blueGrey[100]!
                                                  .withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onTap: () {
                                            // Get.to(CreatePostStrory())!.then((value) {
                                            //   AuthUtils.getAllStoriesAPI(
                                            //       controller: controller);
                                            // });
                                            fromHomeStory = '0';
                                            Get.to(CameraApp(
                                              fromStory: true,
                                            ))!
                                                .then((value) {
                                              fromHomeStory = '0';
                                              AuthUtils.getAllStoriesAPI(
                                                  controller: controller);
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: Obx(
                                            () => !controller.storyLoad.value
                                                ? ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        BouncingScrollPhysics(),
                                                    itemCount: 4,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return ShimerEffect(
                                                        child: Stack(
                                                          children: [
                                                            Container(
                                                              height: 14.0.h,
                                                              width: 20.0.w,
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          0.5.h),
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  image: DecorationImage(
                                                                      fit: BoxFit
                                                                          .fill,
                                                                      image: AssetImage(
                                                                          'assets/images/story.png'))),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    })
                                                : controller
                                                        .listofStories.isEmpty
                                                    ? SizedBox()
                                                    : ListView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            BouncingScrollPhysics(),
                                                        itemCount: controller
                                                            .listofStories
                                                            .length,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemBuilder:
                                                            (context, index) {
                                                          String type = controller
                                                              .listofStories[
                                                                  index]
                                                              .storyobjects![0]
                                                              .type!;
                                                          if (controller
                                                                  .listofStories[
                                                                      index]
                                                                  .storyobjects![
                                                                      0]
                                                                  .event_id !=
                                                              '0') {
                                                            return SizedBox();
                                                          } else {
                                                            return Stack(
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    Get.to(
                                                                            MoreStories(
                                                                      storyobjects: controller
                                                                          .listofStories[
                                                                              index]
                                                                          .storyobjects,
                                                                    ))!
                                                                        .then(
                                                                            (value) {
                                                                      controller
                                                                          .storyLoad
                                                                          .value = false;
                                                                      AuthUtils.getAllStoriesAPI(
                                                                          controller:
                                                                              controller);
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        14.0.h,
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      child: type ==
                                                                              'photo'
                                                                          ? CachedNetworkImage(
                                                                              imageUrl: "$baseImageUrl${controller.listofStories[index].storyobjects![0].src}",
                                                                              fit: BoxFit.cover,
                                                                              progressIndicatorBuilder: (context, url, downloadProgress) => ShimerEffect(
                                                                                child: Image.asset(
                                                                                  'assets/images/home_banner.png',
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                              errorWidget: (context, url, error) => Image.asset(
                                                                                'assets/images/home_banner.png',
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            )
                                                                          : Center(
                                                                              child: Icon(
                                                                                Icons.play_circle_fill,
                                                                                color: Colors.white,
                                                                                size: 30,
                                                                              ),
                                                                            ),
                                                                    ),
                                                                    width:
                                                                        20.0.w,
                                                                    margin: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            0.5.h),
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .black,
                                                                        borderRadius:
                                                                            BorderRadius.circular(8)),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              8,
                                                                          top:
                                                                              5),
                                                                  width: 20.0.w,
                                                                  child: Row(
                                                                    children: [
                                                                      CircularProfileAvatar(
                                                                        '',
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          imageUrl: controller.listofStories[index].storyobjects![0].userPicture == null
                                                                              ? 'https://www.gravatar.com/avatar/test@test.com.jpg?s=200&d=mm'
                                                                              : "$baseImageUrl${controller.listofStories[index].storyobjects![0].userPicture}",
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          progressIndicatorBuilder: (context, url, downloadProgress) =>
                                                                              ShimerEffect(
                                                                            child:
                                                                                Image.asset(
                                                                              'assets/images/home_banner.png',
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                          errorWidget: (context, url, error) =>
                                                                              Image.asset(
                                                                            'assets/images/home_banner.png',
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                        borderColor:
                                                                            appThemes,
                                                                        elevation:
                                                                            5,
                                                                        borderWidth:
                                                                            1,
                                                                        radius:
                                                                            10,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            3,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          '${controller.listofStories[index].storyobjects![0].userName}',
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 8),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                        }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3.0.h,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // SliverPadding(
                        //   padding: EdgeInsets.symmetric(horizontal: width * 0.030),
                        //   sliver: SliverToBoxAdapter(
                        //     child: Column(
                        //       children: [
                        //         SizedBox(
                        //           height: 1.0.h,
                        //         ),
                        //         // Row(
                        //         //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //         //   children: [
                        //         //     Text(
                        //         //       'Event Stories',
                        //         //       style: TextStyle(
                        //         //         fontFamily: AppFonts.segoeui,
                        //         //         fontSize: 16,
                        //         //         color: const Color(0xff000000),
                        //         //         fontWeight: FontWeight.w700,
                        //         //       ),
                        //         //       textAlign: TextAlign.left,
                        //         //     ),
                        //         //   ],
                        //         // ),
                        //         SizedBox(
                        //           height: 1.0.h,
                        //         ),
                        //         Container(
                        //           height: 14.0.h,
                        //           width: width,
                        //           child: Row(
                        //             children: [
                        //               Expanded(
                        //                 child: Obx(
                        //                   () => !controller.storyLoad.value
                        //                       ? ListView.builder(
                        //                           shrinkWrap: true,
                        //                           physics: BouncingScrollPhysics(),
                        //                           itemCount: 4,
                        //                           scrollDirection: Axis.horizontal,
                        //                           itemBuilder: (context, index) {
                        //                             return ShimerEffect(
                        //                               child: Stack(
                        //                                 children: [
                        //                                   Container(
                        //                                     height: 14.0.h,
                        //                                     width: 20.0.w,
                        //                                     margin: EdgeInsets
                        //                                         .symmetric(
                        //                                             horizontal:
                        //                                                 0.5.h),
                        //                                     decoration: BoxDecoration(
                        //                                         borderRadius:
                        //                                             BorderRadius
                        //                                                 .circular(
                        //                                                     8),
                        //                                         image: DecorationImage(
                        //                                             fit:
                        //                                                 BoxFit.fill,
                        //                                             image: AssetImage(
                        //                                                 'assets/images/story.png'))),
                        //                                   ),
                        //                                 ],
                        //                               ),
                        //                             );
                        //                           })
                        //                       : controller.listofStories.isEmpty
                        //                           ? SizedBox()
                        //                           : ListView.builder(
                        //                               shrinkWrap: true,
                        //                               physics:
                        //                                   BouncingScrollPhysics(),
                        //                               itemCount: controller
                        //                                   .listofStories.length,
                        //                               scrollDirection:
                        //                                   Axis.horizontal,
                        //                               itemBuilder:
                        //                                   (context, index) {
                        //                                 String type = controller
                        //                                     .listofStories[index]
                        //                                     .storyobjects![0]
                        //                                     .type!;
                        //                                 if (controller
                        //                                         .listofStories[
                        //                                             index]
                        //                                         .storyobjects![0]
                        //                                         .event_id ==
                        //                                     '0') {
                        //                                   return SizedBox();
                        //                                 } else {
                        //                                   return Stack(
                        //                                     children: [
                        //                                       InkWell(
                        //                                         onTap: () {
                        //                                           Get.to(MoreStories(
                        //                                             storyobjects: controller
                        //                                                 .listofStories[
                        //                                                     index]
                        //                                                 .storyobjects,
                        //                                           ))!
                        //                                               .then((value) {
                        //                                             controller
                        //                                                     .storyLoad
                        //                                                     .value =
                        //                                                 false;
                        //                                             AuthUtils.getAllStoriesAPI(
                        //                                                 controller:
                        //                                                     controller);
                        //                                           });
                        //                                         },
                        //                                         child: Container(
                        //                                           height: 14.0.h,
                        //                                           child: ClipRRect(
                        //                                             borderRadius:
                        //                                                 BorderRadius
                        //                                                     .circular(
                        //                                                         8),
                        //                                             child: type ==
                        //                                                     'photo'
                        //                                                 ? CachedNetworkImage(
                        //                                                     imageUrl:
                        //                                                         "$baseImageUrl${controller.listofStories[index].storyobjects![0].src}",
                        //                                                     fit: BoxFit
                        //                                                         .cover,
                        //                                                     progressIndicatorBuilder: (context,
                        //                                                             url,
                        //                                                             downloadProgress) =>
                        //                                                         ShimerEffect(
                        //                                                       child:
                        //                                                           Image.asset(
                        //                                                         'assets/images/home_banner.png',
                        //                                                         fit:
                        //                                                             BoxFit.cover,
                        //                                                       ),
                        //                                                     ),
                        //                                                     errorWidget: (context,
                        //                                                             url,
                        //                                                             error) =>
                        //                                                         Image.asset(
                        //                                                       'assets/images/home_banner.png',
                        //                                                       fit: BoxFit
                        //                                                           .cover,
                        //                                                     ),
                        //                                                   )
                        //                                                 : Center(
                        //                                                     child:
                        //                                                         Icon(
                        //                                                       Icons
                        //                                                           .play_circle_fill,
                        //                                                       color:
                        //                                                           Colors.white,
                        //                                                       size:
                        //                                                           30,
                        //                                                     ),
                        //                                                   ),
                        //                                           ),
                        //                                           width: 20.0.w,
                        //                                           margin: EdgeInsets
                        //                                               .symmetric(
                        //                                                   horizontal:
                        //                                                       0.5.h),
                        //                                           decoration: BoxDecoration(
                        //                                               color: Colors
                        //                                                   .black,
                        //                                               borderRadius:
                        //                                                   BorderRadius
                        //                                                       .circular(
                        //                                                           8)),
                        //                                         ),
                        //                                       ),
                        //                                       Container(
                        //                                         padding:
                        //                                             EdgeInsets.only(
                        //                                                 left: 8,
                        //                                                 top: 5),
                        //                                         width: 20.0.w,
                        //                                         child: Row(
                        //                                           children: [
                        //                                             CircularProfileAvatar(
                        //                                               '',
                        //                                               child:
                        //                                                   CachedNetworkImage(
                        //                                                 imageUrl: controller.listofStories[index].storyobjects![0].userPicture ==
                        //                                                         null
                        //                                                     ? 'https://www.gravatar.com/avatar/test@test.com.jpg?s=200&d=mm'
                        //                                                     : "$baseImageUrl${controller.listofStories[index].storyobjects![0].userPicture}",
                        //                                                 fit: BoxFit
                        //                                                     .cover,
                        //                                                 progressIndicatorBuilder: (context,
                        //                                                         url,
                        //                                                         downloadProgress) =>
                        //                                                     ShimerEffect(
                        //                                                   child: Image
                        //                                                       .asset(
                        //                                                     'assets/images/home_banner.png',
                        //                                                     fit: BoxFit
                        //                                                         .cover,
                        //                                                   ),
                        //                                                 ),
                        //                                                 errorWidget: (context,
                        //                                                         url,
                        //                                                         error) =>
                        //                                                     Image
                        //                                                         .asset(
                        //                                                   'assets/images/home_banner.png',
                        //                                                   fit: BoxFit
                        //                                                       .cover,
                        //                                                 ),
                        //                                               ),
                        //                                               borderColor:
                        //                                                   appThemes,
                        //                                               elevation: 5,
                        //                                               borderWidth:
                        //                                                   1,
                        //                                               radius: 10,
                        //                                             ),
                        //                                             SizedBox(
                        //                                               width: 3,
                        //                                             ),
                        //                                             Expanded(
                        //                                               child: Text(
                        //                                                 '${controller.listofStories[index].storyobjects![0].userName}',
                        //                                                 maxLines: 2,
                        //                                                 overflow:
                        //                                                     TextOverflow
                        //                                                         .ellipsis,
                        //                                                 style: TextStyle(
                        //                                                     color: Colors
                        //                                                         .white,
                        //                                                     fontSize:
                        //                                                         8),
                        //                                               ),
                        //                                             )
                        //                                           ],
                        //                                         ),
                        //                                       ),
                        //                                     ],
                        //                                   );
                        //                                 }
                        //                               }),
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //         // SizedBox(
                        //         //   height: 3.0.h,
                        //         // ),
                        //         // Row(
                        //         //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //         //   children: [
                        //         //     Text(
                        //         //       'Rooya',
                        //         //       style: TextStyle(
                        //         //         fontFamily: AppFonts.segoeui,
                        //         //         fontSize: 16,
                        //         //         color: Color(0xff000000),
                        //         //         fontWeight: FontWeight.w700,
                        //         //       ),
                        //         //       textAlign: TextAlign.left,
                        //         //     ),
                        //         //     InkWell(
                        //         //       onTap: () {
                        //         //         Get.to(CreatePost())!.then((value) {
                        //         //           AuthUtils.getgetRooyaPostByLimite(
                        //         //               controller: controller);
                        //         //         });
                        //         //       },
                        //         //       child: Container(
                        //         //         padding: EdgeInsets.all(1.0.h),
                        //         //         decoration: BoxDecoration(
                        //         //             border: Border.all(
                        //         //                 color: Color(0xff0bab0d)),
                        //         //             borderRadius: BorderRadius.circular(5)),
                        //         //         child: Text('Add Rooya',
                        //         //             style: TextStyle(
                        //         //               fontFamily: AppFonts.segoeui,
                        //         //               fontSize: 12,
                        //         //               color: const Color(0xff0bab0d),
                        //         //               fontWeight: FontWeight.w700,
                        //         //             )),
                        //         //       ),
                        //         //     )
                        //         //   ],
                        //         // ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 10,
                          ),
                        ),
                        !controller.storyLoad.value
                            ? SliverToBoxAdapter(
                                child: Container(
                                  height: 300,
                                  width: width,
                                  child: Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                ),
                              )
                            : controller.listofSearch.isNotEmpty
                                ? SliverPadding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.030),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                          return Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white),
                                            child: UserPost(
                                              rooyaPostModel: controller
                                                  .listofSearch[index],
                                              onPostLike: () {
                                                setState(() {
                                                  controller.listofSearch[index]
                                                      .islike = true;
                                                  controller.listofSearch[index]
                                                      .likecount = controller
                                                          .listofSearch[index]
                                                          .likecount! +
                                                      1;
                                                });
                                              },
                                              onPostUnLike: () {
                                                setState(() {
                                                  controller.listofSearch[index]
                                                      .islike = false;
                                                  controller.listofSearch[index]
                                                      .likecount = controller
                                                          .listofSearch[index]
                                                          .likecount! -
                                                      1;
                                                });
                                              },
                                              comment: () {
                                                AuthUtils
                                                    .getgetRooyaSearchPostByLimite(
                                                        controller: controller,
                                                        word: searchText.value
                                                            .toString());
                                              },
                                            ),
                                          );
                                        },
                                        childCount:
                                            controller.listofSearch.length,
                                      ),
                                    ),
                                  )
                                : SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                        if (controller
                                                .listofpost[index].origin_id !=
                                            '0') {
                                          return Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          width * 0.030),
                                                  child: Row(
                                                    children: [
                                                      controller
                                                                  .listofpost[
                                                                      index]
                                                                  .userPicture ==
                                                              null
                                                          ? CircularProfileAvatar(
                                                              '',
                                                              child: Image.asset(
                                                                  'assets/images/logo.png'),
                                                              elevation: 5,
                                                              radius: 23,
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(MaterialPageRoute(
                                                                        builder: (c) => Profile(
                                                                              userID: '${controller.listofpost[index].userPosted}',
                                                                            )));
                                                              },
                                                              borderColor:
                                                                  appThemes,
                                                              borderWidth: 1,
                                                            )
                                                          : CircularProfileAvatar(
                                                              '$baseImageUrl${controller.listofpost[index].userPicture}',
                                                              elevation: 5,
                                                              radius: 23,
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(MaterialPageRoute(
                                                                        builder: (c) => Profile(
                                                                              userID: '${controller.listofpost[index].userPosted}',
                                                                            )));
                                                              },
                                                              borderColor:
                                                                  appThemes,
                                                              borderWidth: 1,
                                                            ),
                                                      SizedBox(
                                                        width: 4.0.w,
                                                      ),
                                                      Expanded(
                                                          child: InkWell(
                                                        onTap: () {
                                                          print(
                                                              'Click on profile');
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (c) =>
                                                                      Profile(
                                                                        userID:
                                                                            '${controller.listofpost[index].userPosted}',
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
                                                                    '${controller.listofpost[index].userfullname} ',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          AppFonts
                                                                              .segoeui,
                                                                      fontSize:
                                                                          13,
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
                                                                        ' Shared a ${controller.listofpost[index].pre_user_name} post',
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              AppFonts.segoeui,
                                                                          fontSize:
                                                                              11,
                                                                          color:
                                                                              Colors.black38,
                                                                        )),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              '@${controller.listofpost[index].userName}',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    AppFonts
                                                                        .segoeui,
                                                                fontSize: 10,
                                                                color: const Color(
                                                                    0xff000000),
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            )
                                                          ],
                                                        ),
                                                      )),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 10),
                                                        child: Text(
                                                          '${timeago.format(DateTime.parse(controller.listofpost[index].time!), locale: 'en_short')} ago',
                                                          style: TextStyle(
                                                            fontFamily: AppFonts
                                                                .segoeui,
                                                            fontSize: 10,
                                                            color: const Color(
                                                                0xff000000),
                                                            height: 1.8,
                                                          ),
                                                          textAlign:
                                                              TextAlign.right,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 1.0.h,
                                                ),
                                                InkWell(
                                                  child: IgnorePointer(
                                                    child: SharePost(
                                                      rooyaPostModel: controller
                                                          .listofpost[index],
                                                      onPostLike: () {
                                                        setState(() {
                                                          controller
                                                              .listofpost[index]
                                                              .islike = true;
                                                          controller
                                                              .listofpost[index]
                                                              .likecount = controller
                                                                  .listofpost[
                                                                      index]
                                                                  .likecount! +
                                                              1;
                                                        });
                                                      },
                                                      onPostUnLike: () {
                                                        setState(() {
                                                          controller
                                                              .listofpost[index]
                                                              .islike = false;
                                                          controller
                                                              .listofpost[index]
                                                              .likecount = controller
                                                                  .listofpost[
                                                                      index]
                                                                  .likecount! -
                                                              1;
                                                        });
                                                      },
                                                      comment: () {
                                                        AuthUtils
                                                            .getgetRooyaPostByLimite(
                                                                controller:
                                                                    controller);
                                                      },
                                                    ),
                                                    ignoring: true,
                                                  ),
                                                  onTap: () {
                                                    Get.to(OpenSinglePost(
                                                      postId: controller
                                                          .listofpost[index]
                                                          .postId
                                                          .toString(),
                                                    ));
                                                  },
                                                ),
                                                SizedBox(
                                                  height: height * 0.020,
                                                )
                                              ],
                                            ),
                                          );
                                        } else {
                                          return UserPost(
                                            rooyaPostModel:
                                                controller.listofpost[index],
                                            onPostLike: () {
                                              setState(() {
                                                controller.listofpost[index]
                                                    .islike = true;
                                                controller.listofpost[index]
                                                    .likecount = controller
                                                        .listofpost[index]
                                                        .likecount! +
                                                    1;
                                              });
                                            },
                                            onPostUnLike: () {
                                              setState(() {
                                                controller.listofpost[index]
                                                    .islike = false;
                                                controller.listofpost[index]
                                                    .likecount = controller
                                                        .listofpost[index]
                                                        .likecount! -
                                                    1;
                                              });
                                            },
                                            comment: () {
                                              AuthUtils.getgetRooyaPostByLimite(
                                                  controller: controller);
                                            },
                                          );
                                        }
                                      },
                                      childCount: controller.listofpost.length,
                                    ),
                                  ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => activeMenu.value
                ? Center(
                    child: InkWell(
                      onTap: () {
                        activeMenu.value = false;
                      },
                      child: Stack(
                        children: [
                          Container(
                            height: height,
                            width: width,
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
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
                                  child: CreateAll(),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
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
}
