import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:avatar_stack/positions.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart' as users;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smatch/callclub/call.dart';
import 'package:smatch/callclub/conference.dart';
import 'package:smatch/callclub/screens/common/splash_screen.dart';
import 'package:smatch/club/homeclub.dart';
import 'package:smatch/club/ui/home/Home.dart';
import 'package:smatch/home/notification.dart';
import 'package:smatch/home/presentation.dart';
import 'package:smatch/home/stackuser.dart';
import 'package:smatch/home/stories.dart';
import 'package:smatch/home/tabsrequette.dart';
import 'package:smatch/menu/menuwidget.dart';
import 'package:smatch/msgbranche/message.dart';
import 'package:smatch/newuser.dart';
import 'package:smatch/noeud/creatnoeud.dart';
import 'package:http/http.dart' as http;
import 'package:tezster_dart/tezster_dart.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:tezart/tezart.dart' as tezos;
// import 'package:tezart/tezart.dart';
// import 'package:tezster_dart/tezster_dart.dart';

class home extends StatefulWidget {
  var client;
  home({Key? key, client}) : super(key: key);

  @override
  _homeState createState() => _homeState();
}

class _homeState extends State<home> {
  final _advancedDrawerController = AdvancedDrawerController();

  String? token = " ";
  // final Stream<QuerySnapshot> _abonneStream = FirebaseFirestore.instance
  //     .collection('abonne')
  //     .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
  //     .snapshots();
  final _nombrancheController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _montantcontroller = TextEditingController();
  final _keyformbranche = GlobalKey<FormState>();
  late Stream<QuerySnapshot> _brancheStream = FirebaseFirestore.instance
      .collection('branche')
      .orderBy("range", descending: true)
      .snapshots();
  final settings = RestrictedAmountPositions(
    maxAmountItems: 9,
    maxCoverage: 0.3,
    minCoverage: 0.1,
  );
  String majtext =
      "Merci d’utiliser Smatch ! Nous mettons régulièrement à jour notre application pour la rendre plus performante, réparer les bugs et introduire de nouvelles fonctionnalités qui vous aident à rester en contact avec vos fans, familles et vos business";
  users.User? user = users.FirebaseAuth.instance.currentUser;
  final requ = Get.put(Tabsrequette());
  String nomuser = "";
  double progress = 0.0;
  String affiche = "";
  String avataruser = "";
  CollectionReference branche =
      FirebaseFirestore.instance.collection("branche");
  CollectionReference userbranche =
      FirebaseFirestore.instance.collection("userbranche");
  final Stream<QuerySnapshot> _users = FirebaseFirestore.instance
      .collection('users')
      .where("iduser", isEqualTo: users.FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
  bool check = false;
  final Stream<QuerySnapshot> _actualite =
      FirebaseFirestore.instance.collection('actualite').limit(10).snapshots();

  final Stream<QuerySnapshot> _abonnenoeuds = FirebaseFirestore.instance
      .collection('abonne')
      .where("iduser", isEqualTo: users.FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
  String userid = FirebaseAuth.instance.currentUser!.uid;
  String statut = "";
  String descriptionnoeud = "";
  String? test;
  String typebranche = "";
  List _myuserbranche = [];
  int notification = 0;
  List allnoeud = [];
  bool? ready;
  late FirebaseMessaging messaging;
  bool newser = false;
  String offre = "";
  int notifnoeud = 0;
  int? admin;
  List nomusers = [];
  final sendrequ = Get.put(Changevalue());
  List _abonnenoeud = [];
  int versionapp = 2;
  @override
  initState() {
    super.initState();

    getinfouser();
    allnoeuds();
    abonnenoeud();
    getinfoapp();
    print("laisee");
    if (sendrequ.idnoeuds.isNotEmpty) {
      setState(() {
        _brancheStream = FirebaseFirestore.instance
            .collection('branche')
            .where("id_noeud", isEqualTo: sendrequ.idnoeuds.value)
            .orderBy("range", descending: true)
            .snapshots();
      });
    }
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      setState(() {
        token = value;
      });
      FirebaseFirestore.instance
          .collection("users")
          .doc(users.FirebaseAuth.instance.currentUser!.uid)
          .update({"fcm": value});
    });
  }

  abonnenoeud() {
    FirebaseFirestore.instance
        .collection('abonne')
        .where("iduser", isEqualTo: user!.uid)
        .get()
        .then((querySnapshot) {
      setState(() {
        _abonnenoeud = querySnapshot.docs;
      });
      for (var vu in _abonnenoeud) {
        print(vu);
      }
      print(_abonnenoeud.first);
    });
  }

