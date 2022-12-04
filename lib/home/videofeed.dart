import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smatch/home/tabsrequette.dart';
import 'package:video_player/video_player.dart';

class Videofeed extends StatefulWidget {
  const Videofeed({Key? key}) : super(key: key);

  @override
  _VideofeedState createState() => _VideofeedState();
}

class _VideofeedState extends State<Videofeed> {
  String idbranche = Get.arguments[0]["idbranche"];
  String nombranche = Get.arguments[1]["nombranche"];
  String idcreat = Get.arguments[2]["idcreat"];
  int admin = Get.arguments[3]["admin"];
  String affiche = Get.arguments[5]["affiche"];
  bool publi = Get.arguments[6]["publi"];
  final Stream<QuerySnapshot> streamvideopub = FirebaseFirestore.instance
      .collection("publication")
      .where("idbranche", isEqualTo: Get.arguments[0]["idbranche"])
      .orderBy("range", descending: true)
      .snapshots();
  final PageController pageController = PageController(initialPage: 1);
  int pagenumber = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withBlue(20),
        body: SafeArea(
            child: Stack(
          children: [
            PageView(
              controller: pageController,
              onPageChanged: (value) {
                setState(() {
                  pagenumber = value;
                });
              },
              children: [
                if (publi)
                  Container(
                    color: Colors.black.withBlue(30),
                    child: Mypub(
                      idbranche: idbranche,
                    ),
                  ),
                StreamBuilder(
                  stream: streamvideopub,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    int length = snapshot.data!.docs.length;
                    List videofeeds = snapshot.data!.docs;
                    return (videofeeds.isEmpty)
                        ? EmptyWidget(
                            hideBackgroundAnimation: true,
                            image: "assets/inbox.png",
                            packageImage: null,
                            title: 'Aucune video',
                            subTitle: 'Aucune video disponible',
                            titleTextStyle: const TextStyle(
                              fontSize: 22,
                              color: Color(0xff9da9c7),
                              fontWeight: FontWeight.w500,
                            ),
                            subtitleTextStyle: const TextStyle(
                              fontSize: 18,
                              color: Color(0xffabb8d6),
                            ),
                          )
                        : CarouselSlider.builder(
                            itemCount: length,
                            itemBuilder: (BuildContext context, int index,
                                int pageViewIndex) {
                              return Stack(
                                children: [
                                  Displaytypevideo(
                                    urlvideo: snapshot.data!.docs[index]
                                        ["video"],
                                    idvideo: videofeeds[index]["id"],
                                  ),
                                  Positioned(
                                      right: 1,
                                      bottom: 300,
                                      child: Container(
                                        width: 100,
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              height: 70,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.red,
                                                      width: 5),
                                                  color: Colors.yellow,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(50))),
                                              child: (videofeeds[index]
                                                          ["typepub"] ==
                                                      "compte")
                                                  ? Displaylogo(
                                                      idnoeud: videofeeds[index]
                                                          ["idpub"])
                                                  : Displayavatar(
                                                      iduser: videofeeds[index]
                                                          ["idpub"]),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Displaylike(
                                                idpub: videofeeds[index]["id"]),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Column(
                                              children: <Widget>[
                                                GestureDetector(
                                                  onTap: () {
                                                    showCupertinoModalBottomSheet(
                                                      context: context,
                                                      builder: (context) =>
                                                          Commentvideofeed(
                                                              idvideopub:
                                                                  videofeeds[
                                                                          index]
                                                                      ["id"]),
                                                    );
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withBlue(30),
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    50))),
                                                    child: const Icon(
                                                      Iconsax.message,
                                                      size: 35,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "${videofeeds[index]["nbrecomment"]} ",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )),
                                ],
                              );
                            },
                            options: CarouselOptions(
                                scrollDirection: Axis.vertical,
                                viewportFraction: 1.0,
                                enlargeCenterPage: false,
                                height: MediaQuery.of(context).size.height),
                          );
                  },
                )
              ],
            ),
            if (publi)
              Positioned(
                  top: 1,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Badge(
                          showBadge: (pagenumber == 0) ? true : false,
                          position: const BadgePosition(bottom: 10, end: 1),
                          child: ActionChip(
                              backgroundColor: Colors.black.withBlue(20),
                              onPressed: () {
                                if (pagenumber != 0) {
                                  pageController.animateToPage(0,
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.easeIn);
                                }
                              },
                              label: const Text(
                                'Publier',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              )),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Badge(
                          showBadge: (pagenumber == 1) ? true : false,
                          position: const BadgePosition(bottom: 10, end: 1),
                          child: ActionChip(
                              backgroundColor: Colors.black.withBlue(20),
                              onPressed: () {
                                if (pagenumber != 1) {
                                  pageController.animateToPage(1,
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.easeIn);
                                }
                              },
                              label: const Text(
                                'Feed',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              )),
                        )
                      ],
                    ),
                  ))
          ],
        )),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: (publi)
            ? FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  Get.toNamed("/videofeedpub", arguments: [
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

class Displaytypevideo extends StatefulWidget {
  Displaytypevideo({Key? key, required this.urlvideo, required this.idvideo})
      : super(key: key);
  String urlvideo;
  String idvideo;
  @override
  _DisplaytypevideoState createState() => _DisplaytypevideoState();
}

class _DisplaytypevideoState extends State<Displaytypevideo> {
  late VideoPlayerController _controller;
  bool finishvideo = false;
  @override
  void initState() {
    print(widget.idvideo);
    super.initState();
    _controller = VideoPlayerController.network(widget.urlvideo)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        _controller.play();
      });
    _controller.addListener(checkVideo);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (!_controller.value.isPlaying && !finishvideo) {
                    setState(() {
                      _controller.play();
                    });
                  } else {
                    setState(() {
                      _controller.pause();
                    });
                  }
                },
                child: VideoPlayer(_controller),
              ),
              if (!_controller.value.isPlaying && !finishvideo)
                Positioned(
                    bottom: 200,
                    right: 30,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.black.withBlue(30),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50))),
                      child: const Icon(
                        Iconsax.pause,
                        size: 30,
                        color: Colors.white,
                      ),
                    )),
              if (finishvideo)
                Positioned(
                    bottom: 200,
                    right: 30,
                    child: GestureDetector(
                      onTap: () {
                        _controller.play();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.black.withBlue(30),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50))),
                        child: const Icon(
                          Iconsax.refresh,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    )),
              Positioned(
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                          backgroundColor: Colors.red,
                          bufferedColor: Colors.black,
                          playedColor: Colors.blueAccent),
                    ),
                  )),
              Positioned(
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    color: Colors.white.withOpacity(0.2),
                    child: const Text(
                      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.justify,
                      maxLines: 5,
                    ),
                  ))
            ],
          )
        : Container(
            color: Colors.black.withBlue(30),
            child: const Center(child: CircularProgressIndicator()),
          );
  }

  void checkVideo() {
    // Implement your calls inside these conditions' bodies :

    if (_controller.value.position ==
        Duration(seconds: 0, minutes: 0, hours: 0)) {
      print('video Started');
      setState(() {
        finishvideo = false;
      });
    }

    if (_controller.value.position == _controller.value.duration) {
      print('video Ended');
      setState(() {
        finishvideo = true;
      });
    }
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
                ? GestureDetector(
                    onTap: () {
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
                    child: Container(
                      width: 100,
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.black.withBlue(30),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(50))),
                            child: const Icon(
                              Iconsax.heart,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            "0",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: likedata.data!.docs.length,
                    itemBuilder: (BuildContext, index) {
                      return (likedata.data!.docs.isEmpty)
                          ? const CircularProgressIndicator()
                          : GestureDetector(
                              onTap: () {
                                if (length == 0) {
                                  FirebaseFirestore.instance
                                      .collection("publication")
                                      .doc(widget.idpub)
                                      .collection("userlike")
                                      .add({
                                    "iduserlike":
                                        FirebaseAuth.instance.currentUser!.uid
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
                              child: Container(
                                width: 100,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.black.withBlue(30),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(50))),
                                      child: Icon(
                                        Iconsax.heart,
                                        size: 35,
                                        color: (length == 0)
                                            ? Colors.white
                                            : Colors.red,
                                      ),
                                    ),
                                    Text(
                                      "${likedata.data!.docs[index]["nbrelike"]} ",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            );
                    });
          },
        );
      },
    );
  }
}

