import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smatch/callclub/constants/colors.dart';
import 'package:smatch/callclub/utils/spacer.dart';
import 'package:videosdk/videosdk.dart';

class ParticipantView extends StatelessWidget {
  Stream? stream;
  bool isMicOn = false;
  Color? avatarBackground;
  String participantName = "A";
  bool isLocalScreenShare;
  bool isScreenShare;
  double avatarTextSize;
  Function() onStopScreeenSharePressed;
  ParticipantView(
      {Key? key,
      required this.stream,
      required this.isMicOn,
      required this.avatarBackground,
      required this.participantName,
      this.isLocalScreenShare = false,
      this.avatarTextSize = 50,
      required this.isScreenShare,
      required this.onStopScreeenSharePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        stream != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: RTCVideoView(
                  stream?.renderer as RTCVideoRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              )
            : Center(
                child: !isLocalScreenShare
                    ? Container(
                        padding: EdgeInsets.all(avatarTextSize / 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: avatarBackground,
                        ),
                        child: Text(
                          participantName.characters.first.toUpperCase(),
                          style: TextStyle(fontSize: avatarTextSize),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Icon(Icons.screen_share_sharp,
                                color: Colors.white, size: 30),
                            const VerticalSpacer(20),
                            const Text(
                              "Vous présentez à tout le monde",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const VerticalSpacer(20),
                            MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 30),
                                color: purple,
                                child: const Text("Arrêter de présenter",
                                    style: TextStyle(fontSize: 16)),
                                onPressed: onStopScreeenSharePressed)
                          ])),
        if (!isMicOn)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: black700,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.mic_off,
                  size: avatarTextSize / 2,
                )),
          ),
        if (isScreenShare)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: black700,
              ),
              child: Text(isScreenShare
                  ? "${isLocalScreenShare ? "Vous" : participantName} présente"
                  : participantName),
            ),
          ),
      ],
    );
  }
}
