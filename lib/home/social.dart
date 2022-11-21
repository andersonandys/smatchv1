import 'dart:convert';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smatch/home/settingsvideo.dart';
import 'package:smatch/home/tabsrequette.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Social extends StatefulWidget {
  const Social({Key? key}) : super(key: key);

  @override
  _SocialState createState() => _SocialState();
}

class _SocialState extends State<Social> {
  String idbranche = Get.arguments[0]["idbranche"];
  String nombranche = Get.arguments[1]["nombranche"];
  String idcreat = Get.arguments[2]["idcreat"];
  int admin = Get.arguments[3]["admin"];
  String affiche = Get.arguments[5]["affiche"];
  bool publi = Get.arguments[6]["publi"];
  final Stream<QuerySnapshot> streampub = FirebaseFirestore.instance
      .collection("publication")
      .where("idbranche", isEqualTo: Get.arguments[0]["idbranche"])
      .snapshots();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withBlue(30),
        appBar: AppBar(
          backgroundColor: Colors.black.withBlue(30),
          elevation: 0,
          title: Text(
            nombranche,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            if (publi)
              IconButton(
                  onPressed: () {
                    Get.toNamed("mypubsocial", arguments: [
                      {"idbranche": idbranche}
                    ]);
                  },
                  icon: const Icon(
                    Iconsax.edit,
                    size: 30,
                    color: Colors.white,
                  ))
          ],
        ),
        body: StreamBuilder(
          stream: streampub,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            int length = snapshot.data!.docs.length;
            List publi = snapshot.data!.docs;
            return (publi.isEmpty)
                ? const Text(
                    "aucune data",
                    style: TextStyle(color: Colors.white),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: length,
                    itemBuilder: (BuildContext, index) {
                      return GestureDetector(
                        onTap: () {
                          if (publi[index]["typecontenu"] == "image") {
                            Get.toNamed("viewsocial", arguments: [
                              {"idpub": publi[index]["id"]},
                              {"textpub": publi[index]["text"]},
                              {"type": "image"}
                            ]);
                          } else {
                            Get.toNamed("viewsocial", arguments: [
                              {"idpub": publi[index]["id"]},
                              {"textpub": publi[index]["text"]},
                              {"type": "video"},
                              {"video": publi[index]["video"]}
                            ]);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (publi[index]["typecontenu"] == "image")
                                Stack(
                                  children: [
                                    Displayimage(
                                      idpub: snapshot.data!.docs[index].id,
                                      type: '',
                                      textpub: snapshot.data!.docs[index]
                                          ["text"],
                                    ),
                                  ],
                                ),
                              if (publi[index]["typecontenu"] == "video")
                                Displayvideopub(
                                  idpub: snapshot.data!.docs[index]["id"],
                                  type: '',
                                  textpub: snapshot.data!.docs[index]["text"],
                                  video: snapshot.data!.docs[index]["video"],
                                ),
                              const SizedBox(
                                height: 20,
                              ),
                              DetectableText(
                                trimExpandedText: "Montrer moins",
                                trimCollapsedText: "Montrer plus",
                                moreStyle: const TextStyle(
                                    color: Colors.blueAccent, fontSize: 16),
                                lessStyle: const TextStyle(
                                    color: Colors.blueAccent, fontSize: 18),
                                trimLength: 150,
                                text: publi[index]["text"],
                                detectionRegExp: RegExp(
                                  "(?!\\n)(?:^|\\s)([#@]([$detectionContentLetters]+))|$urlRegexContent",
                                  multiLine: true,
                                ),
                                detectedStyle: const TextStyle(
                                    color: Colors.orange, fontSize: 18),
                                basicStyle: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                                onTap: (tappedText) {
                                  Get.toNamed("/checklien", arguments: [
                                    {"url": tappedText}
                                  ]);
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Divider(
                                color: Colors.white,
                                height: 19,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: (publi[index]["typepub"] ==
                                              "compte")
                                          ? Displaylogo(
                                              idnoeud: publi[index]["idpub"])
                                          : Displayavatar(
                                              iduser: publi[index]["idpub"]),
                                    ),
                                    Expanded(
                                        child: Displaylike(
                                      idpub: snapshot.data!.docs[index].id,
                                    ))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    });
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: (publi)
            ? FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  Get.toNamed("/socialpub", arguments: [
                    {"nombranche": nombranche},
                    {"affiche": affiche},
                    {"idbranche": idbranche}
                  ]);
                },
                child: Icon(Icons.publish),
              )
            : null);
  }
}

class Displayavatar extends StatefulWidget {
  Displayavatar({Key? key, required this.iduser}) : super(key: key);
  String iduser;
  @override
  _DisplayavatarState createState() => _DisplayavatarState();
}

class _DisplayavatarState extends State<Displayavatar> {
  late Stream<QuerySnapshot> streamuser = FirebaseFirestore.instance
      .collection("users")
      .where("iduser", isEqualTo: widget.iduser)
      .snapshots();
  @override
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamuser,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        var userinfo = snapshot.data!.docs.first;
        return ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: CircleAvatar(
            radius: 25,
            backgroundImage:
                CachedNetworkImageProvider(snapshot.data!.docs.first["avatar"]),
          ),
          title: Text(
            "${snapshot.data!.docs.first["nom"]}",
            maxLines: 1,
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            'il y a 3h',
            style: TextStyle(color: Colors.white38),
          ),
        );
      },
    );
  }
}

