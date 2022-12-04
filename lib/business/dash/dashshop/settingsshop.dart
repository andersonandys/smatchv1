import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:async';

import 'package:smatch/home/tabsrequette.dart';

class Settingsshop extends StatefulWidget {
  @override
  _SettingsshopState createState() => _SettingsshopState();
}

class _SettingsshopState extends State<Settingsshop> {
  Timer? _timer;
  String idshop = Get.arguments[0]["idshop"];
  late double _progress;
  String text =
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,";
  final categoriecontroller = TextEditingController();
  final iduseradmin = TextEditingController();
  final nomcommune = TextEditingController();
  final prixlivraison = TextEditingController();
  List alluser = [];
  List userabonne = [];
  @override
  void initState() {
    super.initState();
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });
    // EasyLoading.showSuccess('Use in initState');
    // EasyLoading.removeCallbacks();
    getuser();
    getabonne();
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

  getabonne() {
    FirebaseFirestore.instance
        .collection('abonne')
        .where("idcompte", isEqualTo: Get.arguments[0]["idshop"])
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        userabonne = querySnapshot.docs;
      });
    });
  }

  final requ = Get.put(Tabsrequette());

  String userid = FirebaseAuth.instance.currentUser!.uid;
  final Stream<QuerySnapshot> _compte = FirebaseFirestore.instance
      .collection('noeud')
      .where("idcompte", isEqualTo: Get.arguments[0]["idshop"])
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(25),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withBlue(25),
        title: Text(
          "Paramètre",
          style: GoogleFonts.poppins(),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: StreamBuilder(
              stream: _compte,
              builder:
                  (BuildContext context, AsyncSnapshot<QuerySnapshot> _compte) {
                if (!_compte.hasData) {
                  return const Center(
                      heightFactor: 10, child: CircularProgressIndicator());
                }
                if (_compte.connectionState == ConnectionState.waiting) {
                  return const Center(
                      heightFactor: 10, child: CircularProgressIndicator());
                }
                return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _compte.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: CachedNetworkImageProvider(
                                _compte.data!.docs[index]['logo']),
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
                              "Configuration de la boutique",
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
                                "Prévisualiser",
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed(
                                          "/${_compte.data!.docs[index]["design"]}",
                                          arguments: [
                                            {"idshop": idshop},
                                            {
                                              "nomshop": _compte
                                                  .data!.docs[index]["nom"]
                                            },
                                          ]);
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
                          // choix des design
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Apparence",
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      changedesign(
                                          _compte.data!.docs[index]["design"]);
                                      print(_compte.data!.docs[index].id);
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
                                "Catégorie de la boutique",
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      displaycategorie();
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
                                      addcategorie();
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

                          // Ajouter des emplacement
                          if (_compte.data!.docs[index]["design"] == "2")
                            Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Emplacement des produits",
                                      style: GoogleFonts.poppins(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            displayemplacement();
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
                                            addemplacement();
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
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      print(
                                          _compte.data!.docs[index]['idcreat']);
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
                          // ajout de la livraison
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Système de livraison",
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      viewlivraison();
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
                                      addlivraison();
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
                                              "Votre boutique est passée en mode de production, elle pourra être visible par tout le monde.");
                                        } else {
                                          requ.message("Success",
                                              "Votre boutique est passée en mode développement, elle ne pourra pas être visible par tout le monde.");
                                        }
                                        FirebaseFirestore.instance
                                            .collection("noeud")
                                            .doc(idshop)
                                            .update({"mode": value});
                                      })
                                ],
                              )
                            ],
                          ),
                        ],
                      );
                    });
              })),
    );
  }

