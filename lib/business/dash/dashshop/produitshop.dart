import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smatch/home/tabsrequette.dart';

class Produitshop extends StatefulWidget {
  Produitshop({Key? key}) : super(key: key);

  @override
  _ProduitshopState createState() => _ProduitshopState();
}

class _ProduitshopState extends State<Produitshop> {
  final updatecontroller = TextEditingController();
  final Stream<QuerySnapshot> _allproduit = FirebaseFirestore.instance
      .collection('produitshop')
      .where("idshop", isEqualTo: Get.arguments[0]["idshop"])
      .orderBy("range", descending: true)
      .snapshots();
  final requ = Get.put(Tabsrequette());
  String nom = "";
  String image1 = "";
  String prix = "";
  String description = "";
  String stock = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(25),
      appBar: AppBar(
          backgroundColor: Colors.black.withBlue(25),
          title: Text(
            "Listes des produits",
            style: GoogleFonts.poppins(fontSize: 20),
          ),
          centerTitle: true,
          elevation: 0),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder(
            stream: _allproduit,
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> _allproduits) {
              if (!_allproduits.hasData) {
                return const Center(
                    heightFactor: 10, child: CircularProgressIndicator());
              }
              if (_allproduits.connectionState == ConnectionState.waiting) {
                return const Center(
                    heightFactor: 10, child: CircularProgressIndicator());
              }
              return (_allproduits.data!.docs.isEmpty)
                  ? const Center(
                      heightFactor: 10,
                      child: Text(
                        "Vous n'avez pas de produit.",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ))
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _allproduits.data!.docs.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    height: 60,
                                    width: 60,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50))),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          nom = _allproduits.data!.docs[index]
                                              ["nom"];
                                          prix = _allproduits.data!.docs[index]
                                              ["prix"];
                                          description = _allproduits
                                              .data!.docs[index]["description"];
                                          image1 = _allproduits
                                              .data!.docs[index]["image1"];
                                          stock = _allproduits.data!.docs[index]
                                              ["stock"];
                                        });
                                        viewproduct(
                                            _allproduits.data!.docs[index].id);
                                      },
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(50)),
                                        child: Image.network(
                                          _allproduits.data!.docs[index]
                                              ["image1"],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )),
                                Text(
                                  _allproduits.data!.docs[index]["nom"],
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontSize: 20),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                    _allproduits.data!.docs[index]["prix"] +
                                        " Fcfa",
                                    style: GoogleFonts.poppins(
                                        color: Colors.white))
                              ],
                            ),
                            const Divider(
                              color: Colors.grey,
                            ),
                          ],
                        );
                      });
            }),
      ),
    );
  }

  viewproduct(idproduit) {
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
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            child: Image.network(
                              image1,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(nom,
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white)),
                            const SizedBox(
                              width: 20,
                            ),
                            GestureDetector(
                              onTap: () {
                                modification("au nom", 'nom', nom, idproduit);
                              },
                              child:
                                  const Icon(Iconsax.edit, color: Colors.white),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Prix",
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                        Text(prix + " Fcfa",
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white)),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            modification(
                                "au prix", 'prix', "$prix Fcfa", idproduit);
                          },
                          child: const Icon(Iconsax.edit, color: Colors.white),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Stock",
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                        Text(stock,
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white)),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            modification("au stock", 'stock', stock, idproduit);
                          },
                          child: const Icon(Iconsax.edit, color: Colors.white),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Description",
                            style:
                                TextStyle(fontSize: 20, color: Colors.white70)),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            modification("à la description", 'description',
                                description, idproduit);
                          },
                          child: const Icon(Iconsax.edit, color: Colors.white),
                        )
                      ],
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(description,
                          style: const TextStyle(
                              fontSize: 17, color: Colors.white)),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          deleteproduit(idproduit);
                        },
                        child: const Text(
                          "Supprimer le produit",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            fixedSize: const Size(300, 60),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                    )
                  ],
                ),
              ));
            },
          );
        });
  }

  modification(terminaison, type, data, idproduit) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modification'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Column(
                  children: [
                    Text(
                        "Vous apportez une modification $terminaison du produit.",
                        style: TextStyle()),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      cursorHeight: 20,
                      autofocus: false,
                      controller: updatecontroller,
                      decoration: InputDecoration(
                        labelText: data,
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
              child: const Text('Modifier'),
              onPressed: () {
                if (updatecontroller.text.isEmpty) {
                  requ.message("Echec", "Nous vous prions de remplir le champ");
                } else {
                  Navigator.of(context).pop();
                  if (type == 'nom') {
                    FirebaseFirestore.instance
                        .collection("produitshop")
                        .doc(idproduit)
                        .update({"nom": updatecontroller.text});
                    setState(() {
                      nom = updatecontroller.text;
                    });
                  } else if (type == "prix") {
                    FirebaseFirestore.instance
                        .collection("produitshop")
                        .doc(idproduit)
                        .update({"prix": updatecontroller.text});
                    setState(() {
                      prix = updatecontroller.text;
                    });
                  } else if (type == "stock") {
                    FirebaseFirestore.instance
                        .collection("produitshop")
                        .doc(idproduit)
                        .update({"stock": updatecontroller.text});
                    setState(() {
                      stock = updatecontroller.text;
                    });
                  } else if (type == "description") {
                    FirebaseFirestore.instance
                        .collection("produitshop")
                        .doc(idproduit)
                        .update({"description": updatecontroller.text});
                    setState(() {
                      description = updatecontroller.text;
                    });
                  }
                  requ.message("Success", "Modification apportée avec succès.");
                  updatecontroller.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }

  deleteproduit(idproduit) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  "En supprimant ce produit, vos clients ne pourront plus y avoir accès.",
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
                    .collection("produitshop")
                    .doc(idproduit)
                    .delete();
                requ.message("sucess", "Votre demande a été prise en compte");
              },
            ),
          ],
        );
      },
    );
  }
}
