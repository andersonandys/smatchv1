import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:async';

import 'package:smatch/home/tabsrequette.dart';

class Settingsnoeud extends StatefulWidget {
  @override
  _SettingsnoeudState createState() => _SettingsnoeudState();
}

class _SettingsnoeudState extends State<Settingsnoeud> {
  Timer? _timer;
  late double _progress;
  String text =
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,";
  final categoriecontroller = TextEditingController();
  final iduseradmin = TextEditingController();
  final nomcommune = TextEditingController();
  final prixlivraison = TextEditingController();
  final swapmontant = TextEditingController();
  final montantretrait = TextEditingController();
  String erreur = "";
  List userabonne = [];
  List usernoeud = [];
  final Stream<QuerySnapshot> _streambranche = FirebaseFirestore.instance
      .collection('branche')
      .where("id_noeud", isEqualTo: Get.arguments[0]["idnoeud"])
      .snapshots();
  final Stream<QuerySnapshot> _streamuser = FirebaseFirestore.instance
      .collection('abonne')
      .limit(20)
      .where("idcompte", isEqualTo: Get.arguments[0]["idnoeud"])
      .snapshots();
  final userid = FirebaseAuth.instance.currentUser!.uid;
  final requ = Get.put(Tabsrequette());
  String idnoeud = Get.arguments[0]["idnoeud"];
  final Stream<QuerySnapshot> _compte = FirebaseFirestore.instance
      .collection('noeud')
      .where("idcompte", isEqualTo: Get.arguments[0]["idnoeud"])
      .snapshots();

  final Stream<QuerySnapshot> _swap = FirebaseFirestore.instance
      .collection('swap')
      .where("idcompte", isEqualTo: Get.arguments[0]["idnoeud"])
      .snapshots();

  final Stream<QuerySnapshot> _retrait = FirebaseFirestore.instance
      .collection('demande_transaction')
      .where("idcompte", isEqualTo: Get.arguments[0]["idnoeud"])
      .snapshots();
  String choix = "users";
  final controller = PageController(initialPage: 0);
  final reqsetting = Get.put(settingsnoeud());
  List alluser = [];
  List swaplist = [];
  List retraitlist = [];
  String nomnoeud = Get.arguments[1]["nomnoeud"];
  String idcreat = Get.arguments[2]["idcreat"];
  @override
  void initState() {
    super.initState();
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });
    getadmin();
    getabonne();
    getuser();
    getswap();
    getretrait();
  }

  getadmin() {
    FirebaseFirestore.instance
        .collection('abonne')
        .where("idcompte", isEqualTo: Get.arguments[0]["idnoeud"])
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        usernoeud = querySnapshot.docs;
        print(usernoeud);
      });
    });
  }

  getabonne() {
    FirebaseFirestore.instance
        .collection('abonne')
        .where("idcompte", isEqualTo: Get.arguments[0]["idnoeud"])
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        userabonne = querySnapshot.docs;
      });
    });
  }

  getswap() {
    FirebaseFirestore.instance
        .collection('swap')
        .where("idcompte", isEqualTo: Get.arguments[0]["idnoeud"])
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        swaplist = querySnapshot.docs;
      });
    });
  }

  getretrait() {
    FirebaseFirestore.instance
        .collection('demande_transaction')
        .where("idcompte", isEqualTo: Get.arguments[0]["idnoeud"])
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        retraitlist = querySnapshot.docs;
      });
    });
  }

  getuser() {
    FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        alluser = querySnapshot.docs;
      });
    });
  }

  final walletnumero = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withBlue(25),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black.withBlue(25),
          title: Text(
            nomnoeud,
            style: GoogleFonts.poppins(),
          ),
        ),
        body: PageView(
          controller: controller,
          children: [_wallet(), _settings()],
        ));
  }

