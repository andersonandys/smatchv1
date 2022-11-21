import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smatch/club/ui/home/HomeRoomItem.dart';
import 'package:smatch/club/ui/home/HomeUpcoming.dart';
import 'package:smatch/club/ui/liveroom/LiveRoom.dart';
import 'package:smatch/club/ui/liveroom/LiveRoomMember.dart';
import 'package:smatch/club/utils/DynamicColor.dart';
import 'package:smatch/club/utils/MemojiColors.dart';
import 'package:smatch/club/widgets/SquircleIconButton.dart';
import 'package:smatch/home/tabsrequette.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Stream<QuerySnapshot> streamcall =
      FirebaseFirestore.instance.collection("callclub").snapshots();
  final topics = [
    "🎨 Design",
    "🌍 Flutter",
    "🎯 Figma",
    "👀 Clone",
    "⛱ Saturday",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(20),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(40),
        centerTitle: false,
        title: const Text("Hello,\nLeslie"),
        actions: [
          CircleAvatar(
            radius: 18,
            backgroundColor: MemojiColors.blue,
            child: Image.asset("assets/images/10.png"),
          ),
          const SizedBox(width: 20),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: topics.length,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final color = MemojiColors.values[
                    Random.secure().nextInt(MemojiColors.values.length - 1) +
                        1];
                return InputChip(
                  backgroundColor: DynamicColor.withBrightness(
                    context: context,
                    color: color,
                    darkColor: color.withOpacity(0.15),
                  ),
                  label: Text(
                    "${topics[index]}",
                    style: TextStyle(
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {},
                );
              },
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
              const HomeUpcoming(
                time: "10:00 - 12:00",
                title: "Design talks and chill",
              ),
              const Text(
                "Happening now",
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              const SizedBox(
                height: 10,
              ),
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
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext, index) {
                        return HomeRoomItem(
                          nomsalon: clublist[index]["nomsalon"],
                        );
                      });
                },
              )
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
            builder: (context) => const SingleChildScrollView(
              child: creatsalon(),
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
              'Lancer un salon',
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}

class creatsalon extends StatefulWidget {
  const creatsalon({Key? key}) : super(key: key);

  @override
  _creatsalonState createState() => _creatsalonState();
}

class _creatsalonState extends State<creatsalon> {
  String typesalon = "";
  final nomsalon = TextEditingController();
  final montant = TextEditingController();
  final req = Get.put(Tabsrequette());
  String userid = FirebaseAuth.instance.currentUser!.uid;
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    typesalon = "public";
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      color: (typesalon == "public")
                          ? Colors.greenAccent
                          : Colors.white.withOpacity(0.3)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 30,
                      ),
                      const Text(
                        "Public",
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
                    typesalon = "social";
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      color: (typesalon == "social")
                          ? Colors.greenAccent
                          : Colors.white.withOpacity(0.3)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 30,
                      ),
                      const Text(
                        "Social",
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
                    typesalon = "prive";
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      color: (typesalon == "prive")
                          ? Colors.greenAccent
                          : Colors.white.withOpacity(0.3)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 30,
                      ),
                      const Text(
                        "Privé",
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
          Padding(
            padding: EdgeInsets.only(
                bottom: (typesalon == "prive")
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
          const SizedBox(
            height: 10,
          ),
          if (typesalon == "prive")
            Padding(
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
          const SizedBox(
            height: 30,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton.icon(
              icon: const Text(
                "✌🏼",
                style: TextStyle(fontSize: 18),
              ),
              label: const Text("Leave quietly"),
              style: TextButton.styleFrom(
                foregroundColor: DynamicColor.withBrightness(
                  context: context,
                  color: Colors.white,
                  darkColor: const Color(0xFF9d97ec),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: DynamicColor.withBrightness(
                  context: context,
                  color: Colors.orangeAccent,
                  darkColor: const Color(0xFF2a2b29),
                ),
              ),
              onPressed: () {
                validedata();
              },
            ),
          )
        ],
      ),
    );
  }

  validedata() {
    print("oka");
    if (typesalon.isEmpty) {
      req.message('Echec', "Nous vous prions de choisir un type de salon");
    } else if (nomsalon.text.isEmpty) {
      req.message('Echec', "Nous vous prions de saisir le nom du salon");
    } else {
      if (typesalon == "prive") {
        if (montant.text.isEmpty) {
          req.message('Echec', "Nous vous prions de saisir un montant");
        } else {
          send();
        }
      } else {
        send();
      }
    }
  }

  send() {
    FirebaseFirestore.instance.collection("callclub").add({
      "nomsalon": nomsalon.text,
      "iduser": userid,
      "range": DateTime.now().microsecondsSinceEpoch,
      "date": DateTime.now(),
      "typesalon": typesalon,
      "prix": montant.text
    }).then((value) {
      onJoin();
    });
    setState(() {
      nomsalon.text = "";
      montant.text = "";
    });
  }

  Future<void> onJoin() async {
    // await for camera and mic permissions before pushing video page
    await _handleCameraAndMic(Permission.microphone);
    // push video page with given channel name
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveRoom(
          nomsalon: nomsalon.text,
        ),
      ),
    );
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}
