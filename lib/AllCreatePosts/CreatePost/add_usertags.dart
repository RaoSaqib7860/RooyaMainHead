import 'dart:convert';
import 'dart:developer';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:get/get.dart';
import 'package:rooya_app/ChatModule/ApiConfig/SizeConfiq.dart';
import 'package:rooya_app/models/UserTagModel.dart';
import 'package:rooya_app/utils/AppFonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:rooya_app/utils/ProgressHUD.dart';
import 'package:rooya_app/ApiUtils/baseUrl.dart';
import 'package:http/http.dart' as http;
import 'package:rooya_app/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class AddUserTags extends StatefulWidget {
  List<UserTagModel>? selectedUserTags;
  Function? onAddUserTag;

  AddUserTags({Key? key, this.selectedUserTags, this.onAddUserTag})
      : super(key: key);

  @override
  _AddUserTagsState createState() => _AddUserTagsState();
}

class _AddUserTagsState extends State<AddUserTags> {
  List<UserTagModel> _selectedUserTags = [];
  bool isLoading = false;
  List<UserTagModel> mRooyaUserTagList = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    _selectedUserTags.addAll(widget.selectedUserTags!);
    getUsersTags();
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
            //     'Tag Someone',
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
                              color: appThemes,
                              fontFamily: AppFonts.segoeui)),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (c, i) {
                        if (searchText.value.isEmpty) {
                          return InkWell(
                            onTap: () {
                              if(!_selectedUserTags.contains(mRooyaUserTagList[i])){
                                _selectedUserTags.add(mRooyaUserTagList[i]);
                              }else{
                                _selectedUserTags.remove(mRooyaUserTagList[i]);
                              }
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  CircularProfileAvatar(
                                    '$baseImageUrl${mRooyaUserTagList[i].userPicture}',
                                    radius: 15,
                                    borderColor: appThemes,
                                    borderWidth: 1,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(mRooyaUserTagList[i].userName!),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        _selectedUserTags
                                                .contains(mRooyaUserTagList[i])
                                            ? Container(
                                                child: Icon(
                                                  Icons.check,
                                                  size: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: appThemes),
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
                          if (mRooyaUserTagList[i]
                              .userName!
                              .toString()
                              .contains(searchText.value)) {
                            return InkWell(
                              onTap: () {
                                if(!_selectedUserTags.contains(mRooyaUserTagList[i])){
                                  _selectedUserTags.add(mRooyaUserTagList[i]);
                                }else{
                                  _selectedUserTags.remove(mRooyaUserTagList[i]);
                                }
                                setState(() {});
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  children: [
                                    CircularProfileAvatar(
                                      '$baseImageUrl${mRooyaUserTagList[i].userPicture}',
                                      radius: 15,
                                      borderColor: appThemes,
                                      borderWidth: 1,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(mRooyaUserTagList[i].userName!),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          _selectedUserTags.contains(
                                                  mRooyaUserTagList[i])
                                              ? Container(
                                                  child: Icon(
                                                    Icons.check,
                                                    size: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: appThemes),
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
                      itemCount: mRooyaUserTagList.length,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      widget.onAddUserTag!(_selectedUserTags);
                      Get.back();
                    },
                    child: Container(
                      width: 50.0.w,
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                          color: appThemes,
                          borderRadius: BorderRadius.circular(25)),
                      child: Center(
                          child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Future<List<UserTagModel>> getUsertags(String query) async {
    return mRooyaUserTagList
        .where((user) =>
            user.userName!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> getUsersTags() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    final response = await http.get(Uri.parse('${baseUrl}getRooyaUser${code}'),
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
          mRooyaUserTagList = List<UserTagModel>.from(
              data['data'].map((model) => UserTagModel.fromJson(model)));
        });
      } else {
        setState(() {});
      }
    }
  }
}
