import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smatch/business/shop/2/favoris2.dart';
import 'package:smatch/business/shop/traitementshop.dart';

class Home2shop extends StatefulWidget {
  const Home2shop({Key? key}) : super(key: key);

  @override
  _Home2shopState createState() => _Home2shopState();
}

class _Home2shopState extends State<Home2shop> {
  String idshop = Get.arguments[0]["idshop"];
  String nomshop = Get.arguments[1]["nomshop"];
  final seachcontroller = TextEditingController();
  String image =
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQRm4yWVYXWc2FUuyscYuOiAs6QInpRpJvbMQ&usqp=CAU";
  final List<String> imageList = [
    "https://images.hdqwalls.com/download/spiderman-peter-parker-standing-on-a-rooftop-ix-1280x720.jpg",
    "https://images.wallpapersden.com/image/download/peter-parker-spider-man-homecoming_bGhsa22UmZqaraWkpJRmZ21lrWxnZQ.jpg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSvUgui-suS8DgaljlONNuhy4vPUsC_UKvxJQ&usqp=CAU",
  ];
  List Lcategorie = [];
  String categorie = "tout";
  final traitement = Get.put(Traitment1shop());
  final Stream<QuerySnapshot> _emplacement = FirebaseFirestore.instance
      .collection('emplacement')
      .where("idcompte", isEqualTo: Get.arguments[0]["idshop"])
      .orderBy("range", descending: true)
      .snapshots();
  String choixcategorie = "";
  List allcomptesearch = [];
  List allproduitsearch = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    traitement.streamproduit2(Get.arguments[0]["idshop"], 'tout');
    traitement.emplacementproduit(Get.arguments[0]["idshop"]);
    print('super');

