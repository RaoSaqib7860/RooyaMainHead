import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:rooya_app/ChatModule/ApiConfig/ApiUtils.dart';
import 'package:rooya_app/ChatModule/ApiConfig/SizeConfiq.dart';
import 'package:rooya_app/ChatModule/ClickController/SelectIndexController.dart';
import 'package:rooya_app/ChatModule/Home/chat_screen.dart';
import 'package:rooya_app/ChatModule/Home/friends_screen.dart';
import 'package:rooya_app/ChatModule/Home/group_screen.dart';
import 'package:rooya_app/ChatModule/Home/rooms_screen.dart';
import 'package:rooya_app/ChatModule/SearchUser/SearchUser.dart';
import 'package:rooya_app/ChatModule/responsive/primary_color.dart';
import 'package:rooya_app/ChatModule/sliver_class/sliver.dart';
import 'package:rooya_app/ChatModule/text_filed/app_font.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var selectController = Get.put(SelectIndexController());

  List iconList = [
    'assets/user/prs.svg',
    'assets/user/single.svg',
    'assets/user/persons.svg',
    'assets/user/sw.svg',
    'assets/user/fvrt.svg',
  ];

  int currentIndex = 0;

  List tabContent = [
    (ChatScreen()),
    (FriendsScreen()),
    (GroupScreen()),
    (RoomsScreen()),
    (FriendsScreen()),
  ];

  @override
  void initState() {
    selectController.observeronSearch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              height: height,
              width: width,
              child: Column(
                children: [
                  SizedBox(
                    height: 0.030,
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(CupertinoIcons.back)),
                      CircularProfileAvatar(
                        storage.read('profile') ==
                                'https://cc.rooyatech.com/assets/userImage/'
                            ? '${storage.read('profile')}notfound.png'
                            : '${storage.read('profile')}',
                        radius: 18,
                        backgroundColor: Colors.blueGrey[100]!,
                      ),
                      SizedBox(
                        width: width * 0.030,
                      ),
                      Text(
                        '${storage.read('name')}',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.segoeui),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              child: Icon(
                                CupertinoIcons.search,
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (c) => SearchUser()));
                              },
                            ),
                            SizedBox(
                              width: width * 0.030,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 0.030,
                  ),
                  Expanded(
                    child: ChatScreen(),
                  )
                ],
              ),
            )));
  }
}

class MyDelegate extends SliverPersistentHeaderDelegate {
  MyDelegate(this.widget);

  final Widget widget;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return widget;
  }

  @override
  double get maxExtent => 30;

  @override
  double get minExtent => 30;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