//  les differentes pas de la section

  Widget _wallet() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: StreamBuilder(
            stream: _compte,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> wallet) {
              if (!wallet.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (wallet.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: wallet.data!.docs.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [
                                        Colors.blue.shade800,
                                        Colors.orange.shade900,
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                height: 200,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Align(
                                      alignment: Alignment.topRight,
                                      child: Text(
                                        'Smatch pay',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      'Votre solde',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Center(
                                      child: Text(
                                        (!wallet.data!.docs[index]["masque"])
                                            ? "${wallet.data!.docs[index]["wallet"]} FCFA"
                                            : "******** FCFA",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      'Validité',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "12/2023",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                              if (wallet.data!.docs[index]
                                                  ["masque"]) {
                                                FirebaseFirestore.instance
                                                    .collection("noeud")
                                                    .doc(idnoeud)
                                                    .update({"masque": false});
                                              } else {
                                                FirebaseFirestore.instance
                                                    .collection("noeud")
                                                    .doc(idnoeud)
                                                    .update({"masque": true});
                                              }
                                            },
                                            child: (wallet.data!.docs[index]
                                                    ["masque"])
                                                ? const Icon(
                                                    Iconsax.eye_slash,
                                                    color: Colors.white,
                                                  )
                                                : const Icon(
                                                    Iconsax.eye,
                                                    color: Colors.white,
                                                  ))
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Column(
                              children: <Widget>[
                                GestureDetector(
                                  child: Container(
                                    height: 90,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: const [
                                        Icon(
                                          Iconsax.money_add,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "Swap",
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    swap(wallet.data!.docs[index]["wallet"]);
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                GestureDetector(
                                  child: Container(
                                    height: 90,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: const [
                                        Icon(
                                          Iconsax.money_add,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "Retrait",
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    retrait(wallet.data!.docs[index]["wallet"]);
                                  },
                                ),
                              ],
                            ))
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ActionChip(
                                padding: const EdgeInsets.all(10),
                                label: const Text("Utilisateur"),
                                onPressed: () {
                                  reqsetting.choix("users");
                                }),
                            ActionChip(
                                padding: const EdgeInsets.all(10),
                                label: const Text("Swap"),
                                onPressed: () {
                                  getswap();
                                  reqsetting.choix("swap");
                                }),
                            ActionChip(
                                padding: const EdgeInsets.all(10),
                                label: const Text("Retrait"),
                                onPressed: () {
                                  getretrait();
                                  reqsetting.choix("retrait");
                                })
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Obx(() => (reqsetting.choixnoeud.value == "users")
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    'Utilisateurs',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ListView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: userabonne.length,
                                      itemBuilder: (context, index) {
                                        return (userabonne.isEmpty)
                                            ? const Center(
                                                child: Text(
                                                  'Aucun utilisateur trouvé',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              )
                                            : Column(
                                                children: <Widget>[
                                                  for (var allusers in alluser)
                                                    if (allusers['iduser'] ==
                                                        userabonne[index]
                                                            ['iduser'])
                                                      Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(3),
                                                          child: ListTile(
                                                            leading: Text(
                                                              allusers['nom'],
                                                              style: const TextStyle(
                                                                  fontSize: 19,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            trailing:
                                                                ActionChip(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              backgroundColor: (idcreat ==
                                                                      userabonne[
                                                                              index]
                                                                          [
                                                                          'iduser']
                                                                  ? Colors
                                                                      .blueAccent
                                                                  : Colors.red),
                                                              onPressed: () {
                                                                if (idcreat !=
                                                                    userabonne[
                                                                            index]
                                                                        [
                                                                        'iduser']) {
                                                                  deleteuser(
                                                                      userabonne[
                                                                              index]
                                                                          .id);
                                                                }
                                                              },
                                                              label: Text(
                                                                (idcreat ==
                                                                        userabonne[index]
                                                                            [
                                                                            'iduser']
                                                                    ? "Super admin"
                                                                    : 'Supprimer'),
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ))
                                                ],
                                              );
                                      })
                                ],
                              )
                            : const SizedBox()),
                        Obx(() => (reqsetting.choixnoeud.value == "swap")
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    'swap',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  (swaplist.isEmpty)
                                      ? Column(
                                          children: const <Widget>[
                                            Center(
                                              child: Text(
                                                'Aucun swap trouvé',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 50,
                                            ),
                                            Center(
                                              child: Text(
                                                "Vous pouvez voir les paramètres en swipant (glisser la main sur l'écran) de la droite vers la gauche.",
                                                style: TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 17),
                                              ),
                                            )
                                          ],
                                        )
                                      : ListView.builder(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: swaplist.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                                margin: const EdgeInsets.all(3),
                                                child: ListTile(
                                                  leading: Text(
                                                    "Swap de : " +
                                                        swaplist[index]
                                                            ['montant'] +
                                                        "FCFA",
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white),
                                                  ),
                                                  trailing: const Chip(
                                                    backgroundColor:
                                                        Colors.greenAccent,
                                                    label: Text(
                                                      "Effectué",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ));
                                          })
                                ],
                              )
                            : const SizedBox()),
                        Obx(() => (reqsetting.choixnoeud.value == "retrait")
                            ? (retraitlist.isEmpty)
                                ? Column(
                                    children: const <Widget>[
                                      Center(
                                        child: Text(
                                          'Aucune demande de transaction trouvé',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 50,
                                      ),
                                      Center(
                                        child: Text(
                                          " Vous pouvez voir les paramètres en swipant (glisser la main sur l'écran) de la droite vers la gauche.",
                                          style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 17),
                                        ),
                                      )
                                    ],
                                  )
                                : ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: retraitlist.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                          margin: const EdgeInsets.all(3),
                                          child: ListTile(
                                              leading: Text(
                                                "${retraitlist[index]['montant']} FCFA",
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white),
                                              ),
                                              trailing: (retraitlist[index]
                                                      ['ready'])
                                                  ? const Chip(
                                                      backgroundColor:
                                                          Colors.greenAccent,
                                                      label: Text(
                                                        "Effectué",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )
                                                  : const Chip(
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      label: Text(
                                                        "En cours de traitement",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )));
                                    })
                            : const SizedBox())
                      ],
                    );
                  });
            }),
      ),
    );
  }

  Widget _settings() {
    return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('noeud')
                .where("idcompte", isEqualTo: idnoeud)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> _compte) {
              if (!_compte.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (_compte.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _compte.data!.docs.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: CachedNetworkImageProvider(
                            _compte.data!.docs[index]['logo'],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(),
                        Text(
                          _compte.data!.docs[index]['nom'],
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 20),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Configuration de votre noeud",
                            style: GoogleFonts.poppins(
                                color: Colors.white54, fontSize: 16),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(),
                        // changement de design
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Listes des branches",
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 16),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    viewbranche();
                                  },
                                  child: const Icon(
                                    Iconsax.eye,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(),
                        // ajout de categorie
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Listes des utilisateurs",
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 16),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    viewuser(
                                        _compte.data!.docs[index]['idcreat']);
                                  },
                                  child: const Icon(
                                    Iconsax.eye,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        // ajout d'administrateur
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Administration",
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 16),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    displayadmin(
                                        _compte.data!.docs[index]['idcreat']);
                                  },
                                  child: const Icon(
                                    Iconsax.eye,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    addadmin(
                                        _compte.data!.docs[index]["nom"],
                                        _compte.data!.docs[index]["logo"],
                                        _compte.data!.docs[index]["offre"],
                                        _compte.data!.docs[index]["type"]);
                                  },
                                  child: const Icon(
                                    Iconsax.pen_add,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),

                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Configuration wallet",
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 16),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    walletconfig(_compte.data!.docs[index]
                                        ["type_paiement"]);
                                  },
                                  child: const Icon(
                                    Iconsax.pen_add,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        // activation du compte publicitaire
                        const SizedBox(
                          height: 10,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Production",
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 16),
                            ),
                            Row(
                              children: [
                                Switch.adaptive(
                                    value: _compte.data!.docs[index]["mode"],
                                    onChanged: (value) {
                                      if (value) {
                                        requ.message("Succes",
                                            "Votre nœud est passé en mode de production, elle pourra être visible par tout le monde.");
                                      } else {
                                        requ.message("Success",
                                            "Votre nœud est passé en mode développement, elle ne pourra pas être visible par tout le monde.");
                                      }
                                      FirebaseFirestore.instance
                                          .collection("noeud")
                                          .doc(idnoeud)
                                          .update({"mode": value});
                                    })
                              ],
                            )
                          ],
                        ),
                      ],
                    );
                  });
            }));
  }