  getinfoapp() {
    FirebaseFirestore.instance.collection('appinfo').get().then((valueinfo) {
      if (valueinfo.docs.first["version"] != versionapp) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return Dialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                backgroundColor: Colors.black.withBlue(20),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                        child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)),
                            child: Image.asset(
                              "assets/maj2.png",
                              fit: BoxFit.cover,
                            )),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'Mise a jour V2 disponible !',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Text(
                              'Nouveautés',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              majtext,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _launchUniversalLinkIos(Uri.parse(
                                    "https://play.google.com/store/apps/details?id=com.amj.smatch.amj1"));
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade900,
                                  fixedSize: Size(
                                      MediaQuery.of(context).size.width, 70),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5))),
                              child: const Text(
                                "METTRE À JOUR",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
      }
    });
  }

  allnoeuds() {
    FirebaseFirestore.instance
        .collection('noeud')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        allnoeud = querySnapshot.docs;
      });
    });
  }

  Future<void> getNews() async {
    String apiKey = "174e81982e404fd1ad6020f187f7a8bc";
    String url =
        "https://newsapi.org/v2/top-headlines?category=technology&langage=fr&apiKey=174e81982e404fd1ad6020f187f7a8bc";
    // String url =
    //     "http://newsapi.org/v2/top-headlines?country=us&language=fr&apiKey=${apiKey}";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);

    if (jsonData['status'] == "ok") {
      jsonData["articles"].forEach((element) {
        if (element['urlToImage'] != null && element['description'] != null) {
          print(element["title"]);

          FirebaseFirestore.instance
              .collection("actualite")
              .get()
              .then(((QuerySnapshot querysnap) {
            if (querysnap.docs.isEmpty) {
              FirebaseFirestore.instance.collection("actualite").add({
                "title": element['title'],
                "author": element['author'],
                "description": element['description'],
                "urlToImage": element['urlToImage'],
                "publshedAt": DateTime.parse(element['publishedAt']),
                "content": element["content"],
                "articleUrl": element["url"],
              });
            } else {
              for (var _actualie in querysnap.docs) {
                if (_actualie['title'] != element['title']) {
                  FirebaseFirestore.instance.collection("actualite").add({
                    "title": element['title'],
                    "author": element['author'],
                    "description": element['description'],
                    "urlToImage": element['urlToImage'],
                    "publshedAt": DateTime.parse(element['publishedAt']),
                    "content": element["content"],
                    "articleUrl": element["url"],
                  });
                }
              }
            }
          }));
        }
      });
    } else {}
  }

  getinfouser() {
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser",
            isEqualTo: users.FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      print(querySnapshot.docs.first["addscompte"]);
      if (querySnapshot.docs.first["addscompte"] == 0) {
        Get.off(() => const Newuser());
      } else {
        setState(() {
          nomusers.add(querySnapshot.docs.first['nom']);
          ready = querySnapshot.docs.first['ready'];
          nomuser = querySnapshot.docs.first['nom'];
          avataruser = querySnapshot.docs.first['avatar'];
          notification = querySnapshot.docs.first["notification"];
        });
      }
    });
  }

  userbranches() {
    FirebaseFirestore.instance
        .collection('userbranche')
        .where("iduser",
            isEqualTo: users.FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        _myuserbranche = querySnapshot.docs;
      });
    });
  }

  Future<void> _launchUniversalLinkIos(Uri url) async {
    final bool nativeAppLaunchSucceeded = await launchUrl(
      url,
      mode: LaunchMode.externalNonBrowserApplication,
    );
    if (!nativeAppLaunchSucceeded) {
      await launchUrl(
        url,
        mode: LaunchMode.inAppWebView,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.of(context).size.height;
    DateTime lastTimeBackbuttonWasClicked = DateTime.now();
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.black.withBlue(25),
        appBar: AppBar(
          backgroundColor: Colors.black.withBlue(25),
          title: Text(
            'Smatch',
            style: GoogleFonts.poppins(fontSize: 30),
          ),
          leading: const Menuwidget(),
          elevation: 0,
          centerTitle: true,
          actions: [
            const SizedBox(
              width: 10,
            ),
            // Row(
            //   children: <Widget>[
            //     IconButton(
            //         padding: const EdgeInsets.all(6),
            //         onPressed: () {
            //           Get.to(() => const Notificationhome());
            //         },
            //         icon: const Icon(Iconsax.notification)),
            //     (notification != 0)
            //         ? Badge(
            //             badgeColor: Colors.redAccent,
            //             badgeContent: Text(
            //               "$notification",
            //               style: const TextStyle(color: Colors.white),
            //             ),
            //           )
            //         : const SizedBox()
            //   ],
            // ),
            const SizedBox(
              width: 10,
            ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
                child: Container(
                    padding: const EdgeInsets.all(5),
                    height: screenheight,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Colors.blue.shade800,
                          Colors.orange.shade900,
                        ],
                      ),
                    ),
                    child: Obx(() => (sendrequ.nomnoeuds.isEmpty)
                        ? actualite()
                        : listbranche()))),
            // menu sur le coté

            Obx(() => (requ.displaynoeud.isTrue)
                ? Container(
                    width: 70,
                    padding: EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(
                          height: 5,
                        ),
                        Expanded(
                          child: listnoeud(),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            creatnoeud();
                          },
                          child: DottedBorder(
                            color: Colors.white,
                            dashPattern: const [4, 3],
                            strokeWidth: 2,
                            strokeCap: StrokeCap.round,
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(50),
                            child: Container(
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                  color: Colors.white),
                              height: 50,
                              width: 50,
                              child: const Icon(
                                Iconsax.add,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            requ.displaynoeud.value = false;
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: const BoxDecoration(
                                color: Colors.red,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50))),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ))
                : const SizedBox()),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Obx(() => (requ.displaynoeud.isFalse)
            ? FloatingActionButton(
                backgroundColor: Colors.orangeAccent,
                onPressed: () {
                  requ.displaynoeud.value = true;
                },
                child: const Icon(Iconsax.more),
              )
            : const SizedBox()),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      ),
      onWillPop: () async {
        if (DateTime.now().difference(lastTimeBackbuttonWasClicked) >=
            const Duration(seconds: 2)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(
                "Appuyez à nouveau sur le bouton de retour pour quitter l'application.",
                style: TextStyle(fontSize: 18),
              ),
              duration: Duration(seconds: 5),
            ),
          );

          lastTimeBackbuttonWasClicked = DateTime.now();
          return false;
        } else {
          return true;
        }
      },
    );
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
    sendrequ.novalu();
  }

  creatnoeud() {
    showModalBottomSheet(
        backgroundColor: Colors.black.withBlue(25),
        enableDrag: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        context: context,
        builder: (BuildContext context) {
          return Noeudcreat();
        });
  }

  Widget listnoeud() {
    return (_abonnenoeud.isEmpty)
        ?
        // afficher chargement de logo
        ListView.builder(
            reverse: true,
            shrinkWrap: true,
            itemCount: 5,
            itemBuilder: (BuildContext, index) {
              return CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white.withOpacity(0.3),
              );
            })
        : StreamBuilder(
            stream: _abonnenoeuds,
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> abonnenoeud) {
              if (!abonnenoeud.hasData) {
                return Container();
              } else if (abonnenoeud.connectionState ==
                  ConnectionState.waiting) {
                return Text(abonnenoeud.error.toString());
              }
              return ListView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  itemCount: abonnenoeud.data!.docs.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50))),
                      height: 60,
                      width: 60,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.only(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          for (var allnoeus in allnoeud)
                            if (abonnenoeud.data!.docs[index]["idcompte"] ==
                                allnoeus['idcompte'])
                              GestureDetector(
                                  onTap: () {
                                    print(abonnenoeud.data!.docs[index].id);
                                    FirebaseFirestore.instance
                                        .collection('abonne')
                                        .doc(abonnenoeud.data!.docs[index].id)
                                        .update({"message": 0});
                                    if (abonnenoeud.data!.docs[index]["type"] ==
                                        "noeud") {
                                      sendrequ.getnoeud(
                                          abonnenoeud.data!.docs[index]
                                              ['idcompte'],
                                          abonnenoeud.data!.docs[index]['nom'],
                                          abonnenoeud.data!.docs[index]
                                              ['statut']);
                                      setState(() {
                                        _brancheStream = FirebaseFirestore
                                            .instance
                                            .collection('branche')
                                            .where("id_noeud",
                                                isEqualTo: abonnenoeud.data!
                                                    .docs[index]['idcompte'])
                                            .orderBy("range", descending: true)
                                            .snapshots();
                                      });
                                    } else if (abonnenoeud.data!.docs[index]
                                            ["type"] ==
                                        "boutique") {
                                      var result = allnoeud
                                          .where((user) => user["idcompte"]
                                              .contains(abonnenoeud.data!
                                                  .docs[index]["idcompte"]))
                                          .toList();
                                      print("shop ${result.first["design"]}");
                                      Get.toNamed("/${result.first["design"]}",
                                          arguments: [
                                            {
                                              "idshop": abonnenoeud
                                                  .data!.docs[index]["idcompte"]
                                            },
                                            {"nomshop": result.first["nom"]},
                                          ]);
                                    } else if (abonnenoeud.data!.docs[index]
                                            ["type"] ==
                                        "Moment") {
                                      FirebaseFirestore.instance
                                          .collection('noeud')
                                          .where('idcompte',
                                              isEqualTo: abonnenoeud.data!
                                                  .docs[index]["idcompte"])
                                          .get()
                                          .then((QuerySnapshot value) {
                                        if (value.docs.first["lienvideo"] !=
                                            '') {
                                          var result = allnoeud
                                              .where((user) => user["idcompte"]
                                                  .contains(abonnenoeud.data!
                                                      .docs[index]["idcompte"]))
                                              .toList();
                                          Get.toNamed("/vlog", arguments: [
                                            {
                                              "idchaine": abonnenoeud
                                                  .data!.docs[index]["idcompte"]
                                            },
                                            {
                                              "nomchaine": abonnenoeud
                                                  .data!.docs[index]["nom"]
                                            },
                                            {
                                              "logo": abonnenoeud
                                                  .data!.docs[index]['logo']
                                            },
                                            {
                                              "vignette":
                                                  result.first['vignette']
                                            },
                                            {"titre": result.first['titre']}
                                          ]);
                                        } else {
                                          requ.message("Echec",
                                              "Vous ne ppouvez pas avoir accès au space par manque de configuration");
                                        }
                                      });
                                    }
                                  },
                                  child: Badge(
                                    position:
                                        const BadgePosition(end: 1, top: 2),
                                    showBadge: (abonnenoeud.data!.docs[index]
                                                ["message"] ==
                                            1)
                                        ? true
                                        : false,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(50))),
                                      height: 60,
                                      width: 60,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(50)),
                                        child: CachedNetworkImage(
                                          imageUrl: allnoeus["logo"],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ))
                        ],
                      ),
                    );
                  });
            },
          );
  }

  Widget actualite() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          const Center(
            child: Text(
              'Actualités',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          StreamBuilder(
              stream: _actualite,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> actualite) {
                if (!actualite.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (actualite.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: actualite.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              Get.toNamed("/readactualite", arguments: [
                                {
                                  "url": actualite.data!.docs[index]
                                      ['articleUrl']
                                },
                                {"title": actualite.data!.docs[index]['title']}
                              ]);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  color: Colors.white.withOpacity(0.2)),
                              margin:
                                  const EdgeInsets.only(left: 10, right: 10),
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft: Radius.circular(6),
                                                    topRight:
                                                        Radius.circular(6)),
                                            child: CachedNetworkImage(
                                              imageUrl: actualite.data!
                                                  .docs[index]["urlToImage"],
                                              height: 250,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              fit: BoxFit.cover,
                                            )),
                                        if (actualite.data!.docs[index]
                                                ["author"] !=
                                            null)
                                          Positioned(
                                              top: 10,
                                              right: 10,
                                              child: Chip(
                                                label: Text(
                                                  actualite.data!.docs[index]
                                                      ["author"],
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                                backgroundColor:
                                                    Colors.black.withBlue(10),
                                              )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, bottom: 10),
                                    child: Column(
                                      children: [
                                        Text(
                                          actualite.data!.docs[index]["title"],
                                          maxLines: 2,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          actualite.data!.docs[index]
                                              ["description"],
                                          maxLines: 2,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          )
                        ],
                      );
                    });
              }),
        ],
      ),
    );
  }

  Widget listbranche() {
    return // affichages des branches s'il ya un choix de noeud
        Padding(
            padding: const EdgeInsets.only(
              left: 5,
              right: 5,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        sendrequ.nomnoeuds.value,
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                    ),
                    Obx(() => (sendrequ.isadmins.isTrue)
                        ? IconButton(
                            onPressed: () {
                              optionoeud();
                            },
                            icon: const Icon(
                              Iconsax.more,
                              size: 30,
                              color: Colors.white,
                            ))
                        : Container()),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                // Stories(),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(5),
                            child: ActionChip(
                              onPressed: () {
                                setState(() {
                                  print(sendrequ.idnoeuds.value);
                                  _brancheStream = FirebaseFirestore.instance
                                      .collection('branche')
                                      .where("id_noeud",
                                          isEqualTo: sendrequ.idnoeuds.value)
                                      .where("typebranche", isEqualTo: "inbox")
                                      .orderBy("range", descending: true)
                                      .snapshots();
                                });
                              },
                              backgroundColor: Colors.black.withBlue(20),
                              disabledColor: Colors.black.withBlue(20),
                              padding: const EdgeInsets.all(10),
                              labelStyle: const TextStyle(color: Colors.white),
                              label: const Text(
                                'Inbox',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              avatar: const Icon(
                                Iconsax.message,
                                color: Colors.white,
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: ActionChip(
                            onPressed: () {
                              setState(() {
                                _brancheStream = FirebaseFirestore.instance
                                    .collection('branche')
                                    .where("id_noeud",
                                        isEqualTo: sendrequ.idnoeuds.value)
                                    .where("typebranche", isEqualTo: "social")
                                    .orderBy("range", descending: true)
                                    .snapshots();
                              });
                            },
                            backgroundColor: Colors.black.withBlue(20),
                            disabledColor: Colors.black.withBlue(20),
                            padding: const EdgeInsets.all(10),
                            labelStyle: const TextStyle(color: Colors.white),
                            label: const Text(
                              'Social',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            avatar: const Icon(
                              Iconsax.activity,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(5),
                            child: ActionChip(
                              onPressed: () {
                                setState(() {
                                  _brancheStream = FirebaseFirestore.instance
                                      .collection('branche')
                                      .where("id_noeud",
                                          isEqualTo: sendrequ.idnoeuds.value)
                                      .where("typebranche", isEqualTo: "video")
                                      .orderBy("range", descending: true)
                                      .snapshots();
                                });
                              },
                              backgroundColor: Colors.black.withBlue(20),
                              disabledColor: Colors.black.withBlue(20),
                              padding: const EdgeInsets.all(10),
                              labelStyle: TextStyle(color: Colors.white),
                              label: const Text(
                                'Video',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              avatar: const Icon(
                                Iconsax.video,
                                color: Colors.white,
                              ),
                            ))
                      ],
                    )),

                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: _brancheStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                FirebaseFirestore.instance
                                    .collection('userbranche')
                                    .where('iduser', isEqualTo: userid)
                                    .where("idbranche",
                                        isEqualTo:
                                            snapshot.data!.docs[index].id)
                                    .get()
                                    .then((value) {
                                  if (value.docs.isEmpty) {
                                    if (snapshot.data!.docs[index]["offre"] ==
                                        "gratuit") {
                                      if (snapshot.data!.docs[index]
                                              ["statut"] ==
                                          "public") {
                                        gobranche(
                                            snapshot.data!.docs[index]
                                                ["description"],
                                            snapshot.data!.docs[index].id,
                                            snapshot.data!.docs[index]["nom"],
                                            snapshot.data!.docs[index]
                                                ["ismessage"],
                                            snapshot.data!.docs[index]
                                                ["isfile"],
                                            snapshot.data!.docs[index]
                                                ["isimage"],
                                            snapshot.data!.docs[index]
                                                ["ismention"],
                                            snapshot.data!.docs[index]
                                                ["ismusic"],
                                            snapshot.data!.docs[index]["isnv"],
                                            snapshot.data!.docs[index]
                                                ["isreponse"],
                                            snapshot.data!.docs[index]
                                                ["isvideo"]);
                                      } else {
                                        // envoyer une demande d'integration
                                        sendinvitation(
                                            snapshot.data!.docs[index].id,
                                            snapshot.data!.docs[index]["nom"]);
                                      }
                                    } else if (snapshot.data!.docs[index]
                                            ["offre"] ==
                                        "abonnement") {
                                      byabonnement(
                                          snapshot.data!.docs[index]["nom"],
                                          snapshot.data!.docs[index]["prix"],
                                          snapshot.data!.docs[index].id,
                                          snapshot.data!.docs[index]["offre"]);
                                    }
                                  } else {
                                    FirebaseFirestore.instance
                                        .collection('userbranche')
                                        .where('iduser', isEqualTo: userid)
                                        .where("idbranche",
                                            isEqualTo:
                                                snapshot.data!.docs[index].id)
                                        .get()
                                        .then((value) {
                                      for (var element in value.docs) {
                                        if (snapshot.data!.docs[index]
                                                ["typebranche"] ==
                                            "inbox") {
                                          Get.toNamed("/messagebrache/",
                                              arguments: [
                                                {
                                                  "idbranche": snapshot
                                                      .data!.docs[index].id
                                                },
                                                {
                                                  "nombranche": snapshot
                                                      .data!.docs[index]['nom']
                                                },
                                                {
                                                  "idcreat": snapshot.data!
                                                      .docs[index]['idcreat']
                                                },
                                                {"admin": element['statut']},
                                                {"token": token}
                                              ]);
                                        } else if (snapshot.data!.docs[index]
                                                ["typebranche"] ==
                                            "social") {
                                          print(snapshot.data!.docs[index].id);
                                          Get.toNamed("/social/", arguments: [
                                            {
                                              "idbranche":
                                                  snapshot.data!.docs[index].id
                                            },
                                            {
                                              "nombranche": snapshot
                                                  .data!.docs[index]['nom']
                                            },
                                            {
                                              "idcreat": snapshot
                                                  .data!.docs[index]['idcreat']
                                            },
                                            {"admin": element['statut']},
                                            {
                                              "affiche": snapshot
                                                  .data!.docs[index]['affiche']
                                            },
                                            {
                                              "publi": snapshot
                                                  .data!.docs[index]['public']
                                            },
                                          ]);
                                        } else if (snapshot.data!.docs[index]
                                                ["typebranche"] ==
                                            "video") {
                                          print(snapshot.data!.docs[index]
                                              ['pubic']);
                                          Get.toNamed("/videofeed/",
                                              arguments: [
                                                {
                                                  "idbranche": snapshot
                                                      .data!.docs[index].id
                                                },
                                                {
                                                  "nombranche": snapshot
                                                      .data!.docs[index]['nom']
                                                },
                                                {
                                                  "idcreat": snapshot.data!
                                                      .docs[index]['idcreat']
                                                },
                                                {"admin": element['statut']},
                                                {"token": token},
                                                {
                                                  "affiche": snapshot.data!
                                                      .docs[index]['affiche']
                                                },
                                                {
                                                  "publi": snapshot.data!
                                                      .docs[index]['pubic']
                                                },
                                              ]);
                                        }
                                      }
                                    });

                                    FirebaseFirestore.instance
                                        .collection('userbranche')
                                        .where("idbranche",
                                            isEqualTo:
                                                snapshot.data!.docs[index].id)
                                        .where("iduser", isEqualTo: userid)
                                        .get()
                                        .then((QuerySnapshot querySnapshot) {
                                      for (var doc in querySnapshot.docs) {
                                        userbranche
                                            .doc(doc.id)
                                            .update({"nbremsg": 0});
                                      }
                                    });
                                  }
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    if (snapshot.data!.docs[index]["affiche"] !=
                                        "")
                                      ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        child: Container(
                                          height: 200,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.white,
                                          child: CachedNetworkImage(
                                            imageUrl: snapshot.data!.docs[index]
                                                ["affiche"],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Flexible(
                                                child: Text(
                                              "@ ${snapshot.data!.docs[index]["nom"]}",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            )),
                                            (snapshot.data!.docs[index]
                                                            ["statut"] ==
                                                        "public" &&
                                                    snapshot.data!.docs[index]
                                                            ["offre"] ==
                                                        "gratuit")
                                                ? const Icon(
                                                    IconlyLight.unlock,
                                                    size: 30,
                                                    color: Colors.white,
                                                  )
                                                : const Icon(
                                                    IconlyLight.lock,
                                                    size: 30,
                                                    color: Colors.white,
                                                  ),
                                          ],
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: DetectableText(
                                        trimLength: 150,
                                        trimExpandedText: "montrer moins",
                                        trimCollapsedText: "montrer plus",
                                        text: snapshot.data!.docs[index]
                                            ["description"],
                                        detectionRegExp: RegExp(
                                          "(?!\\n)(?:^|\\s)([#@]([$detectionContentLetters]+))|$urlRegexContent",
                                          multiLine: true,
                                        ),
                                        detectedStyle: const TextStyle(
                                            color: Colors.black),
                                        basicStyle: const TextStyle(
                                            color: Colors.white),
                                        onTap: (tappedText) {
                                          Get.toNamed("/checklien", arguments: [
                                            {"url": tappedText}
                                          ]);
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Stackuser(
                                          idbranche:
                                              snapshot.data!.docs[index].id),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Chip(
                                                    backgroundColor: Colors
                                                        .black
                                                        .withBlue(20),
                                                    label: Text(
                                                      "${snapshot.data!.docs[index]["nbreuser"]}",
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.white),
                                                    ),
                                                    avatar: const Icon(
                                                      Iconsax.user,
                                                      size: 28,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Obx(() => (sendrequ.isadmins
                                                              .isTrue &&
                                                          snapshot.data!.docs[
                                                                      index]
                                                                  ["statut"] ==
                                                              "prive")
                                                      ? Chip(
                                                          backgroundColor:
                                                              Colors.black
                                                                  .withBlue(20),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          avatar: const Icon(
                                                            IconlyLight
                                                                .activity,
                                                            color: Colors.white,
                                                          ),
                                                          label: Text(
                                                            "${snapshot.data!.docs[index]["invitation"]}",
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16),
                                                          ))
                                                      : const SizedBox())
                                                ],
                                              ),
                                              if (snapshot.data!.docs[index]
                                                      ["typebranche"] ==
                                                  "video")
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withBlue(20),
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  50))),
                                                  child: const Icon(
                                                    Iconsax.video,
                                                    size: 28,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              if (snapshot.data!.docs[index]
                                                      ["typebranche"] ==
                                                  "social")
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withBlue(20),
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  50))),
                                                  child: const Icon(
                                                    Iconsax.activity,
                                                    size: 28,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              if (snapshot.data!.docs[index]
                                                      ["typebranche"] ==
                                                  "inbox")
                                                StreamBuilder(
                                                    stream: FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                            "userbranche")
                                                        .where("iduser",
                                                            isEqualTo: userid)
                                                        .where("idbranche",
                                                            isEqualTo: snapshot
                                                                .data!
                                                                .docs[index]
                                                                .id)
                                                        .snapshots(),
                                                    builder: (BuildContext
                                                            contex,
                                                        AsyncSnapshot<
                                                                QuerySnapshot>
                                                            datanbreMessage) {
                                                      if (!datanbreMessage
                                                          .hasData) {
                                                        return Container();
                                                      }
                                                      return (datanbreMessage
                                                              .data!
                                                              .docs
                                                              .isEmpty)
                                                          ? const Chip(
                                                              label: Text(
                                                                '0',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 20,
                                                                ),
                                                              ),
                                                              avatar: Icon(
                                                                Iconsax.message,
                                                                size: 28,
                                                              ),
                                                            )
                                                          : Chip(
                                                              backgroundColor:
                                                                  Colors.black
                                                                      .withBlue(
                                                                          20),
                                                              label: Text(
                                                                "${datanbreMessage.data!.docs.first["nbremsg"]}",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              avatar:
                                                                  const Icon(
                                                                Iconsax.message,
                                                                size: 28,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            );
                                                    }),
                                            ],
                                          )
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
                )
              ],
            ));
  }

  gobranche(
    description,
    idbranche,
    nombranche,
    ismessage,
    isfile,
    isimage,
    ismention,
    ismusic,
    isnv,
    isreponse,
    isvideo,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation d'adhésion"),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  "En rejoignant cette branche, vous acceptez de recevoir les notifications, de respecter les règles et conditions définies par l'administrateur.",
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  print(idbranche);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Annuler',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                )),
            const SizedBox(
              width: 20,
            ),
            TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.orange.shade900)),
              child: const Text(
                'Oui accéder',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                DateTime now = DateTime.now();
                String dateformat =
                    DateFormat("yyyy-MM-dd - kk:mm").format(now);
                userbranche.add({
                  "iduser": userid,
                  "idbranche": idbranche,
                  "date": dateformat,
                  "statut": 0,
                  "avatar": avataruser,
                  "nbremsg": 0,
                  "nomuser": nomuser,
                });
                branche
                    .doc(idbranche)
                    .update({"nbreuser": FieldValue.increment(1)});
                FirebaseFirestore.instance
                    .collection('fcm')
                    .add({"fcm": token, "idbranche": idbranche});
                Navigator.of(context).pop();

                requ.message(
                    "Success", "Vous pouvez accéder à la branche maintenant.");
              },
            ),
          ],
        );
      },
    );
  }

  sendinvitation(idbranche, nombranche) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation d'adhésion"),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  "Cette branche est accessible par demande d'adhésion, Voulez vous envoyer une demande d'adhésion ?",
                ),
                SizedBox(
                  height: 20,
                ),
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
            const SizedBox(
              width: 20,
            ),
            TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.orange.shade900)),
              child: const Text('Oui envoyer',
                  style: TextStyle(color: Colors.white)),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection("invitation")
                    .where('iduser', isEqualTo: userid)
                    .where('idbranche', isEqualTo: idbranche)
                    .get()
                    .then((QuerySnapshot value) {
                  if (value.docs.isEmpty) {
                    requ.message("Echec",
                        "Vous avez déjà envoyé une demande d'intégration, nous vous prions de patienter que les administrateurs traitent votre demande.");
                  } else {
                    DateTime now = DateTime.now();
                    String dateformat =
                        DateFormat("yyyy-MM-dd - kk:mm").format(now);
                    FirebaseFirestore.instance.collection("invitation").add({
                      "iduser": userid,
                      "date": dateformat,
                      "range": DateTime.now().millisecondsSinceEpoch,
                      "nomuser": nomuser,
                      "idbranche": idbranche,
                      "avatar": avataruser,
                      "type": "branche",
                      "nombranche": nombranche,
                      "idnoeud": sendrequ.idnoeuds.value,
                    });
                    FirebaseFirestore.instance
                        .collection("branche")
                        .doc(idbranche)
                        .update({"invitation": FieldValue.increment(1)});
                    requ.message("Sucess",
                        "Votre demande d'adhésion à la branche a été envoyée avec succès..");
                  }
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  byabonnement(nombranches, prix, idbranche, offre) {
    showModalBottomSheet(
        enableDrag: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                decoration: BoxDecoration(
                    color: Colors.black.withBlue(25),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0))),
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(50),
                            )),
                        width: 50,
                        height: 5,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(nombranches,
                          maxLines: 1,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20)),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "  Cette branche est accessible par un abonnement mensuel, vous allez être débité de $prix FCFA, afin d'y accéder. ",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 17),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const ListTile(
                        title: Text(
                          'Vous acceptez de respecter les conditions et règles de la branche.',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ListView(
                        reverse: true,
                        shrinkWrap: true,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                    fixedSize: const Size(100, 50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                child: const Text('Annuler'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  print(idbranche);
                                  FirebaseFirestore.instance
                                      .collection("users")
                                      .where("iduser", isEqualTo: userid)
                                      .get()
                                      .then((QuerySnapshot value) {
                                    byBranche(
                                      prix,
                                      value.docs.first["wallet"],
                                      sendrequ.idnoeuds.value,
                                      idbranche,
                                      offre,
                                      avataruser,
                                      nomuser,
                                      nombranches,
                                    );
                                  });
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade900,
                                    fixedSize: const Size(150, 50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                child: const Text("Je m'abonne"),
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  byBranche(int prix, wallet, idcompte, idbranche, offre, avatar, nomuser,
      nomdelabranche) {
    try {
      print(prix);
      print(wallet);
      print(offre);
      print(idcompte);
      print(avatar);
      print(nomuser);
      // int newprix = int.parse(prix);
      int calcule = (wallet - prix);
      print(calcule);
      if (prix > wallet) {
        message("Echec",
            "Votre solde est insuffisant, nous vous prions de recharger votre wallet.");
      } else {
        FirebaseFirestore.instance.collection("noeud").doc(idcompte).update({
          'wallet': FieldValue.increment(prix),
        });
        FirebaseFirestore.instance
            .collection("users")
            .doc(userid)
            .update({'wallet': calcule});
        branche.doc(idbranche).update({
          'nbreuser': FieldValue.increment(1),
        });
        DateTime now = DateTime.now();
        String dateformat = DateFormat("yyyy-MM-dd - kk:mm").format(now);
        var jour = DateFormat("dd").format(now);
        var djour = int.parse(jour) - 1;
        var mois = DateFormat("MM").format(now);
        userbranche.add({
          "offre": offre,
          "iduser": userid,
          "idbranche": idbranche,
          "date": dateformat,
          "statut": 0,
          "avatar": avatar,
          "nbremsg": 0,
          "nomuser": nomuser,
          "expirejour": djour,
          "expiremois": mois
        });
        FirebaseFirestore.instance.collection("payment").add({
          "date": dateformat,
          "iduser": userid,
          "idcompte": idcompte,
          "nom": nomdelabranche,
          "montant": prix,
          "type": "achat",
          "statut": "Effectue",
          "token": "",
          "lienpayement": "",
          "range": DateTime.now().millisecondsSinceEpoch
        });
        FirebaseFirestore.instance
            .collection('fcm')
            .add({"fcm": token, "idbranche": idbranche});
      }
      requ.message("success", "Vous avez été ajouté à la branche avec succès.");
    } catch (e) {
      message("Echec",
          "Quelque chose, c'est mal passé, nous vous prions de ressayer");
    }
  }

  message(type, message) {
    if (type == "Echec") {
      Get.snackbar(
          type, // title
          message, // message
          icon: const Icon(
            Iconsax.danger,
            color: Colors.white,
          ),
          shouldIconPulse: true,
          colorText: Colors.white,
          barBlur: 20,
          isDismissible: true,
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red);
    } else {
      Get.snackbar(
          type, // title
          message, // message
          shouldIconPulse: true,
          colorText: Colors.white,
          barBlur: 20,
          isDismissible: true,
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.greenAccent);
    }
  }

  viewinvitation(idcompte) {
    showModalBottomSheet(
        backgroundColor: Colors.black.withBlue(25),
        enableDrag: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                margin: const EdgeInsets.all(5),
                height: MediaQuery.of(context).size.height / 1.2,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      height: 5,
                      width: 50,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Demande d'adhésion",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("invitation")
                            .where("idcompte", isEqualTo: idcompte)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> invitation) {
                          if (!invitation.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (invitation.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return (invitation.data!.docs.isEmpty)
                              ? const Text(
                                  "Vous n'avez pas demande d'adhésion",
                                  style: TextStyle(color: Colors.white),
                                )
                              : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: invitation.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.all(5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            invitation.data!.docs[index]
                                                ["nomuser"],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 19),
                                          ),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  refuser(invitation
                                                      .data!.docs[index].id);
                                                },
                                                child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                50)),
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  accepet(
                                                      invitation
                                                              .data!.docs[index]
                                                          ["iduser"],
                                                      invitation
                                                              .data!.docs[index]
                                                          ["idcompte"],
                                                      invitation.data!
                                                          .docs[index]["nom"],
                                                      invitation.data!
                                                          .docs[index]["logo"],
                                                      invitation.data!
                                                          .docs[index]["offre"],
                                                      invitation.data!
                                                          .docs[index]["type"],
                                                      invitation
                                                              .data!.docs[index]
                                                          ["nomuser"],
                                                      invitation
                                                              .data!.docs[index]
                                                          ["statut"],
                                                      invitation.data!
                                                          .docs[index].id);
                                                },
                                                child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                50)),
                                                  ),
                                                  child: const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  });
                        }),
                  ],
                ),
              );
            },
          );
        });
  }

  refuser(iddemande) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  "Êtes-vous sûr de refuser la demande d'adhésion ?",
                  textAlign: TextAlign.justify,
                )
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
            const SizedBox(
              width: 20,
            ),
            TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.orange.shade900)),
              child: const Text('Oui Refuser'),
              onPressed: () {
                Navigator.of(context).pop();
                FirebaseFirestore.instance
                    .collection("invitation")
                    .doc(iddemande)
                    .delete();
                FirebaseFirestore.instance
                    .collection("noeud")
                    .doc(
                      sendrequ.idnoeuds.value,
                    )
                    .update({"notification": FieldValue.increment(-1)});
                requ.message("sucess", "Adhésion refusé avec succès");
              },
            ),
          ],
        );
      },
    );
  }

  accepet(
      iduser, idcompte, nom, logo, offre, type, nomuser, statut, iddemande) {
    DateTime now = DateTime.now();
    String dateformat = DateFormat("yyyy-MM-dd - kk:mm").format(now);
    FirebaseFirestore.instance.collection("abonne").add({
      "iduser": iduser,
      "idcompte": idcompte,
      "nom": nom,
      "logo": logo,
      "date": dateformat,
      "range": DateTime.now().millisecondsSinceEpoch,
      "offre": offre,
      "statut": statut,
      "type": type,
      "nomuser": nomuser
    }).then((value) {
      FirebaseFirestore.instance
          .collection("invitation")
          .doc(iddemande)
          .delete();
    });
    FirebaseFirestore.instance.collection("notification").add({
      "idcompte": idcompte,
      "date": dateformat,
      "iduser": iduser,
      "type": "noeud",
      "nom": sendrequ.nomnoeuds.value,
    });
    FirebaseFirestore.instance
        .collection("noeud")
        .doc(
          sendrequ.idnoeuds.value,
        )
        .update({"notification": FieldValue.increment(-1)});
    requ.message("sucess", "Adhésion acceptée avec succès.");
  }

  addbranche() {
    showMaterialModalBottomSheet(
        backgroundColor: Colors.black.withBlue(25),
        expand: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SafeArea(
                child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.only(left: 20, right: 20),
                decoration: BoxDecoration(
                    color: Colors.black.withBlue(25),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                              height: 5,
                              width: 50,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)))),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text("Création de branche",
                              style: GoogleFonts.poppins(
                                  fontSize: 20, color: Colors.white)),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          children: [
                            Row(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    selectimage();
                                  },
                                  child: Obx(() => CircleAvatar(
                                        radius: 40,
                                        backgroundImage: (requ.affiche.isEmpty)
                                            ? null
                                            : NetworkImage(
                                                requ.affiche.value,
                                              ),
                                      )),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: TextFormField(
                                  style: const TextStyle(color: Colors.white),
                                  controller: _nombrancheController,
                                  decoration: InputDecoration(
                                    fillColor: Colors.white.withOpacity(0.2),
                                    filled: true,
                                    labelStyle:
                                        const TextStyle(color: Colors.white),
                                    label: const Text("Nom de la branche"),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ))
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: _descriptionController,
                              minLines: 2,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                fillColor: Colors.white.withOpacity(0.2),
                                filled: true,
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                label: const Text('Description de la branche'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                          ],
                        ),
                        if (offre == "abonnement")
                          Column(
                            children: <Widget>[
                              TextFormField(
                                controller: _montantcontroller,
                                keyboardType: TextInputType.multiline,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  fillColor: Colors.white.withOpacity(0.2),
                                  filled: true,
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
                                  label: const Text('Prix abonnement'),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Offre",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 20),
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ChoiceChip(
                                selectedColor: Colors.greenAccent,
                                onSelected: (value) {
                                  offre = "gratuit";
                                  setState(
                                    () {
                                      offre = "gratuit";
                                    },
                                  );
                                },
                                padding: const EdgeInsets.all(10),
                                label: const Text('Gratuite'),
                                selected: (offre == "gratuit") ? true : false),
                            const SizedBox(
                              height: 20,
                            ),
                            ChoiceChip(
                                selectedColor: Colors.greenAccent,
                                onSelected: (value) {
                                  setState(
                                    () {
                                      offre = "abonnement";
                                    },
                                  );
                                },
                                padding: const EdgeInsets.all(10),
                                label: const Text('Abonnement'),
                                selected:
                                    (offre == "abonnement") ? true : false),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Type de branche",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 20),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                            height: 120,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 120,
                                            width: 150,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Icon(
                                                  Iconsax.message,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  "Inbox",
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 20,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                          (typebranche == "inbox")
                                              ? const Positioned(
                                                  top: 1,
                                                  right: 1,
                                                  child: Icon(Icons.check,
                                                      color: Colors.green,
                                                      size: 30),
                                                )
                                              : Container()
                                        ],
                                      ),
                                      onTap: () {
                                        setState(() {
                                          typebranche = "inbox";
                                        });
                                      },
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    GestureDetector(
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 120,
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Icon(
                                                  Iconsax.activity,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  "Social",
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 20,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                          (typebranche == "social")
                                              ? const Positioned(
                                                  top: 1,
                                                  right: 1,
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                    size: 30,
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                      onTap: () {
                                        setState(() {
                                          typebranche = "social";
                                        });
                                      },
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    GestureDetector(
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 120,
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Icon(
                                                  Iconsax.video_circle,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  "Video",
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 20,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                          (typebranche == "video")
                                              ? const Positioned(
                                                  top: 1,
                                                  right: 1,
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                    size: 30,
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                      onTap: () {
                                        setState(() {
                                          typebranche = "video";
                                        });
                                      },
                                    )
                                  ],
                                )
                              ],
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        if (typebranche == "video" || typebranche == "social")
                          ListTile(
                            leading: Switch(
                                activeColor: Colors.greenAccent,
                                activeTrackColor: Colors.greenAccent,
                                trackColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return Colors.white;
                                  }
                                  return Colors.greenAccent;
                                }),
                                value: check,
                                onChanged: (value) {
                                  setState(() {
                                    check = value;
                                  });
                                }),
                            title: const Text(
                              'Permettre aux utilisateur de publier dans la branche',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: const Text(
                              "Tout les utilisateur pourront publier dans la branche \n Cette option n'est pas modifiable",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Statut",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 20),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              child: Stack(
                                children: [
                                  Container(
                                    height: 120,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Icon(
                                          Icons.public_rounded,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "Publique",
                                          style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  (statut == "public")
                                      ? const Positioned(
                                          top: 1,
                                          right: 1,
                                          child: Icon(Icons.check,
                                              color: Colors.green, size: 30),
                                        )
                                      : Container()
                                ],
                              ),
                              onTap: () {
                                statut = "public";
                                setState(() {
                                  statut = "public";
                                });
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              child: Stack(
                                children: [
                                  Container(
                                    height: 120,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Icon(
                                          Iconsax.security_user,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "Privé",
                                          style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  (statut == "prive")
                                      ? const Positioned(
                                          top: 1,
                                          right: 1,
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.green,
                                            size: 30,
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                              onTap: () {
                                if (offre == "abonnement") {
                                  requ.message('Echec',
                                      "Désole, vous ne pouvez pas activiter le statut privé pour une offre d'abonnement");
                                } else {
                                  setState(() {
                                    statut = "prive";
                                  });
                                }
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_nombrancheController.text.isEmpty) {
                            message("Echec",
                                "Nous vous prions de saisir le nom de la branche");
                          } else if (_descriptionController.text.isEmpty) {
                            message("Echec",
                                "Nous vous prions de saisir la description de votre branche");
                          } else if (statut.isEmpty) {
                            message("Echec",
                                "Nous vous prions de sélectionner le statut adéquat à votre branche.");
                          } else if (typebranche.isEmpty) {
                            message("Echec",
                                "Nous vous prions de sélectionner le type de branche adequat a votre utilisation.");
                          } else {
                            if (offre == "abonnement") {
                              if (_montantcontroller.text.isEmpty) {
                                requ.message("Echec",
                                    "Nous vous prions de saisir un prix pour l'abonnement.");
                              } else {
                                requ.creatbranche(
                                    _nombrancheController.text,
                                    _descriptionController.text,
                                    statut,
                                    sendrequ.idnoeuds.value,
                                    avataruser,
                                    nomuser,
                                    offre,
                                    _montantcontroller.text,
                                    token,
                                    typebranche,
                                    requ.affiche.value,
                                    check);
                                _nombrancheController.clear();
                                _descriptionController.clear();
                                _montantcontroller.clear();
                                statut = "";
                                offre = "";

                                requ.message(
                                    "Success", "Branche ajouté avec succès");
                                Navigator.of(context).pop();
                              }
                            } else {
                              requ.creatbranche(
                                  _nombrancheController.text,
                                  _descriptionController.text,
                                  statut,
                                  sendrequ.idnoeuds.value,
                                  avataruser,
                                  nomuser,
                                  offre,
                                  0,
                                  token,
                                  typebranche,
                                  requ.affiche.value,
                                  check);
                              _nombrancheController.clear();
                              _descriptionController.clear();
                              _montantcontroller.clear();
                              statut = "";
                              offre = "";
                              requ.message(
                                  "Success", "Branche ajouté avec succès");
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            fixedSize:
                                Size(MediaQuery.of(context).size.width, 70),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        child: const Text(
                          "Valider",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ));
          });
        });
  }

  // uplaod de fichier
  selectimage() async {
    setState(() {
      progress = 0;
    });
    final fila = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (fila != null) {
      try {
        String fileName = fila.name;

        UploadTask task = FirebaseStorage.instance
            .ref()
            .child("business/$fileName")
            .putFile(File(fila.path));

        task.snapshotEvents.listen((event) {
          setState(() {
            progress = ((event.bytesTransferred.toDouble() /
                        event.totalBytes.toDouble()) *
                    100)
                .roundToDouble();
          });
        });
        task.whenComplete(() => upload(fileName));
      } on FirebaseException catch (e) {}
    }
  }

  Future<void> upload(fileName) async {
    String downloadURL = await FirebaseStorage.instance
        .ref()
        .child('business/$fileName')
        .getDownloadURL();
    setState(() {
      affiche = downloadURL;
    });
    requ.affiche.value = downloadURL;
  }

  optionoeud() {
    showMaterialModalBottomSheet(
        backgroundColor: Colors.transparent,
        barrierColor: Colors.transparent,
        expand: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black.withBlue(25),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      height: 5,
                      width: 100,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      onTap: () {
                        addbranche();
                      },
                      leading: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Ajouter une branche',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        viewinvitation(sendrequ.idnoeuds.value);
                      },
                      leading: const Icon(
                        Icons.insert_invitation,
                        color: Colors.white,
                      ),
                      title: const Text('Invitation',
                          style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }
}

class Readactualite extends StatefulWidget {
  const Readactualite({Key? key}) : super(key: key);

  @override
  State<Readactualite> createState() => _ReadactualiteState();
}

class _ReadactualiteState extends State<Readactualite> {
  final GlobalKey webViewKey = GlobalKey();
  String url = Get.arguments[0]["url"];
  String title = Get.arguments[1]["title"];

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  double progress = 0;
  final urlController = TextEditingController();
  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        webViewController?.reload();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withBlue(25),
        title: Text(title),
      ),
      body: SafeArea(
          child: Column(children: <Widget>[
        Expanded(
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: Uri.parse(url)),
                initialOptions: options,
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                androidOnPermissionRequest:
                    (controller, origin, resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  var uri = navigationAction.request.url!;

                  if (![
                    "http",
                    "https",
                    "file",
                    "chrome",
                    "data",
                    "javascript",
                    "about"
                  ].contains(uri.scheme)) {
                    // if (await canLaunch(url)) {
                    //   // Launch the App
                    //   await launch(
                    //     url,
                    //   );
                    //   // and cancel the request
                    //   return NavigationActionPolicy.CANCEL;
                    // }
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStop: (controller, url) async {
                  pullToRefreshController.endRefreshing();
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onLoadError: (controller, url, code, message) {
                  pullToRefreshController.endRefreshing();
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController.endRefreshing();
                  }
                  setState(() {
                    this.progress = progress / 100;
                    urlController.text = this.url;
                  });
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print(consoleMessage);
                },
              ),
              progress < 1.0
                  ? LinearProgressIndicator(value: progress)
                  : Container(),
            ],
          ),
        ),
      ])),
    );
  }
}

class Changevalue extends GetxController {
  var idnoeuds = "".obs;
  var nomnoeuds = "".obs;
  var isadmins = false.obs;
  getnoeud(idnoeud, nomnoeud, isadmin) {
    idnoeuds.value = idnoeud;
    nomnoeuds.value = nomnoeud;
    if (isadmin == 1) {
      isadmins.value = true;
    } else {
      isadmins.value = false;
    }
  }

  novalu() {
    idnoeuds.value = "";
    print("ok cool");
  }
}
