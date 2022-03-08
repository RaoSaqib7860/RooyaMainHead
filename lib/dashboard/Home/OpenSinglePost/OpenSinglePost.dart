import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooya_app/ApiUtils/AuthUtils.dart';
import 'package:rooya_app/dashboard/Home/HomeComponents/user_post.dart';
import 'package:rooya_app/dashboard/Home/Models/RooyaPostModel.dart';
import 'package:rooya_app/dashboard/Home/OpenSinglePost/OpenSinglePostController.dart';
import 'package:rooya_app/utils/SizedConfig.dart';

class OpenSinglePost extends StatefulWidget {
  final String? postId;
  final RooyaPostModel? model;
  final bool? containData;

  const OpenSinglePost(
      {Key? key, this.postId, this.model, this.containData = false})
      : super(key: key);

  @override
  _OpenSinglePostState createState() => _OpenSinglePostState();
}

class _OpenSinglePostState extends State<OpenSinglePost> {
  var controller = Get.put(OpenSinglePostController());
  var modelData = RooyaPostModel();
  @override
  void initState() {
    if (!widget.containData!) {
      print('post is =${widget.postId}');
      controller.getSinglePost(postId: widget.postId);
    }else{
      modelData=widget.model!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        elevation: 0,
      ),
      body: !widget.containData!
          ? Obx(
              () => Container(
                height: height,
                width: width,
                padding: EdgeInsets.symmetric(vertical: height * 0.010),
                child: !controller.loadData.value
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : UserPost(
                        rooyaPostModel: controller.postmodel,
                        onPostLike: () {
                          setState(() {
                            controller.postmodel.islike = true;
                            controller.postmodel.likecount =
                                controller.postmodel.likecount! + 1;
                          });
                        },
                        onPostUnLike: () {
                          setState(() {
                            controller.postmodel.islike = false;
                            controller.postmodel.likecount =
                                controller.postmodel.likecount! - 1;
                          });
                        },
                        comment: () async {
                          await controller.getSinglePost(postId: widget.postId);
                          setState(() {});
                        },
                      ),
              ),
            )
          : UserPost(
              rooyaPostModel: modelData,
              onPostLike: () {
                setState(() {
                  modelData.islike = true;
                  modelData.likecount =
                      modelData.likecount! + 1;
                });
              },
              onPostUnLike: () {
                setState(() {
                  modelData.islike = false;
                  modelData.likecount =
                      modelData.likecount! - 1;
                });
              },
              comment: () async {
                await controller.getSinglePost(postId: widget.postId);
                setState(() {});
              },
            ),
    );
  }
}
