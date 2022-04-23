import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooya_app/ApiUtils/AuthUtils.dart';
import 'package:rooya_app/AppThemes/AppThemes.dart';
import 'package:rooya_app/dashboard/Home/HomeComponents/user_post.dart';
import 'package:rooya_app/utils/SizedConfig.dart';
import 'UserTagSearchController.dart';

class UserTagSearch extends StatefulWidget {
  final String? tag;
  const UserTagSearch({Key? key, this.tag}) : super(key: key);

  @override
  _UserTagSearchState createState() => _UserTagSearchState();
}

class _UserTagSearchState extends State<UserTagSearch> {
  List listOfTab = ['TOP', 'LATEST', 'PEOPLE', 'PHOTOS', 'VIDEOS'];
  var controller = Get.put(UserTagSearchController());
  @override
  void initState() {
    controller.getExplorePosts(tag: widget.tag);
    super.initState();
  }

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
              //  padding: EdgeInsets.only(left: 10, right: 0),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      )),
                  Expanded(
                    child: Container(
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
                          hintStyle:
                              TextStyle(fontSize: 10, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.filter_list_outlined,
                          color: Colors.black)),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
            backgroundColor: Colors.white,
          ),
          body: TabBarView(
            children: [
              Container(
                height: height,
                width: width,
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.030),
                      sliver: Obx(
                        () => !controller.loadPost.value
                            ? SliverToBoxAdapter(
                                child: SizedBox(
                                  height: height - 50,
                                  width: width,
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                ),
                              )
                            : controller.listofpost.isEmpty
                                ? SliverToBoxAdapter(
                                    child: SizedBox(
                                      height: height - 50,
                                      width: width,
                                      child: Center(child: Text('Empty')),
                                    ),
                                  )
                                : SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                        return Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white),
                                          child: UserPost(
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
                                            // comment: () {
                                            //   AuthUtils
                                            //       .getgetRooyaSearchPostByLimite(
                                            //       controller: controller,
                                            //       word: searchText.value
                                            //           .toString());
                                            // },
                                          ),
                                        );
                                      },
                                      childCount: controller.listofpost.length,
                                    ),
                                  ),
                      ),
                    )
                  ],
                ),
              ),
              Icon(Icons.music_video),
              Icon(Icons.music_video),
              Icon(Icons.grade),
              Icon(Icons.email),
            ],
          ),
        ));
  }
}
