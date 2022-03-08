import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooya_app/ApiUtils/baseUrl.dart';
import 'package:rooya_app/Screens/VideoPlayerService/BetterPlayerCustom.dart';
import 'package:rooya_app/dashboard/Home/Models/RooyaPostModel.dart';
import 'package:rooya_app/utils/ShimmerEffect.dart';
import 'package:rooya_app/utils/SizedConfig.dart';
import 'package:rooya_app/view_pic.dart';
import 'package:sizer/sizer.dart';

class PostWith1Image extends StatefulWidget {
  final RooyaPostModel? rooyaPostModel;

  const PostWith1Image({Key? key, this.rooyaPostModel}) : super(key: key);

  @override
  _PostWith1ImageState createState() => _PostWith1ImageState();
}

class _PostWith1ImageState extends State<PostWith1Image> {
  @override
  Widget build(BuildContext context) {
    return widget.rooyaPostModel!.attachment![0].type == 'image'
        ? InkWell(
            onTap: () {
              Get.to(ViewPic(
                attachment: widget.rooyaPostModel!.attachment!,
                position: 0,
              ));
            },
            child: CachedNetworkImage(
              imageUrl:
                  "$baseImageUrl${widget.rooyaPostModel!.attachment![0].attachment}",
              width: double.infinity,
              fit: BoxFit.cover,
              height: height * 0.3,
              placeholder: (context, url) => ShimerEffect(
                child: Container(
                  height: height * 0.3,
                  width: 100.0.w,
                  child: Image.asset(
                    'assets/images/home_banner.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                  height: height * 0.3,
                  width: 100.0.w,
                  child: Center(child: Icon(Icons.image))),
            ),
          )
        : Container(
            height: height * 0.3,
            width: 100.0.w,
            child:
            CustomVideoPlayer(
              url:
                  "$baseImageUrl${widget.rooyaPostModel!.attachment![0].attachment}",
            ),
          );
  }
}