class Commentvideofeed extends StatefulWidget {
  Commentvideofeed({Key? key, required this.idvideopub}) : super(key: key);
  String idvideopub;
  @override
  _CommentvideofeedState createState() => _CommentvideofeedState();
}

class _CommentvideofeedState extends State<Commentvideofeed> {
  String nomuser = "";
  String avataruser = "";
  List alluser = [];
  final instance = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> streamcomment = FirebaseFirestore.instance
      .collection("publication")
      .doc(widget.idvideopub)
      .collection("comment")
      .snapshots();
  final commentcontroller = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.idvideopub);
    getinfouser();
    getuser();
  }

  getinfouser() {
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      nomuser = querySnapshot.docs.first['nom'];
      avataruser = querySnapshot.docs.first['avatar'];
    });
  }

  getuser() {
    FirebaseFirestore.instance.collection('users').get().then((data) {
      setState(() {
        alluser = data.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(20),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Center(
                child: Container(
                  height: 5,
                  width: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: StreamBuilder(
              stream: streamcomment,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: CircularProgressIndicator());
                }
                int length = snapshot.data!.docs.length;
                List comment = snapshot.data!.docs;
                return (comment.isEmpty)
                    ? EmptyWidget(
                        hideBackgroundAnimation: true,
                        image: "assets/inbox.png",
                        packageImage: null,
                        title: 'Aucun commentaire',
                        subTitle: 'Soyez le premier a commenter',
                        titleTextStyle: const TextStyle(
                          fontSize: 22,
                          color: Color(0xff9da9c7),
                          fontWeight: FontWeight.w500,
                        ),
                        subtitleTextStyle: const TextStyle(
                          fontSize: 18,
                          color: Color(0xffabb8d6),
                        ),
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: length,
                        itemBuilder: (BuildContext, index) {
                          return Column(
                            children: <Widget>[
                              for (var users in alluser)
                                if (users["iduser"] == comment[index]['iduser'])
                                  Row(
                                    // mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                users['avatar']),
                                      ),
                                      GestureDetector(
                                        onLongPress: () {
                                          deletecomment(
                                              snapshot.data!.docs[index].id);
                                        },
                                        child: BubbleSpecialThree(
                                          text:
                                              "${users["nom"]} \n ${comment[index]['message']} ",
                                          color: Color(0xFFE8E8EE),
                                          tail: true,
                                          isSender: false,
                                        ),
                                      )
                                    ],
                                  ),
                              const SizedBox(
                                height: 10,
                              )
                            ],
                          );
                        });
              },
            )),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 2),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(50))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(avataruser),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                    controller: commentcontroller,
                    decoration: const InputDecoration(
                      fillColor: Colors.transparent,
                      filled: false,
                      contentPadding: EdgeInsets.all(0),
                      labelStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                    ),
                  )),
                  const SizedBox(
                    width: 5,
                  ),
                  IconButton(
                      onPressed: () {
                        sendcomment();
                      },
                      icon: const Icon(Iconsax.send_1,
                          color: Colors.white, size: 30)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  deletecomment(idvideo) {
    Get.defaultDialog(
      title: "Confirmation",
      content: const Text("Voulez vous vraiment supprimer votre message"),
      textConfirm: 'Supprimer',
      textCancel: "Annuler",
      confirmTextColor: Colors.white,
      onConfirm: () {
        instance
            .collection("publication")
            .doc(widget.idvideopub)
            .collection("comment")
            .doc(idvideo)
            .delete();
        instance
            .collection("publication")
            .doc(widget.idvideopub)
            .update({"nbrecomment": FieldValue.increment(-1)});
        Navigator.of(context).pop();
      },
    );
  }

  sendcomment() {
    instance
        .collection('publication')
        .doc(widget.idvideopub)
        .collection("comment")
        .add({
      "message": commentcontroller.text,
      'range': DateTime.now().millisecondsSinceEpoch,
      "iduser": FirebaseAuth.instance.currentUser!.uid,
      "date": DateTime.now()
    });
    instance
        .collection('publication')
        .doc(widget.idvideopub)
        .update({"nbrecomment": FieldValue.increment(1)});
    print('send');
    setState(() {
      commentcontroller.text = "";
    });
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
        return CircleAvatar(
          radius: 25,
          backgroundImage:
              CachedNetworkImageProvider(snapshot.data!.docs.first["avatar"]),
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
        return CircleAvatar(
          radius: 25,
          backgroundImage: (userinfo["affiche"] != "")
              ? CachedNetworkImageProvider(userinfo["affiche"])
              : null,
        );
      },
    );
  }
}

