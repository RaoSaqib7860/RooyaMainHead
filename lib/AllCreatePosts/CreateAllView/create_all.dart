import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooya_app/AllCreatePosts/CreatePost/create_post.dart';
import 'package:rooya_app/rooya_souq/create_souq.dart';
import 'package:rooya_app/utils/AppFonts.dart';
import 'package:sizer/sizer.dart';
import '../../Screens/Reel/ReelCamera/ReelCamera.dart';
import '../../dashboard/Home/home.dart';
import '../../events/CreateNewEvent/CreateNewEvent.dart';
import 'package:flutter/cupertino.dart';

class CreateAll extends StatefulWidget {
  @override
  _CreateAllState createState() => _CreateAllState();
}

class _CreateAllState extends State<CreateAll> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            Get.to(CreatePost());
            activeMenu.value = false;
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rooya',
                style: TextStyle(
                    fontFamily: AppFonts.segoeui,
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
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
                .then((value) {
              fromHomeStory = '0';
            });
            activeMenu.value = false;
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Story',
                style: TextStyle(
                    fontFamily: AppFonts.segoeui,
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
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
            Get.to(() => CreateSouq());
            activeMenu.value = false;
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Souq',
                style: TextStyle(
                    fontFamily: AppFonts.segoeui,
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
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
            Get.to(() => CreateNewEvent());
            activeMenu.value = false;
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Event',
                style: TextStyle(
                    fontFamily: AppFonts.segoeui,
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
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
    );
  }
}
