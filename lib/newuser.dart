import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smatch/home/home.dart';
import 'package:smatch/menu/menuhome.dart';
import 'home/tabsrequette.dart';

class Newuser extends StatefulWidget {
  const Newuser({Key? key}) : super(key: key);

  @override
  _NewuserState createState() => _NewuserState();
}

class _NewuserState extends State<Newuser> {
  final requ = Get.put(Tabsrequette());
  List allcompte = [];
  final Stream<QuerySnapshot> _allnoeud =
      FirebaseFirestore.instance.collection('noeud').snapshots();
  final Stream<QuerySnapshot> _allnoeudrecommande = FirebaseFirestore.instance
      .collection('noeud')
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
  String idcreat = "";
  int? exist;
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
  int? nbreabonne;
  int adds = 0;
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
            if (doc["nom"] == null) {
              nomuser = user.uid.substring(0, 6);
            } else {
              nomuser = doc["nom"];
            }
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
        elevation: 0,
        backgroundColor: Colors.black.withBlue(25),
        actions: [
          ActionChip(
            label: const Text(
              'Terminer',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              finish();
            },
            backgroundColor: Colors.orange,
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Pour une meilleure utilisation et prise en main de smatch, nous vous prions de vous abonner à des comptes',
                style: TextStyle(color: Colors.white, fontSize: 18),
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
                        child: CircularProgressIndicator(),
                      );
                    }
                    return GridView.builder(
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
                                          child: Image.network(
                                            (_noeud.data!.docs[index]['logo']),
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
                                      Align(
                                        child: Text(
                                          _noeud.data!.docs[index]['type'],
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
                                              (_noeud.data!.docs[index]
                                                          ['offre'] ==
                                                      "gratuit")
                                                  ? "Libre"
                                                  : "Payant",
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white60,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            ActionChip(
                                                backgroundColor: Colors.orange,
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
                                                    nom = _noeud.data!
                                                        .docs[index]['nom'];
                                                    description =
                                                        _noeud.data!.docs[index]
                                                            ['description'];
                                                    type = _noeud.data!
                                                        .docs[index]['type'];
                                                    logo = _noeud.data!
                                                        .docs[index]['logo'];
                                                    offre = _noeud.data!
                                                        .docs[index]['offre'];

                                                    idcompte = _noeud
                                                        .data!.docs[index].id;
                                                    statut = _noeud.data!
                                                        .docs[index]['statut'];
                                                    idcreat = _noeud.data!
                                                        .docs[index]['idcreat'];
                                                  });
                                                  viewinfo();
                                                }),
                                          ]),
                                    ]),
                                  )),
                              (_noeud.data!.docs[index]['statut'] == "public")
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
                        });
                  }),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  finish() {
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser", isEqualTo: user.uid)
        .get()
        .then((QuerySnapshot documentSnapshot) {
      if (documentSnapshot.docs.first["addscompte"] < 2) {
        requ.message(
            "Echec", "Nous vous prions de vous abonner à au moins 2 comptes.");
      } else {
        Get.off(() => Menuhome());
      }
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
          children: [
            const SizedBox(height: 10),
            Container(
              height: 5,
              width: 50,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Container(
                height: 80,
                width: 80,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  child: Image.network(
                    (logo),
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
                      child: Text(
                        nom,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                        overflow: TextOverflow.ellipsis,
                      ),
                      alignment: Alignment.topLeft,
                    ),
                    Align(
                      child: Text(
                        type,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      alignment: Alignment.topLeft,
                    ),
                  ],
                ),
              )
            ]),
            const SizedBox(
              height: 10,
            ),
            const Align(
              child: Text(
                "Description",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              alignment: Alignment.topLeft,
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
                      ? (statut == "public")
                          ? "Libre d'access"
                          : "Accès par adhésion"
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
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (abonneinfo.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: LoadingAnimationWidget.dotsTriangle(
                            color: Colors.blueAccent,
                            size: 100,
                          ),
                        );
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
                                  primary: Colors.orange),
                              onPressed: () {
                                if (statut == "public") {
                                  installer();
                                } else {
                                  sendinvitation();
                                }
                              },
                              child: const Text(
                                // (statut == "public") ? "Obtenir" : "Envitation",
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
    if (offre == "gratuit") {
      requ.rejoindre(nom, idcompte, logo, offre, type, idcreat);
      FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({"addscompte": FieldValue.increment(1)});
    } else {
      requ.byAbonnement(
          prix, wallet, idcompte, nom, logo, offre, type, idcreat);
    }
  }

  sendinvitation() {
    FirebaseFirestore.instance.collection("invitation").add({
      "iduser": user.uid,
      "idcompte": idcompte,
      "nom": nom,
      "logo": logo,
      "date": DateTime.now(),
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
      "date": DateTime.now()
    });
    FirebaseFirestore.instance
        .collection("noeud")
        .doc(idcompte)
        .update({"notification": FieldValue.increment(1)});
    requ.message("Sucess",
        "Votre demande d'adhésion au nœud $nom a été envoyé avec succès");
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
                        "Vous êtes sur le point de quitter. $nom",
                        textAlign: TextAlign.justify,
                      )
                    : Text(
                        "En désinstallant $nom, aucun remboursement sera effectué",
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
                FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .update({"addscompte": FieldValue.increment(-1)});
                requ.message("sucess", "Votre demande a été prise en compte.");
              },
            ),
          ],
        );
      },
    );
  }
}
