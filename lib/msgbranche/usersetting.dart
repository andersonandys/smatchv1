import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smatch/home/tabsrequette.dart';

class Usersetting extends StatefulWidget {
  const Usersetting({Key? key}) : super(key: key);

  @override
  _UsersettingState createState() => _UsersettingState();
}

class _UsersettingState extends State<Usersetting> {
  final _nomcontroller = TextEditingController();
  String idbranche = Get.arguments[0]["idbranche"];

  final requ = Get.put(Tabsrequette());
  String nombranche = Get.arguments[1]["nom"];
  final Stream<QuerySnapshot> _infomsg = FirebaseFirestore.instance
      .collection('message')
      .where("idbranche", isEqualTo: Get.arguments[0]["idbranche"])
      .snapshots();
  final Stream<QuerySnapshot> _infbranche = FirebaseFirestore.instance
      .collection('branche')
      .where("idbranche", isEqualTo: Get.arguments[0]["idbranche"])
      .snapshots();
  final Stream<QuerySnapshot> _userbranche = FirebaseFirestore.instance
      .collection('userbranche')
      .where("idbranche", isEqualTo: Get.arguments[0]["idbranche"])
      .snapshots();
  final Stream<QuerySnapshot> _alluser =
      FirebaseFirestore.instance.collection('users').snapshots();
  CollectionReference permbranche =
      FirebaseFirestore.instance.collection('branche');
  User? user = FirebaseAuth.instance.currentUser;
  List userslist = [];
  List userbranche = [];
  List allusers = [];
  String nameuser = "";
  String avataruser = "";
  int tablength = 4;
  @override
  void initState() {
    super.initState();
    getalluser();
    getallabonne();
  }

  getalluser() {
    FirebaseFirestore.instance
        .collection("users")
        .get()
        .then((QuerySnapshot query) {
      setState(() {
        userslist = query.docs;
      });
    });
  }

  getallabonne() {
    FirebaseFirestore.instance
        .collection("userbranche")
        .where("idbranche", isEqualTo: idbranche)
        .get()
        .then((QuerySnapshot query) {
      setState(() {
        userbranche = query.docs;
      });
      print(userbranche);
    });
  }

