import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:rooya_app/ApiUtils/baseUrl.dart';
import 'package:rooya_app/ChatModule/responsive/primary_color.dart';
import 'package:rooya_app/ChatModule/text_filed/app_font.dart';
import 'package:rooya_app/utils/ProgressHUD.dart';
import 'package:rooya_app/utils/SizedConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateMyEvet extends StatefulWidget {
  final Function()? onCreateCall;

  const CreateMyEvet({Key? key, this.onCreateCall}) : super(key: key);

  @override
  _CreateMyEvetState createState() => _CreateMyEvetState();
}

class _CreateMyEvetState extends State<CreateMyEvet> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;
  String dropDownValue = 'Public';

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      inAsyncCall: isLoading,
      opacity: 0.4,
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height * 0.030,
              ),
              Text(
                'Create Event',
                style: TextStyle(fontFamily: AppFonts.segoeui),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 20,
                ),
                decoration:
                    BoxDecoration(color: Colors.grey[100]!.withOpacity(0.5)),
                child: TextFormField(
                  controller: titleController,
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.multiline,
                  // expands: true,
                  minLines: 1,
                  maxLines: 1,
                  style: TextStyle(fontSize: 14),
                  decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 12),
                    disabledBorder: InputBorder.none,
                    hintText: 'Event name',
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 15, right: 15),
                  ),
                ),
              ),
              // Container(
              //   margin: EdgeInsets.only(
              //     top: 20,
              //   ),
              //   decoration:
              //       BoxDecoration(color: Colors.grey[100]!.withOpacity(0.5)),
              //   child: TextFormField(
              //     controller: descriptionController,
              //     cursorColor: Colors.black,
              //     keyboardType: TextInputType.multiline,
              //     // expands: true,
              //     minLines: 5,
              //     maxLines: 5,
              //     style: TextStyle(fontSize: 14),
              //     decoration: new InputDecoration(
              //       border: InputBorder.none,
              //       focusedBorder: InputBorder.none,
              //       enabledBorder: InputBorder.none,
              //       errorBorder: InputBorder.none,
              //       hintStyle: TextStyle(color: Colors.black38, fontSize: 12),
              //       disabledBorder: InputBorder.none,
              //       hintText: 'Event Description',
              //       contentPadding: EdgeInsets.only(
              //           left: 15, bottom: 11, top: 15, right: 15),
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: height * 0.050,
                    width: width * 0.3,
                    padding: EdgeInsets.symmetric(horizontal: width * 0.025),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey[100]!.withOpacity(0.5),
                    ),
                    child: DropdownButton<String>(
                      items: <String>['Public', 'My Followers', 'Only Me']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                                fontSize: 12, fontFamily: AppFonts.segoeui),
                          ),
                        );
                      }).toList(),
                      underline: SizedBox(),
                      isExpanded: true,
                      hint: Text(
                        '$dropDownValue',
                        style: TextStyle(
                            fontSize: 12, fontFamily: AppFonts.segoeui),
                      ),
                      onChanged: (value) {
                        dropDownValue = value!;
                        setState(() {});
                      },
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (titleController.text.isNotEmpty) {
                        setState(() {
                          isLoading = true;
                        });
                        await CreateMyEvent();
                        setState(() {
                          isLoading = true;
                        });
                        widget.onCreateCall!.call();
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      height: height * 0.050,
                      width: width * 0.270,
                      child: Center(
                        child: Text(
                          'Create Event',
                          style: TextStyle(
                              fontFamily: AppFonts.segoeui,
                              fontSize: 12,
                              color: Colors.white),
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.030,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> CreateMyEvent() async {
    var dt = DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');
    String? userId = await prefs.getString('user_id');
    final response = await http.post(
        Uri.parse('${baseUrl}postRooyaMyEvent$code'),
        headers: {"Content-Type": "application/json", "Authorization": token!},
        body: jsonEncode({
          "event_privacy": dropDownValue == 'public'
              ? "public"
              : dropDownValue == 'My Followers'
                  ? 'friends'
                  : "me",
          "event_maker": userId,
          "event_title": titleController.text,
          "event_location": '',
          "event_hashtag": [],
          "event_tag_peoples": [],
          "event_description": descriptionController.text,
          "event_date_on": '${dt.year}-${dt.month}-${dt.day}'
        }));
    print(' ${response.body}');
  }
}
