import 'package:get/get.dart';
import 'package:rooya_app/ApiUtils/AuthUtils.dart';
import 'package:rooya_app/dashboard/Home/Models/RooyaPostModel.dart';

class OpenSinglePostController extends GetxController {
  var listofpost = <RooyaPostModel>[].obs;

  getSinglePost({String? postId}) async {
    var data = await AuthUtils.getgetRooyaPostBySingle(postId: postId);
  }
}
