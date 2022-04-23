import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rooya_app/ChatModule/ApiConfig/SizeConfiq.dart';
import 'package:rooya_app/story/create_story.dart';

class GallaryViewCustom extends StatefulWidget {
  final List<Map>? listofSelectedFile;
  final List<AssetEntity>? assets;
  final List<AssetPathEntity>? allAssetsPath;
  const GallaryViewCustom(
      {Key? key, this.assets, this.listofSelectedFile, this.allAssetsPath})
      : super(key: key);

  @override
  _GallaryViewCustomState createState() => _GallaryViewCustomState();
}

class _GallaryViewCustomState extends State<GallaryViewCustom> {
  var selectedImage = [];
  var listofURL = [];

  @override
  void initState() {
    for (var i in widget.listofSelectedFile!) {
      if (i.containsKey('image')) {
        selectedImage.add(File(i['image']).path);
        listofURL.add(File(i['image']).path);
      } else {
        selectedImage.add(File(i['video']).path);
        listofURL.add(File(i['video']).path);
      }
    }
    print('selectedImage = $selectedImage');
    Future.delayed(Duration(seconds: 0), () {
      getabsolutePathOfMedia(widget.assets!);
    });
    super.initState();
  }

  var listofFiles = <File>[];
  var assetType = [];
  getabsolutePathOfMedia(List<AssetEntity> assets) async {
    listofFiles = <File>[];
    assetType = [];
    for (var i in assets) {
      File? file = await i.file;
      if (i.type == AssetType.image) {
        assetType.add('image');
      } else {
        assetType.add('video');
      }
      listofFiles.add(file!);
      setState(() {});
    }
  }

  String mediaName = 'All Photos';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 13),
                  ),
                  onTap: () {
                    Navigator.of(context).pop([]);
                  },
                ),
                DropdownButton<String>(
                  items: widget.allAssetsPath!.map((AssetPathEntity value) {
                    return DropdownMenuItem<String>(
                      value: value.name,
                      child: Text(
                        value.name,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    );
                  }).toList(),
                  hint: Text(
                    '$mediaName' == 'Recents' ? 'All Photos' : '$mediaName',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  underline: SizedBox(),
                  onChanged: (v) async {
                    mediaName = v!;
                    setState(() {});
                    int index = widget.allAssetsPath!
                        .indexWhere((element) => element.name == v);
                    var result = await widget.allAssetsPath![index]
                        .getAssetListPaged(page: 0, size: 500);
                    await getabsolutePathOfMedia(result);
                    setState(() {});
                  },
                ),
                selectedImage.isEmpty
                    ? SizedBox(
                        width: 40,
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.of(context).pop(listofURL);
                        },
                        child: Text(
                          'Add',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3),
                itemCount: assetType.length,
                itemBuilder: (BuildContext ctx, i) {
                  if (assetType[i] == 'image') {
                    return InkWell(
                      onTap: () {
                        if (!selectedImage.contains(listofFiles[i].path)) {
                          selectedImage.add(listofFiles[i].path);
                          listofURL.add(listofFiles[i].path.toString());
                        } else {
                          selectedImage.remove(listofFiles[i].path);
                          listofURL.remove(listofFiles[i].path.toString());
                        }
                        setState(() {});
                        print('selectedImage = $selectedImage');
                      },
                      child: Stack(
                        children: [
                          Container(
                            height: double.infinity,
                            width: double.infinity,
                            child: Image.file(
                              listofFiles[i],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Visibility(
                            visible: selectedImage.contains(listofFiles[i].path)
                                ? true
                                : false,
                            child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5)),
                              child: Center(
                                child: Icon(
                                  Icons.check_circle,
                                  size: 30,
                                  color: Color(0xffC4F7E2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    if (assetType[i] == 'video') {
                      return InkWell(
                        onTap: () {
                          if (selectedImage.isEmpty) {
                            listofURL.add(listofFiles[i].path.toString());
                            Navigator.of(context).pop(listofURL);
                          }
                        },
                        child: Container(
                          child: Stack(
                            children: [
                              Container(
                                height: double.infinity,
                                width: double.infinity,
                                child: Thumbnails(
                                  thumb: listofFiles[i].path,
                                ),
                              ),
                              Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              selectedImage.isEmpty
                                  ? SizedBox()
                                  : Container(
                                      height: double.infinity,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.5)),
                                    ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return SizedBox();
                    }
                  }
                }),
          ),
        ],
      ),
    );
  }
}
