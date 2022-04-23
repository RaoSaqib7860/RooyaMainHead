import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:rooya_app/ApiUtils/baseUrl.dart';
import 'package:rooya_app/AppThemes/AppThemes.dart';
import 'package:rooya_app/RooyaExplore/RooyaExploreController.dart';
import 'package:rooya_app/UserTagSearch/UserTagSearch.dart';
import 'package:rooya_app/dashboard/Home/OpenSinglePost/OpenSinglePost.dart';
import 'package:rooya_app/models/HashTagModel.dart';
import 'package:rooya_app/utils/AppFonts.dart';
import 'package:rooya_app/utils/ShimmerEffect.dart';
import 'package:rooya_app/utils/SizedConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class RooyaExplore extends StatefulWidget {
  const RooyaExplore({Key? key}) : super(key: key);

  @override
  _RooyaExploreState createState() => _RooyaExploreState();
}

class _RooyaExploreState extends State<RooyaExplore> {
  var controller = Get.put(RooyaExploreController());

  @override
  void initState() {
    controller.getExplorePosts();
    getHashTags();
    super.initState();
  }

  List listOfTab = ['ALL', 'ROOYA', ' # ', 'STORY', 'SOUQ'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 0,
          leading: SizedBox(),
          bottom: PreferredSize(
            preferredSize: Size(width, height * 0.030),
            child: TabBar(
              isScrollable: true,
              labelColor: appThemes,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: appThemes,
              unselectedLabelColor: Colors.black,
              tabs: listOfTab.map((e) {
                return Column(
                  children: [
                    Text(
                      '$e',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    )
                  ],
                );
              }).toList(),
            ),
          ),
          elevation: 0,
          title: Container(
            height: Get.height * 0.045,
            width: Get.width,
            padding: EdgeInsets.only(left: 10, right: 0),
            child: TextFormField(
              onChanged: (value) {
                // selectController.search.value = value;
                // print('selectController search is = ${selectController.search.value}');
              },
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                disabledBorder: new OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: new BorderSide(
                      color: Colors.black12,
                    )),
                focusedBorder: new OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: new BorderSide(
                      color: Colors.black12,
                    )),
                enabledBorder: new OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: new BorderSide(
                      color: Colors.black12,
                    )),
                border: new OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: new BorderSide(
                      color: Colors.black12,
                    )),
                isDense: true,
                hintText: 'Search here ...',
                hintStyle: TextStyle(fontSize: 10, color: Colors.black),
              ),
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: TabBarView(
          children: [
            Container(
              height: height,
              width: width,
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Obx(
                      () => RefreshIndicator(
                        onRefresh: () async {
                          await controller.getExplorePosts();
                          setState(() {});
                        },
                        child: GridView.custom(
                          gridDelegate: SliverQuiltedGridDelegate(
                            crossAxisCount: 3,
                            mainAxisSpacing: 1,
                            crossAxisSpacing: 1,
                            repeatPattern: QuiltedGridRepeatPattern.same,
                            pattern: [
                              QuiltedGridTile(2, 2),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(2, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(2, 2),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(2, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1),
                              QuiltedGridTile(1, 1)
                            ],
                          ),
                          childrenDelegate:
                              SliverChildBuilderDelegate((context, index) {
                            return InkWell(
                              onTap: () {
                                Get.to(
                                  OpenSinglePost(
                                    postId: controller.listofpost[index].postId
                                        .toString(),
                                    model: controller.listofpost[index],
                                    containData: true,
                                  ),
                                );
                              },
                              child: Container(
                                height: double.infinity,
                                width: double.infinity,
                                decoration: BoxDecoration(color: Colors.black),
                                child: controller.listofpost[index]
                                            .attachment![0].type ==
                                        'image'
                                    ? CachedNetworkImage(
                                        imageUrl:
                                            '$baseImageUrl${controller.listofpost[index].attachment![0].attachment}',
                                        fit: BoxFit.cover,
                                        progressIndicatorBuilder:
                                            (context, url, downloadProgress) =>
                                                ShimerEffect(
                                          child: Image.asset(
                                            'assets/images/home_banner.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          'assets/images/home_banner.png',
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(
                                        child: Icon(
                                          CupertinoIcons.play_circle_fill,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                              ),
                            );
                          }, childCount: controller.listofpost.length),
                        ),
                      ),
                    ),
                  ),

                  // Expanded(
                  //     child: Obx(
                  //   () => StaggeredGridView.countBuilder(
                  //     shrinkWrap: true,
                  //     padding: EdgeInsets.all(0),
                  //     crossAxisCount: 3,
                  //     itemCount: controller.listofpost.length,
                  //     itemBuilder: (BuildContext context, int index) {
                  //       return InkWell(
                  //         onTap: () {
                  //           Get.to(
                  //               OpenSinglePost(
                  //                 postId:
                  //                     controller.listofpost[index].postId.toString(),
                  //                 model: controller.listofpost[index],
                  //                 containData: true,
                  //               ),
                  //               transition: Transition.circularReveal);
                  //         },
                  //         child: Container(
                  //           height: double.infinity,
                  //           width: double.infinity,
                  //           decoration: BoxDecoration(color: Colors.black),
                  //           child: controller.listofpost[index].attachment![0].type ==
                  //                   'image'
                  //               ? CachedNetworkImage(
                  //                   imageUrl:
                  //                       '$baseImageUrl${controller.listofpost[index].attachment![0].attachment}',
                  //                   fit: BoxFit.cover,
                  //                   progressIndicatorBuilder:
                  //                       (context, url, downloadProgress) =>
                  //                           ShimerEffect(
                  //                     child: Image.asset(
                  //                       'assets/images/home_banner.png',
                  //                       fit: BoxFit.cover,
                  //                     ),
                  //                   ),
                  //                   errorWidget: (context, url, error) => Image.asset(
                  //                     'assets/images/home_banner.png',
                  //                     fit: BoxFit.cover,
                  //                   ),
                  //                 )
                  //               : Center(
                  //                   child: Icon(
                  //                     CupertinoIcons.play_circle_fill,
                  //                     color: Colors.white,
                  //                     size: 30,
                  //                   ),
                  //                 ),
                  //         ),
                  //       );
                  //     },
                  //     staggeredTileBuilder: (int index) {
                  //       return StaggeredTile.count(
                  //           ((index + 1) == 10 || (index + 1) % 20 == 0) ||
                  //                   index + 1 == 2
                  //               ? 2
                  //               : 1,
                  //           ((index + 1) == 10 || (index + 1) % 20 == 0) ||
                  //                   index + 1 == 2
                  //               ? 2
                  //               : index >= 27
                  //                   ? (index + 3) % 10 == 0 && (index + 3) % 20 != 0
                  //                       ? 2
                  //                       : 1
                  //                   : 1);
                  //     },
                  //     mainAxisSpacing: 3.0,
                  //     crossAxisSpacing: 3.0,
                  //   ),
                  // ))
                ],
              ),
            ),
            Icon(Icons.music_video),
            Container(
                height: height,
                width: width,
                color: Colors.white,
                child: ListView.builder(
                  itemBuilder: (c, i) {
                    return ListTile(
                      leading: Text(
                        '#',
                        style: TextStyle(fontSize: 40),
                      ),
                      title: Text(
                        '# ${controller.mRooyaHashTagList[i].hashtag}',
                        style: TextStyle(fontSize: 15),
                      ),
                      onTap: () {
                        Get.to(UserTagSearch(
                          tag: '${controller.mRooyaHashTagList[i].hashtag}',
                        ));
                      },
                    );
                  },
                  itemCount: controller.mRooyaHashTagList.length,
                )),
            Icon(Icons.grade),
            Icon(Icons.email),
          ],
        ),
      ),
    );
  }

  Future<void> getHashTags() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    final response = await http.get(
        Uri.parse('${baseUrl}getRooyaPostHashTag${code}'),
        headers: {"Content-Type": "application/json", "Authorization": token!});
    print('hash tag is = ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] == 'success') {
        setState(() {
          controller.mRooyaHashTagList = List<HashTagModel>.from(
              data['data'].map((model) => HashTagModel.fromJson(model)));
        });
        setState(() {});
      } else {
        setState(() {});
      }
    }
  }
}
