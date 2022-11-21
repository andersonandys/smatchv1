import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smatch/home/home.dart';
import 'package:smatch/home/tabsrequette.dart';
import 'package:smatch/menu/menuwidget.dart';

class HomeDicovery extends StatefulWidget {
  @override
  _HomeDicoveryState createState() => _HomeDicoveryState();
}

class _HomeDicoveryState extends State<HomeDicovery> {
  final _advancedDrawerController = AdvancedDrawerController();

  final requ = Get.put(Tabsrequette());
  List allcompte = [];
  final Stream<QuerySnapshot> _allnoeud = FirebaseFirestore.instance
      .collection('noeud')
      .orderBy("range", descending: true)
      .where("mode", isEqualTo: true)
      .snapshots();
  final Stream<QuerySnapshot> _allnoeudrecommande = FirebaseFirestore.instance
      .collection('noeud')
      .orderBy("range", descending: true)
      .where("recomande", isEqualTo: true)
      .snapshots();
  CollectionReference userabonne =
      FirebaseFirestore.instance.collection('abonne');
  String nom = "";
  String description = "";
  String type = "";
  String logo = "";
  String offre = "";
  String statut = "";
  int? exist;
  String idcreat = "";
  String idcomptexist = "";
  String idcompte = "";
  int? prix;
  int? wallet;
  User user = FirebaseAuth.instance.currentUser!;
  String searchdata = "";
  List abonne = [];
  List compte = [];
  String nomuser = "";
  List allcomptesearch = [];
  String avataruser = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getinfouser();
    getabonne();
    getallcompte();
  }

  getinfouser() {
    FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc.id == user.uid) {
          setState(() {
            wallet = doc['wallet'];
            nomuser = doc["nom"];
            avataruser = doc["avatar"];
          });
        }
      }
    });
  }

  getabonne() {
    FirebaseFirestore.instance
        .collection('abonne')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        abonne = querySnapshot.docs;
      });
    });
  }

  getallcompte() {
    FirebaseFirestore.instance
        .collection('noeud')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        compte = querySnapshot.docs;
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
          'Discovery',
          style: GoogleFonts.poppins(fontSize: 30),
        ),
        leading: const Menuwidget(),
        elevation: 0,
      ),
      body: Container(
          child: SingleChildScrollView(
              child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            // bare de recherche
            const SizedBox(height: 20),
            TextField(
                style: TextStyle(color: Colors.white),
                cursorHeight: 20,
                autofocus: false,
                decoration: InputDecoration(
                  labelText: 'Entrer votre recherche',
                  suffixIcon: const Icon(
                    Iconsax.search_normal_1,
                    color: Colors.white,
                  ),
                  filled: true,
                  fillColor: Colors.white12,
                  hintStyle: const TextStyle(color: Colors.white),
                  labelStyle: const TextStyle(color: Colors.white),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.grey, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    gapPadding: 0.0,
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 1.5),
                  ),
                ),
                onChanged: (value) {
                  _runFilter(value);
                }),
            const SizedBox(height: 20),

            (allcomptesearch.isEmpty)
                ?
                // affichage normal
                Column(
                    children: [
                      Align(
                        child: Text(
                          "Recommander pour vous",
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 20),
                        ),
                        alignment: Alignment.topLeft,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                          height: 235,
                          child: StreamBuilder(
                              stream: _allnoeudrecommande,
                              builder: (BuildContext contex,
                                  AsyncSnapshot<QuerySnapshot> _noeud) {
                                if (!_noeud.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: _noeud.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    return Row(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                                width: 200,
                                                decoration: const BoxDecoration(
                                                    color: Colors.white12,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          left: 5,
                                                          right: 10),
                                                  child: Column(children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Container(
                                                      height: 80,
                                                      width: 80,
                                                      decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          15))),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    15.0)),
                                                        child:
                                                            CachedNetworkImage(
                                                          fit: BoxFit.cover,
                                                          imageUrl: (_noeud
                                                                  .data!
                                                                  .docs[index]
                                                              ['logo']),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15),
                                                    Align(
                                                      child: Text(
                                                        _noeud.data!.docs[index]
                                                            ['nom'],
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                fontSize: 20),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                    ),
                                                    Align(
                                                      child: Text(
                                                        _noeud.data!.docs[index]
                                                            ['type'],
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white60,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            (_noeud.data!.docs[
                                                                            index]
                                                                        [
                                                                        'offre'] ==
                                                                    "gratuit")
                                                                ? "Libre"
                                                                : "Payant",
                                                            style: GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white60,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          ActionChip(
                                                              backgroundColor:
                                                                  Colors.orange
                                                                      .shade900,
                                                              label: Text(
                                                                "Obtenir",
                                                                style: GoogleFonts.poppins(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              onPressed: () {
                                                                setState(() {
                                                                  nom = _noeud
                                                                          .data!
                                                                          .docs[
                                                                      index]['nom'];
                                                                  description = _noeud
                                                                          .data!
                                                                          .docs[index]
                                                                      [
                                                                      'description'];
                                                                  type = _noeud
                                                                          .data!
                                                                          .docs[
                                                                      index]['type'];
                                                                  logo = _noeud
                                                                          .data!
                                                                          .docs[
                                                                      index]['logo'];
                                                                  offre = _noeud
                                                                          .data!
                                                                          .docs[index]
                                                                      ['offre'];
                                                                  prix = _noeud
                                                                          .data!
                                                                          .docs[
                                                                      index]['prix'];
                                                                  statut = _noeud
                                                                          .data!
                                                                          .docs[index]
                                                                      [
                                                                      'statut'];
                                                                  idcompte = _noeud
                                                                      .data!
                                                                      .docs[
                                                                          index]
                                                                      .id;
                                                                  idcreat = _noeud
                                                                          .data!
                                                                          .docs[index]
                                                                      [
                                                                      'idcreat'];
                                                                });
                                                                viewinfo();
                                                              }),
                                                        ]),
                                                  ]),
                                                )),
                                            (_noeud.data!.docs[index]
                                                        ['statut'] ==
                                                    "public")
                                                ? const Positioned(
                                                    child: Icon(
                                                      IconlyLight.unlock,
                                                      color: Colors.white70,
                                                    ),
                                                    top: 5,
                                                    right: 5,
                                                  )
                                                : const Positioned(
                                                    child: Icon(
                                                      IconlyLight.lock,
                                                      color: Colors.white70,
                                                    ),
                                                    top: 5,
                                                    right: 5,
                                                  )
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        )
                                      ],
                                    );
                                  },
                                );
                              })),
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Toutes les catégories",
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      StreamBuilder(
                          stream: _allnoeud,
                          builder: (BuildContext contex,
                              AsyncSnapshot<QuerySnapshot> _noeud) {
                            if (!_noeud.hasData) {
                              return const Center(
                                  heightFactor: 2,
                                  child: CircularProgressIndicator());
                            }
                            int length = _noeud.data!.docs.length;
                            List discorde = _noeud.data!.docs;
                            return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: length,
                                itemBuilder: (BuildContext, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10))),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          height: 250,
                                          padding: const EdgeInsets.all(10),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                child: CachedNetworkImage(
                                                  imageUrl: discorde[index]
                                                      ["logo"],
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                  top: 10,
                                                  right: 10,
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    radius: 20,
                                                    child: (discorde[index]
                                                                ["statut"] ==
                                                            "public")
                                                        ? const Icon(
                                                            IconlyBold.unlock,
                                                            color: Colors.black,
                                                          )
                                                        : const Icon(
                                                            IconlyBold.lock,
                                                            color: Colors.black,
                                                          ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    discorde[index]["nom"],
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white),
                                                  ),
                                                  Text(
                                                    (discorde[index]["offre"])
                                                        .toString()
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white),
                                                  )
                                                ],
                                              ),
                                              Text(
                                                (discorde[index]["type"])
                                                    .toString()
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white70),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text(
                                                'Description',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              DetectableText(
                                                trimExpandedText:
                                                    "montrer moins",
                                                trimCollapsedText:
                                                    "montrer plus",
                                                text: discorde[index]
                                                    ["description"],
                                                detectionRegExp: RegExp(
                                                  "(?!\\n)(?:^|\\s)([#@]([$detectionContentLetters]+))|$urlRegexContent",
                                                  multiLine: false,
                                                ),
                                                detectedStyle: const TextStyle(
                                                    color: Colors.black),
                                                basicStyle: const TextStyle(
                                                    color: Colors.white70),
                                                onTap: (tappedText) {
                                                  Get.toNamed("/checklien",
                                                      arguments: [
                                                        {"url": tappedText}
                                                      ]);
                                                },
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  if (discorde[index]
                                                          ["offre"] ==
                                                      "gratuit")
                                                    const Text(
                                                      '0 FCFA',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.white),
                                                    ),
                                                  if (discorde[index]
                                                          ["offre"] !=
                                                      "gratuit")
                                                    Text(
                                                      " ${discorde[index]["prix"]} FCFA",
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.white),
                                                    ),
                                                  Buttonjoin(
                                                      idcompte: _noeud
                                                          .data!.docs[index].id,
                                                      statut: discorde[index]
                                                          ["statut"],
                                                      nom: discorde[index]
                                                          ["nom"],
                                                      logo: discorde[index]
                                                          ["logo"],
                                                      offre: discorde[index]
                                                          ["offre"],
                                                      type: discorde[index]
                                                          ["type"],
                                                      idcreate: idcreat,
                                                      prix: discorde[index]
                                                          ["prix"]),
                                                  // buttonjoin(
                                                  //     _noeud
                                                  //         .data!.docs[index].id,
                                                  //     discorde[index]["logo"],
                                                  //     discorde[index]["nom"],
                                                  //     discorde[index]["type"],
                                                  //     nomuser,
                                                  //     discorde[index]["statut"])
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                });
                          }),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Résultat de votre recherche',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.0,
                                  mainAxisSpacing: 10.0,
                                  crossAxisSpacing: 5.0,
                                  mainAxisExtent: 235),
                          itemCount: allcomptesearch.length,
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
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(15.0)),
                                            child: CachedNetworkImage(
                                              imageUrl: (allcomptesearch[index]
                                                  ['logo']),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        Align(
                                          child: Text(
                                            allcomptesearch[index]['nom'],
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 20),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          alignment: Alignment.center,
                                        ),
                                        Align(
                                          child: Text(
                                            allcomptesearch[index]['type'],
                                            style: GoogleFonts.poppins(
                                                color: Colors.white60,
                                                fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          alignment: Alignment.center,
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                (allcomptesearch[index]
                                                            ['offre'] ==
                                                        "gratuit")
                                                    ? "Libre"
                                                    : "Payant",
                                                style: GoogleFonts.poppins(
                                                    color: Colors.white60,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              ActionChip(
                                                  backgroundColor:
                                                      Colors.orange.shade900,
                                                  label: Text(
                                                    "Obtenir",
                                                    style: GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      print("objet");
                                                      nom =
                                                          allcomptesearch[index]
                                                              ['nom'];
                                                      description =
                                                          allcomptesearch[index]
                                                              ['description'];
                                                      type =
                                                          allcomptesearch[index]
                                                              ['type'];
                                                      logo =
                                                          allcomptesearch[index]
                                                              ['logo'];
                                                      offre =
                                                          allcomptesearch[index]
                                                              ['offre'];
                                                      prix =
                                                          allcomptesearch[index]
                                                              ['prix'];
                                                      idcompte =
                                                          allcomptesearch[index]
                                                              .id;
                                                      statut =
                                                          allcomptesearch[index]
                                                              ['statut'];
                                                      idcreat =
                                                          allcomptesearch[index]
                                                              ['idcreat'];
                                                    });
                                                    viewinfo();
                                                  }),
                                            ]),
                                      ]),
                                    )),
                                (allcomptesearch[index]['statut'] == "public")
                                    ? const Positioned(
                                        child: Icon(
                                          IconlyLight.unlock,
                                          color: Colors.white70,
                                        ),
                                        top: 5,
                                        right: 5,
                                      )
                                    : const Positioned(
                                        child: Icon(
                                          IconlyLight.lock,
                                          color: Colors.white70,
                                        ),
                                        top: 5,
                                        right: 5,
                                      )
                              ],
                            );
                          })
                    ],
                  )
          ],
        ),
      ))),
    );
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }

  buttonjoin(idcomptes, logos, noms, types, nomusers, statuts) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("abonne")
            .where("iduser", isEqualTo: user.uid)
            .where("idcompte", isEqualTo: idcomptes)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> abonneinfo) {
          if (!abonneinfo.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (abonneinfo.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return (abonneinfo.data!.docs.isNotEmpty)
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent),
                  onPressed: () {},
                  child: Text(
                    "Membre",
                    style: GoogleFonts.poppins(color: Colors.black),
                  ))
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade900),
                  onPressed: () {
                    if (statuts == "public") {
                      installer();
                    }

                    if (statuts == "prive") {
                      sendinvitation(idcomptes, logos, noms, types, nomusers);
                    }
                  },
                  child: const Text(
                    "Rejoindre",
                  ));
        });
  }

  viewinfo() {
    showMaterialModalBottomSheet(
      backgroundColor: Colors.black.withBlue(25),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      context: context,
      builder: (context) => SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                height: 5,
                width: 50,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Container(
                height: 80,
                width: 80,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  child: CachedNetworkImage(
                    imageUrl: logo,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 80,
                width: MediaQuery.of(context).size.width / 1.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        nom,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            type,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (offre != 'gratuit')
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              "$prix Fcfa",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              )
            ]),
            const SizedBox(
              height: 20,
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Description",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              description,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (offre == "gratuit")
                      ? "Libre d'accès"
                      : "Accès par abonnement",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("abonne")
                        .where("iduser", isEqualTo: user.uid)
                        .where("idcompte", isEqualTo: idcompte)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> abonneinfo) {
                      if (!abonneinfo.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (abonneinfo.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return (abonneinfo.data!.docs.isNotEmpty)
                          ? ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(primary: Colors.red),
                              onPressed: () {
                                quitter(abonneinfo.data!.docs.first.id);
                              },
                              child: Text(
                                "Quitter",
                                style: GoogleFonts.poppins(),
                              ))
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.orange.shade900),
                              onPressed: () {
                                if (statut == "public") {
                                  installer();
                                } else {
                                  sendinvitation(
                                      idcompte, logo, nom, type, nomuser);
                                }
                              },
                              child: const Text(
                                "Obtenir",
                              ));
                    }),
              ],
            )
          ],
        ),
      )),
    );
  }

  installer() {
    print(user.uid);
    if (offre == "gratuit") {
      requ.rejoindre(nom, idcompte, logo, offre, type, idcreat);
    } else {
      requ.byAbonnement(
          prix, wallet, idcompte, nom, logo, offre, type, idcreat);
    }
  }

  sendinvitation(idcompte, logo, nom, type, nomuser) {
    DateTime now = DateTime.now();
    String dateformat = DateFormat("yyyy-MM-dd - kk:mm").format(now);
    FirebaseFirestore.instance.collection("invitation").add({
      "iduser": user.uid,
      "idcompte": idcompte,
      "nom": nom,
      "logo": logo,
      "date": dateformat,
      "range": DateTime.now().millisecondsSinceEpoch,
      "offre": offre,
      "statut": 0,
      "type": type,
      "nomuser": nomuser,
    });
    FirebaseFirestore.instance.collection("notification").add({
      "message": "$nomuser Souhaite intégrer votre nœud.",
      "logo": logo,
      "type": "invitation",
      "iduser": user.uid,
      "idcompte": idcompte,
      "date": dateformat
    });
    FirebaseFirestore.instance
        .collection("noeud")
        .doc(idcompte)
        .update({"notification": FieldValue.increment(1)});
    requ.message("Sucess",
        "Votre demande d'adhésion au nœud $nom a été envoyé avec succès.");
  }

  quitter(idcomptequitte) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                (offre == "gratuit")
                    ? Text(
                        "Vous êtes sur le point de quitter $nom",
                        textAlign: TextAlign.justify,
                      )
                    : Text(
                        "En quittant $nom, aucun remboursement sera effectué",
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
              child: const Text('Oui quitter'),
              onPressed: () {
                Navigator.of(context).pop();
                userabonne.doc(idcomptequitte).delete();
                requ.message("sucess", "Votre demande a été prise en compte.");
              },
            ),
          ],
        );
      },
    );
  }

  void _runFilter(String enteredKeyword) {
    List results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = [];
    } else {
      results = compte
          .where((user) =>
              user["nom"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      allcomptesearch = results;
    });
    print(allcomptesearch);
  }
}