class Displaylogo extends StatefulWidget {
  Displaylogo({Key? key, required this.idnoeud}) : super(key: key);
  String idnoeud;
  @override
  _DisplaylogoState createState() => _DisplaylogoState();
}

class _DisplaylogoState extends State<Displaylogo> {
  late Stream<QuerySnapshot> streamnoeud = FirebaseFirestore.instance
      .collection("branche")
      .where("idbranche", isEqualTo: widget.idnoeud)
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamnoeud,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        var userinfo = snapshot.data!.docs.first;
        return ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: (userinfo["affiche"] != "")
                ? CachedNetworkImageProvider(userinfo["affiche"])
                : null,
          ),
          title: Text(
            "${userinfo["nom"]}",
            maxLines: 1,
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            'il y a 3h',
            style: TextStyle(color: Colors.white38),
          ),
        );
      },
    );
  }
}

class Displayimage extends StatefulWidget {
  Displayimage(
      {Key? key,
      required this.idpub,
      required this.type,
      required this.textpub})
      : super(key: key);
  String idpub;
  String type;
  String textpub;
  @override
  _DisplayimageState createState() => _DisplayimageState();
}

class _DisplayimageState extends State<Displayimage> {
  late Stream<QuerySnapshot> streamnoeud = FirebaseFirestore.instance
      .collection("publication")
      .doc(widget.idpub)
      .collection("image")
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamnoeud,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        List imagepub = snapshot.data!.docs;
        int length = snapshot.data!.docs.length;
        return CarouselSlider.builder(
          itemCount: length,
          itemBuilder:
              (BuildContext context, int itemIndex, int pageViewIndex) =>
                  GestureDetector(
            onTap: () {
              if (widget.type == "look") {
                Get.toNamed("viewimage", arguments: [
                  {"urlfile": imagepub[itemIndex]["image"]}
                ]);
              } else {
                Get.toNamed("viewsocial", arguments: [
                  {"idpub": widget.idpub},
                  {"textpub": widget.textpub},
                  {"type": "image"}
                ]);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(left: 5, right: 5),
              height: 300,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: CachedNetworkImage(
                  imageUrl: imagepub[itemIndex]["image"],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          options: CarouselOptions(
              height: 300, enlargeStrategy: CenterPageEnlargeStrategy.height),
        );
      },
    );
  }
}

class Displayvideo extends StatefulWidget {
  Displayvideo(
      {Key? key,
      required this.idpub,
      required this.type,
      required this.textpub})
      : super(key: key);
  String idpub;
  String type;
  String textpub;
  @override
  _DisplayvideoState createState() => _DisplayvideoState();
}

class _DisplayvideoState extends State<Displayvideo> {
  late Stream<QuerySnapshot> streamnoeud = FirebaseFirestore.instance
      .collection("publication")
      .doc(widget.idpub)
      .collection("video")
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamnoeud,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        List imagepub = snapshot.data!.docs;
        int length = snapshot.data!.docs.length;
        return CarouselSlider.builder(
          itemCount: length,
          itemBuilder:
              (BuildContext context, int itemIndex, int pageViewIndex) =>
                  GestureDetector(
            onTap: () {
              if (widget.type == "look") {
                Get.toNamed("viewvideo", arguments: [
                  {"urlfile": imagepub[itemIndex]["video"]}
                ]);
              } else {
                Get.toNamed("viewsocial", arguments: [
                  {"idpub": widget.idpub},
                  {"textpub": widget.textpub},
                  {"type": "video"}
                ]);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(left: 5, right: 5),
              height: 300,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: CachedNetworkImage(
                  imageUrl: imagepub[itemIndex]["image"],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          options: CarouselOptions(
              height: 300, enlargeStrategy: CenterPageEnlargeStrategy.height),
        );
      },
    );
  }
}

class Displaylike extends StatefulWidget {
  Displaylike({
    Key? key,
    required this.idpub,
  }) : super(key: key);
  String idpub;
  @override
  _DisplaylikeState createState() => _DisplaylikeState();
}

class _DisplaylikeState extends State<Displaylike> {
  late Stream<QuerySnapshot> streamnoeud = FirebaseFirestore.instance
      .collection("publication")
      .doc(widget.idpub)
      .collection("userlike")
      .where("iduserlike", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
  late Stream<QuerySnapshot> like = FirebaseFirestore.instance
      .collection("publication")
      .where("id", isEqualTo: widget.idpub)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamnoeud,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        int length = snapshot.data!.docs.length;
        return StreamBuilder(
          stream: like,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> likedata) {
            if (!likedata.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else if (likedata.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return (likedata.data!.docs.isEmpty)
                ? Row(
                    children: <Widget>[
                      ActionChip(
                        backgroundColor: Colors.black.withBlue(30),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("publication")
                              .doc(widget.idpub)
                              .collection("userlike")
                              .add({
                            "iduserlike": FirebaseAuth.instance.currentUser!.uid
                          });
                          FirebaseFirestore.instance
                              .collection("publication")
                              .doc(widget.idpub)
                              .update({"nbrelike": FieldValue.increment(1)});
                        },
                        padding: const EdgeInsets.all(10),
                        label: const Text(
                          "0",
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                        avatar: const Icon(Iconsax.heart, color: Colors.white),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ActionChip(
                        backgroundColor: Colors.black.withBlue(30),
                        onPressed: () {},
                        padding: const EdgeInsets.all(10),
                        label: const Text(
                          "0",
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                        avatar:
                            const Icon(Iconsax.message, color: Colors.white),
                      )
                    ],
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: likedata.data!.docs.length,
                    itemBuilder: (BuildContext, index) {
                      return (likedata.data!.docs.isEmpty)
                          ? CircularProgressIndicator()
                          : Row(
                              children: <Widget>[
                                ActionChip(
                                  backgroundColor: Colors.black.withBlue(30),
                                  onPressed: () {
                                    if (length == 0) {
                                      FirebaseFirestore.instance
                                          .collection("publication")
                                          .doc(widget.idpub)
                                          .collection("userlike")
                                          .add({
                                        "iduserlike": FirebaseAuth
                                            .instance.currentUser!.uid
                                      });
                                      FirebaseFirestore.instance
                                          .collection("publication")
                                          .doc(widget.idpub)
                                          .update({
                                        "nbrelike": FieldValue.increment(1)
                                      });
                                    } else {
                                      print(snapshot.data!.docs.first.id);
                                      FirebaseFirestore.instance
                                          .collection("publication")
                                          .doc(widget.idpub)
                                          .collection("userlike")
                                          .doc(snapshot.data!.docs.first.id)
                                          .delete();
                                      FirebaseFirestore.instance
                                          .collection("publication")
                                          .doc(widget.idpub)
                                          .update({
                                        "nbrelike": FieldValue.increment(-1)
                                      });
                                    }
                                  },
                                  padding: const EdgeInsets.all(10),
                                  label: Text(
                                    "${likedata.data!.docs[index]["nbrelike"]}",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 17),
                                  ),
                                  avatar: Icon(Iconsax.heart,
                                      color: (length == 1)
                                          ? Colors.red
                                          : Colors.white),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                ActionChip(
                                  backgroundColor: Colors.black.withBlue(30),
                                  onPressed: () {},
                                  padding: const EdgeInsets.all(10),
                                  label: Text(
                                    "${likedata.data!.docs[index]["nbrecomment"]}",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 17),
                                  ),
                                  avatar: const Icon(Iconsax.message,
                                      color: Colors.white),
                                )
                              ],
                            );
                    });
          },
        );
      },
    );
  }
}

class Displayvideopub extends StatefulWidget {
  Displayvideopub(
      {Key? key,
      required this.idpub,
      required this.type,
      required this.textpub,
      required this.video})
      : super(key: key);
  String idpub;

