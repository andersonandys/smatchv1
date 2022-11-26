import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';

class Call extends StatefulWidget {
  const Call({Key? key}) : super(key: key);

  @override
  _CallState createState() => _CallState();
}

class _CallState extends State<Call> {
  final userid = FirebaseAuth.instance.currentUser!.uid;
  bool isHost = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltLiveAudioRoom(
        appID: 689689888,
        appSign:
            "96c72d9809ceef948bdbf9dfd46fad337080617afbff0184838a7a1f7a6f99c3",
        userID:
            userid, // userID should only contain numbers, English characters and  '_'
        userName: 'user_name',
        liveID: 'live_id',
        config: isHost
            ? ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
            : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience(),
      ),
    );
  }
}
