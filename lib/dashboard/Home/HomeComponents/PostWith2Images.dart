import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooya_app/ApiUtils/baseUrl.dart';
import 'package:rooya_app/dashboard/Home/Models/RooyaPostModel.dart';
import 'package:rooya_app/utils/ShimmerEffect.dart';
import 'package:rooya_app/utils/SizedConfig.dart';
import 'package:sizer/sizer.dart';

import '../../../view_pic.dart';

class PostWith2Images extends StatefulWidget {
  final RooyaPostModel? rooyaPostModel;

  const PostWith2Images({Key? key, this.rooyaPostModel}) : super(key: key);

  @override
  _PostWith2ImagesState createState() => _PostWith2ImagesState();
}

class _PostWith2ImagesState extends State<PostWith2Images> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: widget.rooyaPostModel!.attachment![0].type == 'image'
                    ? InkWell(onTap: (){
                  Get.to(ViewPic(
                    attachment: widget.rooyaPostModel!.attachment!,
                    position: 0,
                  ));
                },
                      child: CachedNetworkImage(
                          imageUrl:
                              "$baseImageUrl${widget.rooyaPostModel!.attachment![0].attachment}",
                          height: height * 0.3,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => ShimerEffect(
                            child: Container(
                              height: height * 0.3,
                              child: Image.asset(
                                'assets/images/home_banner.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                              height: height * 0.3,
                              child: Center(child: Icon(Icons.image))),
                        ),
                    )
                    : Container(
                        height: height * 0.3,
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
                child: widget.rooyaPostModel!.attachment![1].type == 'image'
                    ? InkWell(onTap:(){
                  Get.to(ViewPic(
                    attachment: widget.rooyaPostModel!.attachment!,
                    position: 1,
                  ));
                },
                      child: CachedNetworkImage(
                          imageUrl:
                              "$baseImageUrl${widget.rooyaPostModel!.attachment![1].attachment}",
                          height: height * 0.3,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => ShimerEffect(
                            child: Container(
                              height: 40.0.w,
                              child: Image.asset(
                                'assets/images/home_banner.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                              height: height * 0.3,
                              child: Center(child: Icon(Icons.image))),
                        ),
                    )
                    : Container(
                        height: height * 0.3,
                        decoration: BoxDecoration(color: Colors.black),
                        child: Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ))
          ],
        )
      ],
    );
  }
}
