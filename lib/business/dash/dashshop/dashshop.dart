import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smatch/home/tabsrequette.dart';

class Dashshop extends StatefulWidget {
  const Dashshop({Key? key}) : super(key: key);

  @override
  _DashshopState createState() => _DashshopState();
}

class _DashshopState extends State<Dashshop> {
  final datas = Get.arguments;
  var idshop = Get.arguments[0]["idshop"];
  var nomshop = Get.arguments[1]["nomshop"];
  String design = Get.arguments[2]["design"];
  // var admin = Get.arguments[2]["admin"];
  final Stream<QuerySnapshot> _compteshop = FirebaseFirestore.instance
      .collection('noeud')
      .where("idcompte", isEqualTo: Get.arguments[0]["idshop"])
      .snapshots();
  String chose =
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSjV7qgLnnov_9e6IHBr4-8KsOJV7o7tgtU0A&usqp=CAU";
  final Stream<QuerySnapshot> _allproduit = FirebaseFirestore.instance
      .collection('produitshop')
      .where("idshop", isEqualTo: Get.arguments[0]["idshop"])
      .orderBy("range", descending: true)
      .limit(10)
      .snapshots();
  final updatecontroller = TextEditingController();
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
        elevation: 0,
        title: Text(
          "$nomshop",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: StreamBuilder(
              stream: _compteshop,
              builder:
                  (BuildContext context, AsyncSnapshot<QuerySnapshot> compte) {
                if (!compte.hasData) {
                  return const Center(
                    heightFactor: 10,
                    child: CircularProgressIndicator(),
                  );
                }
                if (compte.connectionState == ConnectionState.waiting) {
                  return const Center(
                    heightFactor: 10,
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: compte.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.0,
                                    mainAxisSpacing: 10.0,
                                    crossAxisSpacing: 5.0,
                                    mainAxisExtent: 115),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                height: 100,
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                            "${compte.data!.docs[index]['nbrproduit']}",
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.white)),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Icon(
                                        Icons.shopping_basket,
                                        color: Colors.orange.shade900,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      "Produit",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                height: 100,
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                            "${compte.data!.docs[index]['nbrcommande']}",
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.white)),
                                      ],
                                    ),
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Icon(
                                        Icons.shopping_cart,
                                        color: Colors.blueAccent,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      "Commande",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                height: 100,
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                            "${compte.data!.docs[index]['nbretraite']}",
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.white)),
                                      ],
                                    ),
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Icon(
                                        Icons.playlist_add_check_circle_sharp,
                                        color: Colors.greenAccent,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      "Effectuée",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                height: 100,
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                            "${compte.data!.docs[index]['nbreannule']}",
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.white)),
                                      ],
                                    ),
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: Colors.redAccent,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      "Annulée",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          StreamBuilder(
                              stream: _allproduit,
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> _allproduits) {
                                if (!_allproduits.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (_allproduits.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                return (_allproduits.data!.docs.isEmpty)
                                    ?
                                    // aucun produit
                                    Column(
                                        children: [
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          const Center(
                                            child: Text(
                                              "Bienvenue sur votre dashboard",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          const Text(
                                            "Dans le but de publier le plus rapidement votre premier produit, nous vous prions de suivre les 3 étapes ci-dessous ",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                            textAlign: TextAlign.justify,
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          const Text(
                                            "Étape 1 : rendez-vous dans  paramètre, choisissez catégorie pour ajouter les catégories indispensables à la structuration de votre boutique.",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                          if (compte.data!.docs[index]
                                                  ['design'] ==
                                              "2")
                                            Column(
                                              children: const [
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Text(
                                                  "Étape * : rendez-vous dans paramètre, choisissez emplacement pour ajouter des emplacements pour vos produits indispensable à la structuration de votre boutique.",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          const Text(
                                            "Étape 2 : Rendez-vous dans paramètre, choisissez le système de livraison pour ajouter les communes que vous couvrez ainsi que leur prix.",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          const Text(
                                            "Étape 3 : appuyez sur le bouton ajouté un produit, pour publier votre premier produit.",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          const Text(
                                            "À savoir : le bouton 'Production' dans  paramètre permet de déterminer si votre boutique doit être visible par les utilisateurs ou non. Il est désactivé par défaut, nous vous prions de l'activer une fois, vous avez terminé la configuration de votre boutique et publier vos produits.",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                          const SizedBox(
                                            height: 60,
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: <Widget>[
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          const Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              "Liste des produits",
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          ListView.builder(
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: _allproduits
                                                  .data!.docs.length,
                                              itemBuilder: (context, index) {
                                                return Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                            height: 60,
                                                            width: 60,
                                                            decoration: const BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            50))),
                                                            child:
                                                                GestureDetector(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        nom = _allproduits
                                                                            .data!
                                                                            .docs[index]["nom"];
                                                                        prix = _allproduits
                                                                            .data!
                                                                            .docs[index]["prix"];
                                                                        description = _allproduits
                                                                            .data!
                                                                            .docs[index]["description"];
                                                                        image1 = _allproduits
                                                                            .data!
                                                                            .docs[index]["image1"];
                                                                        stock = _allproduits
                                                                            .data!
                                                                            .docs[index]["stock"];
                                                                      });
                                                                      viewproduct(_allproduits
                                                                          .data!
                                                                          .docs[
                                                                              index]
                                                                          .id);
                                                                    },
                                                                    child:
                                                                        CircleAvatar(
                                                                      backgroundImage: CachedNetworkImageProvider(_allproduits
                                                                          .data!
                                                                          .docs[index]["image1"]),
                                                                    ))),
                                                        Text(
                                                          _allproduits.data!
                                                                  .docs[index]
                                                              ["nom"],
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 20),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                            _allproduits.data!
                                                                            .docs[
                                                                        index]
                                                                    ["prix"] +
                                                                " Fcfa",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    color: Colors
                                                                        .white))
                                                      ],
                                                    ),
                                                    const Divider(
                                                      color: Colors.grey,
                                                    ),
                                                  ],
                                                );
                                              })
                                        ],
                                      );
                              }),
                        ],
                      );
                    });
              })),
      floatingActionButton:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        FloatingActionButton.extended(
          backgroundColor: Colors.orange.shade900,
          label: const Text(
            "Ajouter un produit",
            style: TextStyle(),
          ),
          onPressed: () {
            print(design);
            FirebaseFirestore.instance
                .collection("noeud")
                .where("idcompte", isEqualTo: idshop)
                .get()
                .then((QuerySnapshot value) {
              Get.toNamed('/publicationshop', arguments: [
                {"idshop": idshop},
                {"design": value.docs.first['design']}
              ]);
            });
          },
          heroTag: null,
        ),
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                        style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            fixedSize: const Size(300, 60),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: const Text(
                          "Supprimer le produit",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
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
                        "Vous apportez une modification $terminaison du produit",
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
                  requ.message("Success", "Modification apportée avec succès");
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
              child: const Text('Oui supprimer',
                  style: TextStyle(color: Colors.white)),
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
