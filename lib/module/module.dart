import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smatch/home/tabsrequette.dart';

import '../menus.dart';

class Mymodule extends StatefulWidget {
  @override
  _MymoduleState createState() => _MymoduleState();
}

class _MymoduleState extends State<Mymodule> {
  final _advancedDrawerController = AdvancedDrawerController();
  User? user = FirebaseAuth.instance.currentUser;
  CollectionReference userabonne =
      FirebaseFirestore.instance.collection("abonne");
  final Stream<QuerySnapshot> spacestream = FirebaseFirestore.instance
      .collection('abonne')
      .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      // .where("type", isNotEqualTo: "noeud")
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
    return AdvancedDrawer(
      backdropColor: Colors.blueGrey,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Scaffold(
        backgroundColor: Colors.black.withBlue(30),
        appBar: AppBar(
          backgroundColor: Colors.black.withBlue(30),
          title: Text(
            'Space',
            style: GoogleFonts.poppins(fontSize: 30),
          ),
          leading: IconButton(
            onPressed: _handleMenuButtonPressed,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: _advancedDrawerController,
              builder: (_, value, __) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    value.visible ? Icons.clear : Icons.menu,
                    key: ValueKey<bool>(value.visible),
                  ),
                );
              },
            ),
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
            child: Container(
          margin: const EdgeInsets.only(left: 10, right: 10),
          child: StreamBuilder(
              stream: spacestream,
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
                                mainAxisExtent: 235),
                        itemCount: _noeud.data!.docs.length,
                        itemBuilder: (BuildContext ctx, index) {
                          return Stack(
                            children: [
                              Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
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
                                        child: Text(
                                          _noeud.data!.docs[index]['nom'],
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 20),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        alignment: Alignment.center,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Align(
                                        child: ActionChip(
                                            backgroundColor: Colors.orange,
                                            label: Text(
                                              "Quitter",
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            onPressed: () {
                                              quitter(
                                                  _noeud.data!.docs[index].id,
                                                  _noeud.data!.docs[index]
                                                      ["nom"]);
                                            }),
                                        alignment: Alignment.center,
                                      )
                                    ]),
                                  )),
                              Positioned(
                                child: (_noeud.data!.docs[index]["statut"] == 1)
                                    ? Center(
                                        child: GestureDetector(
                                        onTap: () {
                                          if (_noeud.data!.docs[index]
                                                  ["type"] ==
                                              "boutique") {
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
                                                  {
                                                    "design": _noeud.data!
                                                        .docs[index]["design"]
                                                  },
                                                ]);
                                          } else {
                                            Get.toNamed("/tabsvlog",
                                                arguments: [
                                                  {
                                                    "idchaine": _noeud.data!
                                                        .docs[index]["idcompte"]
                                                  },
                                                  {
                                                    "nomchaine": _noeud.data!
                                                        .docs[index]["nom"]
                                                  },
                                                ]);
                                          }
                                        },
                                        child: const Icon(
                                          Icons.admin_panel_settings_rounded,
                                          size: 35,
                                          color: Colors.white,
                                        ),
                                      ))
                                    : Container(),
                                top: 5,
                                right: 5,
                              )
                            ],
                          );
                        });
              }),
        )),
      ),
      drawer: SafeArea(
          child: Container(
        child: Stack(
          children: [
            menus().allmenu(),
            Container(
                margin:
                    const EdgeInsets.only(top: 30.0, bottom: 20.0, left: 10),
                child: Row(children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: CachedNetworkImageProvider(avataruser),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      nomuser,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ])),
          ],
        ),
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
                  "Vous etes sur le point de quitter $nom",
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
              child: const Text('Oui quitter'),
              onPressed: () {
                Navigator.of(context).pop();
                userabonne.doc(idcompte).delete();
                requ.message("sucess", "Votre demande a ete pris en compte");
              },
            ),
          ],
        );
      },
    );
  }
}
