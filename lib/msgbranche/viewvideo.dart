import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Viewvideo extends StatefulWidget {
  const Viewvideo({Key? key}) : super(key: key);

  @override
  _ViewvideoState createState() => _ViewvideoState();
}

class _ViewvideoState extends State<Viewvideo> {
  final url = Get.arguments[0]['urlfile'];
  late FlickManager flickManager;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    flickManager =
        FlickManager(videoPlayerController: VideoPlayerController.network(url));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    flickManager.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(20),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withBlue(40),
      ),
      body: SafeArea(
        child: VisibilityDetector(
            key: ObjectKey(flickManager),
            onVisibilityChanged: (visibility) {
              if (visibility.visibleFraction == 0 && mounted) {
                flickManager.flickControlManager?.autoPause();
              } else if (visibility.visibleFraction == 1) {
                flickManager.flickControlManager?.autoResume();
              }
            },
            child: FlickVideoPlayer(
              flickManager: flickManager,
              flickVideoWithControls: const FlickVideoWithControls(
                controls: FlickPortraitControls(),
              ),
              flickVideoWithControlsFullscreen: const FlickVideoWithControls(
                controls: FlickLandscapeControls(),
              ),
            )),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {
      //       _controller.value.isPlaying
      //           ? _controller.pause()
      //           : _controller.play();
      //     });
      //   },
      //   child: Icon(
      //     _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
      //   ),
      // ),
    );
  }
}