    allcategories();
    getallproduit();
  }

  allcategories() {
    print("object");
    FirebaseFirestore.instance
        .collection('categorie')
        .where("idcompte", isEqualTo: Get.arguments[0]["idshop"])
        .orderBy("range", descending: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        Lcategorie = querySnapshot.docs;
      });
    });
  }

  getallproduit() {
    FirebaseFirestore.instance
        .collection('produitshop')
        .where("idshop", isEqualTo: Get.arguments[0]["idshop"])
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        allproduitsearch = querySnapshot.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black.withBlue(20),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(20),
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Icon(
            IconlyLight.arrowLeftCircle,
            color: Colors.white,
            size: 30,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        title: Text(
          nomshop,
          style: GoogleFonts.mcLaren(
            color: Colors.white,
            fontSize: 25,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed("/favoris2", arguments: [
                {"idshop": idshop}
              ]);
            },
            icon: const Icon(
              Iconsax.heart,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              TextField(
                  style: TextStyle(color: Colors.white),
                  cursorHeight: 20,
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: 'Entrer votre recherche',
                    suffixIcon: const Icon(
                      Iconsax.search_normal_1,
                      color: Colors.white,
                    ),
                    filled: true,
                    fillColor: Colors.white12,
                    hintStyle: const TextStyle(color: Colors.white),
                    labelStyle: const TextStyle(color: Colors.white),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      gapPadding: 0.0,
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(color: Colors.white, width: 1.5),
                    ),
                  ),
                  onChanged: (value) {
                    _runFilter(value);
                  }),
              const SizedBox(height: 20),
              (allcomptesearch.isNotEmpty)
                  ?
                  // resultat de search
                  StaggeredGridView.countBuilder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 12,
                      itemCount: allcomptesearch.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              goviewproduit(
                                allcomptesearch[index]["nom"],
                                allcomptesearch[index]["description"],
                                allcomptesearch[index]["prix"],
                                allcomptesearch[index]["image1"],
                                allcomptesearch[index]["image2"],
                                allcomptesearch[index]["image3"],
                                idshop,
                                allcomptesearch[index].id,
                                allcomptesearch[index]["categorie"],
                              );
                            },
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12))),
                                  child: Column(
                                    children: [
                                      Expanded(
                                          child: Container(
                                        height: 200,
                                        width: 200,
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            child: Hero(
                                              tag: allcomptesearch[index]
                                                      ["image1"] +
                                                  "3",
                                              child: CachedNetworkImage(
                                                  imageUrl:
                                                      allcomptesearch[index]
                                                          ["image1"],
                                                  fit: BoxFit.cover),
                                            )),
                                      )),
                                      Container(
                                        margin: const EdgeInsets.only(
                                            top: 10,
                                            left: 5,
                                            right: 5,
                                            bottom: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              allcomptesearch[index]["nom"],
                                              style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  color: Colors.white),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 1,
                                  left: 10,
                                  child: Chip(
                                    backgroundColor: Colors.black.withBlue(25),
                                    label: Text(
                                      "${allcomptesearch[index]["prix"]} Fcfa",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ));
                      },
                      staggeredTileBuilder: (index) {
                        return StaggeredTile.count(1, index.isEven ? 1.2 : 1.5);
                      })
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => StreamBuilder(
                            stream: traitement.emplacement.value,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> emplacement) {
                              if (!emplacement.hasData) {
                                return const Center(
                                    child: Text(
                                  "Chargement des emplacements...",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ));
                              }
                              if (emplacement.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: Text(
                                  "Chargement des emplacements...",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ));
                              }
                              return ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: emplacement.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                emplacement.data!.docs[index]
                                                    ["nomemplacement"],
                                                style: GoogleFonts.poppins(
                                                    fontSize: 20,
                                                    color: Colors.white)),
                                            GestureDetector(
                                              onTap: () {
                                                viewemplacement(
                                                    emplacement
                                                            .data!.docs[index]
                                                        ["nomemplacement"],
                                                    emplacement
                                                        .data!.docs[index].id);
                                              },
                                              child: const Icon(Iconsax.more,
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        SizedBox(
                                          height: 250,
                                          child: StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection('produitshop')
                                                  .where("idshop",
                                                      isEqualTo: idshop)
                                                  .where("idemplacement",
                                                      isEqualTo: emplacement
                                                          .data!.docs[index].id)
                                                  .orderBy("range",
                                                      descending: true)
                                                  .snapshots(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<QuerySnapshot>
                                                      _produitemplacement) {
                                                if (!_produitemplacement
                                                    .hasData) {
                                                  return const Center(
                                                      child: Text(
                                                    "Chargement des produits..",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  ));
                                                }
                                                if (_produitemplacement
                                                        .connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(
                                                      child: Text(
                                                    "Chargement des produits..",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  ));
                                                }
                                                return (_produitemplacement
                                                        .data!.docs.isEmpty)
                                                    ? const Center(
                                                        child: Text(
                                                        "Aucun produit disponible pour cette section",
                                                        textAlign:
                                                            TextAlign.justify,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: 17),
                                                      ))
                                                    : ListView.builder(
                                                        physics:
                                                            BouncingScrollPhysics(),
                                                        itemCount:
                                                            _produitemplacement
                                                                .data!
                                                                .docs
                                                                .length,
                                                        shrinkWrap: true,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  goviewproduit(
                                                                    _produitemplacement
                                                                            .data!
                                                                            .docs[index]
                                                                        ["nom"],
                                                                    _produitemplacement
                                                                            .data!
                                                                            .docs[index]
                                                                        [
                                                                        "description"],
                                                                    _produitemplacement
                                                                            .data!
                                                                            .docs[index]
                                                                        [
                                                                        "prix"],
                                                                    _produitemplacement
                                                                            .data!
                                                                            .docs[index]
                                                                        [
                                                                        "image1"],
                                                                    _produitemplacement
                                                                            .data!
                                                                            .docs[index]
                                                                        [
                                                                        "image2"],
                                                                    _produitemplacement
                                                                            .data!
                                                                            .docs[index]
                                                                        [
                                                                        "image3"],
                                                                    idshop,
                                                                    _produitemplacement
                                                                        .data!
                                                                        .docs[
                                                                            index]
                                                                        .id,
                                                                    _produitemplacement
                                                                            .data!
                                                                            .docs[index]
                                                                        [
                                                                        "categorie"],
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 240,
                                                                  width: 200,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              0.1),
                                                                      borderRadius: const BorderRadius
                                                                              .all(
                                                                          Radius.circular(
                                                                              10))),
                                                                  child: Column(
                                                                    children: [
                                                                      Expanded(
                                                                          child: Container(
                                                                              height: 240,
                                                                              width: 200,
                                                                              decoration: const BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.all(Radius.circular(10))),
                                                                              child: ClipRRect(
                                                                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                  child: Hero(
                                                                                    tag: _produitemplacement.data!.docs[index].id + "1",
                                                                                    child: CachedNetworkImage(imageUrl: _produitemplacement.data!.docs[index]["image1"], fit: BoxFit.cover),
                                                                                  )))),
                                                                      Container(
                                                                        margin: const EdgeInsets.only(
                                                                            top:
                                                                                10,
                                                                            left:
                                                                                5,
                                                                            right:
                                                                                5,
                                                                            bottom:
                                                                                5),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            SizedBox(
                                                                              width: 200 / 1.7,
                                                                              child: Text(
                                                                                _produitemplacement.data!.docs[index]["nom"],
                                                                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              "${_produitemplacement.data!.docs[index]["prix"]} Fcfa",
                                                                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              )
                                                            ],
                                                          );
                                                        });
                                              }),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    );
                                  });
                            })),