  alluser() {
    FirebaseFirestore.instance
        .collection("users")
        .get()
        .then((QuerySnapshot value) {
      setState(() {
        allusers = value.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.black.withBlue(30),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black.withBlue(30),
          title: Text(nombranche),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            isScrollable: true,
            tabs: [
              Tab(text: 'Membre'),
              Tab(text: 'Image'),
              Tab(text: 'Video'),
              Tab(text: 'Document'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: const BoxDecoration(),
                child: displayuser()),
            Container(
              child: displayimage(),
            ),
            Container(
              child: displayvideo(),
            ),
            Container(
              child: displaydoc(),
            ),
          ],
        ),
      ),
    );
  }

  Widget displayuser() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: MediaQuery.of(context).size.height / 2, //height of TabBarView
      decoration: const BoxDecoration(),
      child: ListView(
        shrinkWrap: true,
        children: [
          for (var userbranch in userbranche)
            for (var userslis in userslist)
              if (userbranch['iduser'] == userslis['iduser'])
                ListTile(
                  leading: CircleAvatar(
                    foregroundImage: NetworkImage(userslis["avatar"]),
                  ),
                  title: Text(
                    userslis['nom'],
                    style: const TextStyle(color: Colors.white),
                  ),
                )
        ],
      ),
    );
  }

  Widget displayimage() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('message')
            .where("idbranche", isEqualTo: "")
            .where("typemessage", isEqualTo: "image")
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> imglistlessage) {
          if (!imglistlessage.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (imglistlessage.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return (imglistlessage.data!.docs.isEmpty)
              ? const Center(
                  child: Text(
                  "Aucune image trouvée",
                  style: TextStyle(color: Colors.white),
                ))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 5.0,
                      mainAxisExtent: 235),
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: imglistlessage.data!.docs.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed('/viewimage', arguments: [
                          {
                            "urlfile": imglistlessage.data!.docs[index]
                                ['urlfile']
                          }
                        ]);
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(7))),
                          margin: const EdgeInsets.all(3),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7)),
                            child: CachedNetworkImage(
                              imageUrl: imglistlessage.data!.docs[index]
                                  ['urlfile'],
                              fit: BoxFit.cover,
                            ),
                          )),
                    );
                  });
        });
  }

  Widget displayvideo() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('message')
            .where("idbranche", isEqualTo: "")
            .where("typemessage", isEqualTo: "video")
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> imglistlessage) {
          if (!imglistlessage.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (imglistlessage.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return (imglistlessage.data!.docs.isEmpty)
              ? const Center(
                  child: Text(
                  "Aucune video trouvée",
                  style: TextStyle(color: Colors.white),
                ))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 5.0,
                      mainAxisExtent: 235),
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: imglistlessage.data!.docs.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed('/viewvideo', arguments: [
                          {
                            "urlfile": imglistlessage.data!.docs[index]
                                ['urlfile']
                          }
                        ]);
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(7))),
                          margin: const EdgeInsets.all(3),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7)),
                            child: CachedNetworkImage(
                              imageUrl: imglistlessage.data!.docs[index]
                                  ['vignette'],
                              fit: BoxFit.cover,
                            ),
                          )),
                    );
                  });
        });
  }

  Widget displaydoc() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('message')
            .where("idbranche", isEqualTo: "")
            .where("typemessage", isEqualTo: "doc")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> docpub) {
          if (!docpub.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (docpub.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
              itemCount: docpub.data!.docs.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Iconsax.document,
                            color: Colors.white,
                            size: 25,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Flexible(
                              child: Text(
                            docpub.data!.docs[index]['namefile'],
                            style: const TextStyle(color: Colors.white),
                          ))
                        ],
                      ),
                    ));
              });
        });
  }

  desablebranche() {
    Get.defaultDialog(
        radius: 10,
        onConfirm: () {
          FirebaseFirestore.instance
              .collection('branche')
              .doc(idbranche)
              .update({"active": 1});
        },
        textConfirm: "Oui désactiver la branche",
        textCancel: "Annuler",
        title: "Confirmation",
        titleStyle: const TextStyle(),
        confirmTextColor: Colors.white,
        content: const Text(
          "En desactivant cette branche, vous la rendez innaccessible pour tout vos utilisateur.",
          style: TextStyle(),
          textAlign: TextAlign.justify,
        ));
  }

  updatenamebranche() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modification'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  "Apporter une modification au nom de la branche",
                  style: TextStyle(),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nomcontroller,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    hintText: "Nom de la branche",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'annuler',
                  style: TextStyle(color: Colors.white),
                )),
            const SizedBox(
              width: 20,
            ),
            TextButton(
              child: const Text('Confirmer'),
              onPressed: () {
                if (_nomcontroller.text != "") {
                  FirebaseFirestore.instance
                      .collection('branche')
                      .doc(idbranche)
                      .update({"nom": _nomcontroller.text});
                  setState(() {
                    nombranche = _nomcontroller.text;
                  });

                  // requette.message(
                  //     "Succes", "Le changement va etre pris en compte");
                  Navigator.of(context).pop();
                  _nomcontroller.clear();
                }

                if (_nomcontroller.text == "") {
                  // requette.message("Echec",
                  //     "Nous vous prions de saisir un nom pour votre branche");
                }
              },
            ),
          ],
        );
      },
    );
  }

  createNewMeeting() async {}

  Widget viewinvitation() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          "Demande d'adhesion",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 20),
        StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("invitation")
                .where("idbranche", isEqualTo: idbranche)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> invitation) {
              if (!invitation.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (invitation.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return (invitation.data!.docs.isEmpty)
                  ? const Text(
                      "Vous n'avez pas demande d'adhesion",
                      style: TextStyle(color: Colors.white),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: invitation.data!.docs.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                invitation.data!.docs[index]["nomuser"],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 19),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      refuser(invitation.data!.docs[index].id);
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50)),
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
                                        invitation.data!.docs[index]["iduser"],
                                        invitation.data!.docs[index]
                                            ["idbranche"],
                                        invitation.data!.docs[index]["nomuser"],
                                        invitation.data!.docs[index].id,
                                        invitation.data!.docs[index]["avatar"],
                                      );
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50)),
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
    );
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
                  "Etes vous sur de refuser la demande d'adhesion",
                  textAlign: TextAlign.justify,
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'annuler',
                  style: TextStyle(color: Colors.white),
                )),
            const SizedBox(
              width: 20,
            ),
            TextButton(
              child: const Text('Oui Refuser'),
              onPressed: () {
                Navigator.of(context).pop();
                FirebaseFirestore.instance
                    .collection("invitation")
                    .doc(iddemande)
                    .delete();
                FirebaseFirestore.instance
                    .collection("noeud")
                    .doc(iddemande)
                    .update({"notification": FieldValue.increment(-1)});
                requ.message("sucess", "Adhesion refuser avec sucess");
              },
            ),
          ],
        );
      },
    );
  }

  accepet(iduser, idbranchedemande, nomuser, iddemande, avatar) {
    FirebaseFirestore.instance.collection("userbranche").add({
      "iduser": iduser,
      "idbranche": idbranchedemande,
      "date": DateTime.now(),
      "statut": 0,
      "nbremsg": 0,
      "avatar": avatar,
      "nomuser": nomuser
    });

    FirebaseFirestore.instance
        .collection("branche")
        .doc(idbranchedemande)
        .update({
      "nbreuser": FieldValue.increment(1),
      "invitation": FieldValue.increment(-1)
    });
    FirebaseFirestore.instance
        .collection("users")
        .doc(iduser)
        .update({"notification": FieldValue.increment(1)});

    FirebaseFirestore.instance.collection("notification").add({
      "idbranche": idbranchedemande,
      "date": DateTime.now(),
      "iduser": iduser,
      "type": "branche"
    });
    FirebaseFirestore.instance
        .collection("noeud")
        .doc(idbranchedemande)
        .update({"notification": FieldValue.increment(-1)});
    requ.message("sucess", "Adhesion accepté avec success");
    FirebaseFirestore.instance.collection("invitation").doc(iddemande).delete();
  }
}