// afficher les categories
  viewbranche() {
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
              return SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Container(
                          height: 5,
                          width: 50,
                          decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text("Liste des branches",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(
                          height: 10,
                        ),
                        StreamBuilder(
                            stream: _streambranche,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> _categorie) {
                              if (!_categorie.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (_categorie.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _categorie.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _categorie.data!.docs[index]
                                                  ["nom"],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            ActionChip(
                                                backgroundColor: Colors.red,
                                                label: Text("Supprimer",
                                                    style: GoogleFonts.poppins(
                                                        color: Colors.white)),
                                                onPressed: () {
                                                  confirmdeletebranche(
                                                      _categorie.data!
                                                          .docs[index].id);
                                                })
                                          ],
                                        ),
                                        const Divider()
                                      ],
                                    );
                                  });
                            })
                      ],
                    )),
              );
            },
          );
        });
  }

// listes des utilisateur
  viewuser(idcreat) {
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
              return SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Container(
                          height: 5,
                          width: 50,
                          decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text("Liste des utilisateurs",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(
                          height: 10,
                        ),
                        StreamBuilder(
                            stream: _streamuser,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> _userliste) {
                              if (!_userliste.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (_userliste.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _userliste.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        for (var allusers in alluser)
                                          if (allusers['iduser'] ==
                                              _userliste.data!.docs[index]
                                                  ['iduser'])
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  allusers["nom"],
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                (idcreat ==
                                                        _userliste.data!
                                                                .docs[index]
                                                            ["iduser"])
                                                    ? ActionChip(
                                                        backgroundColor:
                                                            Colors.blueAccent,
                                                        label: Text(
                                                            "Super admin",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    color: Colors
                                                                        .white)),
                                                        onPressed: () {})
                                                    : ActionChip(
                                                        backgroundColor:
                                                            Colors.red,
                                                        label: Text("Supprimer",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    color: Colors
                                                                        .white)),
                                                        onPressed: () {
                                                          confirmdeleteuser(
                                                              _userliste
                                                                  .data!
                                                                  .docs[index]
                                                                  .id,
                                                              idcreat);
                                                        })
                                              ],
                                            ),
                                        const Divider()
                                      ],
                                    );
                                  });
                            })
                      ],
                    )),
              );
            },
          );
        });
  }

  retrait(montant) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Demande de retrait'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                  "Entrer le montant que vous souhaiter retirer",
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  cursorHeight: 20,
                  autofocus: false,
                  controller: montantretrait,
                  decoration: InputDecoration(
                    labelText: "Montant",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
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
              child: const Text('Valider'),
              onPressed: () {
                if (montantretrait.text.isEmpty) {
                  requ.message(
                      "Echec", "Nous vous prions de rentrer un montant");
                } else if (montant < int.parse(montantretrait.text)) {
                  requ.message("Echec",
                      "Désolé montant insuffisant pour effectuer cette transaction");
                } else {
                  var newmontant = int.parse(montantretrait.text);
                  FirebaseFirestore.instance
                      .collection("demande_transaction")
                      .add({
                    "montant": newmontant,
                    "idcompte": idnoeud,
                    "date": DateTime.now(),
                    "ready": false
                  });
                  Navigator.of(context).pop();
                  montantretrait.clear();
                  requ.message("sucess", "Opération effectuée avec succès");
                }
              },
            ),
          ],
        );
      },
    );
  }

  swap(montant) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Swap de montant'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                  "Entrer le montant que vous souhaiter Swaper sur votre wallet utilisateur",
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  cursorHeight: 20,
                  autofocus: false,
                  controller: swapmontant,
                  decoration: InputDecoration(
                    labelText: "Montant",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
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
              child: const Text('Valider'),
              onPressed: () {
                if (swapmontant.text.isEmpty) {
                  requ.message(
                      "Echec", "Nous vous prions de rentrer un montant");
                } else if (montant < int.parse(swapmontant.text)) {
                  requ.message("Echec",
                      "Désolé montant insuffisant pour effectuer cette transaction");
                } else {
                  var newmontant = int.parse(swapmontant.text);
                  FirebaseFirestore.instance
                      .collection("noeud")
                      .doc(idnoeud)
                      .update({"wallet": FieldValue.increment(-newmontant)});
                  FirebaseFirestore.instance
                      .collection("users")
                      .doc(userid)
                      .update({"wallet": FieldValue.increment(newmontant)});
                  FirebaseFirestore.instance.collection("swap").add({
                    "montant": swapmontant.text,
                    "idcompte": idnoeud,
                    "date": DateTime.now()
                  });
                  Navigator.of(context).pop();

                  requ.message("sucess", "Opération effectuée avec succès");
                  swapmontant.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }

  confirmdeleteuser(idusercompte, idcreat) {
    if (idcreat == idusercompte) {
      requ.message(
          "Echec", "Vous ne pouvez pas supprimer le créateur du noeud");
    } else {
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
                    "Vous êtes sur le point de supprimer cet utilisateur.",
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
                child: const Text('Oui supprimer'),
                onPressed: () {
                  Navigator.of(context).pop();
                  FirebaseFirestore.instance
                      .collection("abonne")
                      .doc(idusercompte)
                      .delete();
                  requ.message("sucess", "Utilisateur supprimé avec succès");
                },
              ),
            ],
          );
        },
      );
    }
  }

