import 'package:get/get.dart';
import 'package:rooya_app/ApiUtils/AuthUtils.dart';
import 'package:rooya_app/dashboard/Home/Models/RooyaPostModel.dart';

class UserTagSearchController extends GetxController {
  var listofpost = <RooyaPostModel>[].obs;
  var loadPost=false.obs;
  getExplorePosts({String? tag}) async {
    List data = await AuthUtils.getRooyaPostByHashTagApi(tag: tag);
    listofpost.value = data.map((e) => RooyaPostModel.fromJson(e)).toList();
    listofpost.removeWhere((element) => element.attachment!.isEmpty);
    loadPost.value=true;
  }
}