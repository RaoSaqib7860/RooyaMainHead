import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rooya_app/AppThemes/AppThemes.dart';
import 'package:rooya_app/ExploreRooya/ExploreRooya.dart';
import 'package:rooya_app/RooyaExplore/RooyaExplore.dart';
import 'package:rooya_app/Screens/Reel/Reel.dart';
import '../../main.dart';
import '../Home/home.dart';
import '../menu.dart';
import '../../CreateSouq/rooya_souq.dart';

PersistentTabController? persistentcontroller;
bool selectHome = true;

class BottomSheetCustom extends StatefulWidget {
  final int? index;

  const BottomSheetCustom({Key? key, this.index = 0}) : super(key: key);

  @override
  _BottomSheetCustomState createState() => _BottomSheetCustomState();
}

class _BottomSheetCustomState extends State<BottomSheetCustom> {
  @override
  void initState() {
    persistentcontroller = PersistentTabController(initialIndex: widget.index!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PersistentTabView(
        context,
        screens: _buildScreens(),
        items: _navBarsItems(),
        controller: persistentcontroller,
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardShows: true,
        onItemSelected: (index) {
          if (index != 2) {
            streamController.sink.add(10.0);
          }
          if (index == 0) {
            if (selectHome) {
              scrollController.animateTo(
                scrollController.position.minScrollExtent,
                duration: Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
              );
            } else {
              selectHome = true;
            }
          } else {
            selectHome = false;
          }
        },
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: ItemAnimationProperties(
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle: NavBarStyle.simple,
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      Home(),
      RooyaExplore(),
      ReelPage(),
      RooyaSouq(),
      Menu(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
          icon: SvgPicture.asset(
            'assets/svg/HomeIcon.svg',
            height: 24,
            color: appThemes,
          ),
          inactiveIcon: SvgPicture.asset(
            'assets/svg/HomeIcon.svg',
            height: 24,
            color: Colors.black,
          ),
          activeColorPrimary: Colors.black,
          inactiveColorPrimary: Colors.black),
      PersistentBottomNavBarItem(
          icon: SvgPicture.asset(
            'assets/BottomTabSVG/Explore.svg',
            height: 40,
            color: appThemes,
          ),
          inactiveIcon: SvgPicture.asset(
            'assets/BottomTabSVG/Explore.svg',
            height: 40,
            color: Colors.black,
          ),
          activeColorPrimary: Colors.black,
          inactiveColorPrimary: Colors.black),
      PersistentBottomNavBarItem(
          icon: SvgPicture.asset(
            'assets/BottomTabSVG/Reel.svg',
            height: 24,
            color: appThemes,
          ),
          inactiveIcon: SvgPicture.asset(
            'assets/BottomTabSVG/Reel.svg',
            height: 24,
            color: Colors.black,
          ),
          activeColorPrimary: Colors.black,
          inactiveColorPrimary: Colors.black),
      PersistentBottomNavBarItem(
          icon: SvgPicture.asset(
            'assets/BottomTabSVG/Souq.svg',
            height: 24,
            color: appThemes,
          ),
          inactiveIcon: SvgPicture.asset(
            'assets/BottomTabSVG/Souq.svg',
            height: 24,
            color: Colors.black,
          ),
          activeColorPrimary: Colors.black,
          inactiveColorPrimary: Colors.black),
      PersistentBottomNavBarItem(
          icon: Container(
            padding: EdgeInsets.all(5),
            child: Icon(
              Icons.menu,
            ),
          ),
          activeColorPrimary: appThemes,
          inactiveColorPrimary: Colors.black),
    ];
  }
}