// gestion du changement de design
  changedesign(String design) {
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
                  child: Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 10, bottom: 10),
                child: Column(
                  children: [
                    Container(
                      height: 5,
                      width: 50,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Light",
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        ChoiceChip(
                          selectedColor: Colors.green,
                          disabledColor: Colors.grey,
                          labelStyle: (design == "1")
                              ? const TextStyle(color: Colors.white)
                              : const TextStyle(color: Colors.black),
                          label: Text(
                            (design == "1") ? "Desactivée" : "Activée",
                          ),
                          selected: (design == "1") ? true : false,
                          onSelected: (value) {
                            if (design != "1") {
                              Navigator.of(context).pop;
                              confirmdesign("1");
                            }
                          },
                        )
                      ],
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                          "Présente un design assez simple, pour une utilisation sans effort et immédiat sans passer par beaucoup de configuration. L'apparence Light est faite pour les débutants en e-commerce.",
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                          textAlign: TextAlign.justify),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Light+",
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        ChoiceChip(
                          selectedColor: Colors.green,
                          disabledColor: Colors.grey,
                          labelStyle: (design == "2")
                              ? const TextStyle(color: Colors.white)
                              : const TextStyle(color: Colors.black),
                          label: Text(
                            (design == "2") ? "Desactivée" : "Activée",
                            style: GoogleFonts.poppins(),
                          ),
                          selected: (design == "2") ? true : false,
                          onSelected: (value) {
                            if (design != "2") {
                              Navigator.of(context).pop;
                              confirmdesign("2");
                            }
                          },
                        )
                      ],
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                          "Présente un design unique et une configuration assez libre. Elle octroie plus de fonctionnalité et une meilleure gestion d'une boutique. L'apparence Light+ est faite pour des personnes possédant déjà une boutique e-commerce et ayant des bases dans ce domaine.",
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                          textAlign: TextAlign.justify),
                    ),
                  ],
                ),
              ));
            },
          );
        });
  }

// afficher les categories
  displaycategorie() {
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
                        Text("Liste des catégories",
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('categorie')
                                .where("idcompte", isEqualTo: idshop)
                                .orderBy("range", descending: true)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> _categorie) {
                              if (!_categorie.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (_categorie.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
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
                                                    ["nomcategorie"],
                                                style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            ActionChip(
                                                backgroundColor: Colors.red,
                                                label: Text("Supprimer",
                                                    style: GoogleFonts.poppins(
                                                        color: Colors.white)),
                                                onPressed: () {
                                                  confirmdeletecategorie(
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

//  afficher les emplacement des produit
  displayemplacement() {
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
                        Text("Liste des emplacements produit",
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 20,
                        ),
                        StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('emplacement')
                                .where("idcompte", isEqualTo: idshop)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> _emplacement) {
                              if (!_emplacement.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (_emplacement.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _emplacement.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        ListTile(
                                            title: Text(
                                                _emplacement.data!.docs[index]
                                                    ["nomemplacement"],
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            trailing: ActionChip(
                                                backgroundColor: Colors.red,
                                                label: Text("Supprimer",
                                                    style: GoogleFonts.poppins(
                                                        color: Colors.white)),
                                                onPressed: () {
                                                  print(_emplacement
                                                      .data!.docs[index].id);
                                                  confirmdeletemplacement(
                                                      _emplacement.data!
                                                          .docs[index].id);
                                                })),
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

// afficher les administrateur
  displayadmin(idcreat) {
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
                        Text("Liste des administrateurs",
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 20,
                        ),
                        StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('abonne')
                                .where("idcompte", isEqualTo: idshop)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> _admin) {
                              if (!_admin.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (_admin.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _admin.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        for (var allusers in alluser)
                                          if (allusers['iduser'] ==
                                                      _admin.data!.docs[index]
                                                          ['iduser'] &&
                                                  _admin.data!.docs[index]
                                                          ['statut'] ==
                                                      1 ||
                                              idcreat == allusers['iduser'])
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(allusers["nom"],
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 18,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                (_admin.data!.docs[index]
                                                            ['idcreat'] ==
                                                        allusers['iduser'])
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
                                                            _admin.data!
                                                                .docs[index].id,
                                                          );
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

// ajout d'un administrateur
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
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.orange.shade900)),
              child: const Text('Ajouter'),
              onPressed: () {
                if (iduseradmin.text.isEmpty) {
                  requ.message(
                      "Echec", "Vous devez saisir un identifiant utilisateur.");
                } else {
                  var resultuser = alluser
                      .where(
                          (user) => user["iduser"].contains(iduseradmin.text))
                      .toList();
                  DateTime now = DateTime.now();
                  String dateformat =
                      DateFormat("yyyy-MM-dd - kk:mm").format(now);
                  if (resultuser.isEmpty) {
                    requ.message("Echec",
                        "Aucun utilisateur ne correspond à cet ID, nous vous prions de vérifier l'identifiant");
                  } else {
                    print(iduseradmin.text);

                    FirebaseFirestore.instance
                        .collection('abonne')
                        .where('idcompte', isEqualTo: idshop)
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
                          "idcompte": idshop,
                          "nom": nomnoeud,
                          "logo": logo,
                          "date": dateformat,
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

// suppresion administrateur
  deleteadmin(idamin) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Vous êtes sur le point de supprimer cet utilisateur en tant qu'administrateur.",
                  style: GoogleFonts.poppins(),
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
              child: const Text('Oui supprimer'),
              onPressed: () {
                Navigator.of(context).pop();
                FirebaseFirestore.instance
                    .collection("abonne")
                    .doc(idamin)
                    .update({"statut": 0});
                requ.message("sucess", "Administrateur supprimé avec succès");
              },
            ),
          ],
        );
      },
    );
  }

// suppression de categorie
  confirmdeletecategorie(idcategorie) {
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
                  "En supprimant cette catégorie, vous allez perdre toutes les données qui y sont liées.",
                  style: GoogleFonts.poppins(),
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
              child: const Text('Oui supprimer'),
              onPressed: () {
                Navigator.of(context).pop();
                FirebaseFirestore.instance
                    .collection("categorie")
                    .doc(idcategorie)
                    .delete();
                requ.message("sucess", "Votre demande a été prise en compte");
              },
            ),
          ],
        );
      },
    );
  }

  // delete emplacement
  confirmdeletemplacement(idemplacement) {
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
                  "En supprimant cet emplacement, vous allez perdre toutes les données qui y sont liées.",
                  style: GoogleFonts.poppins(),
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
              child: const Text('Oui supprimer'),
              onPressed: () {
                Navigator.of(context).pop();
                FirebaseFirestore.instance
                    .collection("emplacement")
                    .doc(idemplacement)
                    .delete();
                requ.message("sucess", "Emplacement supprimé avec succès");
              },
            ),
          ],
        );
      },
    );
  }

