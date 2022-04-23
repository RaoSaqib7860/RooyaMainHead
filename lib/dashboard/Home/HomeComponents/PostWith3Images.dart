import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooya_app/ApiUtils/baseUrl.dart';
import 'package:rooya_app/dashboard/Home/Models/RooyaPostModel.dart';
import 'package:rooya_app/utils/ShimmerEffect.dart';
import 'package:rooya_app/utils/SizedConfig.dart';
import 'package:sizer/sizer.dart';

import '../../../view_pic.dart';

class PostWith3Images extends StatefulWidget {
  final RooyaPostModel? rooyaPostModel;

  const PostWith3Images({Key? key, this.rooyaPostModel}) : super(key: key);

  @override
  _PostWith3ImagesState createState() => _PostWith3ImagesState();
}

class _PostWith3ImagesState extends State<PostWith3Images> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: widget.rooyaPostModel!.attachment![0].type == 'image'
              ? InkWell(
                  onTap: () {
                    Get.to(ViewPic(
                      attachment: widget.rooyaPostModel!.attachment!,
                      position: 0,
                    ));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(7),
                        topLeft: Radius.circular(7)),
                    child: CachedNetworkImage(
                      imageUrl:
                          "$baseImageUrl${widget.rooyaPostModel!.attachment![0].attachment}",
                      width: double.infinity,
                      height: height * 0.230,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => ShimerEffect(
                        child: Container(
                          height: height * 0.230,
                          width: 100.0.w,
                          child: Image.asset(
                            'assets/images/home_banner.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                          height: height * 0.230,
                          width: 100.0.w,
                          child: Center(child: Icon(Icons.image))),
                    ),
                  ),
                )
              : Container(
                  height: height * 0.230,
                  width: 100.0.w,
                  decoration: BoxDecoration(color: Colors.black),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
        ),
        SizedBox(
          width: 1,
        ),
        Expanded(
            child: widget.rooyaPostModel!.attachment![1].type == 'image'
                ? InkWell(
                    onTap: () {
                      Get.to(ViewPic(
                        attachment: widget.rooyaPostModel!.attachment!,
                        position: 1,
                      ));
                    },
                    child: CachedNetworkImage(
                      imageUrl:
                          "$baseImageUrl${widget.rooyaPostModel!.attachment![1].attachment}",
                      height: height * 0.230,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                          height: height * 0.230,
                          child: Center(child: CircularProgressIndicator())),
                      errorWidget: (context, url, error) => Container(
                          height: height * 0.230,
                          child: Center(child: Icon(Icons.error))),
                    ),
                  )
                : Container(
                    height: height * 0.230,
                    decoration: BoxDecoration(color: Colors.black),
                    child: Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  )),
        SizedBox(
          width: 1,
        ),
        Expanded(
            child: widget.rooyaPostModel!.attachment![2].type == 'image'
                ? ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(7),
                        topRight: Radius.circular(7)),
                    child: InkWell(
                      onTap: () {
                        Get.to(ViewPic(
                          attachment: widget.rooyaPostModel!.attachment!,
                          position: 2,
                        ));
                      },
                      child: CachedNetworkImage(
                        imageUrl:
                            "$baseImageUrl${widget.rooyaPostModel!.attachment![2].attachment}",
                        height: height * 0.230,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                            height: height * 0.230,
                            child: Center(child: CircularProgressIndicator())),
                        errorWidget: (context, url, error) => Container(
                            height: height * 0.230,
                            child: Center(child: Icon(Icons.error))),
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(7),
                        topRight: Radius.circular(7)),
                    child: Container(
                      height: height * 0.230,
                      decoration: BoxDecoration(color: Colors.black),
                      child: Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ))
      ],
    );
  }
}
