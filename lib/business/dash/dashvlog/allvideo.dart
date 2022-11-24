import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Allvideo extends StatefulWidget {
  const Allvideo({Key? key}) : super(key: key);

  @override
  _AllvideoState createState() => _AllvideoState();
}

class _AllvideoState extends State<Allvideo> {
  String idchaine = Get.arguments[0]["idchaine"];
  final Stream<QuerySnapshot> _allvideo = FirebaseFirestore.instance
      .collection('videovlog')
      .where("idvlog", isEqualTo: Get.arguments[0]["idchaine"])
      .orderBy("range", descending: true)
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(25),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(25),
        title: const Text("video"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
            stream: _allvideo,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> videopub) {
              if (!videopub.hasData) {
                return const Expanded(
                    child: Center(
                        heightFactor: 5, child: CircularProgressIndicator()));
              }
              if (videopub.connectionState == ConnectionState.waiting) {
                return const Expanded(
                    child: Center(
                        heightFactor: 5, child: CircularProgressIndicator()));
              }
              return (videopub.data!.docs.isEmpty)
                  ? const Expanded(
                      child: Center(
                          heightFactor: 10,
                          child: Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              "Vous n'avez pas encore de vidéo publiée.",
                              textAlign: TextAlign.justify,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          )))
                  : ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: videopub.data!.docs.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onDoubleTap: () {
                            deletecomande(videopub.data!.docs[index].id,
                                videopub.data!.docs[index]["titre"]);
                          },
                          child: Container(
                              margin: const EdgeInsets.only(
                                  bottom: 10, left: 10, right: 10),
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(5),
                                        topLeft: Radius.circular(5)),
                                    child: CachedNetworkImage(
                                      imageUrl: videopub.data!.docs[index]
                                          ["vignette"],
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width,
                                      height: 200,
                                    ),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10, top: 10),
                                      child: Column(
                                        children: [
                                          Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                videopub.data!.docs[index]
                                                    ["titre"],
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                                overflow: TextOverflow.ellipsis,
                                              )),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                  videopub.data!.docs[index]
                                                      ["description"],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ))),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Chip(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                label: Text(
                                                  "${videopub.data!.docs[index]["vue"]}",
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                                avatar: const Icon(
                                                  Iconsax.eye,
                                                  size: 30,
                                                ),
                                              ),
                                              Chip(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                label: Text(
                                                  "${videopub.data!.docs[index]["comment"]}",
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                                avatar: const Icon(
                                                  Iconsax.message,
                                                  size: 30,
                                                ),
                                              ),
                                              Chip(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                label: Text(
                                                  "${videopub.data!.docs[index]["like"]}",
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                                avatar: const Icon(
                                                  Iconsax.heart,
                                                  size: 30,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ))
                                ],
                              )),
                        );
                      });
            }),
      ),
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
                Text("Vous êtes sur le point de supprimer. $nom"),
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
