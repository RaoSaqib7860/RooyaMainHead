import 'dart:convert';
import 'dart:developer';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:get/get.dart';
import 'package:rooya_app/models/HashTagModel.dart';
import 'package:rooya_app/utils/AppFonts.dart';
import 'package:rooya_app/utils/ProgressHUD.dart';
import 'package:rooya_app/ApiUtils/baseUrl.dart';
import 'package:http/http.dart' as http;
import 'package:rooya_app/utils/SizedConfig.dart';
import 'package:rooya_app/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/cupertino.dart';

class AddHashTags extends StatefulWidget {
  List<HashTagModel>? selectedHashTags;
  Function? onAddHashTag;

  AddHashTags({Key? key, this.selectedHashTags, this.onAddHashTag})
      : super(key: key);

  @override
  _AddHashTagsState createState() => _AddHashTagsState();
}

class _AddHashTagsState extends State<AddHashTags> {
  List<HashTagModel> _selectedHashTags = [];
  bool isLoading = false;
  List<HashTagModel> mRooyaHashTagList = [];

  @override
  void initState() {
    _selectedHashTags.addAll(widget.selectedHashTags!);
    getHashTags();
    debounce(searchText, (value) {
      setState(() {});
    }, time: Duration(milliseconds: 300));
    super.initState();
  }

  var searchText = ''.obs;

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
        inAsyncCall: isLoading,
        opacity: 0.5,
        child: SafeArea(
          child: Scaffold(
            // appBar: AppBar(
            //   backgroundColor: Colors.white,
            //   elevation: 0,
            //   centerTitle: true,
            //   title: Text(
            //     'Add Hash Tags',
            //     style: TextStyle(
            //         fontSize: 16,
            //         color: Colors.black,
            //         fontFamily: AppFonts.segoeui),
            //   ),
            //   leading: IconButton(
            //       onPressed: () {
            //         Get.back();
            //       },
            //       icon: Icon(CupertinoIcons.back, color: Colors.black)),
            // ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 2.w),
              child: Column(
                children: [
                  Container(
                    height: height * 0.070,
                    child: TextFormField(
                      onChanged: (value) {
                        searchText.value = value;
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          isDense: true,
                          fillColor: Colors.green.withAlpha(30),
                          hintText: 'Search',
                          hintStyle: TextStyle(
                              fontSize: 13, fontFamily: AppFonts.segoeui),
                          labelStyle: TextStyle(
                              fontSize: 13,
                              color: primaryColor,
                              fontFamily: AppFonts.segoeui)),
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      itemBuilder: (c, i) {
                        if (searchText.value.isEmpty) {
                          return InkWell(
                            onTap: () {
                              if (!_selectedHashTags
                                  .contains(mRooyaHashTagList[i])) {
                                _selectedHashTags.add(mRooyaHashTagList[i]);
                              } else {
                                _selectedHashTags.remove(mRooyaHashTagList[i]);
                              }
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 7),
                              child: Row(
                                children: [
                                  Text(mRooyaHashTagList[i].hashtag!),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        _selectedHashTags
                                                .contains(mRooyaHashTagList[i])
                                            ? Container(
                                                child: Icon(
                                                  Icons.check,
                                                  size: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: primaryColor),
                                                padding: EdgeInsets.all(3),
                                              )
                                            : SizedBox()
                                      ],
                                      mainAxisAlignment: MainAxisAlignment.end,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        } else {
                          if (mRooyaHashTagList[i]
                              .hashtag!
                              .toString()
                              .contains(searchText.value)) {
                            return InkWell(
                              onTap: () {
                                if (!_selectedHashTags
                                    .contains(mRooyaHashTagList[i])) {
                                  _selectedHashTags.add(mRooyaHashTagList[i]);
                                } else {
                                  _selectedHashTags
                                      .remove(mRooyaHashTagList[i]);
                                }
                                setState(() {});
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  children: [
                                    Text(mRooyaHashTagList[i].hashtag!),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          _selectedHashTags.contains(
                                                  mRooyaHashTagList[i])
                                              ? Container(
                                                  child: Icon(
                                                    Icons.check,
                                                    size: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: primaryColor),
                                                  padding: EdgeInsets.all(3),
                                                )
                                              : SizedBox()
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return SizedBox();
                          }
                        }
                      },
                      itemCount: mRooyaHashTagList.length,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      widget.onAddHashTag!(_selectedHashTags);
                      Get.back();
                    },
                    child: Container(
                      width: 50.0.w,
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(25)),
                      child: Center(
                          child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future<List<HashTagModel>> getHashtags(String query) async {
    return mRooyaHashTagList
        .where((hastag) =>
            hastag.hashtag!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> getHashTags() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    final response = await http.get(
        Uri.parse('${baseUrl}getRooyaPostHashTag${code}'),
        headers: {"Content-Type": "application/json", "Authorization": token!});

    setState(() {
      isLoading = false;
    });

    print(response.request);
    print(response.statusCode);
    print(response.body);
    log(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] == 'success') {
        setState(() {
          mRooyaHashTagList = List<HashTagModel>.from(
              data['data'].map((model) => HashTagModel.fromJson(model)));
        });
      } else {
        setState(() {});
      }
    }
  }
}