  String type;

  String textpub;
  String video;
  @override
  _DisplayvideopubState createState() => _DisplayvideopubState();
}

class _DisplayvideopubState extends State<Displayvideopub> {
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String videoUrl =
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";

    videoPlayerController = VideoPlayerController.network(widget.video)
      ..initialize().then((value) => setState(() {}));
    _customVideoPlayerController = CustomVideoPlayerController(
        context: context,
        videoPlayerController: videoPlayerController,
        customVideoPlayerSettings:
            CustomVideoPlayerSettings(settingsButtonAvailable: false));
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        print("ok");
        Get.toNamed("viewsocial", arguments: [
          {"idpub": widget.idpub},
          {"textpub": widget.textpub},
          {"type": "video"},
          {"video": widget.video}
        ]);
      },
      child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CustomVideoPlayer(
              customVideoPlayerController: _customVideoPlayerController,
            ),
          )),
    );
  }
}

class Mypublicationsocial extends StatefulWidget {
  const Mypublicationsocial({Key? key}) : super(key: key);

  @override
  _MypublicationsocialState createState() => _MypublicationsocialState();
}

class _MypublicationsocialState extends State<Mypublicationsocial> {
  final instance = FirebaseFirestore.instance;
  final Stream<QuerySnapshot> streamepublication = FirebaseFirestore.instance
      .collection("publication")
      .where("idpub", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where("idbranche", isEqualTo: Get.arguments[0]["idbranche"])
      .snapshots();
  final req = Get.put(Tabsrequette());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(30),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(30),
        title: const Text('Mes publications'),
      ),
      body: StreamBuilder(
        stream: streamepublication,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          int length = snapshot.data!.docs.length;
          List datavideo = snapshot.data!.docs;
          return (datavideo.isEmpty)
              ? EmptyWidget(
                  hideBackgroundAnimation: true,
                  image: null,
                  packageImage: PackageImage.Image_1,
                  title: 'Aucun contenu',
                  subTitle: "Aucun contenu publier pour l'intant",
                  titleTextStyle: const TextStyle(
                    fontSize: 22,
                    color: Color(0xff9da9c7),
                    fontWeight: FontWeight.w500,
                  ),
                  subtitleTextStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xffabb8d6),
                  ),
                )
              : ListView.builder(
                  itemCount: length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext, index) {
                    return Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (datavideo[index]["typecontenu"] == "image")
                            Displayimage(
                                idpub: datavideo[index]["id"],
                                type: datavideo[index]["typecontenu"],
                                textpub: datavideo[index]["text"]),
                          if (datavideo[index]["typecontenu"] == "video")
                            Container(
                              height: 300,
                              child: DisplaySettingsvideo(
                                  url: datavideo[index]["video"]),
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            datavideo[index]["text"],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Chip(
                                      padding: const EdgeInsets.all(10),
                                      avatar: const Icon(Iconsax.heart),
                                      label: Text(
                                        "${datavideo[index]["nbrelike"]} ",
                                        style: const TextStyle(fontSize: 16),
                                      )),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Chip(
                                      padding: const EdgeInsets.all(10),
                                      avatar: const Icon(Iconsax.message),
                                      label: Text(
                                        "${datavideo[index]["nbrecomment"]} ",
                                        style: const TextStyle(fontSize: 16),
                                      ))
                                ],
                              ),
                              ActionChip(
                                  onPressed: () {
                                    Get.defaultDialog(
                                        onConfirm: () {
                                          instance
                                              .collection("publication")
                                              .doc(
                                                  snapshot.data!.docs[index].id)
                                              .delete();
                                          Navigator.of(context).pop();
                                          req.message("success",
                                              "Publication supprime avec succes");
                                        },
                                        textCancel: "Annuler",
                                        textConfirm: "Supprimer",
                                        title: "Confirmation",
                                        content: const Text(
                                            "Voulez vous vraiment supprimer cette publication ?"),
                                        confirmTextColor: Colors.white);
                                  },
                                  backgroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.all(10),
                                  avatar: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Supprimer',
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  ))
                            ],
                          )
                        ],
                      ),
                    );
                  });
        },
      ),
    );
  }
}
