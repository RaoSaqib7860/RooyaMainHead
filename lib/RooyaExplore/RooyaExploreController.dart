import 'package:get/get.dart';
import 'package:rooya_app/ApiUtils/AuthUtils.dart';
import 'package:rooya_app/dashboard/Home/Models/RooyaPostModel.dart';

class RooyaExploreController extends GetxController {
  var listofpost = <RooyaPostModel>[].obs;

  getExplorePosts() async {
    List data = await AuthUtils.getRooyaPostByLimitExploreApi();
    listofpost.value = data.map((e) => RooyaPostModel.fromJson(e)).toList();
    listofpost.removeWhere((element) => element.attachment!.isEmpty);
    print('Completed');
  }
}
