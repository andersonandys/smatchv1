import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smatch/business/shop/traitementshop.dart';

class Commandeshop extends StatefulWidget {
  const Commandeshop({Key? key}) : super(key: key);

  @override
  _CommandeshopState createState() => _CommandeshopState();
}

class _CommandeshopState extends State<Commandeshop> {
  String idshop = Get.arguments[0]["idshop"];
  final Stream<QuerySnapshot> _allcommande = FirebaseFirestore.instance
      .collection('commandeproduit')
      .where("idshop", isEqualTo: Get.arguments[0]["idshop"])
      .orderBy("range", descending: true)
      .snapshots();
  final traitement = Get.put(Traitment1shop());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(25),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Liste des commandes",
        ),
      ),
      body: StreamBuilder(
          stream: _allcommande,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> allcommande) {
            if (!allcommande.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (allcommande.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return (allcommande.data!.docs.isEmpty)
                ? Center(
                    child: Container(
                      child: const Text(
                        "Vous n'avez pas de commande.",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      margin: const EdgeInsets.only(left: 10, right: 10),
                    ),
                  )
                : ListView.builder(
                    itemCount: allcommande.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Container(
                          margin: const EdgeInsets.only(
                              left: 2, right: 2, bottom: 5, top: 5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(15),
                              ),
                              color: Colors.white.withOpacity(0.1)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 180,
                                  width: 120,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                    color: Colors.amber,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    child: Image.network(
                                      allcommande.data!.docs[index]["image1"],
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        allcommande.data!.docs[index]["nom"],
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Prix : ",
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "${allcommande.data!.docs[index]["prix"]} Fcfa",
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Quantité : ",
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "${allcommande.data!.docs[index]["nbre"]} ",
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Commune : ",
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "${allcommande.data!.docs[index]["commune"]}",
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Numéro : ",
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "${allcommande.data!.docs[index]["number"]} ",
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      (allcommande.data!.docs[index]
                                                  ["statut"] ==
                                              0)
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: ActionChip(
                                                      backgroundColor:
                                                          Colors.red,
                                                      label: Text(
                                                        "Refuser",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                      onPressed: () {
                                                        refusecommande(
                                                            allcommande.data!
                                                                .docs[index].id,
                                                            allcommande.data!
                                                                    .docs[index]
                                                                ["nom"]);
                                                      }),
                                                ),
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: ActionChip(
                                                      backgroundColor:
                                                          Colors.grey,
                                                      label: Text(
                                                        "En cours...",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                      onPressed: () {
                                                        confirmecommande(
                                                            allcommande.data!
                                                                .docs[index].id,
                                                            allcommande.data!
                                                                    .docs[index]
                                                                ["nom"]);
                                                      }),
                                                ),
                                              ],
                                            )
                                          : (allcommande.data!.docs[index]
                                                      ["statut"] ==
                                                  1)
                                              ? Align(
                                                  alignment: Alignment.topRight,
                                                  child: ActionChip(
                                                      backgroundColor:
                                                          Colors.green,
                                                      label: Text(
                                                        "Commande livrée",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                      onPressed: () {}),
                                                )
                                              : (allcommande.data!.docs[index]
                                                          ["statut"] ==
                                                      2)
                                                  ? Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: ActionChip(
                                                          backgroundColor:
                                                              Colors.red,
                                                          label: Text(
                                                            "Commande annulée",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                          onPressed: () {}),
                                                    )
                                                  : Container(),
                                    ],
                                  ))
                            ],
                          ));
                    });
          }),
    );
  }

  validecommande(id) {
    FirebaseFirestore.instance
        .collection('commandeshop')
        .doc(id)
        .update({"statut": 1});
  }

  confirmecommande(id, nom) async {
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
                    'Vous confirmez avoir traité la commande $nom en bonne et due forme'),
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
              child: const Text('Oui confirmer'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('commandeproduit')
                    .doc(id)
                    .update({"statut": 1});
                FirebaseFirestore.instance
                    .collection("noeud")
                    .doc(idshop)
                    .update({"nbretraite": FieldValue.increment(1)});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  refusecommande(id, nom) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Voulez vous vraiment refuser la commande $nom '),
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
              child: const Text('Oui confirmer'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection("commandeproduit")
                    .doc(id)
                    .update({"statut": 2});
                FirebaseFirestore.instance
                    .collection("noeud")
                    .doc(idshop)
                    .update({"nbreannule": FieldValue.increment(1)});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
