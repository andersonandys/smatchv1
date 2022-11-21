import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smatch/home/tabsrequette.dart';

class Dashvlog extends StatefulWidget {
  const Dashvlog({Key? key}) : super(key: key);

  @override
  _DashvlogState createState() => _DashvlogState();
}

class _DashvlogState extends State<Dashvlog> {
  String nomchaine = Get.arguments[1]["nomchaine"];
  String idchaine = Get.arguments[0]["idchaine"];
  final Stream<QuerySnapshot> _videopub = FirebaseFirestore.instance
      .collection("videovlog")
      .where("idvlog", isEqualTo: Get.arguments[0]["idchaine"])
      .orderBy("range", descending: true)
      .snapshots();
  final Stream<QuerySnapshot> _vlog = FirebaseFirestore.instance
      .collection("noeud")
      .where("idcompte", isEqualTo: Get.arguments[0]["idchaine"])
      .snapshots();
  final requ = Get.put(Tabsrequette());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black.withBlue(25),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(25),
        title: Text(nomchaine),
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('noeud')
                    .where("idcompte", isEqualTo: idchaine)
                    .get()
                    .then((QuerySnapshot value) {
                  if (value.docs.first["lienvideo"] == "") {
                    requ.message(
                        "Echec", "Aucune vidéo n'a été définie pour la une.");
                  } else {
                    Get.toNamed("/vlog", arguments: [
                      {"idchaine": value.docs.first["idcompte"]},
                      {"nomchaine": value.docs.first["nom"]},
                      {"logo": value.docs.first['logo']},
                      {"vignette": value.docs.first['vignette']},
                      {"titre": value.docs.first['titre']}
                    ]);
                  }
                });
              },
              icon: const Icon(
                Iconsax.eye,
              ))
        ],
      ),
      body: StreamBuilder(
          stream: _vlog,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> _vlog) {
            if (!_vlog.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (_vlog.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _vlog.data!.docs.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.only(
                        top: 10, right: 10, left: 10, bottom: 30),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildCreditCard(
                              color: const Color(0xFF090943),
                              cardExpiration: "12/2023",
                              cardHolder: nomchaine,
                              cardNumber:
                                  " ${idchaine.substring(0, 4)} **** ${idchaine.substring(4, 8)}",
                              wallet: _vlog.data!.docs.first['wallet']),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                height: 100,
                                width: 150,
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Utilisateur",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "${_vlog.data!.docs.first['nbreuser']}",
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 100,
                                width: 150,
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Vidéo",
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white)),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "${_vlog.data!.docs.first['nbrevideo']}",
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          StreamBuilder(
                              stream: _videopub,
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> videopub) {
                                if (!videopub.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (videopub.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                return (videopub.data!.docs.isEmpty)
                                    ? Center(
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: const [
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Center(
                                                child: Text(
                                                  "Bienvenue sur votre dashboard",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                "Dans le but de publier le plus rapidement votre première vidéo, nous vous prions de suivre les 3 étapes ci-dessous. ",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                                textAlign: TextAlign.justify,
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                "Étape 1 : rendez-vous dans paramètre, choisissez playlist afin d'ajouter les playlist indispensables à la structuration de votre Space",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                "Étape 2 : appuyez sur le bouton avec l'icône vidéo, pour publier votre première vidéo.",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                "Étape 3 : Pour votre première publication, nous vous conseillons d'activer l'option définir comme série à la une pendant la publication.",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                "NB : Double-cliquez sur une série pour la supprimer définitivement de votre playlist dans la liste de vos séries.",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                "À savoir : le bouton 'Production' dans paramètre permet de déterminer si votre Space doit être visible par les utilisateurs ou non. Il est désactivé par défaut, nous vous prions de l'activer une fois, vous avez terminé la configuration de votre boutique et publier vos produits.",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                              SizedBox(
                                                height: 60,
                                              ),
                                            ]),
                                      )
                                    : Column(
                                        children: <Widget>[
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          const Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "Série publiées",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              )),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          ListView.builder(
                                              physics:
                                                  const ClampingScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount:
                                                  videopub.data!.docs.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onDoubleTap: () {
                                                    deletecomande(
                                                        videopub.data!
                                                            .docs[index].id,
                                                        videopub.data!
                                                                .docs[index]
                                                            ["titre"]);
                                                  },
                                                  child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 10),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    15)),
                                                        color: Colors.white
                                                            .withOpacity(0.1),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius: const BorderRadius
                                                                    .only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        5),
                                                                topLeft: Radius
                                                                    .circular(
                                                                        5)),
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl: videopub
                                                                          .data!
                                                                          .docs[
                                                                      index]
                                                                  ["vignette"],
                                                              fit: BoxFit.cover,
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              height: 200,
                                                            ),
                                                          ),
                                                          Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 10,
                                                                      right: 10,
                                                                      top: 10),
                                                              child: Column(
                                                                children: [
                                                                  Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topLeft,
                                                                      child:
                                                                          Text(
                                                                        videopub
                                                                            .data!
                                                                            .docs[index]["titre"],
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 20),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      )),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topLeft,
                                                                      child: Text(
                                                                          videopub.data!.docs[index]
                                                                              [
                                                                              "description"],
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                          ))),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Chip(
                                                                        label: Text(
                                                                            "${videopub.data!.docs[index]["vue"]} "),
                                                                        avatar:
                                                                            const Icon(Iconsax.eye),
                                                                      ),
                                                                      Chip(
                                                                        label: Text(
                                                                            "${videopub.data!.docs[index]["comment"]} "),
                                                                        avatar:
                                                                            const Icon(Iconsax.message),
                                                                      ),
                                                                      Chip(
                                                                        label: Text(
                                                                            "${videopub.data!.docs[index]["like"]} "),
                                                                        avatar:
                                                                            const Icon(Iconsax.heart),
                                                                      )
                                                                    ],
                                                                  )
                                                                ],
                                                              ))
                                                        ],
                                                      )),
                                                );
                                              })
                                        ],
                                      );
                              }),
                        ],
                      ),
                    ),
                  );
                });
          }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(IconlyBold.video),
        backgroundColor: Colors.orange.shade800,
        onPressed: () {
          Get.toNamed('/publicationvlog', arguments: [
            {"idchaine": idchaine}
          ]);
        },
        heroTag: null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  deletecomande(id, nom) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Vous êtes sur le point de supprimer $nom"),
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
            TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.orange.shade900)),
              child: const Text('Oui supprimmer'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection("commandeproduit")
                    .doc(id)
                    .delete();

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

Card _buildCreditCard(
    {required Color color,
    required String cardNumber,
    required String cardHolder,
    required String cardExpiration,
    required wallet}) {
  return Card(
    elevation: 4.0,
    color: color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    child: Container(
      height: 200,
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          /* Here we are going to place the _buildLogosBlock */
          _buildLogosBlock(wallet),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            /* Here we are going to place the Card number */
            child: Text(
              cardNumber,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontFamily: 'CourrierPrime'),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              /* Here we are going to place the _buildDetailsBlock */
              _buildDetailsBlock(
                label: 'TITULAIRE',
                value: cardHolder,
              ),
              _buildDetailsBlock(
                label: 'VALIDITE',
                value: cardExpiration,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Column _buildDetailsBlock({@required String? label, required String value}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        '$label',
        style: const TextStyle(
            color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
      ),
      Text(
        value,
        style: const TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
      )
    ],
  );
}

Row _buildLogosBlock(wallet) {
  return Row(
    /*1*/
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Image.asset(
        "assets/goo.png",
        height: 20,
        width: 18,
      ),
      Container(
        padding: const EdgeInsets.only(top: 10, right: 10),
        child: Text(
          "$wallet Fcfa",
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      )
    ],
  );
}
