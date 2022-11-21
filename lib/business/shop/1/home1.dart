import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smatch/business/shop/traitementshop.dart';

class home1shop extends StatefulWidget {
  const home1shop({Key? key}) : super(key: key);

  @override
  _home1shopState createState() => _home1shopState();
}

class _home1shopState extends State<home1shop> {
  String idshop = Get.arguments[0]["idshop"];
  String nomshop = Get.arguments[1]["nomshop"];

// listes de touts les produits
  final Stream<QuerySnapshot> _allproduit = FirebaseFirestore.instance
      .collection('produitshop')
      .where("idshop", isEqualTo: Get.arguments[0]["idshop"])
      .snapshots();
  // produit recommander
  final Stream<QuerySnapshot> _produitrecommander = FirebaseFirestore.instance
      .collection('produitshop')
      .where("idshop", isEqualTo: Get.arguments[0]["idshop"])
      .where("emplacement", isEqualTo: "recommander")
      .orderBy("range", descending: true)
      .snapshots();
  // meilleur produit
  final Stream<QuerySnapshot> _meilleurproduit = FirebaseFirestore.instance
      .collection('produitshop')
      .where("idshop", isEqualTo: Get.arguments[0]["idshop"])
      .where("emplacement", isEqualTo: "top")
      .orderBy("range", descending: true)
      .snapshots();