// afficher les administrateur
  displayadmin(idcreat) {
    showMaterialModalBottomSheet(
        backgroundColor: Colors.black.withBlue(25),
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        builder: (context) => SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        height: 5,
                        width: 50,
                        decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Liste des administrateurs",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('abonne')
                              .where("idcompte", isEqualTo: idnoeud)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> _admin) {
                            if (!_admin.hasData) {
                              return Center(
                                child: LoadingAnimationWidget.dotsTriangle(
                                  color: Colors.blueAccent,
                                  size: 100,
                                ),
                              );
                            }
                            if (_admin.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: LoadingAnimationWidget.dotsTriangle(
                                  color: Colors.blueAccent,
                                  size: 100,
                                ),
                              );
                            }
                            return ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _admin.data!.docs.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onDoubleTap: () {},
                                    child: Column(
                                      children: [
                                        for (var allusers in alluser)
                                          if (allusers['iduser'] ==
                                                      _admin.data!.docs[index]
                                                          ['iduser'] &&
                                                  _admin.data!.docs[index]
                                                          ['statut'] ==
                                                      1 ||
                                              _admin.data!.docs[index]
                                                      ['idcreat'] ==
                                                  allusers['iduser'])
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(allusers["nom"],
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                (idcreat ==
                                                        _admin.data!.docs[index]
                                                            ["iduser"])
                                                    ? ActionChip(
                                                        backgroundColor:
                                                            Colors.lightBlue,
                                                        label: Text(
                                                            "Super admin",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    color: Colors
                                                                        .white)),
                                                        onPressed: () {})
                                                    : ActionChip(
                                                        backgroundColor:
                                                            Colors.lightBlue,
                                                        label: Text(
                                                            "Retirer admin",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    color: Colors
                                                                        .white)),
                                                        onPressed: () {
                                                          deleteadmin(
                                                              _admin
                                                                  .data!
                                                                  .docs[index]
                                                                  .id,
                                                              0);
                                                        })
                                              ],
                                            ),
                                        const Divider()
                                      ],
                                    ),
                                  );
                                });
                          })
                    ],
                  )),
            ));
  }

