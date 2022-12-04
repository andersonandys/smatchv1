import 'package:bottom_sheet/bottom_sheet.dart';
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

class Settingsvlog extends StatefulWidget {
  @override
  _SettingsvlogState createState() => _SettingsvlogState();
}

class _SettingsvlogState extends State<Settingsvlog> {
  Timer? _timer;
  late double _progress;
  String text =
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,";
  final categoriecontroller = TextEditingController();
  final iduseradmin = TextEditingController();
  final nomcommune = TextEditingController();
  final prixlivraison = TextEditingController();
  bool erreur = false;
  List alluser = [];
  List userabonne = [];
  String userid = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
    EasyLoading.addStatusCallback((status) {
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
        .where("idcompte", isEqualTo: Get.arguments[0]["idchaine"])
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        userabonne = querySnapshot.docs;
      });
    });
  }

  final Stream<QuerySnapshot> adminstream = FirebaseFirestore.instance
      .collection('abonne')
      .where("idcompte", isEqualTo: Get.arguments[0]["idchaine"])
      .where("statut", isEqualTo: 1)
      .snapshots();
  final requ = Get.put(Tabsrequette());
  String idchaine = Get.arguments[0]["idchaine"];
  final Stream<QuerySnapshot> _compte = FirebaseFirestore.instance
      .collection('noeud')
      .where("idcompte", isEqualTo: Get.arguments[0]["idchaine"])
      .snapshots();
  final Stream<QuerySnapshot> streamcategorie = FirebaseFirestore.instance
      .collection('categorie')
      .where("idcompte", isEqualTo: Get.arguments[0]["idchaine"])
      .orderBy("range", descending: true)
      .snapshots();
  final walletnumero = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(25),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withBlue(25),
        title: const Text(
          "Paraméttre",
          style: TextStyle(),
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
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _compte.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50))),
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50)),
                              child: CachedNetworkImage(
                                imageUrl: (_compte.data!.docs[index]['logo']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(),
                          Text(
                            _compte.data!.docs[index]['nom'],
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Configuration de votre Space",
                              style: TextStyle(
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
                              const Text(
                                "Prévisualiser votre Space",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      FirebaseFirestore.instance
                                          .collection('noeud')
                                          .where("idcompte",
                                              isEqualTo: idchaine)
                                          .get()
                                          .then((QuerySnapshot value) {
                                        if (value.docs.first["lienvideo"] ==
                                            "") {
                                          requ.message("Echec",
                                              "Aucune vidéo n'a été définie pour la une");
                                        } else {
                                          Get.toNamed("/vlog", arguments: [
                                            {
                                              "idchaine":
                                                  value.docs.first["idcompte"]
                                            },
                                            {
                                              "nomchaine":
                                                  value.docs.first["nom"]
                                            },
                                            {"logo": value.docs.first['logo']},
                                            {
                                              "vignette":
                                                  value.docs.first['vignette']
                                            },
                                            {"titre": value.docs.first['titre']}
                                          ]);
                                        }
                                      });
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
                              const Text(
                                "Playlist",
                                style: TextStyle(
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
                          // ajout d'administrateur
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Administration",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      print(idchaine);
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
                              const Text(
                                "Configuration wallet",
                                style: TextStyle(
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
                              const Text(
                                "Production",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Row(
                                children: [
                                  Switch.adaptive(
                                      value: _compte.data!.docs[index]["mode"],
                                      onChanged: (value) {
                                        if (value) {
                                          requ.message("Succes",
                                              "Votre Space est passé en mode de production, elle pourra être visible par tout le monde");
                                        } else {
                                          requ.message("Success",
                                              "Votre Space est passé en mode développement, elle ne pourra pas être visible par tout le monde");
                                        }
                                        FirebaseFirestore.instance
                                            .collection("noeud")
                                            .doc(idchaine)
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
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 5,
                            width: 50,
                            decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50))),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text("Liste des playslist",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 15,
                        ),
                        StreamBuilder(
                            stream: streamcategorie,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> _categorie) {
                              if (!_categorie.hasData) {
                                return const Center(
                                    heightFactor: 10,
                                    child: CircularProgressIndicator());
                              }
                              if (_categorie.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    heightFactor: 10,
                                    child: CircularProgressIndicator());
                              }
                              return (_categorie.data!.docs.isEmpty)
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          "Vous n'avez pas encore ajouté de playlist",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: _categorie.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    _categorie.data!.docs[index]
                                                        ["nomcategorie"],
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                ActionChip(
                                                    backgroundColor: Colors.red,
                                                    label: const Text(
                                                        "Supprimer",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
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
                        const Text("Liste des administrateurs",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 15,
                        ),
                        StreamBuilder(
                            stream: adminstream,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> _admin) {
                              if (!_admin.hasData) {
                                return const Center(
                                    heightFactor: 10,
                                    child: CircularProgressIndicator());
                              }
                              if (_admin.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    heightFactor: 10,
                                    child: CircularProgressIndicator());
                              }
                              return ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
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
                      "Echec", "Vous devez saisir un identifiant utilisateur");
                } else {
                  var resultuser = alluser
                      .where(
                          (user) => user["iduser"].contains(iduseradmin.text))
                      .toList();

                  if (resultuser.isEmpty) {
                    requ.message("Echec",
                        "Aucun utilisateur ne correspond à cet ID, nous vous prions de vérifier l'identifiant. ");
                  } else {
                    FirebaseFirestore.instance
                        .collection('abonne')
                        .where('idcompte', isEqualTo: idchaine)
                        .get()
                        .then((QuerySnapshot value) {
                      var resultabonne = value.docs
                          .where((user) =>
                              user["iduser"].contains(iduseradmin.text))
                          .toList();
                      print(resultabonne);
                      DateTime now = DateTime.now();
                      String dateformat =
                          DateFormat("yyyy-MM-dd - kk:mm").format(now);
                      if (resultabonne.isEmpty) {
                        FirebaseFirestore.instance.collection("abonne").add({
                          "iduser": resultuser.first['iduser'],
                          "idcompte": idchaine,
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
          title: const Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  "Vous êtes sur le point de supprimer cet utilisateur en tant qu'administrateur.",
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
                    .doc(idamin)
                    .update({"statut": 0});
                requ.message("sucess", "administrateur supprimé avec succès");
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
              children: const <Widget>[
                Text(
                  "En supprimant cette catégorie, vous allez perdre toutes les données qui y sont liées.",
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
                    .collection("categorie")
                    .doc(idcategorie)
                    .delete();
                requ.message("sucess", " Playlist supprimée avec succès.");
              },
            ),
          ],
        );
      },
    );
  }
//  ajout de la categorie

  addcategorie() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajout de playlist'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                  "Entrer le nom d'une playlist",
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  cursorHeight: 20,
                  autofocus: false,
                  controller: categoriecontroller,
                  decoration: InputDecoration(
                    labelText: "playlist",
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
                  'annuler',
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
                  requ.message(
                      "Echec", "Vous devez donner un nom a votre playlist");
                } else {
                  DateTime now = DateTime.now();
                  String dateformat =
                      DateFormat("yyyy-MM-dd - kk:mm").format(now);
                  Navigator.of(context).pop();
                  FirebaseFirestore.instance.collection('categorie').add({
                    "idcompte": idchaine,
                    "nomcategorie": categoriecontroller.text,
                    "date": dateformat,
                    "range": DateTime.now().millisecondsSinceEpoch
                  });
                  categoriecontroller.clear();
                  requ.message("Succes", "playslit ajouté avec succès");
                }
              },
            ),
          ],
        );
      },
    );
  }

  // configuration wallet
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
                                      "Rentrer votre numéro Orange Money. \n Ce numéro sera utilisé pour vos transactions de retrait de fonds.",
                                      "Nous vous prions de saisir votre numéro orange Money",
                                      "Numéro OM");
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
                                      "Rentrer votre numéro MTN. \n Ce numéro sera utilisé pour vos transactions de retrait de fonds.",
                                      "nous vous prions de saisir votre numéro MTN Money",
                                      "Numéro MTN  Money");
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
                                      "Rentrer le numéro de votre CB. \n Cette CB sera utilisée pour vos transactions de retrait de fonds.",
                                      "Nous vous prions de saisir le numéro de votre CB",
                                      "Numéro CB");
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
                                            "Carte banquaire",
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
                                      "Rentrer votre adresse TEZOS. \n Cette adresse sera utilisée pour vos transactions de retrait de fonds.",
                                      "nous vous prions de saisir votre adresse TEZOS",
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
                if (walletnumero.text.isEmpty) {
                  requ.message("Echec", erreurs);
                } else {
                  FirebaseFirestore.instance
                      .collection("noeud")
                      .doc(idchaine)
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
}
