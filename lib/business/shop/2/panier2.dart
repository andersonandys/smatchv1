import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smatch/business/shop/traitementshop.dart';

class Panier2shop extends StatefulWidget {
  const Panier2shop({Key? key}) : super(key: key);

  @override
  _Panier2shopState createState() => _Panier2shopState();
}

class _Panier2shopState extends State<Panier2shop> {
  String idshop = Get.arguments[0]["idshop"];
  int nbre = 1;
  final numbercontroller = TextEditingController();
  final Stream<QuerySnapshot> _allpanier = FirebaseFirestore.instance
      .collection('panierproduit')
      .where("idshop", isEqualTo: Get.arguments[0]["idshop"])
      .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .orderBy("range", descending: true)
      .snapshots();
  final Stream<QuerySnapshot> allLivraison = FirebaseFirestore.instance
      .collection('livraison')
      .where("idcompte", isEqualTo: Get.arguments[0]["idshop"])
      .snapshots();
  final traitement = Get.put(Traitment1shop());
  String? commune;
  String? prixlivraison;
  String? number;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    infouser();
  }

  infouser() {
    print("non");
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          number = doc["number"];
        });
        print(number);
      }
    });
  }

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
          "Panier",
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Commune de livraison",
                style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 50,
            child: StreamBuilder(
                stream: allLivraison,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> allivraison) {
                  if (!allivraison.hasData) {
                    return const Text(
                      "Chargement des produits...",
                      style: TextStyle(color: Colors.white),
                    );
                  }
                  if (allivraison.connectionState == ConnectionState.waiting) {
                    return const Text("Chargement des produits...",
                        style: TextStyle(color: Colors.white));
                  }
                  return (allivraison.data!.docs.isEmpty)
                      ? const Center(
                          child: Text(
                          "Aucune commune de livraison disponible",
                          style: TextStyle(color: Colors.white),
                        ))
                      : ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: allivraison.data!.docs.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(left: 5, right: 5),
                              child: ChoiceChip(
                                padding: EdgeInsets.all(10),
                                selectedColor: Colors.greenAccent,
                                disabledColor: Colors.grey,
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                onSelected: (value) {
                                  setState(() {
                                    commune = allivraison.data!.docs[index]
                                        ["commune"];
                                    prixlivraison = allivraison
                                        .data!.docs[index]["prixlivraison"];
                                  });
                                },
                                selected: (commune ==
                                        allivraison.data!.docs[index]
                                            ["commune"])
                                    ? true
                                    : false,
                                label: Text(
                                  allivraison.data!.docs[index]["commune"] +
                                      " : " +
                                      allivraison.data!.docs[index]
                                          ["prixlivraison"] +
                                      " Fcfa",
                                  style:
                                      GoogleFonts.poppins(color: Colors.black),
                                ),
                              ),
                            );
                          });
                }),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Liste des produits",
                style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          StreamBuilder(
              stream: _allpanier,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> allpanier) {
                if (!allpanier.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (allpanier.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return (allpanier.data!.docs.isEmpty)
                    ? const Center(
                        heightFactor: 5,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Text(
                            "Vous n'avez pas de produit dans votre panier",
                            textAlign: TextAlign.justify,
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: allpanier.data!.docs.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(
                                left: 2, right: 2, bottom: 10),
                            child: Container(
                                height: 190,
                                margin:
                                    const EdgeInsets.only(left: 10, right: 10),
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
                                            imageUrl: allpanier
                                                .data!.docs[index]["image1"],
                                            fit: BoxFit.cover,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
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
                                              allpanier.data!.docs[index]
                                                  ["nom"],
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "${allpanier.data!.docs[index]["prix"]} Fcfa",
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
                                                              'panierproduit')
                                                          .doc(allpanier.data!
                                                              .docs[index].id)
                                                          .update(
                                                              {"nbre": nbre});
                                                    }
                                                  },
                                                  child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black,
                                                              width: 1),
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          50))),
                                                      child: const Center(
                                                        child: Icon(
                                                          IconlyLight
                                                              .arrowDown2,
                                                        ),
                                                      )),
                                                ),
                                                Text(
                                                  "${allpanier.data!.docs[index]["nbre"]} ",
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      nbre++;
                                                    });
                                                    print(nbre);
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            'panierproduit')
                                                        .doc(allpanier.data!
                                                            .docs[index].id)
                                                        .update({"nbre": nbre});
                                                  },
                                                  child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black,
                                                              width: 1),
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
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
                                            Align(
                                              alignment: Alignment.center,
                                              child: ActionChip(
                                                  backgroundColor: Colors.red,
                                                  label: Text(
                                                    "Supprimer le produit",
                                                    style: GoogleFonts.poppins(
                                                        color: Colors.white),
                                                  ),
                                                  onPressed: () {
                                                    confirmdeleteproduit(
                                                        allpanier.data!
                                                            .docs[index].id);
                                                  }),
                                            ),
                                          ],
                                        ))
                                  ],
                                )),
                          );
                        });
              }),
        ],
      ),
      floatingActionButton:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        FloatingActionButton.extended(
          backgroundColor: Colors.red,
          label: Text("Commander", style: GoogleFonts.poppins(fontSize: 20)),
          onPressed: () {
            print(number);
            if (number == null) {
              print("non");
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      title: const Text('Information'),
                      content: Container(
                        height: 150,
                        child: Column(
                          children: [
                            const Text(
                                "Vous devez ajouter votre numéro de téléphone avant de commander."),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[],
                              cursorHeight: 20,
                              autofocus: false,
                              controller: numbercontroller,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "Numéro de téléphone",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
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
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.orange.shade900)),
                            onPressed: () {
                              if (numbercontroller.text.isEmpty) {
                                traitement.message("erreur",
                                    "Nous vous prions de saisir votre numéro");
                              } else {
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .update({"number": numbercontroller.text});
                                traitement.addcommande(
                                    idshop, commune, numbercontroller.text);
                                numbercontroller.text;
                              }
                              Navigator.of(context).pop();
                            },
                            child: const Text('Valider'))
                      ],
                    );
                  });
            } else {
              traitement.addcommande(idshop, commune, number);
              print("object");
            }
          },
          heroTag: null,
        ),
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                  "Êtes-vous sûr de supprimer ce produit de votre panier ?",
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
                    .collection("panierproduit")
                    .doc(idproduit)
                    .delete();
                traitement.message("sucess", "Produit retiré de votre panier");
              },
            ),
          ],
        );
      },
    );
  }
}