// suppresion administrateur

  deleteadmin(idamin, type) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                (type == 0)
                    ? const Text(
                        "Vous êtes sur le point de supprimer cet utilisateur en tant qu'administrateur.",
                      )
                    : const Text(
                        "Vous êtes sur le point d'ajouter cet utilisateur en tant qu'administrateur.",
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
              child: (type == 0)
                  ? const Text('Oui supprimer')
                  : const Text('Oui Ajouter'),
              onPressed: () {
                Navigator.of(context).pop();
                if (type == 0) {
                  FirebaseFirestore.instance
                      .collection("abonne")
                      .doc(idamin)
                      .update({"statut": type});
                  requ.message("sucess", "Administrateur supprimé avec succès");
                } else {
                  FirebaseFirestore.instance
                      .collection("abonne")
                      .doc(idamin)
                      .update({"statut": type});
                  requ.message("sucess", "Administrateur ajouté avec succès");
                }
              },
            ),
          ],
        );
      },
    );
  }

  deleteuser(idusercompte) {
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
                  "Vous êtes sur le point de supprimer cet utilisateur.",
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
              child: const Text('Oui supprimer'),
              onPressed: () {
                Navigator.of(context).pop();
                FirebaseFirestore.instance
                    .collection("abonne")
                    .doc(idusercompte)
                    .delete();
                requ.message("sucess", "Utilisateur supprimé avec succès");
              },
            ),
          ],
        );
      },
    );
  }
