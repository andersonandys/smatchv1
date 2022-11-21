// import 'package:better_player/better_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_3.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:bottom_sheet/bottom_sheet.dart';

class viewvlog extends StatefulWidget {
  const viewvlog({Key? key}) : super(key: key);

  @override
  State<viewvlog> createState() => _viewvlogState();
}

class _viewvlogState extends State<viewvlog> with TickerProviderStateMixin {
  String idvideo = Get.arguments[0]["idvideo"];
  String lienvideo = Get.arguments[1]["lienvideo"];
  String titre = Get.arguments[2]["titre"];
  String description = Get.arguments[3]["description"];
  String idvlog = Get.arguments[4]["idvlog"];
  final Stream<QuerySnapshot> _infoview = FirebaseFirestore.instance
      .collection('videovlog')
      .where("idvideo", isEqualTo: Get.arguments[0]['idvideo'])
      .snapshots();
  final Stream<QuerySnapshot> _pubvideo = FirebaseFirestore.instance
      .collection('videovlog')
      .where("idvlog", isEqualTo: Get.arguments[4]['idvlog'])
      .limit(5)
      .snapshots();
  final commencontroller = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  final Stream<QuerySnapshot> _datalike = FirebaseFirestore.instance
      .collection("videolike")
      .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where("idvideo", isEqualTo: Get.arguments[0]['idvideo'])
      .snapshots();
  final Stream<QuerySnapshot> _comment = FirebaseFirestore.instance
      .collection("comment")
      .where("idvideo", isEqualTo: Get.arguments[0]['idvideo'])
      .orderBy("range", descending: false)
      .snapshots();
  String? avataruser;
  String? nomuser;
  bool ischange = false;
  List alluser = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
        if (doc.id == user!.uid) {
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
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black.withBlue(30),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(250.0), // here the desired height
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.red, Colors.pink],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter)),
          // child: BetterPlayer.network(
          //   "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
          //   betterPlayerConfiguration: const BetterPlayerConfiguration(
          //       fit: BoxFit.fill, fullScreenAspectRatio: 50 / 9),
          // ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              child: StreamBuilder(
                  stream: (!ischange)
                      ? _infoview
                      : FirebaseFirestore.instance
                          .collection('videovlog')
                          .where("idvideo", isEqualTo: idvideo)
                          .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> videopub) {
                    if (!videopub.hasData) {
                      return Center(
                        child: LoadingAnimationWidget.dotsTriangle(
                          color: Colors.blueAccent,
                          size: 100,
                        ),
                      );
                    }
                    if (videopub.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: LoadingAnimationWidget.dotsTriangle(
                          color: Colors.blueAccent,
                          size: 100,
                        ),
                      );
                    }
                    return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: videopub.data!.docs.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: size.width / 1.1,
                                        child: Text(
                                          titre,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ]),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Column(
                                    children: [
                                      StreamBuilder(
                                          stream: (!ischange)
                                              ? _datalike
                                              : FirebaseFirestore.instance
                                                  .collection("videolike")
                                                  .where("iduser",
                                                      isEqualTo: user!.uid)
                                                  .where("idvideo",
                                                      isEqualTo: idvideo)
                                                  .snapshots(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<QuerySnapshot>
                                                  like) {
                                            if (!like.hasData) {
                                              return Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade300,
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  100))),
                                                  child: const Icon(
                                                    Iconsax.heart,
                                                  ));
                                            }
                                            if (like.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                            return (like.data!.docs.isEmpty)
                                                ? Column(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          likes();
                                                        },
                                                        child: Container(
                                                            height: 50,
                                                            width: 50,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                borderRadius:
                                                                    const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            100))),
                                                            child: const Icon(
                                                                Iconsax.heart)),
                                                      ),
                                                      Text(
                                                        "${videopub.data!.docs[index]["like"]} ",
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  )
                                                : Column(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          removelike(
                                                              like.data!.docs
                                                                  .first.id,
                                                              videopub.data!
                                                                          .docs[
                                                                      index]
                                                                  ["like"]);
                                                        },
                                                        child: Container(
                                                            height: 50,
                                                            width: 50,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                borderRadius:
                                                                    const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            100))),
                                                            child: const Icon(
                                                              Iconsax.heart,
                                                              color: Colors.red,
                                                            )),
                                                      ),
                                                      Text(
                                                        "${videopub.data!.docs[index]["like"]} ",
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  );
                                          }),
                                    ],
                                  ),
                                  const SizedBox(width: 15),
                                  GestureDetector(
                                    onTap: () {
                                      viewcomment();
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(100))),
                                            child: const Icon(Iconsax.message)),
                                        Text(
                                          "${videopub.data!.docs[index]["comment"]} ",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: const Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Description',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  description,
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: const Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Plus de vidéo',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                              SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: StreamBuilder(
                                    stream: _pubvideo,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<QuerySnapshot> pubvideo) {
                                      if (!pubvideo.hasData) {
                                        return Center(
                                          child: LoadingAnimationWidget
                                              .dotsTriangle(
                                            color: Colors.blueAccent,
                                            size: 100,
                                          ),
                                        );
                                      }
                                      if (pubvideo.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: LoadingAnimationWidget
                                              .dotsTriangle(
                                            color: Colors.blueAccent,
                                            size: 100,
                                          ),
                                        );
                                      }
                                      return (pubvideo.data!.docs.isEmpty)
                                          ? const Text(
                                              "Aucune video disponible",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 30),
                                            )
                                          : ListView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount:
                                                  pubvideo.data!.docs.length,
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    color: Colors.white
                                                        .withOpacity(0.1),
                                                  ),
                                                  height: 150,
                                                  margin: const EdgeInsets.only(
                                                      left: 10,
                                                      right: 10,
                                                      top: 10),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10)),
                                                          ),
                                                          height: size.height,
                                                          width: 150,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                ischange = true;
                                                                titre = pubvideo
                                                                        .data!
                                                                        .docs[index]
                                                                    ["titre"];
                                                                description = pubvideo
                                                                        .data!
                                                                        .docs[index]
                                                                    [
                                                                    "description"];
                                                                idvideo = pubvideo
                                                                    .data!
                                                                    .docs[index]
                                                                    .id;
                                                              });
                                                            },
                                                            // child: Avatar(
                                                            //     sources: [
                                                            //       NetworkSource(
                                                            //         pubvideo.data!
                                                            //                 .docs[index]
                                                            //             [
                                                            //             "vignette"],
                                                            //       )
                                                            //     ],
                                                            //     shape: AvatarShape.rectangle(
                                                            //         100,
                                                            //         100,
                                                            //         const BorderRadius
                                                            //                 .all(
                                                            //             Radius.circular(
                                                            //                 10.0)))),
                                                          )),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5,
                                                                    left: 5),
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2,
                                                            child: Text(
                                                              pubvideo.data!
                                                                          .docs[
                                                                      index]
                                                                  ["titre"],
                                                              style: const TextStyle(
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: [
                                                                Chip(
                                                                  label: Text(
                                                                      "${pubvideo.data!.docs[index]["like"]} "),
                                                                  avatar: const Icon(
                                                                      Iconsax
                                                                          .heart),
                                                                ),
                                                                Chip(
                                                                  label: Text(
                                                                      "${pubvideo.data!.docs[index]["comment"]} "),
                                                                  avatar: const Icon(
                                                                      Iconsax
                                                                          .message),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                );
                                              });
                                    }),
                              )
                            ],
                          );
                        });
                  }),
            )
          ],
        ),
      ),
    );
  }

  viewcomment() {
    showStickyFlexibleBottomSheet<void>(
      minHeight: 0,
      initHeight: 0.8,
      maxHeight: .8,
      headerHeight: 70,
      context: context,
      decoration: BoxDecoration(
        color: Colors.black.withBlue(30),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      headerBuilder: (context, offset) {
        return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black.withBlue(30),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(offset == 0.8 ? 0 : 20),
                topRight: Radius.circular(offset == 0.8 ? 0 : 20),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(left: 10, right: 5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Commentaires',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Iconsax.close_circle,
                          size: 30,
                          color: Colors.white,
                        ))
                  ]),
            ));
      },
      bodyBuilder: (context, offset) {
        return SliverChildListDelegate([
          Expanded(
              child: Column(
            children: [
              Container(
                  margin: const EdgeInsets.all(10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
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
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                gapPadding: 0.0,
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            sendcomment();
                          },
                          child: const Icon(
                            Iconsax.send_1,
                            size: 40,
                            color: Colors.white,
                          ),
                        )
                      ])),
              SizedBox(
                  height: MediaQuery.of(context).size.height / 1.8,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: StreamBuilder(
                        stream: _comment,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> comment) {
                          if (!comment.hasData) {
                            return Center(
                              heightFactor: 5,
                              child: LoadingAnimationWidget.dotsTriangle(
                                color: Colors.blueAccent,
                                size: 100,
                              ),
                            );
                          }
                          if (comment.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              heightFactor: 5,
                              child: LoadingAnimationWidget.dotsTriangle(
                                color: Colors.blueAccent,
                                size: 100,
                              ),
                            );
                          }
                          return (comment.data!.docs.isEmpty)
                              ? const Center(
                                  heightFactor: 5,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Text(
                                      "Aucun commentaire, soyez le premier à commenter",
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ))
                              : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: comment.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onDoubleTap: () {
                                        deletecomment(
                                            comment.data!.docs[index].id,
                                            comment.data!.docs[index]
                                                ["iduser"]);
                                      },
                                      child: Stack(
                                        children: [
                                          for (var alluser in alluser)
                                            if (alluser["iduser"] ==
                                                comment.data!.docs[index]
                                                    ["iduser"])
                                              Positioned(
                                                bottom: 1,
                                                left: 5,
                                                child: CircleAvatar(
                                                  radius: 20,
                                                  backgroundImage: NetworkImage(
                                                      comment.data!.docs[index]
                                                          ["avatar"]),
                                                ),
                                              ),
                                          ChatBubble(
                                            clipper: ChatBubbleClipper3(
                                                type:
                                                    BubbleType.receiverBubble),
                                            backGroundColor:
                                                const Color(0xffE7E7ED),
                                            margin: const EdgeInsets.only(
                                                top: 20, left: 43),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                              ),
                                              child: Text(
                                                comment.data!.docs[index]
                                                    ["message"],
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                        }),
                  )),
            ],
          ))
        ]);
      },
      anchors: [0],
    );
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
        "iduser": user!.uid
      });
      FirebaseFirestore.instance
          .collection("videovlog")
          .doc(idvideo)
          .update({"comment": FieldValue.increment(1)});
    }
    commencontroller.clear();
  }

  likes() {
    FirebaseFirestore.instance.collection("videolike").add(
        {"idvideo": idvideo, "iduser": FirebaseAuth.instance.currentUser!.uid});
    FirebaseFirestore.instance
        .collection("videovlog")
        .doc(idvideo)
        .update({"like": FieldValue.increment(1)});
  }

  removelike(id, nbrelike) {
    if (nbrelike == 0) {
    } else {
      FirebaseFirestore.instance.collection('videolike').doc(id).delete();
      FirebaseFirestore.instance
          .collection("videovlog")
          .doc(idvideo)
          .update({"like": FieldValue.increment(-1)});
    }
  }

  deletecomment(id, iduser) async {
    if (iduser == user!.uid) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text(" Voulez-vous vraiment supprimer votre commentaire ?"),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'annuler',
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
}
