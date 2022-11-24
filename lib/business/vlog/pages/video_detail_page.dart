import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_3.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage({
    Key? key,
  }) : super(key: key);
  @override
  _VideoDetailPageState createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  int activeEpisode = 0;

  // for video player
  late VideoPlayerController _controller;

  String videoUrl = Get.arguments[0]['videourl'];
  String description = Get.arguments[1]['description'];
  String titre = Get.arguments[2]['titre'];
  String vignette = Get.arguments[3]['vignette'];
  // String date = Get.arguments[4]['date'];
  String nomchaine = Get.arguments[5]['nomchaine'];
  String idvideo = Get.arguments[6]['idvideo'];
  String categorie = Get.arguments[7]['categorie'];
  String nomuser = "";
  String avataruser = '';
  String userid = FirebaseAuth.instance.currentUser!.uid;
  List alluser = [];
  final commencontroller = TextEditingController();

  final Stream<QuerySnapshot> _pubvideo = FirebaseFirestore.instance
      .collection('videovlog')
      .where("idvideo", isEqualTo: Get.arguments[6]['idvideo'])
      .snapshots();

  final Stream<QuerySnapshot> _datalike = FirebaseFirestore.instance
      .collection("videolike")
      .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where("idvideo", isEqualTo: Get.arguments[6]['idvideo'])
      .snapshots();
  final Stream<QuerySnapshot> _comment = FirebaseFirestore.instance
      .collection("comment")
      .where("idvideo", isEqualTo: Get.arguments[6]['idvideo'])
      .orderBy("range", descending: true)
      .snapshots();
  String idlike = "";
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;
  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(videoUrl)
      ..initialize().then((value) => setState(() {}));
    _customVideoPlayerController = CustomVideoPlayerController(
        context: context,
        videoPlayerController: videoPlayerController,
        customVideoPlayerSettings:
            CustomVideoPlayerSettings(settingsButtonAvailable: false));
    getinfouser();
    getalluser();
  }

  getinfouser() {
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc.id == userid) {
          setState(() {
            nomuser = doc['nom'];
            avataruser = doc['avatar'];
          });
        }
      }
    });
  }

  getalluser() {
    FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot value) {
      setState(() {
        alluser = value.docs;
      });
    });
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(200.0), // here the desired height
          child: SafeArea(
            child: CustomVideoPlayer(
                customVideoPlayerController: _customVideoPlayerController),
          )),
      body: getBody(),
    );
  }

  Widget getBody() {
    return Container(
      child: Column(
        children: [
          Expanded(
              child: Container(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 20, left: 15, right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titre,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  height: 1.4,
                                  fontSize: 20,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Text(
                                  nomchaine,
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(
                                          width: 2,
                                          color:
                                              Colors.white.withOpacity(0.2))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4, right: 4, top: 2, bottom: 2),
                                    child: Text(
                                      categorie,
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(
                                          width: 2,
                                          color:
                                              Colors.white.withOpacity(0.2))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4, right: 4, top: 2, bottom: 2),
                                    child: Text(
                                      "HD",
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            widgetLike(),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Description",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              description,
                              style: TextStyle(
                                  height: 1.4,
                                  color: Colors.white.withOpacity(0.9)),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Commentaire",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            StreamBuilder(
                                stream: _comment,
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> comment) {
                                  if (!comment.hasData) {
                                    return const Center(
                                        heightFactor: 5,
                                        child: CircularProgressIndicator());
                                  }
                                  if (comment.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        heightFactor: 5,
                                        child: CircularProgressIndicator());
                                  }
                                  return (comment.data!.docs.isEmpty)
                                      ? const Center(
                                          heightFactor: 2,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: Text(
                                              "Aucun commentaire, soyez le premier à commenter.",
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 18),
                                            ),
                                          ))
                                      : ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: comment.data!.docs.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onLongPress: () {
                                                deletecomment(
                                                    comment
                                                        .data!.docs[index].id,
                                                    comment.data!.docs[index]
                                                        ["iduser"]);
                                              },
                                              child: Stack(
                                                children: [
                                                  for (var alluser in alluser)
                                                    if (alluser["iduser"] ==
                                                        comment.data!
                                                                .docs[index]
                                                            ["iduser"])
                                                      Positioned(
                                                        bottom: 1,
                                                        left: 5,
                                                        child: CircleAvatar(
                                                          radius: 20,
                                                          backgroundImage:
                                                              CachedNetworkImageProvider(
                                                                  comment.data!
                                                                              .docs[
                                                                          index]
                                                                      [
                                                                      "avatar"]),
                                                        ),
                                                      ),
                                                  ChatBubble(
                                                    clipper: ChatBubbleClipper3(
                                                        type: BubbleType
                                                            .receiverBubble),
                                                    backGroundColor:
                                                        const Color(0xffE7E7ED),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 20, left: 43),
                                                    child: Container(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                      ),
                                                      child: Text(
                                                        comment.data!
                                                                .docs[index]
                                                            ["message"],
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          });
                                }),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: TextField(
                    cursorHeight: 20,
                    style: const TextStyle(color: Colors.white),
                    autofocus: false,
                    controller: commencontroller,
                    decoration: InputDecoration(
                      label: const Text("Entrer votre commentaire",
                          style: TextStyle(color: Colors.white)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        gapPadding: 0.0,
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    sendcomment();
                  },
                  child: const Icon(
                    Iconsax.send_2,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget widgetLike() {
    return StreamBuilder(
        stream: _pubvideo,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> videopub) {
          if (!videopub.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (videopub.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: videopub.data!.docs.length,
              itemBuilder: (context, index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      children: [
                        StreamBuilder(
                            stream: _datalike,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> like) {
                              if (!like.hasData) {
                                return Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(100))),
                                    child: const Icon(Iconsax.heart,
                                        color: Colors.white));
                              }
                              if (like.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (like.data!.docs.isEmpty) {
                                      } else {
                                        setState(() {
                                          idlike = like.data!.docs[index].id;
                                        });
                                      }
                                      likeordislike(idlike,
                                          videopub.data!.docs[index]["like"]);
                                    },
                                    child: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100))),
                                        child: Icon(
                                          Iconsax.heart,
                                          color: (like.data!.docs.isEmpty)
                                              ? Colors.white
                                              : Colors.red,
                                        )),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    "${videopub.data!.docs[index]["like"]} ",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ],
                              );
                            }),
                      ],
                    ),
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: () {},
                      child: Column(
                        children: [
                          Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(100))),
                              child: const Icon(
                                Iconsax.message,
                                color: Colors.white,
                              )),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            "${videopub.data!.docs[index]["comment"]} ",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                );
              });
        });
  }

  sendcomment() {
    if (commencontroller.text.isEmpty) {
    } else {
      FirebaseFirestore.instance.collection("comment").add({
        "idvideo": idvideo,
        "nom": nomuser,
        "avatar": avataruser,
        "date": DateTime.now(),
        "range": DateTime.now().millisecondsSinceEpoch,
        "message": commencontroller.text,
        "iduser": userid
      });
      FirebaseFirestore.instance
          .collection("videovlog")
          .doc(idvideo)
          .update({"comment": FieldValue.increment(1)});
    }
    commencontroller.clear();
  }

  deletecomment(String id, idsend) {
    if (idsend == userid) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text("Voulez-vous vraiment supprimer votre commentaire ?"),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: Colors.black),
                  )),
              TextButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.orange.shade900)),
                child: const Text('Oui supprimmer'),
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('comment')
                      .doc(id)
                      .delete();
                  FirebaseFirestore.instance
                      .collection("videovlog")
                      .doc(idvideo)
                      .update({"comment": FieldValue.increment(-1)});
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void likeordislike(id, int nombrelike) {
    FirebaseFirestore.instance
        .collection("videolike")
        .where("iduser", isEqualTo: userid)
        .where("idvideo", isEqualTo: idvideo)
        .get()
        .then((QuerySnapshot value) {
      if (value.docs.isEmpty) {
        FirebaseFirestore.instance.collection("videolike").add({
          "idvideo": idvideo,
          "iduser": FirebaseAuth.instance.currentUser!.uid
        });
        FirebaseFirestore.instance
            .collection("videovlog")
            .doc(idvideo)
            .update({"like": FieldValue.increment(1)});
      } else {
        if (nombrelike > 0) {
          FirebaseFirestore.instance.collection('videolike').doc(id).delete();
          FirebaseFirestore.instance
              .collection("videovlog")
              .doc(idvideo)
              .update({"like": FieldValue.increment(-1)});
        }
      }
    });
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

  static const List<Duration> _exampleCaptionOffsets = <Duration>[
    Duration(seconds: -10),
    Duration(seconds: -3),
    Duration(seconds: -1, milliseconds: -500),
    Duration(milliseconds: -250),
    Duration.zero,
    Duration(milliseconds: 250),
    Duration(seconds: 1, milliseconds: 500),
    Duration(seconds: 3),
    Duration(seconds: 10),
  ];
  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topLeft,
          child: PopupMenuButton<Duration>(
            initialValue: controller.value.captionOffset,
            tooltip: 'Caption Offset',
            onSelected: (Duration delay) {
              controller.setCaptionOffset(delay);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<Duration>>[
                for (final Duration offsetDuration in _exampleCaptionOffsets)
                  PopupMenuItem<Duration>(
                    value: offsetDuration,
                    child: Text('${offsetDuration.inMilliseconds}ms'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
