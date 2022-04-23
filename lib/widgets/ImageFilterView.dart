import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/filters/filters.dart';
import 'package:photofilters/widgets/photo_filter.dart';
import 'package:rooya_app/utils/SizedConfig.dart';

class ImageFilterView extends StatefulWidget {
  final Widget title;
  final Color appBarColor;
  final List<Filter> filters;
  final imageLib.Image image;
  final Widget loader;
  final BoxFit fit;
  final String filename;
  final bool circleShape;
  final String? imagePath;

  const ImageFilterView({
    Key? key,
    required this.title,
    required this.filters,
    required this.image,
    this.appBarColor = Colors.blue,
    this.loader = const Center(child: CircularProgressIndicator()),
    this.fit = BoxFit.fill,
    required this.filename,
    this.circleShape = false,
    this.imagePath,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _ImageFilterViewState();
}

class _ImageFilterViewState extends State<ImageFilterView> {
  String? filename;
  Map<String, List<int>?> cachedFilters = {};
  Filter? _filter;
  imageLib.Image? image;
  late bool loading;

  TextEditingController controller = TextEditingController();
  bool isLoading = false;

  bool isCropMode = false;

  @override
  void initState() {
    loading = false;
    _filter = widget.filters[0];
    filename = widget.filename;
    image = widget.image;
    super.initState();
  }

  int selected_Icon = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // TextFieldsProfile(
            //   controller: controller,
            //   hint: 'Write your comment'.tr,
            //   uperhint: 'Write your comment'.tr,
            //   width: Get.width,
            // ),
            // SizedBox(
            //   height: Get.height * 0.010,
            // ),
            Expanded(
              child: _buildFilteredImage(
                _filter,
                image,
                filename,
              ),
            ),
            // InkWell(
            //   onTap: () async {
            //     setState(() {
            //       loading = true;
            //     });
            //     File imageFile = await saveFilteredImage();
            //     List listofurl = [];
            //     String value = await createStory(imageFile.path);
            //     listofurl.add(value);
            //     print('listofurl= $listofurl');
            //     await uploadStoryData(
            //         text: controller.text, listOfUrl: listofurl);
            //     setState(() {
            //       isLoading = false;
            //     });
            //     snackBarSuccess('Story post successfully');
            //     Future.delayed(Duration(seconds: 2), () {
            //       Get.offAll(() => BottomSheetCustom());
            //     });
            //   },
            //   child: Container(
            //     padding:
            //         EdgeInsets.symmetric(vertical: 7, horizontal: 40),
            //     decoration: BoxDecoration(
            //         color: appThemes,
            //         borderRadius: BorderRadius.circular(25)),
            //     child: Text(
            //       'POST',
            //       style: TextStyle(
            //           color: Colors.white,
            //           fontFamily: AppFonts.segoeui),
            //     ),
            //   ),
            // ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: height * 0.120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.filters.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _buildFilterThumbnail(widget.filters[index], image,
                            filename, widget.filters[index].name),
                      ],
                    ),
                  ),
                  onTap: () => setState(() {
                    _filter = widget.filters[index];
                  }),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  _buildFilterThumbnail(Filter filter, imageLib.Image? image, String? filename,
      String? filterName) {
    if (cachedFilters[filter.name] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return CircleAvatar(
                radius: 30.0,
                child: Center(
                  child: widget.loader,
                ),
                backgroundColor: Colors.white,
              );
            case ConnectionState.done:
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              cachedFilters[filter.name] = snapshot.data;
              return Container(
                height: height * 0.090,
                width: width * 0.180,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.memory(
                        snapshot.data as dynamic,
                        fit: BoxFit.cover,
                        height: height * 0.090,
                        width: width * 0.180,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: width * 0.180,
                        padding: EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5)),
                        ),
                        child: Text(
                          filterName!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontFamily: 'segoeui'),
                        ),
                      ),
                    )
                  ],
                ),
              );
          }
          // unreachable
        },
      );
    } else {
      return Container(
        height: height * 0.090,
        width: width * 0.180,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.memory(
                cachedFilters[filter.name] as dynamic,
                fit: BoxFit.cover,
                height: height * 0.090,
                width: width * 0.180,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: width * 0.180,
                padding: EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5)),
                ),
                child: Text(
                  filterName!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 8, color: Colors.white, fontFamily: 'segoeui'),
                ),
              ),
            )
          ],
        ),
      );
      // return CircleAvatar(
      //   radius: 30.0,
      //   backgroundImage: MemoryImage(
      //     cachedFilters[filter.name] as dynamic,
      //   ),
      //   backgroundColor: Colors.white,
      // );
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/filtered_${_filter?.name ?? "_"}_$filename');
  }

  Future<File> saveFilteredImage() async {
    var imageFile = await _localFile;
    await imageFile.writeAsBytes(cachedFilters[_filter?.name ?? "_"]!);
    return imageFile;
  }

  Widget _buildFilteredImage(
      Filter? filter, imageLib.Image? image, String? filename) {
    if (cachedFilters[filter?.name ?? "_"] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return widget.loader;
            case ConnectionState.active:
            case ConnectionState.waiting:
              return widget.loader;
            case ConnectionState.done:
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              cachedFilters[filter?.name ?? "_"] = snapshot.data;
              return widget.circleShape
                  ? SizedBox(
                height: MediaQuery.of(context).size.width / 3,
                width: MediaQuery.of(context).size.width / 3,
                child: Center(
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width / 3,
                    backgroundImage: MemoryImage(
                      snapshot.data as dynamic,
                    ),
                  ),
                ),
              )
                  : Image.memory(
                snapshot.data as dynamic,
                fit: BoxFit.cover,
              );
          }
          // unreachable
        },
      );
    } else {
      return widget.circleShape
          ? SizedBox(
        height: MediaQuery.of(context).size.width / 3,
        width: MediaQuery.of(context).size.width / 3,
        child: Center(
          child: CircleAvatar(
            radius: MediaQuery.of(context).size.width / 3,
            backgroundImage: MemoryImage(
              cachedFilters[filter?.name ?? "_"] as dynamic,
            ),
          ),
        ),
      )
          : Image.memory(
        cachedFilters[filter?.name ?? "_"] as dynamic,
        fit: widget.fit,
      );
    }
  }

/////////////

}

