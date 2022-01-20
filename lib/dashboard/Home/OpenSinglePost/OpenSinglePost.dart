import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooya_app/dashboard/Home/OpenSinglePost/OpenSinglePostController.dart';

class OpenSinglePost extends StatefulWidget {
  final String? postId;

  const OpenSinglePost({Key? key, this.postId}) : super(key: key);

  @override
  _OpenSinglePostState createState() => _OpenSinglePostState();
}

class _OpenSinglePostState extends State<OpenSinglePost> {
  var controller = Get.put(OpenSinglePostController());

  @override
  void initState() {
    controller.getSinglePost(postId: widget.postId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