  // listes de toutes les categorie
  final Stream<QuerySnapshot> _allcategorie = FirebaseFirestore.instance
      .collection('categorie')
      .where("idcompte", isEqualTo: Get.arguments[0]["idshop"])
      .orderBy("range", descending: true)
      .snapshots();
  String categorie = "Toutes les cateories";
  String noimage =
      "https://firebasestorage.googleapis.com/v0/b/flutterprojet-e8896.appspot.com/o/business%2Fimages.png?alt=media&token=27fc4039-7e73-49a9-bf72-3493a61fc8fc";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          nomshop,
          style: GoogleFonts.poppins(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Icon(
            IconlyLight.arrowLeftCircle,
            color: Colors.black,
            size: 30,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),

              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Recommander pour vous",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              StreamBuilder(
                  stream: _produitrecommander,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> allproduit) {
                    if (!allproduit.hasData) {
                      return const Center(
                          child: Text(
                        "Chargement des produits...",
                        style: TextStyle(color: Colors.white),
                      ));
                    }
                    if (allproduit.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: Text(
                        "Chargement des produits...",
                        style: TextStyle(color: Colors.white),
                      ));
                    }
                    return (allproduit.data!.docs.isEmpty)
                        ? const Text(
                            "Aucun produit disponible pour cette section")
                        : SizedBox(
                            height: 270,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: allproduit.data!.docs.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        left: 2, right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    height: 230,
                                    width: 200,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                goviewproduit(
                                                    allproduit.data!.docs[index]
                                                        ["nom"],
                                                    allproduit.data!.docs[index]
                                                        ["description"],
                                                    allproduit.data!.docs[index]
                                                        ["prix"],
                                                    allproduit.data!.docs[index]
                                                        ["image1"],
                                                    allproduit.data!.docs[index]
                                                        ["image2"],
                                                    allproduit.data!.docs[index]
                                                        ["image3"],
                                                    idshop,
                                                    allproduit
                                                        .data!.docs[index].id);
                                              },
                                              child: Container(
                                                height: 200,
                                                width: 200,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                  child: CachedNetworkImage(
                                                    fit: BoxFit.cover,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height,
                                                    imageUrl: allproduit.data!
                                                        .docs[index]["image1"],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  allproduit.data!.docs[index]
                                                      ["nom"],
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: Text(
                                                    "${allproduit.data!.docs[index]["prix"]} Fcfa",
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          );
                  }),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Meilleur produit",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10,
              ),

              StreamBuilder(
                  stream: _meilleurproduit,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> allproduit) {
                    if (!allproduit.hasData) {
                      return const Center(
                          child: Text(
                        "Chargement des produits...",
                        style: TextStyle(color: Colors.white),
                      ));
                    }
                    if (allproduit.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: Text(
                        "Chargement des produits...",
                        style: TextStyle(color: Colors.white),
                      ));
                    }
                    return (allproduit.data!.docs.isEmpty)
                        ? const Text(
                            "Aucun produit disponible pour cette section")
                        : SizedBox(
                            height: 270,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: allproduit.data!.docs.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        left: 2, right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    height: 230,
                                    width: 200,
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                goviewproduit(
                                                    allproduit.data!.docs[index]
                                                        ["nom"],
                                                    allproduit.data!.docs[index]
                                                        ["description"],
                                                    allproduit.data!.docs[index]
                                                        ["prix"],
                                                    allproduit.data!.docs[index]
                                                        ["image1"],
                                                    allproduit.data!.docs[index]
                                                        ["image2"],
                                                    allproduit.data!.docs[index]
                                                        ["image3"],
                                                    idshop,
                                                    allproduit
                                                        .data!.docs[index].id);
                                              },
                                              child: Container(
                                                height: 200,
                                                width: 200,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                  child: CachedNetworkImage(
                                                    fit: BoxFit.cover,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height,
                                                    imageUrl: allproduit.data!
                                                        .docs[index]["image1"],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  allproduit.data!.docs[index]
                                                      ["nom"],
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: Text(
                                                    "${allproduit.data!.docs[index]["prix"]} Fcfa",
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          );
                  }),

              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Catégorie",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  ChoiceChip(
                    selectedColor: Colors.greenAccent,
                    disabledColor: Colors.grey,
                    selected: (categorie == "Tout") ? true : false,
                    backgroundColor: Colors.grey.shade100,
                    padding: const EdgeInsets.all(5),
                    label: Text("Tout",
                        style: GoogleFonts.poppins(
                            fontSize: 20, color: Colors.black87)),
                    onSelected: (value) {
                      setState(() {
                        categorie = "Toutes les catégories";
                        print(categorie);
                      });
                    },
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                        height: 50,
                        child: StreamBuilder(
                            stream: _allcategorie,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> allcategorie) {
                              if (!allcategorie.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (allcategorie.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: allcategorie.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                          left: 5, right: 5),
                                      child: ChoiceChip(
                                        selectedColor: Colors.greenAccent,
                                        disabledColor: Colors.grey,
                                        selected: (categorie ==
                                                allcategorie.data!.docs[index]
                                                    ['nomcategorie'])
                                            ? true
                                            : false,
                                        backgroundColor: Colors.grey.shade200,
                                        padding: const EdgeInsets.all(5),
                                        label: Text(
                                            allcategorie.data!.docs[index]
                                                ["nomcategorie"],
                                            style: GoogleFonts.poppins(
                                                fontSize: 20,
                                                color: Colors.black87)),
                                        onSelected: (value) {
                                          setState(() {
                                            categorie = allcategorie.data!
                                                .docs[index]["nomcategorie"];
                                            print(categorie);
                                          });
                                        },
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)),
                                        ),
                                      ),
                                    );
                                  });
                            })),
                  )
                ],
              ),

              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                  stream: (categorie == "Toutes les cateories")
                      ?
                      // affiche tout les produits
                      FirebaseFirestore.instance
                          .collection('produitshop')
                          .where("idshop",
                              isEqualTo: Get.arguments[0]["idshop"])
                          .orderBy("range", descending: true)
                          .snapshots()
                      :
                      //  affiche les produit par categorie
                      FirebaseFirestore.instance
                          .collection('produitshop')
                          .where("idshop",
                              isEqualTo: Get.arguments[0]["idshop"])
                          .where("categorie", isEqualTo: categorie)
                          .orderBy("range", descending: true)
                          .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> allproduit) {
                    if (!allproduit.hasData) {
                      return Center(
                        heightFactor: 10,
                        child: LoadingAnimationWidget.dotsTriangle(
                          color: Colors.blueAccent,
                          size: 100,
                        ),
                      );
                    }
                    if (allproduit.connectionState == ConnectionState.waiting) {
                      return Center(
                        heightFactor: 10,
                        child: LoadingAnimationWidget.dotsTriangle(
                          color: Colors.blueAccent,
                          size: 100,
                        ),
                      );
                    }
                    return (allproduit.data!.docs.isEmpty)
                        ? Text(
                            "Aucun produit trouvé pour $categorie",
                            style: const TextStyle(fontSize: 15),
                            textAlign: TextAlign.justify,
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.0,
                              mainAxisSpacing: 10.0,
                              crossAxisSpacing: 5.0,
                              mainAxisExtent: 270,
                            ),
                            itemCount: allproduit.data!.docs.length,
                            itemBuilder: (BuildContext ctx, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                height: 230,
                                width: 200,
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            goviewproduit(
                                                allproduit.data!.docs[index]
                                                    ["nom"],
                                                allproduit.data!.docs[index]
                                                    ["description"],
                                                allproduit.data!.docs[index]
                                                    ["prix"],
                                                allproduit.data!.docs[index]
                                                    ["image1"],
                                                allproduit.data!.docs[index]
                                                    ["image2"],
                                                allproduit.data!.docs[index]
                                                    ["image3"],
                                                idshop,
                                                allproduit
                                                    .data!.docs[index].id);
                                          },
                                          child: Container(
                                            height: 200,
                                            width: 200,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                            ),
                                            child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                child: Hero(
                                                  tag: allproduit
                                                      .data!.docs[index].id,
                                                  child: CachedNetworkImage(
                                                    fit: BoxFit.cover,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height,
                                                    imageUrl: allproduit.data!
                                                        .docs[index]["image1"],
                                                  ),
                                                )),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              allproduit.data!.docs[index]
                                                  ["nom"],
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Text(
                                                "${allproduit.data!.docs[index]["prix"]} Fcfa",
                                                style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.w400)),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            });
                  }),
              // afficher les produits correpondant au choix de l'utilisateur
            ],
          ),
        ),
      ),
    );
  }

  goviewproduit(
      nom, description, prix, image1, image2, image3, idshop, idproduit) {
    Get.toNamed("/viewproduit1", arguments: [
      {"nom": nom},
      {"prix": prix},
      {"description": description},
      {"image1": image1},
      {"image2": image2},
      {"image3": image3},
      {"idshop": idshop},
      {"idproduit": idproduit}
    ]);
  }
}

