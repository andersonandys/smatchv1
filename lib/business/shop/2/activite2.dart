import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smatch/business/shop/traitementshop.dart';

class Activite2shop extends StatefulWidget {
  const Activite2shop({Key? key}) : super(key: key);

  @override
  _Activite2shopState createState() => _Activite2shopState();
}

class _Activite2shopState extends State<Activite2shop> {
  String idshop = Get.arguments[0]["idshop"];
  final Stream<QuerySnapshot> _allcommande = FirebaseFirestore.instance
      .collection('commandeproduit')
      .where("idshop", isEqualTo: Get.arguments[0]["idshop"])
      .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .orderBy("range", descending: true)
      .snapshots();
  final traitement = Get.put(Traitment1shop());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(20),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            IconlyLight.arrowLeftCircle,
            size: 30,
          ),
        ),
        title: const Text(
          "Commande",
        ),
      ),
      body: StreamBuilder(
          stream: _allcommande,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> allcommande) {
            if (!allcommande.hasData) {
              return const Center(
                  heightFactor: 10, child: CircularProgressIndicator());
            }
            if (allcommande.connectionState == ConnectionState.waiting) {
              return const Center(
                  heightFactor: 10, child: CircularProgressIndicator());
            }
            return (allcommande.data!.docs.isEmpty)
                ? const Center(
                    heightFactor: 10,
                    child: Text("Vous n'avez pas de commande",
                        style: TextStyle(color: Colors.white, fontSize: 20)))
                : ListView.builder(
                    itemCount: allcommande.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Container(
                          height: 190,
                          margin: const EdgeInsets.only(
                              left: 2, right: 2, bottom: 5, top: 5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(15),
                              ),
                              color: Colors.grey.shade200),
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
                                    child: CachedNetworkImage(
                                      imageUrl: allcommande.data!.docs[index]
                                          ["image1"],
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
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "${allcommande.data!.docs[index]["prix"]} Fcfa",
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black,
                                                        width: 1),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                50))),
                                                child: const Center(
                                                  child: Icon(
                                                    IconlyLight.arrowDown2,
                                                  ),
                                                )),
                                          ),
                                          Text(
                                            "${allcommande.data!.docs[index]["nbre"]} ",
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black,
                                                        width: 1),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                50))),
                                                child: const Center(
                                                  child: Icon(
                                                    IconlyLight.arrowUp2,
                                                    // size: 30,
                                                  ),
                                                )),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      (allcommande.data!.docs[index]
                                                  ["statut"] ==
                                              0)
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: ActionChip(
                                                      backgroundColor:
                                                          Colors.red,
                                                      label: Text(
                                                        "Annuler",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                      onPressed: () {
                                                        confirmdeleteproduit(
                                                            allcommande.data!
                                                                .docs[index].id,
                                                            idshop);
                                                      }),
                                                ),
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: ActionChip(
                                                      backgroundColor:
                                                          Colors.grey,
                                                      label: Text(
                                                        "En cours",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                      onPressed: () {
                                                        print("object");
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
                                                        "Commande livr??e",
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
                                                            "Commande annul??e",
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

  confirmdeleteproduit(idcommande, idshopannule) {
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
                  "????tes-vous s??r d'annuler cette commande ?",
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
                    .collection("commandeproduit")
                    .doc(idcommande)
                    .update({"statut": 2});
                FirebaseFirestore.instance
                    .collection("noeud")
                    .doc(idshopannule)
                    .update({"nbreannule": FieldValue.increment(1)});
                traitement.message("Succes", "Votre commande a ??t?? annul??e");
              },
            ),
          ],
        );
      },
    );
  }
}