class Buttonjoin extends StatefulWidget {
  Buttonjoin(
      {Key? key,
      required this.idcompte,
      required this.statut,
      required this.nom,
      required this.logo,
      required this.offre,
      required this.type,
      required this.idcreate,
      required this.prix})
      : super(key: key);
  String idcompte;
  String statut;
  String logo;
  String offre;
  String type;
  String idcreate;
  String nom;
  int prix;
  @override
  _ButtonjoinState createState() => _ButtonjoinState();
}

class _ButtonjoinState extends State<Buttonjoin> {
  final requ = Get.put(Tabsrequette());
  final instance = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;
  int? wallet;
  String nomuser = "";
  String avataruser = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getinfouser();
  }

  getinfouser() {
    FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc.id == user.uid) {
          setState(() {
            wallet = doc['wallet'];
            nomuser = doc["nom"];
            avataruser = doc["avatar"];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("abonne")
            .where("iduser", isEqualTo: user.uid)
            .where("idcompte", isEqualTo: widget.idcompte)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> abonneinfo) {
          if (!abonneinfo.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (abonneinfo.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return (abonneinfo.data!.docs.isNotEmpty)
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent),
                  onPressed: () {
                    // quitter(abonneinfo.data!.docs.first.id);
                  },
                  child: Text(
                    "Membre",
                    style: GoogleFonts.poppins(color: Colors.black),
                  ))
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade900),
                  onPressed: () {
                    if (widget.statut == "public") {
                      installer();
                    }
                    if (widget.statut == "prive") {
                      sendinvitation(widget.idcompte, widget.logo, widget.nom,
                          widget.type, widget.nom);
                    }
                  },
                  child: const Text(
                    "Rejoindre",
                  ));
        });
  }

  installer() {
    print(user.uid);
    if (widget.offre == "gratuit") {
      requ.rejoindre(widget.nom, widget.idcompte, widget.logo, widget.offre,
          widget.type, widget.idcreate);
    } else {
      requ.byAbonnement(widget.prix, wallet, widget.idcompte, widget.nom,
          widget.logo, widget.offre, widget.type, widget.idcreate);
    }
  }

  sendinvitation(idcompte, logo, nom, type, nomuser) {
    DateTime now = DateTime.now();
    String dateformat = DateFormat("yyyy-MM-dd - kk:mm").format(now);
    FirebaseFirestore.instance.collection("invitation").add({
      "iduser": user.uid,
      "idcompte": widget.idcompte,
      "nom": widget.nom,
      "logo": widget.logo,
      "date": dateformat,
      "range": DateTime.now().millisecondsSinceEpoch,
      "offre": widget.offre,
      "statut": 0,
      "type": widget.type,
      "nomuser": nomuser,
    });
    FirebaseFirestore.instance.collection("notification").add({
      "message": "$nomuser Souhaite intégrer votre nœud.",
      "logo": widget.logo,
      "type": "invitation",
      "iduser": user.uid,
      "idcompte": widget.idcompte,
      "date": dateformat
    });
    FirebaseFirestore.instance
        .collection("noeud")
        .doc(idcompte)
        .update({"notification": FieldValue.increment(1)});
    requ.message("Sucess",
        "Votre demande d'adhésion au nœud $nom a été envoyé avec succès.");
  }
}
