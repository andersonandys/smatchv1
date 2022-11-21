import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Vlog extends StatefulWidget {
  @override
  _VlogState createState() => _VlogState();
}

class _VlogState extends State<Vlog> {
  String nomchaine = Get.arguments[1]["nomchaine"];
  String idchaine = Get.arguments[0]["idchaine"];
  final Stream<QuerySnapshot> _video = FirebaseFirestore.instance
      .collection("videovlog")
      .where("idvlog", isEqualTo: Get.arguments[0]["idchaine"])
      .snapshots();
  String playlsietchoix = "tout";
  final Stream<QuerySnapshot> playliste = FirebaseFirestore.instance
      .collection('categorie')
      .where("idcompte", isEqualTo: Get.arguments[0]["idchaine"])
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(30),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(30),
        title: Text(
          nomchaine,
          style: GoogleFonts.poppins(fontSize: 25),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                viewplayliste();
              },
              icon: const Icon(IconlyLight.filter)),
        ],
      ),
      body: Container(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                (playlsietchoix != "tout")
                    ? Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            playlsietchoix,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                        ))
                    : Container(),
                const SizedBox(
                  height: 20,
                ),
                StreamBuilder(
                    stream: (playlsietchoix == "tout")
                        ? _video
                        : FirebaseFirestore.instance
                            .collection("videovlog")
                            .where("idvlog",
                                isEqualTo: Get.arguments[0]["idchaine"])
                            .where("playliste", isEqualTo: playlsietchoix)
                            .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> videochaine) {
                      if (!videochaine.hasData) {
                        return Center(
                          heightFactor: 5,
                          child: LoadingAnimationWidget.dotsTriangle(
                            color: Colors.blueAccent,
                            size: 100,
                          ),
                        );
                      }
                      if (videochaine.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          heightFactor: 5,
                          child: LoadingAnimationWidget.dotsTriangle(
                            color: Colors.blueAccent,
                            size: 100,
                          ),
                        );
                      }
                      return (videochaine.data!.docs.isEmpty)
                          ? const Center(
                              heightFactor: 10,
                              child: Text(
                                "Aucune vidéo disponible",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            )
                          : ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: videochaine.data!.docs.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Get.toNamed('/viewblog', arguments: [
                                      {
                                        "idvideo":
                                            videochaine.data!.docs[index].id,
                                      },
                                      {
                                        "lienvideo": videochaine
                                            .data!.docs[index]["video"]
                                      },
                                      {
                                        "titre": videochaine.data!.docs[index]
                                            ["titre"]
                                      },
                                      {
                                        "description": videochaine
                                            .data!.docs[index]["description"]
                                      },
                                      {"idvlog": idchaine}
                                    ]);
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      height: 350,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15)),
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10),
                                                    topLeft:
                                                        Radius.circular(10)),
                                            child: Image.network(
                                              videochaine.data!.docs[index]
                                                  ["vignette"],
                                              fit: BoxFit.cover,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 230,
                                            ),
                                          ),
                                          Container(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 10, top: 10),
                                              child: Column(
                                                children: [
                                                  Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        videochaine.data!
                                                                .docs[index]
                                                            ["titre"],
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                          videochaine.data!
                                                                  .docs[index]
                                                              ["description"],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                          ))),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Chip(
                                                          label: Row(
                                                        children: [
                                                          const Icon(
                                                              Iconsax.heart),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                              "${videochaine.data!.docs[index]["like"]} ")
                                                        ],
                                                      )),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Chip(
                                                          label: Row(
                                                        children: [
                                                          const Icon(
                                                              Iconsax.message),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                              "${videochaine.data!.docs[index]["comment"]} ")
                                                        ],
                                                      )),
                                                    ],
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
          )),
    );
  }

  viewplayliste() {
    showStickyFlexibleBottomSheet<void>(
      minHeight: 0,
      initHeight: 0.5,
      maxHeight: .8,
      headerHeight: 70,
      context: context,
      decoration: BoxDecoration(
        color: Colors.black.withBlue(30),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      headerBuilder: (context, offset) {
        return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black.withBlue(30),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(offset == 0.8 ? 0 : 20),
                topRight: Radius.circular(offset == 0.8 ? 0 : 20),
              ),
            ),
            child: Container(
                margin: const EdgeInsets.only(left: 10, right: 5),
                child: const Center(
                  child: Text(
                    'Playliste',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                )));
      },
      bodyBuilder: (context, offset) {
        return SliverChildListDelegate([
          Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            playlsietchoix = "tout";
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Toutes les vidéos",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      )),
                  const Divider(
                    color: Colors.white,
                  ),
                ],
              )),
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: StreamBuilder(
                stream: playliste,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> playliste) {
                  if (!playliste.hasData) {
                    return Center(
                      child: LoadingAnimationWidget.dotsTriangle(
                        color: Colors.blueAccent,
                        size: 100,
                      ),
                    );
                  }
                  if (playliste.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: LoadingAnimationWidget.dotsTriangle(
                        color: Colors.blueAccent,
                        size: 100,
                      ),
                    );
                  }
                  return (playliste.data!.docs.isEmpty)
                      ? const Center(
                          child: Text(
                          "Aucune playliste disponible",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ))
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: playliste.data!.docs.length,
                          itemBuilder: (context, index) {
                            return Container(
                                margin: const EdgeInsets.all(15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          playlsietchoix = playliste.data!
                                              .docs[index]["nomcategorie"];
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          playliste.data!.docs[index]
                                              ["nomcategorie"],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                      ),
                                    ),
                                    const Divider(
                                      color: Colors.white,
                                    ),
                                  ],
                                ));
                          });
                }),
          )
        ]);
      },
      anchors: [.2, 0.5, .8],
    );
  }
}
