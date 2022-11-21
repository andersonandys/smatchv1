// import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smatch/club/ui/liveroom/LiveRoomMember.dart';
import 'package:smatch/club/utils/DynamicColor.dart';
import 'package:smatch/club/utils/MemojiColors.dart';

// import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

class LiveRoom extends StatefulWidget {
  LiveRoom({Key? key, required this.nomsalon}) : super(key: key);
  String nomsalon;
  @override
  _LiveRoomState createState() => _LiveRoomState();
}

class _LiveRoomState extends State<LiveRoom> {
  // late RtcEngine _engine;
  Map<int, Userparticipe> _userMap = new Map<int, Userparticipe>();
  bool _muted = false;
  int? _localUid;

  @override
  void dispose() {
    //clear users
    _userMap.clear();
    // destroy sdk
    // _engine.leaveChannel();
    // _engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    // initialize();
  }

  // Future<void> initialize() async {
  //   if (APP_ID.isEmpty) {
  //     print("'APP_ID missing, please provide your APP_ID in settings.dart");
  //     return;
  //   }
  //   await _initAgoraRtcEngine();
  //   _addAgoraEventHandlers();
  //   await _engine.joinChannel(null, widget.nomsalon, null, 0);
  // }

  // /// Create agora sdk instance and initialize
  // Future<void> _initAgoraRtcEngine() async {
  //   _engine = await RtcEngine.create(APP_ID);
  //   await _engine.enableVideo();
  //   await _engine.setChannelProfile(ChannelProfile.Communication);
  //   // Enables the audioVolumeIndication
  //   await _engine.enableAudioVolumeIndication(250, 3, true);
  // }

  // void _addAgoraEventHandlers() {
  //   _engine.setEventHandler(
  //     RtcEngineEventHandler(error: (code) {
  //       print("error occurred $code");
  //     }, joinChannelSuccess: (channel, uid, elapsed) {
  //       setState(() {
  //         _localUid = uid;
  //         _userMap.addAll({uid: Userparticipe(uid, false)});
  //       });
  //     }, leaveChannel: (stats) {
  //       setState(() {
  //         _userMap.clear();
  //       });
  //     }, userJoined: (uid, elapsed) {
  //       setState(() {
  //         _userMap.addAll({uid: Userparticipe(uid, false)});
  //       });
  //     }, userOffline: (uid, elapsed) {
  //       setState(() {
  //         _userMap.remove(uid);
  //       });
  //     },

  //         /// Detecting active speaker by using audioVolumeIndication callback
  //         audioVolumeIndication: (volumeInfo, v) {
  //       volumeInfo.forEach((speaker) {
  //         //detecting speaking person whose volume more than 5
  //         if (speaker.volume > 5) {
  //           try {
  //             _userMap.forEach((key, value) {
  //               //Highlighting local user
  //               //In this callback, the local user is represented by an uid of 0.
  //               if ((_localUid?.compareTo(key) == 0) && (speaker.uid == 0)) {
  //                 setState(() {
  //                   _userMap.update(key, (value) => Userparticipe(key, true));
  //                 });
  //               }

  //               //Highlighting remote user
  //               else if (key.compareTo(speaker.uid) == 0) {
  //                 setState(() {
  //                   _userMap.update(key, (value) => Userparticipe(key, true));
  //                 });
  //               } else {
  //                 setState(() {
  //                   _userMap.update(key, (value) => Userparticipe(key, false));
  //                 });
  //               }
  //             });
  //           } catch (error) {
  //             print('Error:${error.toString()}');
  //           }
  //         }
  //       });
  //     }),
  //   );
  // }

