import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smatch/callclub/constants/colors.dart';
import 'package:smatch/callclub/utils/api.dart';
import 'package:smatch/callclub/utils/spacer.dart';
import 'package:smatch/callclub/utils/toast.dart';
import 'package:smatch/callclub/widgets/common/app_bar/recording_indicator.dart';
import 'package:videosdk/videosdk.dart';

class MeetingAppBar extends StatefulWidget {
  String token;
  Room meeting;
  String recordingState;
  bool isFullScreen;
  MeetingAppBar(
      {Key? key,
      required this.meeting,
      required this.token,
      required this.isFullScreen,
      required this.recordingState})
      : super(key: key);

  @override
  State<MeetingAppBar> createState() => MeetingAppBarState();
}

class MeetingAppBarState extends State<MeetingAppBar> {
  Duration? elapsedTime;
  Timer? sessionTimer;

  List<MediaDeviceInfo> cameras = [];

  @override
  void initState() {
    startTimer();
    // Holds available cameras info
    cameras = widget.meeting.getCameras();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        crossFadeState: !widget.isFullScreen
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        secondChild: const SizedBox.shrink(),
        firstChild: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
          child: Row(
            children: [
              if (widget.recordingState == "STARTING" ||
                  widget.recordingState == "STARTED")
                RecordingIndicator(recordingState: widget.recordingState),
              if (widget.recordingState == "STARTING" ||
                  widget.recordingState == "STARTED")
                const HorizontalSpacer(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.meeting.id,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        GestureDetector(
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                            child: Icon(
                              Icons.copy,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: widget.meeting.id));
                            showSnackBarMessage(
                                message: "L'ID de réunion a été copié.",
                                context: context);
                          },
                        ),
                      ],
                    ),
                    // VerticalSpacer(),
                    Text(
                      elapsedTime == null
                          ? "00:00:00"
                          : elapsedTime.toString().split(".").first,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    )
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.cameraswitch_rounded, size: 30),
                onPressed: () {
                  MediaDeviceInfo newCam = cameras.firstWhere((camera) =>
                      camera.deviceId != widget.meeting.selectedCamId);
                  widget.meeting.changeCam(newCam.deviceId);
                },
              ),
            ],
          ),
        ));
  }

  Future<void> startTimer() async {
    dynamic session = await fetchSession(widget.token, widget.meeting.id);
    DateTime sessionStartTime = DateTime.parse(session['start']);
    final difference = DateTime.now().difference(sessionStartTime);

    setState(() {
      elapsedTime = difference;
      sessionTimer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(() {
            elapsedTime = Duration(
                seconds: elapsedTime != null ? elapsedTime!.inSeconds + 1 : 0);
          });
        },
      );
    });
    // log("session start time" + session.data[0].start.toString());
  }

  @override
  void dispose() {
    if (sessionTimer != null) {
      sessionTimer!.cancel();
    }
    super.dispose();
  }
}
