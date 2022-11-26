import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class Liveconf extends StatefulWidget {
  const Liveconf({Key? key}) : super(key: key);

  @override
  _LiveconfState createState() => _LiveconfState();
}

class _LiveconfState extends State<Liveconf> {
  final userid = FirebaseAuth.instance.currentUser!.uid;
  bool isHost = true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltLiveStreaming(
        appID: 689689888,
        appSign:
            "96c72d9809ceef948bdbf9dfd46fad337080617afbff0184838a7a1f7a6f99c3",
        userID:
            userid, // userID should only contain numbers, English characters and  '_'
        userName: 'user_name',
        liveID: 'live_id',
        config: isHost
            ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
            : ZegoUIKitPrebuiltLiveStreamingConfig.audience(),
      ),
    );
  }
}
