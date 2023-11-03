// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerOptimized extends StatefulWidget {
  const YoutubePlayerOptimized({
    required this.videoId,
    this.changeSizeVideoToSmall,
    this.changeSizeVideoToFullScreen,
    super.key,
  });

  final String videoId;
  final Function()? changeSizeVideoToSmall;
  final Function()? changeSizeVideoToFullScreen;

  @override
  State<YoutubePlayerOptimized> createState() => _YoutubePlayerOptimizedState();
}

class _YoutubePlayerOptimizedState extends State<YoutubePlayerOptimized> {
  late YoutubePlayerController controllerVideo;
  bool isUpdate = false;
  bool isLoading = true;
  bool isShowInterface = false;
  bool isPaused = false;
  Duration pausedMoment = const Duration();
  Duration oldMoment = const Duration();
  bool isDragging = false;

  @override
  void initState() {
    controllerVideo = YoutubePlayerController(
      initialVideoId: widget.videoId.toString(),
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        hideControls: true,
        showLiveFullscreenButton: false,
        loop: true,
      ),
    );
    controllerVideo.addListener(update);
    super.initState();
  }

  @override
  void dispose() {
    controllerVideo.removeListener(update);
    controllerVideo.dispose();
    super.dispose();
  }

  Future<void> update() async {
    if (controllerVideo.value.position != oldMoment) {
      if (isLoading) {
        setState(() {
          isLoading = false;
        });
      }
      if (!isPaused) {
        oldMoment = controllerVideo.value.position;
      }
    }
    await Future.delayed(const Duration(milliseconds: 5));
  }

  Future<void> showInterface() async {
    if (!isShowInterface) {
      setState(() {
        isShowInterface = true;
      });
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        isShowInterface = false;
      });
    }
  }

  Future<void> changeVideoPosition({required int seconds}) async {
    controllerVideo.removeListener(update);
    setState(() {
      isUpdate = true;
      isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 10));
    controllerVideo = YoutubePlayerController(
      initialVideoId: widget.videoId.toString(),
      flags: YoutubePlayerFlags(
        autoPlay: true,
        hideControls: true,
        showLiveFullscreenButton: false,
        startAt: seconds,
      ),
    );
    setState(() {
      isUpdate = false;
    });
    oldMoment = const Duration();
    controllerVideo.addListener(update);
  }

  Future<void> playPauseVideo() async{
    setState(() {
      isPaused = !isPaused;
    });
    if (isPaused) {
      pausedMoment = controllerVideo.value.position;
      controllerVideo.value = controllerVideo.value.copyWith(
        playerState: PlayerState.paused,
        isPlaying: false,
      );
    } else {
      controllerVideo.value = controllerVideo.value.copyWith(
        playerState: PlayerState.playing,
        isPlaying: true,
      );
      changeVideoPosition(seconds: pausedMoment.inSeconds);
    }
  }

  Future<void> changeSizeVideo() async {
    controllerVideo.toggleFullScreenMode();
    if (controllerVideo.value.isFullScreen && widget.changeSizeVideoToSmall != null) {
      widget.changeSizeVideoToSmall!();
    } else {
      setState(changeStatusBarToLight);
    }
    if (widget.changeSizeVideoToFullScreen != null) {
      widget.changeSizeVideoToFullScreen!();
    }
  }

  // ignore: type_annotate_public_apis
  changeStatusBarToLight() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(changeStatusBarToLight);
        return true;
      },
      child: (isUpdate) ? const SizedBox.shrink() : Center(
      child: SizedBox(
        width: double.infinity,
        height: controllerVideo.value.isFullScreen ? double.infinity : MediaQuery.of(context).size.width / 1280 * 720,
        child: Stack(
          children: [
            Center(
              child: YoutubePlayerBuilder(
                player: YoutubePlayer(controller: controllerVideo),
                builder: (context, player) {
                  return player;
                },
              ),
            ),
            if (!isLoading)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: showInterface,
                      onDoubleTap: () {
                        changeVideoPosition(seconds: controllerVideo.value.position.inSeconds - 5);
                      },
                      child: const SizedBox(height: double.infinity),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: showInterface,
                      onDoubleTap: () {
                        changeVideoPosition(seconds: controllerVideo.value.position.inSeconds + 5);
                      },
                      child: const SizedBox(height: double.infinity),
                    ),
                  ),
                ],
              ),
            if (isShowInterface && !isLoading)
              Center(
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: playPauseVideo,
                  child: Icon(
                    isPaused ? Icons.play_arrow : Icons.pause,
                    color: const Color(0xFFFFFFFF),
                    size: 40,
                  ),
                ),
              ),
            if (isShowInterface && !isLoading)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4, right: 4),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: changeSizeVideo,
                    child: Icon(
                      (controllerVideo.value.isFullScreen) ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: const Color(0xFFFFFFFF),
                      size: 30,
                    ),
                  ),
                ),
              ),
            if (isShowInterface && !isLoading && !isPaused)
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Row(
                    children: [
                      ProgressBar(
                        isExpanded: true,
                        colors: const ProgressBarColors(),
                        controller: controllerVideo,
                        changeVideoPosition: () {
                          changeVideoPosition(seconds: controllerVideo.value.position.inSeconds);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFFFFF)),
              ),
          ],
        ),
      ),
    ),
    );
  }
}
