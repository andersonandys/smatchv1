import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  VideoWidget({Key? key, required this.videoUrl}) : super(key: key);
  final String videoUrl;
  @override
  _VideoWidgetState createState() => _VideoWidgetState(this.videoUrl);
}

class _VideoWidgetState extends State<VideoWidget> {
  final String videoUrl;
  late VideoPlayerController _controller;

  _VideoWidgetState(this.videoUrl);

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(videoUrl)
      ..initialize().then((_) {
        _controller.setLooping(true); // à ajouter pour la lecture en boucle
        _controller.play(); // pour lancer la lecture vidéo
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayer(_controller);
  }
}
