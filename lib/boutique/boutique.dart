import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:smatch/home/tabsrequette.dart';
import 'package:smatch/menu/menuwidget.dart';

class Mesboutiques extends StatefulWidget {
  @override
  _MesboutiquesState createState() => _MesboutiquesState();
}

class _MesboutiquesState extends State<Mesboutiques> {
  final _advancedDrawerController = AdvancedDrawerController();
  User? user = FirebaseAuth.instance.currentUser;
  CollectionReference userabonne =
      FirebaseFirestore.instance.collection("abonne");
  final Stream<QuerySnapshot> mesboutiquesstream = FirebaseFirestore.instance
      .collection('abonne')
      .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where("type", isNotEqualTo: "Boutique")
      .snapshots();

  List _compte = [];
  final requ = Get.put(Tabsrequette());
  String nomuser = "";
  String avataruser = "";
  List _abonnenoeud = [];
  List allnoeud = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getcompte();
    getinfouser();
    abonnenoeud();
    allnoeuds();
  }

  abonnenoeud() {
    FirebaseFirestore.instance
        .collection('abonne')
        .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        _abonnenoeud = querySnapshot.docs;
      });
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

  getinfouser() {
    print(FirebaseAuth.instance.currentUser!.uid);
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        nomuser = querySnapshot.docs.first['nom'];
        avataruser = querySnapshot.docs.first['avatar'];
      });
      print('object');
    });
  }

  getcompte() {
    FirebaseFirestore.instance
        .collection('noeud')
        .where("type", isEqualTo: "boutique")
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        _compte = querySnapshot.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(25),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(25),
        title: Text(
          'Boutique',
          style: GoogleFonts.poppins(fontSize: 30),
        ),
        leading: Menuwidget(),
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('abonne')
                .where("iduser", isEqualTo: user!.uid)
                .where("type", isEqualTo: "boutique")
                .orderBy("range", descending: true)
                .snapshots(),
            builder:
                (BuildContext contex, AsyncSnapshot<QuerySnapshot> _noeud) {
              if (!_noeud.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return (_noeud.data!.docs.isEmpty)
                  ? const Center(
                      heightFactor: 10,
                      child: Text(
                        "Aucune boutique disponible pour l'instant",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                        textAlign: TextAlign.justify,
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.0,
                              mainAxisSpacing: 10.0,
                              crossAxisSpacing: 5.0,
                              mainAxisExtent: 220),
                      itemCount: _noeud.data!.docs.length,
                      itemBuilder: (BuildContext ctx, index) {
                        return Stack(
                          children: [
                            Container(
                                decoration: const BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 5, right: 10),
                                  child: Column(children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 80,
                                      width: 80,
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15.0)),
                                        child: CachedNetworkImage(
                                          imageUrl: _noeud.data!.docs[index]
                                              ['logo'],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        _noeud.data!.docs[index]['nom'],
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: ActionChip(
                                          backgroundColor: Colors.orangeAccent,
                                          label: Text(
                                            "Consulter",
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () {
                                            var result = allnoeud
                                                .where((user) =>
                                                    user["idcompte"].contains(
                                                        _abonnenoeud[index]
                                                            ["idcompte"]))
                                                .toList();
                                            FirebaseFirestore.instance
                                                .collection("noeud")
                                                .where('idcompte',
                                                    isEqualTo:
                                                        _abonnenoeud[index]
                                                            ["idcompte"])
                                                .get()
                                                .then((QuerySnapshot value) {
                                              Get.toNamed(
                                                  "/" +
                                                      value
                                                          .docs.first["design"],
                                                  arguments: [
                                                    {
                                                      "idshop":
                                                          _abonnenoeud[index]
                                                              ["idcompte"]
                                                    },
                                                    {
                                                      "nomshop": value
                                                          .docs.first["nom"]
                                                    },
                                                  ]);
                                            });
                                          }),
                                    )
                                  ]),
                                )),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: (_noeud.data!.docs[index]["statut"] == 1 ||
                                      _noeud.data!.docs[index]["idcreat"] ==
                                          user!.uid)
                                  ? Center(
                                      child: GestureDetector(
                                      onTap: () {
                                        for (var item in _compte) {
                                          if (item['idcompte'] ==
                                              _noeud.data!.docs[index]
                                                  ['idcompte']) {
                                            Get.toNamed("/tabsmenushop",
                                                arguments: [
                                                  {
                                                    "idshop": _noeud.data!
                                                        .docs[index]["idcompte"]
                                                  },
                                                  {
                                                    "nomshop": _noeud.data!
                                                        .docs[index]["nom"]
                                                  },
                                                  {"design": item["design"]},
                                                ]);
                                          }
                                        }
                                      },
                                      child: const Icon(
                                        Icons.admin_panel_settings_rounded,
                                        size: 35,
                                        color: Colors.white,
                                      ),
                                    ))
                                  : Container(),
                            )
                          ],
                        );
                      });
            }),
      )),
    );
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }

  quitter(idcompte, nom) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Vous êtes sur le point de quitter $nom",
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
              child: const Text(
                'Oui quitter',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                userabonne.doc(idcompte).delete();
                requ.message("sucess", "Votre demande a été prise en compte.");
              },
            ),
          ],
        );
      },
    );
  }
}
