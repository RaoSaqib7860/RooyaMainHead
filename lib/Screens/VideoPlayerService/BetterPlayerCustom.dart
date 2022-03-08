import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String? url;

  const CustomVideoPlayer({Key? key, this.url}) : super(key: key);

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  BetterPlayerController? betterPlayerController;

  @override
  void initState() {
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      "${widget.url}",
    );
    betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          looping: true,
          fit: BoxFit.contain,
          aspectRatio: 0.1,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
          ],
          deviceOrientationsOnFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeRight,
            DeviceOrientation.landscapeLeft,
          ],
          autoDetectFullscreenAspectRatio: true,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            showControlsOnInitialize: false,
          ),
        ),
        betterPlayerDataSource: betterPlayerDataSource);
    betterPlayerController!.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.openFullscreen) {
        betterPlayerController!.setControlsEnabled(true);
        betterPlayerController!.setVolume(1);
        setState(() {});
      }
      if (event.betterPlayerEventType == BetterPlayerEventType.hideFullscreen) {
        betterPlayerController!.setControlsEnabled(false);
        betterPlayerController!.setVolume(0);
        setState(() {});
      }
      if (!betterPlayerController!.isFullScreen &&
          betterPlayerController!.controlsEnabled) {
        betterPlayerController!.setVolume(0);
        betterPlayerController!.setControlsEnabled(false);
        setState(() {});
      }
      setState(() {});
    });
    betterPlayerController!.setVolume(0);
    super.initState();
  }

  @override
  void dispose() {
    betterPlayerController!.dispose();
    super.dispose();
  }

  var key = UniqueKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            child: VisibilityDetector(
              key: key,
              onVisibilityChanged: (visibilityInfo) {
                var visiblePercentage = visibilityInfo.visibleFraction * 100;
                if (visiblePercentage <= 50.0 &&
                    betterPlayerController!.isPlaying()! &&
                    !betterPlayerController!.isFullScreen) {
                  betterPlayerController!.pause();
                  setState(() {});
                }
              },
              child: Container(
                height: double.infinity,
                width: double.infinity,
                child: IgnorePointer(
                  ignoring: true,
                  child: BetterPlayer(
                    controller: betterPlayerController!,
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            child: Container(
              height: double.infinity,
              width: double.infinity,
            ),
            onTap: () {
              print('Click on Video');
              if (!betterPlayerController!.isFullScreen) {
                betterPlayerController!.toggleFullScreen();
                betterPlayerController!.setVolume(1);
              }
            },
          )
        ],
      ),
    );
  }
}
