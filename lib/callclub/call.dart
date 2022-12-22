import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';

class Call extends StatefulWidget {
  Call(
      {Key? key,
      required this.username,
      required this.idlive,
      required this.isHost})
      : super(key: key);
  String username;
  String idlive;
  bool isHost;
  @override
  _CallState createState() => _CallState();
}

class _CallState extends State<Call> {
  final userid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltLiveAudioRoom(
        appID: 689689888,
        appSign:
            "96c72d9809ceef948bdbf9dfd46fad337080617afbff0184838a7a1f7a6f99c3",
        userID:
            userid, // userID should only contain numbers, English characters and  '_'
        userName: widget.username,
        roomID: widget.idlive,
        config: widget.isHost
            ? ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
            : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience(),
      ),
    );
  }
}