class Mypub extends StatefulWidget {
  Mypub({Key? key, required this.idbranche}) : super(key: key);
  String idbranche;
  @override
  _MypubState createState() => _MypubState();
}

class _MypubState extends State<Mypub> {
  late Stream<QuerySnapshot> streamvideopub = FirebaseFirestore.instance
      .collection("publication")
      .where("idpub", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where("idbranche", isEqualTo: widget.idbranche)
      .snapshots();
  final req = Get.put(Tabsrequette());
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamvideopub,
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
        List videofeeds = snapshot.data!.docs;
        return (videofeeds.isEmpty)
            ? EmptyWidget(
                image: "assets/inbox.png",
                packageImage: null,
                title: 'Pas de video',
                subTitle: "Vous n'avez pas encore publie de video",
                hideBackgroundAnimation: true,
                titleTextStyle: const TextStyle(
                  fontSize: 22,
                  color: Color(0xff9da9c7),
                  fontWeight: FontWeight.w500,
                ),
                subtitleTextStyle: const TextStyle(
                  fontSize: 18,
                  color: Color(0xffabb8d6),
                ),
              )
            : CarouselSlider.builder(
                itemCount: length,
                itemBuilder:
                    (BuildContext context, int index, int pageViewIndex) {
                  return Stack(
                    children: [
                      Displaytypevideo(
                        urlvideo: videofeeds[index]["video"],
                        idvideo: videofeeds[index]["id"],
                      ),
                      Positioned(
                          right: 1,
                          bottom: 300,
                          child: Container(
                            width: 100,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.red, width: 5),
                                      color: Colors.yellow,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(50))),
                                  child: (videofeeds[index]["typepub"] ==
                                          "compte")
                                      ? Displaylogo(
                                          idnoeud: videofeeds[index]["idpub"])
                                      : Displayavatar(
                                          iduser: videofeeds[index]["idpub"]),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Displaylike(idpub: videofeeds[index]["id"]),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        showCupertinoModalBottomSheet(
                                          context: context,
                                          builder: (context) =>
                                              Commentvideofeed(
                                                  idvideopub: videofeeds[index]
                                                      ["id"]),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.black.withBlue(30),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(50))),
                                        child: const Icon(
                                          Iconsax.message,
                                          size: 35,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "${videofeeds[index]["nbrecomment"]} ",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )),
                      Positioned(
                          right: 5,
                          top: 5,
                          child: GestureDetector(
                            onTap: () {
                              Get.defaultDialog(
                                title: 'Confirmation',
                                textConfirm: "Supprimer",
                                textCancel: "Annuler",
                                confirmTextColor: Colors.white,
                                content: const Text(
                                    'Voulez vraimeent supprimer cette publication ?'),
                                onConfirm: () {
                                  FirebaseFirestore.instance
                                      .collection("publication")
                                      .doc(snapshot.data!.docs[index].id);
                                  Navigator.of(context).pop();
                                  req.message("success",
                                      "Publication supprime avec success");
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.black.withBlue(30),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50))),
                              child: const Icon(
                                Iconsax.trash,
                                size: 25,
                                color: Colors.white,
                              ),
                            ),
                          ))
                    ],
                  );
                },
                options: CarouselOptions(
                    scrollDirection: Axis.vertical,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    height: MediaQuery.of(context).size.height),
              );
      },
    );
  }
}
