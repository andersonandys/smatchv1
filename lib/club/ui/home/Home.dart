import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smatch/callclub/call.dart';
import 'package:smatch/callclub/conference.dart';
import 'package:smatch/club/ui/home/HomeRoomItem.dart';
import 'package:smatch/club/ui/home/HomeUpcoming.dart';
import 'package:smatch/club/ui/liveroom/LiveRoom.dart';
import 'package:smatch/club/ui/liveroom/LiveRoomMember.dart';
import 'package:smatch/club/utils/DynamicColor.dart';
import 'package:smatch/club/utils/MemojiColors.dart';
import 'package:smatch/club/widgets/SquircleIconButton.dart';
import 'package:smatch/home/tabsrequette.dart';
import 'package:smatch/msgbranche/data.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Stream<QuerySnapshot> streamcall =
      FirebaseFirestore.instance.collection("callclub").snapshots();
  String nomusers = "";
  final userid = FirebaseAuth.instance.currentUser!.uid;
  List salonlist = [];
  String avataruser = "";
  final topics = [
    "🎨 Live audio",
    "🌍 Live vidéo",
    "Conférence",
  ];
  List allsalonsearch = [];
  getinfouser() {
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        nomusers = querySnapshot.docs.first['nom'];
        avataruser = querySnapshot.docs.first['avatar'];
      });
    });
  }

  getallsalon() {
    FirebaseFirestore.instance
        .collection('callclub')
        .get()
        .then((querySnapshot) {
      setState(() {
        salonlist = querySnapshot.docs;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getinfouser();
    getallsalon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(20),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(40),
        centerTitle: false,
        title: Text("Hello $nomusers "),
        actions: [
          CircleAvatar(
            radius: 18,
            backgroundColor: MemojiColors.blue,
            backgroundImage: CachedNetworkImageProvider(avataruser),
          ),
          const SizedBox(width: 20),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                maxLines: 1,
                // controller: nomsalon,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  _runFilter(value);
                },
                decoration: InputDecoration(
                  suffixIcon: const Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(
                      Iconsax.search_normal,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.3),
                  hintText: "Recherche un salon",
                  hintStyle: const TextStyle(color: Colors.white70),
                  contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                (allsalonsearch.isEmpty)
                    ? "Salon ouvert"
                    : "Resultat pour la recherche",
                style: const TextStyle(color: Colors.white, fontSize: 25),
              ),
              const SizedBox(
                height: 10,
              ),
              if (allsalonsearch.isEmpty)
                StreamBuilder(
                  stream: streamcall,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    int length = snapshot.data!.docs.length;
                    List clublist = snapshot.data!.docs;
                    return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              FirebaseFirestore.instance
                                  .collection("callclub")
                                  .doc(snapshot.data!.docs[index].id)
                                  .update(
                                      {"nbreuser": FieldValue.increment(1)});
                              if (clublist[index]["iduser"] == userid) {
                                gosalon(clublist[index]["typesalon"], true,
                                    snapshot.data!.docs[index].id);
                              } else {
                                gosalon(clublist[index]["typesalon"], false,
                                    snapshot.data!.docs[index].id);
                              }
                            },
                            child: HomeRoomItem(
                              nomsalon: clublist[index]["nomsalon"],
                              descsalon: clublist[index]["description"],
                              nbreuser: clublist[index]["nbreuser"],
                            ),
                          );
                        });
                  },
                ),
              if (allsalonsearch.isNotEmpty)
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allsalonsearch.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          FirebaseFirestore.instance
                              .collection("callclub")
                              .doc(allsalonsearch[index].id)
                              .update({"nbreuser": FieldValue.increment(1)});
                          if (allsalonsearch[index]["iduser"] == userid) {
                            gosalon(allsalonsearch[index]["typesalon"], true,
                                allsalonsearch[index]["idsalon"]);
                          } else {
                            gosalon(allsalonsearch[index]["typesalon"], false,
                                allsalonsearch[index]["idsalon"]);
                          }
                        },
                        child: HomeRoomItem(
                          nomsalon: allsalonsearch[index]["nomsalon"],
                          descsalon: allsalonsearch[index]["description"],
                          nbreuser: allsalonsearch[index]["nbreuser"],
                        ),
                      );
                    })
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black.withBlue(30),
        onPressed: () {
          showCupertinoModalBottomSheet(
            context: context,
            builder: (context) => SingleChildScrollView(
              child: creatsalon(
                nomuser: nomusers,
              ),
            ),
          );
        },
        label: Row(
          children: const <Widget>[
            Icon(Iconsax.add_circle),
            SizedBox(
              width: 10,
            ),
            Text(
              'Demarrer',
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }

  void _runFilter(String enteredKeyword) {
    List results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = [];
    } else {
      results = salonlist
          .where((user) => user["nomsalon"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      allsalonsearch = results;
    });
    print(allsalonsearch);
    print(allsalonsearch.length);
  }

  gosalon(typesalon, ishost, idsalon) {
    if (typesalon == "audio") {
      Get.to(() => Call(
            username: nomusers,
            idlive: idsalon,
            isHost: ishost,
          ));
    }
    if (typesalon == "conference") {
      VideoConferencePage(
        conferenceID: idsalon,
        username: nomusers,
      );
    }
  }
}

class creatsalon extends StatefulWidget {
  creatsalon({Key? key, required this.nomuser}) : super(key: key);
  String nomuser;
  @override
  _creatsalonState createState() => _creatsalonState();
}

class _creatsalonState extends State<creatsalon> {
  String typesalon = "";
  final nomsalon = TextEditingController();
  final montant = TextEditingController();
  final description = TextEditingController();
  final req = Get.put(Tabsrequette());
  String userid = FirebaseAuth.instance.currentUser!.uid;
  String typebye = "";
  // List section = [
  //   {"nom": "Technologie", "val": "tech"},
  //   {"nom": "Famille", "val": "fam"},
  //   {"nom": "Communication", "val": "com"},
  //   {"nom": "Entrepeunaria", "val": "entre"}
  // ];
  // String typeselection = "";
  // String salonselection = "";
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.black.withBlue(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              height: 5,
              width: 50,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                  color: Colors.white70)),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Création de salon",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    typesalon = "audio";
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      color: (typesalon == "audio")
                          ? Colors.greenAccent
                          : Colors.white.withOpacity(0.3)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
                      SizedBox(
                        height: 2,
                      ),
                      CircleAvatar(
                        radius: 30,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Live Audio",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    typesalon = "conference";
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(7)),
                      color: (typesalon == "conference")
                          ? Colors.greenAccent
                          : Colors.white.withOpacity(0.3)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
                      SizedBox(
                        height: 2,
                      ),
                      CircleAvatar(
                        radius: 30,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Conférence",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: <Widget>[
          //     ActionChip(
          //         padding: const EdgeInsets.all(5),
          //         onPressed: () {
          //           setState(() {
          //             typebye = "gratuit";
          //           });
          //         },
          //         backgroundColor: (typebye == "gratuit")
          //             ? Colors.greenAccent
          //             : Colors.white.withOpacity(0.3),
          //         label: const Text(
          //           'Gratuit',
          //           style: TextStyle(fontSize: 16),
          //         )),
          //     ActionChip(
          //         padding: const EdgeInsets.all(5),
          //         onPressed: () {
          //           setState(() {
          //             typebye = "payant";
          //           });
          //         },
          //         backgroundColor: (typebye == "payant")
          //             ? Colors.greenAccent
          //             : Colors.white.withOpacity(0.3),
          //         label: const Text(
          //           'Payant',
          //           style: TextStyle(fontSize: 16),
          //         ))
          //   ],
          // ),
          const SizedBox(
            height: 10,
          ),
          Container(
            margin: const EdgeInsets.only(left: 35, right: 35, top: 10),
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: (typesalon == "payant")
                      ? 0
                      : MediaQuery.of(context).viewInsets.bottom),
              child: TextField(
                maxLines: 1,
                controller: nomsalon,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.3),
                  hintText: "Nom du salon",
                  hintStyle: const TextStyle(color: Colors.white70),
                  contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          if (typebye == "payant")
            Container(
              margin: const EdgeInsets.only(left: 35, right: 35, top: 10),
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: TextField(
                  maxLines: 1,
                  controller: montant,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    hintText: "Montant",
                    hintStyle: const TextStyle(color: Colors.white70),
                    contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(left: 35, right: 35, top: 20),
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: TextField(
                maxLines: 3,
                controller: description,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.3),
                  hintText: "Description",
                  hintStyle: const TextStyle(color: Colors.white70),
                  contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          // Container(
          //   margin: const EdgeInsets.only(left: 35, right: 35),
          //   height: 50,
          //   child: ListView.builder(
          //       itemCount: section.length,
          //       scrollDirection: Axis.horizontal,
          //       itemBuilder: (context, index) {
          //         return Padding(
          //           padding: const EdgeInsets.all(5),
          //           child: ActionChip(
          //               padding: const EdgeInsets.all(5),
          //               backgroundColor:
          //                   (section[index]["val"] == typeselection)
          //                       ? Colors.greenAccent
          //                       : Colors.white.withOpacity(0.3),
          //               onPressed: () {
          //                 setState(() {
          //                   typeselection = section[index]["val"];
          //                   salonselection = section[index]["nom"];
          //                 });
          //               },
          //               label: Text(
          //                 section[index]["nom"],
          //                 style: TextStyle(fontSize: 16),
          //               )),
          //         );
          //       }),
          // ),
          const SizedBox(
            height: 30,
          ),
          Container(
            margin: const EdgeInsets.only(left: 35, right: 35),
            child: ElevatedButton(
              onPressed: () {
                validedata();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade900,
                  fixedSize: Size(MediaQuery.of(context).size.width, 70),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))),
              child: const Text(
                "Commencer ✌🏼",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  validedata() {
    if (typesalon.isEmpty) {
      req.message('Echec', "Nous vous prions de choisir un type de salon");
    } else if (nomsalon.text.isEmpty) {
      req.message('Echec', "Nous vous prions de saisir le nom du salon");
    } else if (description.text.isEmpty) {
      req.message('Echec', "Nous vous prions de saisir une description");
    } else {
      send();
    }
  }

  send() {
    FirebaseFirestore.instance.collection("callclub").add({
      "nomsalon": nomsalon.text,
      "iduser": userid,
      "range": DateTime.now().microsecondsSinceEpoch,
      "date": DateTime.now(),
      "typesalon": typesalon,
      "prix": montant.text,
      "description": description.text,
      "nbreuser": 1,
      "idsalon": ''
    }).then((value) {
      FirebaseFirestore.instance
          .collection("callclub")
          .doc(value.id)
          .update({"idsalon": value.id});
      if (typesalon == "audio") {
        Get.to(() => Call(
              idlive: value.id,
              username: widget.nomuser,
              isHost: true,
            ));
        Navigator.of(context).pop();
      }
      if (typesalon == "conference") {
        Get.to(() => VideoConferencePage(
              conferenceID: value.id,
              username: widget.nomuser,
            ));
      }
    });
    setState(() {
      nomsalon.text = "";
      montant.text = "";
    });
  }
}
