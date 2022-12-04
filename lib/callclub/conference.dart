import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

class VideoConferencePage extends StatelessWidget {
  final String conferenceID;
  final String username;
  final avataruser;
  final nombranche;
  VideoConferencePage({
    Key? key,
    required this.conferenceID,
    required this.username,
    required this.avataruser,
    required this.nombranche,
  }) : super(key: key);
  final userid = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltVideoConference(
        appID: 689689888,
        appSign:
            "96c72d9809ceef948bdbf9dfd46fad337080617afbff0184838a7a1f7a6f99c3",
        userID:
            userid, // userID should only contain numbers, English characters and  '_'
        userName: username,
        conferenceID: conferenceID,
        config: ZegoUIKitPrebuiltVideoConferenceConfig(
          bottomMenuBarConfig: ZegoBottomMenuBarConfig(
              hideAutomatically: false, hideByClick: true),
          topMenuBarConfig: ZegoTopMenuBarConfig(
            title: nombranche,
          ),
          memberListConfig: ZegoMemberListConfig(),
          avatarBuilder: (context, size, user, extraInfo) {
            return CircleAvatar(
              radius: 50,
              backgroundImage: CachedNetworkImageProvider(avataruser),
            );
          },
        ),
      ),
    );
  }
}