class Viewproduit1 extends StatefulWidget {
  const Viewproduit1({Key? key}) : super(key: key);

  @override
  _Viewproduit1State createState() => _Viewproduit1State();
}

class _Viewproduit1State extends State<Viewproduit1> {
  String nomproduit = Get.arguments[0]["nom"];
  String prix = Get.arguments[1]["prix"];
  String description = Get.arguments[2]["description"];
  String image1 = Get.arguments[3]["image1"];
  String image2 = Get.arguments[4]["image2"];
  String image3 = Get.arguments[5]["image3"];
  String idshop = Get.arguments[6]["idshop"];
  String idproduit = Get.arguments[7]["idproduit"];
  int? wallet;
  String noimage =
      "https://firebasestorage.googleapis.com/v0/b/flutterprojet-e8896.appspot.com/o/business%2Fimages.png?alt=media&token=27fc4039-7e73-49a9-bf72-3493a61fc8fc";
  User? user = FirebaseAuth.instance.currentUser;
  final traitement = Get.put(Traitment1shop());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getinfouser();
  }

  getinfouser() {
    FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc.id == user!.uid) {
          wallet = doc["wallet"];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            IconlyLight.arrowLeftCircle,
            color: Colors.black,
            size: 30,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed("/panier1shop", arguments: [
                {"idshop": idshop}
              ]);
            },
            icon: const Icon(
              IconlyLight.bag,
              color: Colors.black,
              size: 30,
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Stack(
            children: [
              SizedBox(
                height: 300,
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        CachedNetworkImage(
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          imageUrl: (image1.isEmpty) ? noimage : image1,
                        ),
                        CachedNetworkImage(
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          imageUrl: (image2.isEmpty) ? noimage : image2,
                        ),
                        CachedNetworkImage(
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          imageUrl: (image3.isEmpty) ? noimage : image3,
                        ),
                      ],
                    )),
              ),
              Positioned(
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('favorisproduit')
                          .where("idproduit", isEqualTo: idproduit)
                          .where("iduser", isEqualTo: user!.uid)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> allfavoris) {
                        if (!allfavoris.hasData) {
                          return LiquidCircularProgressIndicator();
                        }
                        if (allfavoris.connectionState ==
                            ConnectionState.waiting) {
                          return LiquidCircularProgressIndicator();
                        }
                        return (allfavoris.data!.docs.isEmpty)
                            ?
                            // si l'utilisateur n'a pas encore ajoute au favoris
                            GestureDetector(
                                onTap: () {
                                  traitement.addfavoris(idproduit, idshop,
                                      nomproduit, prix, image1);
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        border: Border.all(
                                            color: Colors.black, width: 1),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(50))),
                                    child: const Center(
                                      child: Icon(
                                        Iconsax.heart,
                                        size: 30,
                                      ),
                                    )),
                              )
                            :
                            //  si l'utilisateur a deja ajoute au favoris
                            GestureDetector(
                                onTap: () {
                                  traitement.deletefavoris(
                                      allfavoris.data!.docs.first.id);
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        border: Border.all(
                                            color: Colors.black, width: 1),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(50))),
                                    child: const Center(
                                      child: Icon(Iconsax.heart,
                                          size: 30, color: Colors.white),
                                    )),
                              );
                      }),
                  bottom: 40,
                  right: 30),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.black.withBlue(40),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15))),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      nomproduit,
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      "$prix Fcfa",
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Détail de l'article",
                      style: GoogleFonts.poppins(
                          fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      description,
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
              child: Container(
            color: Colors.black.withBlue(40),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  traitement.addpanier(
                      nomproduit, prix, idshop, idproduit, image1, user!.uid);
                },
                child: Text(
                  "Ajouter au panier",
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70),
                ),
                style: ElevatedButton.styleFrom(
                    primary: Colors.orange.shade900,
                    fixedSize: const Size(300, 60),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
