import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:rooya_app/utils/colors.dart';
import "package:velocity_x/velocity_x.dart";

import '../controllers/sound_list_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/global_keys.dart';
import '../helpers/helper.dart';
import '../models/sound_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/sound_repository.dart' as soundRepo;
import '../repositories/user_repository.dart';
import '../repositories/video_repository.dart' as videoRepo;
import '../widgets/MarqueWidget.dart';

class SoundList extends StatefulWidget {
  SoundList();

  @override
  _SoundListState createState() => _SoundListState();
}

class _SoundListState extends StateMVC<SoundList> {
  SoundListController _con = SoundListController();

  _SoundListState() : super(SoundListController()) {
    _con = SoundListController();
  }

  @override
  void initState() {
    _con.assetsAudioPlayer.playlistFinished.listen((data) {
      print("finished : $data");
    });
    _con.assetsAudioPlayer.playlistAudioFinished.listen((data) {
      print("playlistAudioFinished : $data");
    });
    _con.assetsAudioPlayer.current.listen((data) {
      print("current : $data");
    });
    _con.getSounds();
    super.initState();
  }

  @override
  void dispose() {
    _con.assetsAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: Color(0xff2d3d44),
          statusBarIconBrightness: Brightness.light),
    );
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () async {
                videoRepo.isOnRecordingPage.value = true;
                videoRepo.isOnRecordingPage.notifyListeners();
                Navigator.pushReplacementNamed(context, '/video-recorder');
              }),
          iconTheme: IconThemeData(
            size: 16,
            color: Colors.white, //change your color here
          ),
          title: Text(
            'Sound',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          backgroundColor: Colors.black,
          centerTitle: true,
        ),
        body: Container(
          color: settingRepo.setting.value.bgColor,
          child: DefaultTabController(
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  color: Color(0xff4A4545).withOpacity(0.5),
                  child: TabBar(
                    onTap: (index) {
                      if (index == 1) {
                        _con.getFavSounds();
                      } else {
                        _con.getSounds();
                      }
                    },
                    indicatorColor: settingRepo.setting.value.dividerColor,
                    labelColor: settingRepo.setting.value.textColor,
                    unselectedLabelColor:
                        settingRepo.setting.value.textColor!.withOpacity(0.3),
                    indicatorWeight: 1,
                    tabs: [
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Explore",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'RockWellStd',
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Favorites",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'RockWellStd',
                                  color: settingRepo.setting.value.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: _con.showLoader,
                  builder: (context, bool loader, _) {
                    return SingleChildScrollView(
                      child: Container(
                        color: settingRepo.setting.value.bgColor,
                        height: MediaQuery.of(context).size.height - 145,
                        child: TabBarView(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  height: 45,
                                  child: TextField(
                                    controller: _con.textController1,
                                    style: TextStyle(
                                      color:
                                          settingRepo.setting.value.textColor,
                                      fontSize: 16.0,
                                    ),
                                    obscureText: false,
                                    keyboardType: TextInputType.text,
                                    onChanged: (String val) {
                                      // _con.searchKeyword1 = val;
                                      if (val.length > 2) {
                                        Timer(Duration(milliseconds: 1000), () {
                                          _con.getSounds(val);
                                        });
                                      }
                                      if (val.length == 0) {
                                        print("length 0");
                                        Timer(Duration(milliseconds: 1000), () {
                                          _con.getSounds();
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      errorStyle: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        wordSpacing: 2.0,
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: settingRepo
                                              .setting.value.buttonColor!,
                                          width: 0.3,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: settingRepo
                                              .setting.value.buttonColor!,
                                          width: 0.3,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: settingRepo
                                              .setting.value.buttonColor!,
                                          width: 0.3,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                      hintText: "Search",
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300,
                                      ),
                                      suffixIcon: IconButton(
                                        padding: EdgeInsets.only(bottom: 12),
                                        onPressed: () {
                                          _con.textController1.clear();
                                          _con.searchKeyword = "";
                                        },
                                        icon: Icon(
                                          Icons.clear,
                                          color: _con.searchKeyword != ""
                                              ? settingRepo
                                                  .setting.value.iconColor
                                              : Colors.transparent,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ).pSymmetric(h: 10),
                                ValueListenableBuilder(
                                    valueListenable: soundRepo.soundsData,
                                    builder:
                                        (context, SoundModelList _sounds, _) {
                                      if ((_sounds.soundData != null)) {
                                        if (_sounds.soundData!.length > 0) {
                                          return Column(
                                            children: <Widget>[
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height -
                                                    200,
                                                child: ModalProgressHUD(
                                                  progressIndicator:
                                                      _con.showLoaderSpinner(),
                                                  inAsyncCall: loader,
                                                  opacity: 1.0,
                                                  color: settingRepo
                                                      .setting.value.bgColor!
                                                      .withOpacity(0.5),
                                                  child: GroupedListView<
                                                      SoundData, String>(
                                                    shrinkWrap: true,
                                                    controller:
                                                        _con.scrollController,
                                                    elements:
                                                        _sounds.soundData!,
                                                    groupBy: (element) =>
                                                        element.link! +
                                                        "_" +
                                                        element.link!,
                                                    order:
                                                        GroupedListOrder.DESC,
                                                    groupSeparatorBuilder:
                                                        (String value) {
                                                      var full =
                                                          value.split("_");
                                                      return Container(
                                                        color: settingRepo
                                                            .setting
                                                            .value
                                                            .bgColor,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: <
                                                                Widget>[],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    itemBuilder: (c, e) {
                                                      return PlayerWidget(
                                                        sound: e,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        } else {
                                          if (!loader) {
                                            return Center(
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height -
                                                    185,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      "No Sounds found",
                                                      style: TextStyle(
                                                          color: settingRepo
                                                              .setting
                                                              .value
                                                              .textColor,
                                                          fontSize: 15),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Container(
                                              color: settingRepo
                                                  .setting.value.bgColor,
                                              child: Center(
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        new AlwaysStoppedAnimation<
                                                                Color>(
                                                            settingRepo
                                                                .setting
                                                                .value
                                                                .iconColor!),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      } else {
                                        if (!loader) {
                                          return Center(
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height -
                                                  185,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    "No Sounds found",
                                                    style: TextStyle(
                                                        color: settingRepo
                                                            .setting
                                                            .value
                                                            .textColor,
                                                        fontSize: 15),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        } else {
                                          return Container(
                                            color: settingRepo
                                                .setting.value.bgColor,
                                            child: Center(
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      new AlwaysStoppedAnimation<
                                                          Color>(
                                                    settingRepo.setting.value
                                                        .iconColor!,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                      // : Helper.showLoaderSpinner(Colors.white);
                                    }),
                              ],
                            ),
                            ModalProgressHUD(
                              progressIndicator: _con.showLoaderSpinner(),
                              inAsyncCall: loader,
                              opacity: 1.0,
                              color: settingRepo.setting.value.bgColor!,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: TextField(
                                      controller: _con.textController2,
                                      style: TextStyle(
                                        color:
                                            settingRepo.setting.value.textColor,
                                        fontSize: 16.0,
                                      ),
                                      obscureText: false,
                                      keyboardType: TextInputType.text,
                                      onChanged: (String val) {
                                        _con.searchKeyword2 = val;
                                        if (val.length > 2) {
                                          Timer(Duration(seconds: 1), () {
                                            _con.getFavSounds(val);
                                          });
                                        }
                                        if (val.length == 0) {
                                          Timer(Duration(milliseconds: 1000),
                                              () {
                                            _con.getFavSounds();
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        errorStyle: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          wordSpacing: 2.0,
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: settingRepo
                                                .setting.value.buttonColor!,
                                            width: 0.3,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: settingRepo
                                                .setting.value.buttonColor!,
                                            width: 0.3,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: settingRepo
                                                .setting.value.buttonColor!,
                                            width: 0.3,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.all(10),
                                        hintText: "Search favorite sound",
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300,
                                        ),
                                        suffixIcon: IconButton(
                                          padding: EdgeInsets.only(bottom: 12),
                                          onPressed: () {
                                            _con.textController2.clear();
                                            _con.searchKeyword2 = "";
                                            _con.getFavSounds();
                                          },
                                          icon: Icon(
                                            Icons.clear,
                                            color: _con.searchKeyword2 != ""
                                                ? settingRepo
                                                    .setting.value.iconColor
                                                : Colors.transparent,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ).pSymmetric(h: 10),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 48.0),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                                  .8 -
                                              90,
                                      child: ValueListenableBuilder(
                                          valueListenable:
                                              soundRepo.favSoundsData,
                                          builder: (context,
                                              SoundModelList _favSounds, _) {
                                            return (_favSounds.soundData !=
                                                        null &&
                                                    _favSounds
                                                            .soundData!.length >
                                                        0)
                                                ? ListView.builder(
                                                    shrinkWrap: true,
                                                    controller:
                                                        _con.scrollController1,
                                                    itemCount: _favSounds
                                                        .soundData!.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return PlayerWidget(
                                                        sound: _favSounds
                                                            .soundData![index],
                                                      );
                                                    })
                                                : (!loader)
                                                    ? Center(
                                                        child: Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height -
                                                              360,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Text(
                                                                "No favourite sounds found",
                                                                style: TextStyle(
                                                                    color: settingRepo
                                                                        .setting
                                                                        .value
                                                                        .textColor,
                                                                    fontSize:
                                                                        15),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        color: settingRepo
                                                            .setting
                                                            .value
                                                            .bgColor,
                                                        child: Center(
                                                          child: Container(
                                                            width: 20,
                                                            height: 20,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              valueColor: new AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  settingRepo
                                                                      .setting
                                                                      .value
                                                                      .iconColor!),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                          }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlayerWidget extends StatefulWidget {
  final SoundData sound;

  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();

  const PlayerWidget({
    required this.sound,
  });
}

class _PlayerWidgetState extends StateMVC<PlayerWidget> {
  int userId = 0;
  int videoId = 0;
  bool showLoader = true;
  AssetsAudioPlayer assetsAudioPlayer = new AssetsAudioPlayer();
  SoundListController _con = SoundListController();
  int isFav = 0;
  bool showLoading = false;

  _PlayerWidgetState() : super(SoundListController()) {
    _con = SoundListController();
  }

  @override
  void initState() {
    print(222222);
    print(currentUser.value.token);
    //setState(() {
    isFav = 0;
    //});
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    assetsAudioPlayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: assetsAudioPlayer.isPlaying,
      initialData: false,
      builder: (context, snapshotPlaying) {
        final bool isPlaying = snapshotPlaying.data as bool;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color:
                      settingRepo.setting.value.dividerColor!.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.5),
              child: Container(
                padding: EdgeInsets.all(4),
                width: config.App(context).appWidth(100),
                decoration: BoxDecoration(
                  color: settingRepo.setting.value.bgColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        AssetsAudioPlayer.allPlayers().forEach((key, value) {
                          value.pause();
                        });
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor:Colors.white,
                                insetPadding: EdgeInsets.zero,
                                content: Container(
                                  height: 50,
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      Helper.showLoaderSpinner(appThemes),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Downloading.. Please wait...",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: appThemes),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                        print("this.widget.sound");
                        print(this.widget.sound.preview);
                        _con.selectSound(this.widget.sound);
                        videoRepo.isOnRecordingPage.value = true;
                        videoRepo.isOnRecordingPage.notifyListeners();
                        DefaultCacheManager()
                            .getSingleFile(widget.sound.preview!)
                            .then((file) {
                          Navigator.pushReplacementNamed(
                            context,
                            '/video-recorder',
                          );
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            image: new DecorationImage(
                              image: CachedNetworkImageProvider(
                                widget.sound.artist!.pictureSmall!,
                              ),
                              fit: BoxFit.cover,
                            ),
                            // gradient: Gradients.blush,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          AssetsAudioPlayer.allPlayers().forEach((key, value) {
                            value.pause();
                          });
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor:Colors.white,
                                  insetPadding: EdgeInsets.zero,
                                  content: Container(
                                    height: 50,
                                    color:Colors.white,
                                    child: Row(
                                      children: [
                                        Helper.showLoaderSpinner(appThemes),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Downloading.. Please wait...",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color:appThemes),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                          print("this.widget.sound");
                          print(this.widget.sound.preview);
                          _con.selectSound(this.widget.sound);
                          videoRepo.isOnRecordingPage.value = true;
                          videoRepo.isOnRecordingPage.notifyListeners();
                          DefaultCacheManager()
                              .getSingleFile(widget.sound.preview!)
                              .then((file) {
                            Navigator.pushReplacementNamed(
                              context,
                              '/video-recorder',
                            );
                          });
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              children: [
                                Container(
                                  width: 150,
                                  child: MarqueeWidget(
                                    child: Text(
                                      this.widget.sound.artist!.name!,
                                      style: TextStyle(
                                        color:
                                            settingRepo.setting.value.textColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 150,
                                  child: MarqueeWidget(
                                    child: Text(
                                      widget.sound.album!.title!,
                                      style: TextStyle(
                                        color: Color(0xff707070),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    widget.sound.duration.toString() + " sec",
                                    style: TextStyle(
                                      color:
                                          settingRepo.setting.value.textColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      if (assetsAudioPlayer.current.first ==
                                          null) {
                                        AssetsAudioPlayer.allPlayers()
                                            .forEach((key, value) {
                                          value.pause();
                                        });
                                        setState(() {
                                          showLoading = true;
                                        });
                                        await DefaultCacheManager()
                                            .getSingleFile(
                                                widget.sound.preview!)
                                            .then((file) {
                                          AssetsAudioPlayer.allPlayers()
                                              .forEach((key, value) {
                                            value.pause();
                                          });
                                          assetsAudioPlayer.open(
                                            Audio.file(file.path),
                                            autoStart: true,
                                          );
                                          setState(() {
                                            showLoading = false;
                                          });
                                        });
                                      } else {
                                        AssetsAudioPlayer.allPlayers()
                                            .forEach((key, value) {
                                          value.pause();
                                        });
                                        assetsAudioPlayer.playOrPause();
                                      }
                                    },
                                    child: Center(
                                        child: showLoading
                                            ? Container(
                                                width: 40,
                                                height: 40,
                                                child: Helper.showLoaderSpinner(
                                                    Colors.white))
                                            : IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: Icon(
                                                  isPlaying
                                                      ? Icons
                                                          .pause_circle_outline_rounded
                                                      : Icons
                                                          .play_circle_outline,
                                                  size: 40,
                                                  color: settingRepo
                                                      .setting.value.iconColor,
                                                ),
                                                onPressed: () async {
                                                  AssetsAudioPlayer.allPlayers()
                                                      .forEach((key, value) {
                                                    value.pause();
                                                  });
                                                  if (!isPlaying) {
                                                    final List<
                                                            StreamSubscription>
                                                        _subscriptions = [];
                                                    _subscriptions.add(
                                                        assetsAudioPlayer
                                                            .isBuffering
                                                            .listen(
                                                                (isBuffering) {
                                                      if (isBuffering) {
                                                        setState(() {
                                                          showLoading = true;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          showLoading = false;
                                                        });
                                                      }
                                                    }));
                                                    assetsAudioPlayer.open(
                                                      Audio.network(widget
                                                          .sound.preview!),
                                                      autoStart: true,
                                                    );
                                                  } else {
                                                    assetsAudioPlayer.pause();
                                                  }
                                                },
                                              )),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                      ),
                    ),
                    // Expanded(
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: <Widget>[
                    //       Expanded(
                    //         child: InkWell(
                    //           onTap: () async {
                    //             AssetsAudioPlayer.allPlayers()
                    //                 .forEach((key, value) {
                    //               value.pause();
                    //             });
                    //             showDialog(
                    //                 barrierDismissible: false,
                    //                 context: context,
                    //                 builder: (BuildContext context) {
                    //                   return AlertDialog(
                    //                     backgroundColor: settingRepo
                    //                         .setting.value.accentColor,
                    //                     insetPadding: EdgeInsets.zero,
                    //                     content: Container(
                    //                       height: 50,
                    //                       color: settingRepo
                    //                           .setting.value.accentColor,
                    //                       child: Row(
                    //                         children: [
                    //                           Helper.showLoaderSpinner(
                    //                               settingRepo.setting.value
                    //                                   .iconColor!),
                    //                           SizedBox(
                    //                             width: 10,
                    //                           ),
                    //                           Text(
                    //                             "Downloading.. Please wait...",
                    //                             style: TextStyle(
                    //                                 fontSize: 15,
                    //                                 color: settingRepo.setting
                    //                                     .value.textColor),
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     ),
                    //                   );
                    //                 });
                    //             print("this.widget.sound");
                    //             print(this.widget.sound.preview);
                    //             _con.selectSound(this.widget.sound);
                    //             videoRepo.isOnRecordingPage.value = true;
                    //             videoRepo.isOnRecordingPage.notifyListeners();
                    //             DefaultCacheManager()
                    //                 .getSingleFile(widget.sound.preview!)
                    //                 .then((file) {
                    //               Navigator.pushReplacementNamed(
                    //                 context,
                    //                 '/video-recorder',
                    //               );
                    //             });
                    //           },
                    //           child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               Container(
                    //                 width: config.App(context).appWidth(100),
                    //                 child: MarqueeWidget(
                    //                   child: Text(
                    //                     this.widget.sound.artist!.name!,
                    //                     style: TextStyle(
                    //                       color: settingRepo
                    //                           .setting.value.textColor,
                    //                       fontSize: 14,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //               Row(
                    //                 mainAxisAlignment:
                    //                     MainAxisAlignment.spaceBetween,
                    //                 children: [
                    //                   Container(
                    //                     width: 100,
                    //                     child: MarqueeWidget(
                    //                       child: Text(
                    //                         widget.sound.album!.title!,
                    //                         style: TextStyle(
                    //                           color: Color(0xff707070),
                    //                           fontSize: 12,
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   Container(
                    //                     //width: config.App(context).appWidth(40),
                    //                     child: Row(
                    //                       mainAxisAlignment:
                    //                           MainAxisAlignment.start,
                    //                       children: [
                    //                         Text(
                    //                           widget.sound.duration.toString() +
                    //                               " sec",
                    //                           style: TextStyle(
                    //                             color: settingRepo
                    //                                 .setting.value.textColor,
                    //                             fontSize: 11,
                    //                           ),
                    //                         ),
                    //                         GestureDetector(
                    //                           onTap: () async {
                    //                             if (assetsAudioPlayer
                    //                                     .current.first ==
                    //                                 null) {
                    //                               AssetsAudioPlayer.allPlayers()
                    //                                   .forEach((key, value) {
                    //                                 value.pause();
                    //                               });
                    //                               setState(() {
                    //                                 showLoading = true;
                    //                               });
                    //                               await DefaultCacheManager()
                    //                                   .getSingleFile(
                    //                                       widget.sound.preview!)
                    //                                   .then((file) {
                    //                                 AssetsAudioPlayer
                    //                                         .allPlayers()
                    //                                     .forEach((key, value) {
                    //                                   value.pause();
                    //                                 });
                    //                                 assetsAudioPlayer.open(
                    //                                   Audio.file(file.path),
                    //                                   autoStart: true,
                    //                                 );
                    //                                 setState(() {
                    //                                   showLoading = false;
                    //                                 });
                    //                               });
                    //                             } else {
                    //                               AssetsAudioPlayer.allPlayers()
                    //                                   .forEach((key, value) {
                    //                                 value.pause();
                    //                               });
                    //                               assetsAudioPlayer
                    //                                   .playOrPause();
                    //                             }
                    //                           },
                    //                           child: Center(
                    //                             child: showLoading
                    //                                 ? Container(
                    //                                     width: 40,
                    //                                     height: 40,
                    //                                     child: Helper
                    //                                         .showLoaderSpinner(
                    //                                             Colors.white))
                    //                                 : IconButton(
                    //                                     padding:
                    //                                         EdgeInsets.zero,
                    //                                     icon: Icon(
                    //                                       isPlaying
                    //                                           ? Icons
                    //                                               .pause_circle_outline_rounded
                    //                                           : Icons
                    //                                               .play_circle_outline,
                    //                                       size: 40,
                    //                                       color: settingRepo
                    //                                           .setting
                    //                                           .value
                    //                                           .iconColor,
                    //                                     ),
                    //                                     onPressed: () async {
                    //                                       AssetsAudioPlayer
                    //                                               .allPlayers()
                    //                                           .forEach(
                    //                                               (key, value) {
                    //                                         value.pause();
                    //                                       });
                    //                                       if (!isPlaying) {
                    //                                         final List<
                    //                                                 StreamSubscription>
                    //                                             _subscriptions =
                    //                                             [];
                    //                                         _subscriptions.add(
                    //                                             assetsAudioPlayer
                    //                                                 .isBuffering
                    //                                                 .listen(
                    //                                                     (isBuffering) {
                    //                                           if (isBuffering) {
                    //                                             setState(() {
                    //                                               showLoading =
                    //                                                   true;
                    //                                             });
                    //                                           } else {
                    //                                             setState(() {
                    //                                               showLoading =
                    //                                                   false;
                    //                                             });
                    //                                           }
                    //                                         }));
                    //                                         assetsAudioPlayer
                    //                                             .open(
                    //                                           Audio.network(
                    //                                               widget.sound
                    //                                                   .preview!),
                    //                                           autoStart: true,
                    //                                         );
                    //                                       } else {
                    //                                         assetsAudioPlayer
                    //                                             .pause();
                    //                                       }
                    //                                     },
                    //                                   ),
                    //                           ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

//  }
//}
class SoundCatList extends StatefulWidget {
  final int catId;
  final String catName;

  SoundCatList(this.catId, this.catName);

  @override
  _SoundCatListState createState() => _SoundCatListState();
}

class _SoundCatListState extends StateMVC<SoundCatList> {
  Map<String, dynamic> sounds = {};

  List soundsList = [];
  var _textController = TextEditingController();
  SoundListController _con = SoundListController();

  _SoundCatListState() : super(SoundListController()) {
    _con = SoundListController();
  }

  static String searchKeyword = '';

  int page = 1;
  bool moreResults = true;

  final AssetsAudioPlayer _assetsAudioPlayer =
      AssetsAudioPlayer.withId("4234234323asdsad");

  @override
  void initState() {
    _assetsAudioPlayer.playlistFinished.listen((data) {
      print("finished : $data");
    });
    _assetsAudioPlayer.playlistAudioFinished.listen((data) {
      print("playlistAudioFinished : $data");
    });
    _assetsAudioPlayer.current.listen((data) {
      print("current : $data");
    });

    print("widget.catId");
    print(widget.catId);
    _con.getCatSounds(widget.catId);
    super.initState();
  }

  @override
  void dispose() {
    _assetsAudioPlayer.dispose();
    super.dispose();
  }

  /*SoundModel find(List<SoundData> source, String fromPath) {
    return source.firstWhere((element) => element.audio.path == fromPath);
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: settingRepo.setting.value.bgColor,
      key: _con.soundScaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: settingRepo.setting.value.iconColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.catName,
          style: TextStyle(color: settingRepo.setting.value.textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Container(
          color: settingRepo.setting.value.bgColor,
          child: ValueListenableBuilder(
            valueListenable: _con.showLoader,
            builder: (context, bool loader, _) {
              return ModalProgressHUD(
                progressIndicator: _con.showLoaderSpinner(),
                inAsyncCall: loader,
                opacity: 0.5,
                color: settingRepo.setting.value.bgColor!,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 2,
                      child: Container(
                        color: settingRepo.setting.value.bgColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                        // width: MediaQuery.of(context).size.width - 50,
                        child: TextField(
                          controller: _textController,
                          style: TextStyle(
                            color: settingRepo.setting.value.textColor,
                            fontSize: 16.0,
                          ),
                          obscureText: false,
                          keyboardType: TextInputType.text,
                          onChanged: (String val) {
                            _con.catSearchKeyword = val;
                            if (val.length > 2) {
                              Timer(Duration(seconds: 1), () {
                                _con.getCatSounds(widget.catId, val);
                              });
                            }
                            if (val.length == 0) {
                              Timer(Duration(milliseconds: 1000), () {
                                _con.getCatSounds(widget.catId);
                              });
                            }
                          },
                          decoration: InputDecoration(
                            errorStyle: TextStyle(
                              color: Colors.red,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              wordSpacing: 2.0,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: settingRepo.setting.value.textColor!,
                                width: 0.3,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: settingRepo.setting.value.textColor!,
                                width: 0.3,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: settingRepo.setting.value.textColor!,
                                width: 0.3,
                              ),
                            ),
                            contentPadding: EdgeInsets.all(10),
                            hintText: "Search",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                            ),
                            suffixIcon: IconButton(
                              padding: EdgeInsets.only(bottom: 12),
                              onPressed: () {
                                _textController.clear();
                                _con.getCatSounds(widget.catId);
                              },
                              icon: Icon(
                                Icons.clear,
                                color: _con.searchKeyword2 != ""
                                    ? settingRepo.setting.value.iconColor
                                    : Colors.transparent,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: soundRepo.catSoundsData,
                      builder: (context, SoundModelList _catSounds, _) {
                        return ValueListenableBuilder(
                          valueListenable: _con.showLoader,
                          builder: (context, bool loader, _) {
                            return (_catSounds.soundData != null &&
                                    _catSounds.soundData!.length > 0)
                                ? SingleChildScrollView(
                                    child: Container(
                                      color: settingRepo.setting.value.bgColor,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        controller: _con.catScrollController,
                                        itemCount: _catSounds.soundData!.length,
                                        itemBuilder: (context, index) {
                                          return PlayerWidget(
                                            sound: _catSounds.soundData![index],
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                : (!loader)
                                    ? Center(
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              360,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                "No favourite sounds found",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 15,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color:
                                            settingRepo.setting.value.bgColor,
                                        child: Center(
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  new AlwaysStoppedAnimation<
                                                      Color>(Colors.white),
                                            ),
                                          ),
                                        ),
                                      );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          )),
    );
  }
}