// suppression de categorie

  confirmdeletebranche(idcategorie) {
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
                  "En supprimant cette branche, vous allez perdre toutes les données qui y sont liées.",
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
              child: const Text('Oui supprimer'),
              onPressed: () {
                Navigator.of(context).pop();
                FirebaseFirestore.instance
                    .collection("branche")
                    .doc(idcategorie)
                    .delete();
                requ.message("sucess", "Branche supprimé avec succès");
              },
            ),
          ],
        );
      },
    );
  }

  // configuration wallet
  walletconfig(type) {
    // requ.message("Echec", "Cette fonction n'est pas disponible pour vous");

    showModalBottomSheet(
        backgroundColor: Colors.black.withBlue(20),
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
              return SingleChildScrollView(
                child: Container(
                    margin:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                    child: Column(
                      children: [
                        Container(
                          height: 5,
                          width: 50,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Align(
                            alignment: Alignment.topLeft,
                            child: TextButton(
                              onPressed: () {
                                setState(() {});
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                "Nous vous prions de choisir le système de transaction qui vous arrange le plus pour vos transactions. Cette configuration vous permet de définir le moyen de retrait adéquat pour vos transactions.",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                                textAlign: TextAlign.justify,
                              ),
                            )),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  addwallet(
                                      'om',
                                      "Ajout de compte OM",
                                      "Rentrer votre numéro Orange Money. \n ce numéro sera utilisé pour vos transactions de retrait de fonds",
                                      "Nous vous prions de saisir votre numéro orange Money.",
                                      "Numero OM");
                                },
                                child: Stack(
                                  children: [
                                    if (type == "om")
                                      const Positioned(
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.greenAccent,
                                        ),
                                        right: 10,
                                        top: 5,
                                      ),
                                    Container(
                                        height: 100,
                                        width: 150,
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        child: const Center(
                                          child: Text(
                                            "ORANGE money",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                        )),
                                  ],
                                )),
                            GestureDetector(
                                onTap: () {
                                  addwallet(
                                      'mtn',
                                      "Ajout de compte MTN",
                                      "Rentrer votre numéro MTN. \n ce numéro sera utilisé pour vos transactions de retrait de fonds",
                                      "Nous vous prions de saisir votre numéro MTN Money.",
                                      "Numero MTN  Money");
                                },
                                child: Stack(
                                  children: [
                                    if (type == "mtn")
                                      const Positioned(
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.greenAccent,
                                        ),
                                        right: 10,
                                        top: 5,
                                      ),
                                    Container(
                                        height: 100,
                                        width: 150,
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        child: const Center(
                                          child: Text(
                                            "MTN money",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                        )),
                                  ],
                                ))
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  addwallet(
                                      'cb',
                                      "Ajout de CB",
                                      "Rentrer le numéro de votre CB. \n cette carte bancaire sera utilisé pour vos transactions de retrait de fonds",
                                      "Nous vous prions de saisir le numéro de votre CB",
                                      "Numero CB");
                                },
                                child: Stack(
                                  children: [
                                    if (type == "cb")
                                      const Positioned(
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.greenAccent,
                                        ),
                                        right: 10,
                                        top: 5,
                                      ),
                                    Container(
                                        height: 100,
                                        width: 150,
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        child: const Center(
                                          child: Text(
                                            "Carte bancaire",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                        )),
                                  ],
                                )),
                            GestureDetector(
                                onTap: () {
                                  addwallet(
                                      'tezos',
                                      "Ajout d'adresse TEZOS",
                                      "Rentrer votre adresse TEZOS. \n cette adresse sera utilisé pour vos transactions de retrait de fonds",
                                      "Nous vous prions de saisir votre adresse TEZOS.",
                                      "Adress TEZOS");
                                },
                                child: Stack(
                                  children: [
                                    if (type == "tezos")
                                      const Positioned(
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.greenAccent,
                                        ),
                                        right: 10,
                                        top: 5,
                                      ),
                                    Container(
                                        height: 100,
                                        width: 150,
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        child: const Center(
                                          child: Text(
                                            "Tezos",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                        )),
                                  ],
                                ))
                          ],
                        )
                      ],
                    )),
              );
            },
          );
        });
  }

  // configuration du wallet
  addwallet(type, title, info, erreurs, label) async {
    // ajout d'un administrateur

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(info),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  cursorHeight: 20,
                  autofocus: false,
                  controller: walletnumero,
                  decoration: InputDecoration(
                    labelText: label,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  walletnumero.clear();
                },
                child: const Text(
                  ' Annuler',
                  style: TextStyle(color: Colors.black),
                )),
            const SizedBox(
              width: 20,
            ),
            TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.orange.shade900)),
              child: const Text('Ajouter'),
              onPressed: () {
                print("object");
                if (walletnumero.text.isEmpty) {
                  requ.message("Echec", erreurs);
                } else {
                  FirebaseFirestore.instance
                      .collection("noeud")
                      .doc(idnoeud)
                      .update({
                    "type_paiement": type,
                    "contenu": walletnumero.text
                  });
                  walletnumero.clear();
                  Navigator.of(context).pop();
                  requ.message("success", "Configuration prise en compte");
                }
              },
            ),
          ],
        );
      },
    );
  }

  addadmin(nomnoeud, logo, offre, type) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ajout d'administrateur"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                  "Entrer l'identifiant (ID) de l'utilisateur",
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  cursorHeight: 20,
                  autofocus: false,
                  controller: iduseradmin,
                  decoration: InputDecoration(
                    labelText: "Identifiant utilisateur",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  iduseradmin.clear();
                },
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Colors.black),
                )),
            const SizedBox(
              width: 20,
            ),
            TextButton(
              child: const Text('Ajouter'),
              onPressed: () {
                if (iduseradmin.text.isEmpty) {
                  requ.message(
                      "Echec", "Vous devez saisir un identifiant utilisateur");
                } else {
                  var resultuser = alluser
                      .where(
                          (user) => user["iduser"].contains(iduseradmin.text))
                      .toList();

                  if (resultuser.isEmpty) {
                    requ.message("Echec",
                        "Aucun utilisateur ne correspond à cet ID, nous vous prions de vérifier l'identifiant saisis");
                  } else {
                    FirebaseFirestore.instance
                        .collection('abonne')
                        .where('idcompte', isEqualTo: idnoeud)
                        .get()
                        .then((QuerySnapshot value) {
                      var resultabonne = value.docs
                          .where((user) =>
                              user["iduser"].contains(iduseradmin.text))
                          .toList();
                      print(resultabonne);

                      if (resultabonne.isEmpty) {
                        FirebaseFirestore.instance.collection("abonne").add({
                          "iduser": resultuser.first['iduser'],
                          "idcompte": idnoeud,
                          "nom": nomnoeud,
                          "logo": logo,
                          "date": DateTime.now(),
                          "offre": offre,
                          "statut": 1,
                          "type": type,
                          "nomuser": resultuser.first["nom"],
                          "idcreat": "",
                          "range": DateTime.now().millisecondsSinceEpoch
                        }).then((value) => requ.message("echec", value.id));
                        requ.message(
                            "success", "Administrateur ajouté avec succès");
                        iduseradmin.clear();
                        print('ok');
                        Navigator.of(context).pop();
                      } else {
                        print("non");
                        for (var item in resultabonne) {
                          FirebaseFirestore.instance
                              .collection('abonne')
                              .doc(item.id)
                              .update({"statut": 1});
                          Navigator.of(context).pop();
                        }
                        iduseradmin.clear();
                        requ.message(
                            "Success", "Administrateur ajouté avec succès");
                      }
                    });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class settingsnoeud extends GetxController {
  var choixnoeud = "users".obs;

  choix(value) {
    choixnoeud.value = value;
  }
}

//  print("ok1");
//                         for (var itemuser in userabonne) {
//                           if (itemuser['iduser'].toString().substring(0, 5) ==
//                               iduseradmin.text) {
//                             FirebaseFirestore.instance
//                                 .collection('abonne')
//                                 .doc(itemuser.id)
//                                 .update({"statut": 1});
//                           } else {
//                             FirebaseFirestore.instance
//                                 .collection("abonne")
//                                 .add({
//                               "iduser": alluser.id,
//                               "idcompte": idnoeud,
//                               "nom": nomnoeud,
//                               "logo": logo,
//                               "date": DateTime.now(),
//                               "offre": offre,
//                               "statut": 1,
//                               "type": type,
//                               "nomuser": alluser["nom"]
//                             });
//                             requ.message("success",
//                                 "Administrateur ajouté avec success");
//                             iduseradmin.clear();
//                             Navigator.of(context).pop();
//                           }
//                         }
