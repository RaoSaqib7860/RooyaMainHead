import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooya_app/ApiUtils/baseUrl.dart';
import 'package:rooya_app/dashboard/Home/Models/RooyaPostModel.dart';
import 'package:rooya_app/utils/ShimmerEffect.dart';
import 'package:rooya_app/utils/SizedConfig.dart';
import 'package:sizer/sizer.dart';

import '../../../view_pic.dart';

class PostWith4Images extends StatefulWidget {
  final RooyaPostModel? rooyaPostModel;

  const PostWith4Images({Key? key, this.rooyaPostModel}) : super(key: key);

  @override
  _PostWith4ImagesState createState() => _PostWith4ImagesState();
}

class _PostWith4ImagesState extends State<PostWith4Images> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
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
                      child: CachedNetworkImage(
                        imageUrl:
                            "$baseImageUrl${widget.rooyaPostModel!.attachment![0].attachment}",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: height * 0.150,
                        placeholder: (context, url) => ShimerEffect(
                          child: Container(
                            height: height * 0.150,
                            child: Image.asset(
                              'assets/images/home_banner.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                            height: height * 0.150,
                            child: Center(child: Icon(Icons.image))),
                      ),
                    )
                  : Container(
                      height: height * 0.150,
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
                          fit: BoxFit.cover,
                          height: height * 0.150,
                          placeholder: (context, url) => Container(
                              height: height * 0.150,
                              child: ShimerEffect(
                                child: Image.asset(
                                  'assets/images/home_banner.png',
                                  fit: BoxFit.cover,
                                ),
                              )),
                          errorWidget: (context, url, error) => Container(
                              height: height * 0.150,
                              child: Center(child: Icon(Icons.image))),
                        ),
                      )
                    : Container(
                        height: height * 0.150,
                        decoration: BoxDecoration(color: Colors.black),
                        child: Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      )),
          ],
        ),
        SizedBox(
          height: 1,
        ),
        Row(
          children: [
            Expanded(
                child: widget.rooyaPostModel!.attachment![2].type == 'image'
                    ? InkWell(
                        onTap: () {
                          Get.to(ViewPic(
                            attachment: widget.rooyaPostModel!.attachment!,
                            position: 2,
                          ));
                        },
                        child: CachedNetworkImage(
                          imageUrl:
                              "$baseImageUrl${widget.rooyaPostModel!.attachment![2].attachment}",
                          fit: BoxFit.cover,
                          height: height * 0.150,
                          placeholder: (context, url) => Container(
                              height: height * 0.150,
                              child: ShimerEffect(
                                child: Image.asset(
                                  'assets/images/home_banner.png',
                                  fit: BoxFit.cover,
                                ),
                              )),
                          errorWidget: (context, url, error) => Container(
                              height: height * 0.150,
                              child: Center(child: Icon(Icons.image))),
                        ),
                      )
                    : Container(
                        height: height * 0.150,
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
                child: widget.rooyaPostModel!.attachment![3].type == 'image'
                    ? InkWell(
                        onTap: () {
                          Get.to(ViewPic(
                            attachment: widget.rooyaPostModel!.attachment!,
                            position: 3,
                          ));
                        },
                        child: CachedNetworkImage(
                          imageUrl:
                              "$baseImageUrl${widget.rooyaPostModel!.attachment![3].attachment}",
                          fit: BoxFit.cover,
                          height: height * 0.150,
                          placeholder: (context, url) => Container(
                              height: height * 0.150,
                              child: ShimerEffect(
                                child: Image.asset(
                                  'assets/images/home_banner.png',
                                  fit: BoxFit.cover,
                                ),
                              )),
                          errorWidget: (context, url, error) => Container(
                              height: height * 0.150,
                              child: Center(child: Icon(Icons.image))),
                        ),
                      )
                    : Container(
                        height: height * 0.150,
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
        ),
        // Row(
        //   children: [
        //     Expanded(
        //         child: widget.rooyaPostModel!.attachment![1].type == 'image'
        //             ? CachedNetworkImage(
        //               imageUrl:
        //                   "$baseImageUrl${widget.rooyaPostModel!.attachment![1].attachment}",
        //               fit: BoxFit.cover,
        //               height: height * 0.140,
        //               placeholder: (context, url) => Container(
        //                   height: height * 0.140,
        //                   child: ShimerEffect(
        //                     child: Image.asset(
        //                       'assets/images/home_banner.png',
        //                       fit: BoxFit.cover,
        //                     ),
        //                   )),
        //               errorWidget: (context, url, error) => Container(
        //                   height: height * 0.140,
        //                   child: Center(child: Icon(Icons.image))),
        //             )
        //             : Container(
        //                 height: height * 0.140,
        //                 decoration: BoxDecoration(color: Colors.black),
        //                 child: Center(
        //                   child: Icon(
        //                     Icons.play_circle_fill,
        //                     color: Colors.white,
        //                     size: 40,
        //                   ),
        //                 ),
        //               )),
        //     SizedBox(
        //       width: 1,
        //     ),
        //     Expanded(
        //         child: widget.rooyaPostModel!.attachment![2].type == 'image'
        //             ? CachedNetworkImage(
        //               imageUrl:
        //                   "$baseImageUrl${widget.rooyaPostModel!.attachment![2].attachment}",
        //               fit: BoxFit.cover,
        //               height: height * 0.140,
        //               placeholder: (context, url) => Container(
        //                   height: height * 0.140,
        //                   child: ShimerEffect(
        //                     child: Image.asset(
        //                       'assets/images/home_banner.png',
        //                       fit: BoxFit.cover,
        //                     ),
        //                   )),
        //               errorWidget: (context, url, error) => Container(
        //                   height: height * 0.140,
        //                   child: Center(child: Icon(Icons.image))),
        //             )
        //             : Container(
        //                 height: height * 0.140,
        //                 decoration: BoxDecoration(color: Colors.black),
        //                 child: Center(
        //                   child: Icon(
        //                     Icons.play_circle_fill,
        //                     color: Colors.white,
        //                     size: 40,
        //                   ),
        //                 ),
        //               )),
        //     SizedBox(
        //       width: 1,
        //     ),
        //     Expanded(
        //         child: widget.rooyaPostModel!.attachment![3].type == 'image'
        //             ? ClipRRect(
        //           borderRadius: BorderRadius.only(
        //               bottomLeft: Radius.circular(5),
        //               topLeft: Radius.circular(5)),
        //                 child: CachedNetworkImage(
        //                   imageUrl:
        //                       "$baseImageUrl${widget.rooyaPostModel!.attachment![3].attachment}",
        //                   fit: BoxFit.cover,
        //                   height: height * 0.140,
        //                   placeholder: (context, url) => Container(
        //                       height: height * 0.140,
        //                       child: ShimerEffect(
        //                         child: Image.asset(
        //                           'assets/images/home_banner.png',
        //                           fit: BoxFit.cover,
        //                         ),
        //                       )),
        //                   errorWidget: (context, url, error) => Container(
        //                       height: height * 0.140,
        //                       child: Center(child: Icon(Icons.image))),
        //                 ),
        //               )
        //             : Container(
        //                 height: height * 0.140,
        //                 decoration: BoxDecoration(color: Colors.black),
        //                 child: Center(
        //                   child: Icon(
        //                     Icons.play_circle_fill,
        //                     color: Colors.white,
        //                     size: 40,
        //                   ),
        //                 ),
        //               ))
        //   ],
        // )
      ],
    );
  }
}
