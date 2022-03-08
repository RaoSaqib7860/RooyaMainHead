import 'package:get/get.dart';
import 'package:rooya_app/ChatModule/ApiConfig/ApiUtils.dart';
import 'package:rooya_app/ChatModule/SearchUser/SearchUserModel.dart';

class SearchUserController extends GetxController {
  var searchUserModel = SearchUserModel().obs;

  getFriendList()async{
    searchUserModel.value=await ApiUtils.getfriendList(limit: 50,start: 0);
  }
}
