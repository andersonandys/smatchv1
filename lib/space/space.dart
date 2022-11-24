import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smatch/home/home.dart';
import 'package:smatch/home/tabsrequette.dart';
import 'package:smatch/menu/menuwidget.dart';

class Space extends StatefulWidget {
  @override
  _SpaceState createState() => _SpaceState();
}

class _SpaceState extends State<Space> {
  final _advancedDrawerController = AdvancedDrawerController();
  User? user = FirebaseAuth.instance.currentUser;
  CollectionReference userabonne =
      FirebaseFirestore.instance.collection("abonne");
  final Stream<QuerySnapshot> spacestream = FirebaseFirestore.instance
      .collection('abonne')
      .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where("type", isNotEqualTo: "Moment")
      .snapshots();

  List _compte = [];
  final requ = Get.put(Tabsrequette());
  String nomuser = "";
  String avataruser = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getcompte();
    getinfouser();
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
        .collection('abonne')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc["iduser"] == user!.uid && doc["type"] == "boutique" ||
            doc['type'] == "Moment") {
          setState(() {
            _compte = querySnapshot.docs;
          });
          print(_compte);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(25),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(25),
        title: Text(
          'Space',
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
                .where("type", isEqualTo: "Moment")
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
                        "Aucun Space disponible pour l'instant",
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
                                          backgroundColor:
                                              Colors.orange.shade800,
                                          label: Text(
                                            "Consulter",
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () {
                                            FirebaseFirestore.instance
                                                .collection('noeud')
                                                .where("idcompte",
                                                    isEqualTo:
                                                        _noeud.data!.docs[index]
                                                            ['idcompte'])
                                                .get()
                                                .then((QuerySnapshot value) {
                                              if (value.docs
                                                      .first["lienvideo"] ==
                                                  "") {
                                                requ.message("Echec",
                                                    "Aucune vidéo n'a été définie pour la une.");
                                              } else {
                                                Get.toNamed("/vlog",
                                                    arguments: [
                                                      {
                                                        "idchaine": value.docs
                                                            .first["idcompte"]
                                                      },
                                                      {
                                                        "nomchaine": value
                                                            .docs.first["nom"]
                                                      },
                                                      {
                                                        "logo": value
                                                            .docs.first['logo']
                                                      },
                                                      {
                                                        "vignette": value.docs
                                                            .first['vignette']
                                                      },
                                                      {
                                                        "titre": value
                                                            .docs.first['titre']
                                                      }
                                                    ]);
                                              }
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
                                        print(_noeud.data!.docs[index]
                                            ["idcompte"]);
                                        Get.toNamed("/tabsvlog", arguments: [
                                          {
                                            "idchaine": _noeud.data!.docs[index]
                                                ["idcompte"]
                                          },
                                          {
                                            "nomchaine":
                                                _noeud.data!.docs[index]["nom"]
                                          },
                                        ]);
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
              child: const Text('Oui quitter',
                  style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                userabonne.doc(idcompte).delete();
                requ.message("sucess", "Votre demande a été prise en compte");
              },
            ),
          ],
        );
      },
    );
  }
}