// fin de la nouvelle affichage

                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text("Catégorie",
                              style: GoogleFonts.poppins(
                                  fontSize: 20, color: Colors.white)),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                Obx(
                                  () => ChoiceChip(
                                      selected: (traitement.categories.value ==
                                              "tout")
                                          ? true
                                          : false,
                                      selectedColor: Colors.greenAccent,
                                      disabledColor: Colors.grey,
                                      padding: const EdgeInsets.all(10),
                                      label: Text(
                                        "Tout",
                                        style:
                                            GoogleFonts.poppins(fontSize: 15),
                                      ),
                                      onSelected: (value) {
                                        traitement.streamproduit2(
                                            idshop, "tout");
                                      }),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: Lcategorie.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return Row(
                                          children: [
                                            ChoiceChip(
                                                selectedColor:
                                                    Colors.greenAccent,
                                                disabledColor: Colors.grey,
                                                selected: (categorie ==
                                                        Lcategorie[index]
                                                            ["nomcategorie"])
                                                    ? true
                                                    : false,
                                                padding:
                                                    const EdgeInsets.all(10),
                                                label: Text(
                                                  Lcategorie[index]
                                                      ["nomcategorie"],
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                onSelected: (value) {
                                                  traitement.streamproduit2(
                                                      idshop,
                                                      Lcategorie[index]
                                                          ['nomcategorie']);
                                                }),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                          ],
                                        );
                                      }),
                                )
                              ],
                            )),
                        const SizedBox(height: 20),
                        Obx(() => StreamBuilder(
                            stream: traitement.streamtest.value,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> allproduit) {
                              if (!allproduit.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (allproduit.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return (allproduit.data!.docs.isEmpty)
                                  ? Center(
                                      child: Text(
                                          "Aucun produit disponible pour  $categorie",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18)))
                                  : StaggeredGridView.countBuilder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 12,
                                      itemCount: allproduit.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
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
                                                allproduit.data!.docs[index].id,
                                                allproduit.data!.docs[index]
                                                    ["categorie"],
                                              );
                                            },
                                            child: Stack(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  12))),
                                                  child: Column(
                                                    children: [
                                                      Expanded(
                                                          child: Container(
                                                        height: 200,
                                                        width: 200,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.3),
                                                            borderRadius:
                                                                const BorderRadius
                                                                        .all(
                                                                    Radius.circular(
                                                                        10))),
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                const BorderRadius
                                                                        .all(
                                                                    Radius
                                                                        .circular(
                                                                            10)),
                                                            child: Hero(
                                                              tag: allproduit
                                                                          .data!
                                                                          .docs[index]
                                                                      [
                                                                      "image1"] +
                                                                  "3",
                                                              child: CachedNetworkImage(
                                                                  imageUrl: allproduit
                                                                          .data!
                                                                          .docs[index]
                                                                      [
                                                                      "image1"],
                                                                  fit: BoxFit
                                                                      .cover),
                                                            )),
                                                      )),
                                                      Container(
                                                        margin: const EdgeInsets
                                                                .only(
                                                            top: 10,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 5),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              allproduit.data!
                                                                      .docs[
                                                                  index]["nom"],
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                      fontSize:
                                                                          15,
                                                                      color: Colors
                                                                          .white),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 1,
                                                  left: 10,
                                                  child: Chip(
                                                    backgroundColor: Colors
                                                        .black
                                                        .withBlue(30),
                                                    label: Text(
                                                      "${allproduit.data!.docs[index]["prix"]} Fcfa",
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ));
                                      },
                                      staggeredTileBuilder: (index) {
                                        return StaggeredTile.count(
                                            1, index.isEven ? 1.2 : 1.5);
                                      });
                            }))
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }

  void _runFilter(String enteredKeyword) {
    List results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = [];
    } else {
      results = allproduitsearch
          .where((user) =>
              user["nom"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      allcomptesearch = results;
    });
    print(allcomptesearch);
  }

  goviewproduit(nom, description, prix, image1, image2, image3, idshop,
      idproduit, categorie) {
    Get.toNamed("/viewproduit2", arguments: [
      {"nom": nom},
      {"prix": prix},
      {"description": description},
      {"image1": image1},
      {"image2": image2},
      {"image3": image3},
      {"idshop": idshop},
      {"idproduit": idproduit},
      {"categorie": categorie}
    ]);
  }

  viewemplacement(title, idemplacement) {
    showMaterialModalBottomSheet(
        backgroundColor: Colors.black.withBlue(25),
        expand: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        context: context,
        builder: (context) => Container(
              margin: const EdgeInsets.only(left: 5, right: 5),
              height: MediaQuery.of(context).size.height / 1.2,
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                      height: 5,
                      width: 50,
                      decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(50)))),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                          fontSize: 20, color: Colors.white),
                    ),
                    alignment: Alignment.center,
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('produitshop')
                          .where("idshop", isEqualTo: idshop)
                          .where("idemplacement", isEqualTo: idemplacement)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> allproduit) {
                        if (!allproduit.hasData) {
                          return const Center(
                            heightFactor: 5,
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (allproduit.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            heightFactor: 5,
                            child: CircularProgressIndicator(),
                          );
                        }
                        return (allproduit.data!.docs.isEmpty)
                            ? const Center(
                                heightFactor: 10,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child: Text(
                                    "Aucun produit disponible pour cette section",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ))
                            : StaggeredGridView.countBuilder(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 12,
                                itemCount: allproduit.data!.docs.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                      onTap: () {
                                        Get.toNamed("/viewproduit2");
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(12))),
                                            child: Column(
                                              children: [
                                                Expanded(
                                                    child: Container(
                                                  height: 200,
                                                  width: 200,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  10))),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    child: CachedNetworkImage(
                                                        imageUrl: allproduit
                                                                .data!
                                                                .docs[index]
                                                            ["image1"],
                                                        fit: BoxFit.cover),
                                                  ),
                                                )),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 10,
                                                      left: 5,
                                                      right: 5,
                                                      bottom: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        allproduit.data!
                                                            .docs[index]["nom"],
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .white),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            child: Chip(
                                              backgroundColor:
                                                  Colors.black.withBlue(25),
                                              label: Text(
                                                "${allproduit.data!.docs[index]["prix"]} F",
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            top: 1,
                                            left: 10,
                                          )
                                        ],
                                      ));
                                },
                                staggeredTileBuilder: (index) {
                                  return StaggeredTile.count(
                                      1, index.isEven ? 1.2 : 1.5);
                                });
                      })
                ],
              )),
            ));
  }
}

