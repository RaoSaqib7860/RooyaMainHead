import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rooya_app/utils/AppFonts.dart';
import 'package:rooya_app/utils/colors.dart';

class CreateRooyaPostController extends GetxController {

  var assetsEntity = <AssetEntity>[].obs;
  var  listOfAllAssets=<AssetPathEntity>[];
  getFilesPath()async{
    await PhotoManager.requestPermissionExtend();
    List<AssetPathEntity> list = await PhotoManager.getAssetPathList();
    listOfAllAssets=list;
    print('${list.length}');
    log('AssetPathEntity = ${list}');
    AssetPathEntity data = list[0];
    assetsEntity.value = await data.getAssetListPaged(page: 0, size: 500);
    // AssetEntity entity = assetsEntity[0];
    // File? file = await entity.file;
    // print('file ppp = ${file!.path}');
    // print('file ppp = ${entity.type}');
  }
//hello there
  final ImagePicker _picker = ImagePicker();
  onImageButtonPressed(ImageSource source, String tag) async {
    try {
      PickedFile? pickedFile;
      if (tag == 'image') {
        pickedFile = await _picker.getImage(
          source: source,
        );
      } else {
        pickedFile = await _picker.getVideo(
          source: source,
        );
      }
      print('pickedFile = ${pickedFile!.path}');
      if (!listOfSelectedfiles.contains(pickedFile.path) &&
          listOfSelectedfiles.length < 8) {
        if (pickedFile.path.contains('.mp4')) {
          listOfSelectedfiles.add({'video': '${pickedFile.path}'});
        } else {
          listOfSelectedfiles.add({'image': '${pickedFile.path}'});
        }
      }
    } catch (e) {}
  }
  List listofAlreadySelectedFiles=[];
  gallarypress() async {
    try {
      final FilePickerResult? pickedFile;
      pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true,
      );
      print('pickedFile = ${pickedFile!.paths}');
      pickedFile.paths.forEach((element) {
        if (!listOfSelectedfiles.contains(element) &&
            listOfSelectedfiles.length < 8) {
          if (element!.contains('.mp4')) {
            listOfSelectedfiles.add({'video': '$element'});
          } else {
            listOfSelectedfiles.add({'image': '$element'});
          }
        }
      });
    } catch (e) {}
  }

  selectLocation(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            elevation: 0,
            backgroundColor: Colors.black.withOpacity(0.5),
            insetPadding: EdgeInsets.symmetric(horizontal: width / 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            //this right here
            child: Container(
              height: height / 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      onImageButtonPressed(ImageSource.camera, 'image');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: appThemes,
                          borderRadius: BorderRadius.circular(5)),
                      padding: EdgeInsets.all(7),
                      child: Text(
                        'Image',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: AppFonts.segoeui,
                            fontSize: 13),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      onImageButtonPressed(ImageSource.camera, 'video');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: appThemes,
                          borderRadius: BorderRadius.circular(5)),
                      padding: EdgeInsets.all(7),
                      child: Text(
                        'Video',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: AppFonts.segoeui,
                            fontSize: 13),
                      ),
                    ),
                  )
                ],
              ),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        });
  }

  var listOfSelectedfiles = <Map>[].obs;
  var listOfVidoeFilea = [].obs;
  var listOfImageFilea = [].obs;
}
