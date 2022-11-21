import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smatch/business/shop/traitementshop.dart';

class Favoris2shop extends StatefulWidget {
  const Favoris2shop({Key? key}) : super(key: key);

  @override
  _Favoris2shopState createState() => _Favoris2shopState();
}

class _Favoris2shopState extends State<Favoris2shop> {
  final Stream<QuerySnapshot> _allfavoris = FirebaseFirestore.instance
      .collection('favorisproduit')
      .where("idshop", isEqualTo: Get.arguments[0]["idshop"])
      .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .orderBy("range", descending: true)
      .snapshots();
  int nbre = 1;
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
          "Favoris",
        ),
      ),
      body: StreamBuilder(
          stream: _allfavoris,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> allfavoris) {
            if (!allfavoris.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (allfavoris.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return (allfavoris.data!.docs.isEmpty)
                ? const Center(
                    child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      "Vous n'avez pas de produit en favoris.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: allfavoris.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(
                            left: 2, right: 2, bottom: 10),
                        child: Container(
                            height: 190,
                            margin: const EdgeInsets.only(left: 10, right: 10),
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
                                        imageUrl: allfavoris.data!.docs[index]
                                            ["image1"],
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width,
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
                                          allfavoris.data!.docs[index]["nom"],
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "${allfavoris.data!.docs[index]["prix"]} Fcfa",
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
                                              onTap: () {
                                                if (nbre > 1) {
                                                  setState(() {
                                                    nbre--;
                                                  });
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                          'favorisproduit')
                                                      .doc(allfavoris
                                                          .data!.docs[index].id)
                                                      .update({"nbre": nbre});
                                                }
                                              },
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.black,
                                                          width: 1),
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  50))),
                                                  child: const Center(
                                                    child: Icon(
                                                      IconlyLight.arrowDown2,
                                                    ),
                                                  )),
                                            ),
                                            Text(
                                              "${allfavoris.data!.docs[index]["nbre"]} ",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  nbre++;
                                                });
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        'favorisproduit')
                                                    .doc(allfavoris
                                                        .data!.docs[index].id)
                                                    .update({"nbre": nbre});
                                              },
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.black,
                                                          width: 1),
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ActionChip(
                                                backgroundColor: Colors.red,
                                                label: Text(
                                                  "Supprimer",
                                                  style: GoogleFonts.poppins(
                                                      color: Colors.white),
                                                ),
                                                onPressed: () {
                                                  confirmdeleteproduit(
                                                      allfavoris.data!
                                                          .docs[index].id);
                                                }),
                                            ActionChip(
                                                backgroundColor:
                                                    Colors.grey.shade800,
                                                label: Text(
                                                  "Ajouter",
                                                  style: GoogleFonts.poppins(
                                                      color: Colors.white),
                                                ),
                                                onPressed: () {
                                                  traitement.addpanier(
                                                      allfavoris.data!
                                                          .docs[index]["nom"],
                                                      allfavoris.data!
                                                          .docs[index]["prix"],
                                                      allfavoris
                                                              .data!.docs[index]
                                                          ["idshop"],
                                                      allfavoris
                                                          .data!.docs[index].id,
                                                      allfavoris
                                                              .data!.docs[index]
                                                          ["image1"],
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid);
                                                  traitement.deletefavoris(
                                                      allfavoris.data!
                                                          .docs[index].id);
                                                }),
                                          ],
                                        ),
                                      ],
                                    ))
                              ],
                            )),
                      );
                    });
          }),
    );
  }

  confirmdeleteproduit(idproduit) {
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
                  "Êtes-vous sûr de supprimer ce produit de vos favoris ?",
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
                    .collection("favorisproduit")
                    .doc(idproduit)
                    .delete();
                traitement.message("sucess", "Produit retiré de vos favoris");
              },
            ),
          ],
        );
      },
    );
  }
}
