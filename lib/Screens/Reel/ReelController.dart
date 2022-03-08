import 'package:flutter/cupertino.dart';
import 'package:rooya_app/ApiUtils/AuthUtils.dart';
import 'package:rooya_app/models/ReelModel.dart';
import 'package:get/get.dart';

class ReelController extends ChangeNotifier {
  var listofReels = <ReelModel>[].obs;
  var loadReels = false.obs;

  getReelData() async {
    List list = await AuthUtils.getReelData();
    listofReels.value = list.map((e) => ReelModel.fromJson(e)).toList();
    loadReels.value = true;
  }
}