//  confirmation du chnagement du design
  confirmdesign(String design) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de modification'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Vous êtes sur le point de modifier le design total de votre boutique.",
                  style: GoogleFonts.poppins(),
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
              child: const Text('Oui modifier'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection("noeud")
                    .doc(idshop)
                    .update({"design": design});
                _progress = 0;
                _timer?.cancel();
                _timer = Timer.periodic(const Duration(milliseconds: 100),
                    (Timer timer) {
                  EasyLoading.showProgress(_progress,
                      maskType: EasyLoadingMaskType.black,
                      status:
                          "${(_progress * 100).toStringAsFixed(0)}% \n Changement général de l'apparence de votre boutique \n Patientez s'il vous plaît");
                  _progress += 0.01;

                  if (_progress >= 1) {
                    _timer?.cancel();
                    EasyLoading.dismiss();
                    requ.message("Succes",
                        "Le changement d'apparence va être effectif dans peu de temps. Nous vous prions de patienter.");

                    categoriecontroller.clear();
                    Navigator.of(context).pop();
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

//  ajout de la categorie
  addcategorie() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajout de catégorie'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Entrer le nom d'une catégorie",
                    style: GoogleFonts.poppins()),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  cursorHeight: 20,
                  autofocus: false,
                  controller: categoriecontroller,
                  decoration: InputDecoration(
                    labelText: "catégorie",
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
              child: const Text('Ajouter'),
              onPressed: () {
                if (categoriecontroller.text.isEmpty) {
                  requ.message("Echec",
                      "Vous devez saisir un nom pour votre catégorie.");
                } else {
                  DateTime now = DateTime.now();
                  String dateformat =
                      DateFormat("yyyy-MM-dd - kk:mm").format(now);
                  Navigator.of(context).pop();
                  FirebaseFirestore.instance.collection('categorie').add({
                    "idcompte": idshop,
                    "nomcategorie": categoriecontroller.text,
                    "date": dateformat,
                    "range": DateTime.now().millisecondsSinceEpoch
                  });
                  requ.message("Succes", "Catégorie ajouté avec succès");
                  categoriecontroller.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ajout d'emplacement
  addemplacement() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ajout d'emplacement"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Entrer le nom de l'emplacement",
                    style: GoogleFonts.poppins()),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  cursorHeight: 20,
                  autofocus: false,
                  controller: categoriecontroller,
                  decoration: InputDecoration(
                    labelText: "ex:meilleur produit",
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
              child: const Text('Ajouter'),
              onPressed: () {
                if (categoriecontroller.text.isEmpty) {
                  requ.message("Echec",
                      "Vous devez saisir un nom pour votre emplacement.");
                } else {
                  DateTime now = DateTime.now();
                  String dateformat =
                      DateFormat("yyyy-MM-dd - kk:mm").format(now);
                  Navigator.of(context).pop();
                  FirebaseFirestore.instance.collection('emplacement').add({
                    "idcompte": idshop,
                    "nomemplacement": categoriecontroller.text,
                    "date": dateformat,
                    "range": DateTime.now().millisecondsSinceEpoch
                  });
                  requ.message("Succes", "Emplacement ajouté avec succès");
                  categoriecontroller.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }

//  listes des communes de livraisons
  viewlivraison() {
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
                        Text("Liste des communes",
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('livraison')
                                .where("idcompte", isEqualTo: idshop)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> _livraiosn) {
                              if (!_livraiosn.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (_livraiosn.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _livraiosn.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                _livraiosn.data!.docs[index]
                                                    ["commune"],
                                                style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            Text(
                                                _livraiosn.data!.docs[index]
                                                        ["prixlivraison"] +
                                                    " FCFA",
                                                style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            ActionChip(
                                                backgroundColor: Colors.red,
                                                label: Text("Supprimer",
                                                    style: GoogleFonts.poppins(
                                                        color: Colors.white)),
                                                onPressed: () {
                                                  deletelivraiosn(_livraiosn
                                                      .data!.docs[index].id);
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

// ajout de commune de livraison
  addlivraison() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ajout de commune"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Column(
                  children: [
                    Text(
                        "Vous pouvez ajouter toutes les communes que vous couvrez pour la livraison de vos produits ainsi que leur prix.",
                        style: GoogleFonts.poppins()),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      cursorHeight: 20,
                      autofocus: false,
                      controller: nomcommune,
                      decoration: InputDecoration(
                        labelText: "Commune de livraison",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      cursorHeight: 20,
                      autofocus: false,
                      controller: prixlivraison,
                      decoration: InputDecoration(
                        labelText: "Prix de livraison",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2),
                        ),
                      ),
                    ),
                  ],
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
              child: const Text('Ajouter'),
              onPressed: () {
                if (nomcommune.text.isEmpty) {
                  requ.message(
                      "Echec", "Vous devez saisir le nom d'une commune.");
                } else if (prixlivraison.text.isEmpty) {
                  requ.message(
                      "Echec", "Vous devez saisir le prix de la livraison.");
                } else {
                  Navigator.of(context).pop();
                  FirebaseFirestore.instance.collection('livraison').add({
                    "idcompte": idshop,
                    "commune": nomcommune.text,
                    "prixlivraison": prixlivraison.text,
                  });
                  requ.message(
                      "success", "Commune de livraison ajouté avec succès");
                  nomcommune.clear();
                  prixlivraison.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // suppression d'une communes de livraison
  deletelivraiosn(idlivraiosn) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "En supprimant cette commune, vos clients ne pourront plus y avoir accès.",
                  style: GoogleFonts.poppins(),
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
              child: const Text('Oui supprimer'),
              onPressed: () {
                Navigator.of(context).pop();
                FirebaseFirestore.instance
                    .collection("livraison")
                    .doc(idlivraiosn)
                    .delete();
                requ.message("sucess", "Commune supprimé avec succès");
              },
            ),
          ],
        );
      },
    );
  }
}