  final members = [
    const LiveRoomMember(
      name: "Sarah",
      isModerator: true,
      isMuted: false,
      imagePath: "assets/images/3.png",
      color: MemojiColors.black,
    ),
    const LiveRoomMember(
      name: "Daniel",
      isModerator: true,
      imagePath: "assets/images/2.png",
      color: MemojiColors.amber,
    ),
    const LiveRoomMember(
      name: "Samantha",
      isModerator: true,
      imagePath: "assets/images/4.png",
      color: MemojiColors.white,
    ),
    const LiveRoomMember(
      name: "Aishat",
      isModerator: true,
      imagePath: "assets/images/6.png",
      color: MemojiColors.yellow,
    ),
    const LiveRoomMember(
      name: "Ruth",
      isModerator: true,
      imagePath: "assets/images/5.png",
      color: MemojiColors.green,
    ),
    const LiveRoomMember(
      name: "Rich",
      imagePath: "assets/images/1.png",
      color: MemojiColors.red,
    ),
    const LiveRoomMember(
      name: "Sarah",
      isNewMember: true,
      imagePath: "assets/images/7.png",
      color: MemojiColors.blue,
    ),
    const LiveRoomMember(
      name: "Mercy",
      isNewMember: true,
      imagePath: "assets/images/8.png",
      color: MemojiColors.white,
    ),
    const LiveRoomMember(
      name: "Tim",
      isNewMember: true,
      imagePath: "assets/images/9.png",
      color: MemojiColors.purple,
    ),
    const LiveRoomMember(
      name: "Ed",
      isNewMember: true,
      imagePath: "assets/images/10.png",
      color: MemojiColors.yellow,
    ),
    const LiveRoomMember(
      name: "John",
      isNewMember: true,
      imagePath: "assets/images/11.png",
      color: MemojiColors.green,
    ),
    const LiveRoomMember(
      name: "Lauret",
      isNewMember: true,
      imagePath: "assets/images/12.png",
      color: MemojiColors.purple,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black.withBlue(20),
        appBar: AppBar(
            backgroundColor: Colors.black.withBlue(20),
            title: const Text("Design talk and chill"),
            leading: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: IconButton(
                icon: const Icon(CupertinoIcons.chevron_down),
                onPressed: () {
                  Navigator.maybePop(context);
                },
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: Badge(
                    child: const Icon(
                      Iconsax.message,
                      size: 30,
                    ),
                  )),
              const SizedBox(
                width: 10,
              )
            ]),
        body: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: members.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1 / 1,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  return members[index];
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 6,
                    width: 70,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          maxLines: null,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.6),
                            hintText: "Type a thought here...",
                            hintStyle: const TextStyle(color: Colors.white70),
                            contentPadding:
                                const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blueAccent,
                        child: const Icon(CupertinoIcons.paperplane_fill),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: ColoredBox(
          color: Colors.blueAccent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            height: 110,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  TextButton.icon(
                    icon: const Text(
                      "✌🏼",
                      style: TextStyle(fontSize: 18),
                    ),
                    label: const Text("Leave quietly"),
                    style: TextButton.styleFrom(
                      foregroundColor: DynamicColor.withBrightness(
                        context: context,
                        color: Colors.blueAccent,
                        darkColor: const Color(0xFF9d97ec),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      backgroundColor: DynamicColor.withBrightness(
                        context: context,
                        color: const Color(0xFFeff0f5),
                        darkColor: const Color(0xFF2a2b29),
                      ),
                    ),
                    onPressed: () {},
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: DynamicColor.withBrightness(
                      context: context,
                      color: const Color(0xFFeff0f5),
                      darkColor: const Color(0xFF2a2b29),
                    ),
                    child: const Text(
                      "✋🏼",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: DynamicColor.withBrightness(
                      context: context,
                      color: const Color(0xFFeff0f5),
                      darkColor: const Color(0xFF2a2b29),
                    ),
                    child: Image.asset("assets/images/10.png"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  // void _onToggleMute() {
  //   setState(() {
  //     _muted = !_muted;
  //   });
  //   _engine.muteLocalAudioStream(_muted);
  // }

  // void _onSwitchCamera() {
  //   _engine.switchCamera();
  // }
}

class Userparticipe {
  int uid;
  bool isSpeaking;

  Userparticipe(this.uid, this.isSpeaking);

  @override
  String toString() {
    return 'User{uid: $uid, isSpeaking: $isSpeaking}';
  }
}

/// Define App ID
const APP_ID = "40323438469d4c1e90c258227fcf9a77";