class Viewproduit2 extends StatefulWidget {
  const Viewproduit2({Key? key}) : super(key: key);

  @override
  _Viewproduit2State createState() => _Viewproduit2State();
}

class _Viewproduit2State extends State<Viewproduit2> {
  String noimage =
      "https://firebasestorage.googleapis.com/v0/b/flutterprojet-e8896.appspot.com/o/business%2Fimages.png?alt=media&token=27fc4039-7e73-49a9-bf72-3493a61fc8fc";
  String nomproduit = Get.arguments[0]["nom"];
  String prix = Get.arguments[1]["prix"];
  String description = Get.arguments[2]["description"];
  String image1 = Get.arguments[3]["image1"];
  String image2 = Get.arguments[4]["image2"];
  String image3 = Get.arguments[5]["image3"];
  String idshop = Get.arguments[6]["idshop"];
  String idproduit = Get.arguments[7]["idproduit"];
  String categorie = Get.arguments[8]["categorie"];
  int? wallet;
  User? user = FirebaseAuth.instance.currentUser;
  final traitement = Get.put(Traitment1shop());

  final Stream<QuerySnapshot> _similaireproduit = FirebaseFirestore.instance
      .collection('produitshop')
      .where("idshop", isEqualTo: Get.arguments[6]["idshop"])
      .limit(5)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.center, colors: [
          Colors.white,
          Colors.black.withBlue(25),
          Colors.black.withBlue(25),
        ])),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(50))),
                  height: 300,
                  child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(50)),
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: [
                          CachedNetworkImage(
                            imageUrl: (image1.isEmpty) ? noimage : image1,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                          ),
                          CachedNetworkImage(
                            imageUrl: (image2.isEmpty) ? noimage : image2,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                          ),
                          CachedNetworkImage(
                            imageUrl: (image3.isEmpty) ? noimage : image3,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                          ),
                        ],
                      )),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: GestureDetector(
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
                Positioned(
                    bottom: 20,
                    right: 10,
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('favorisproduit')
                            .where("idproduit", isEqualTo: idproduit)
                            .where("iduser", isEqualTo: user!.uid)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> allfavoris) {
                          if (!allfavoris.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (allfavoris.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
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
                        })),
              ],
            ),
            Expanded(
                child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.black.withBlue(20),
                  borderRadius:
                      const BorderRadius.only(topLeft: Radius.circular(0))),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(nomproduit,
                              style: GoogleFonts.poppins(
                                  fontSize: 20, color: Colors.white))),
                    ),
                    Align(
                        alignment: Alignment.topRight,
                        child: Text(prix + " Fcfa",
                            style: GoogleFonts.poppins(
                                fontSize: 20, color: Colors.white))),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text("Détail",
                            style: GoogleFonts.poppins(
                                fontSize: 20, color: Colors.white70))),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(description,
                            style: GoogleFonts.poppins(
                                fontSize: 16, color: Colors.white),
                            textAlign: TextAlign.justify)),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text("Produit similaire",
                            style: GoogleFonts.poppins(
                                fontSize: 20, color: Colors.white70))),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 200,
                      child: StreamBuilder(
                          stream: _similaireproduit,
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> allproduit) {
                            if (!allproduit.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (allproduit.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return ListView.builder(
                                itemCount: allproduit.data!.docs.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      Container(
                                        height: 190,
                                        width: 170,
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        child: Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  nomproduit = allproduit
                                                      .data!.docs[index]["nom"];
                                                  prix = allproduit.data!
                                                      .docs[index]["prix"];
                                                  description = allproduit
                                                          .data!.docs[index]
                                                      ["description"];
                                                  image1 = allproduit.data!
                                                      .docs[index]["image1"];
                                                  image2 = allproduit.data!
                                                      .docs[index]["image2"];
                                                  image3 = allproduit.data!
                                                      .docs[index]["image3"];
                                                  idshop = allproduit.data!
                                                      .docs[index]["idshop"];
                                                  idproduit = allproduit
                                                      .data!.docs[index].id;
                                                  categorie = allproduit.data!
                                                      .docs[index]["categorie"];
                                                });
                                              },
                                              child: Expanded(
                                                  child: Container(
                                                      height: 150,
                                                      width: 180,
                                                      decoration: const BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10))),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    10)),
                                                        child: CachedNetworkImage(
                                                            imageUrl: allproduit
                                                                    .data!
                                                                    .docs[index]
                                                                ["image1"],
                                                            fit: BoxFit.cover),
                                                      ))),
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                                child: Text(
                                                    allproduit.data!.docs[index]
                                                        ["nom"],
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        color: Colors.white),
                                                    overflow:
                                                        TextOverflow.ellipsis)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      )
                                    ],
                                  );
                                });
                          }),
                    ),
                  ],
                ),
              ),
            ))
          ],
        ),
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade900,
        child: const Icon(Iconsax.shopping_cart),
        onPressed: () {
          traitement.addpanier(
              nomproduit, prix, idshop, idproduit, image1, user!.uid);
        },
        heroTag: null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
