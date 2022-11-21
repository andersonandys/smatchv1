import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:smatch/home/tabsrequette.dart';

class publicationshop extends StatefulWidget {
  const publicationshop({Key? key}) : super(key: key);

  @override
  _publicationshopState createState() => _publicationshopState();
}

class _publicationshopState extends State<publicationshop> {
  Timer? _timer;
  late double _progress;
  final nomcontroller = TextEditingController();
  final priscontroller = TextEditingController();
  final descriptoncontroller = TextEditingController();
  final stockcontroller = TextEditingController();
  String image1 = "";
  String image2 = "";
  String image3 = "";
  bool viewprogressbar = false;
  File? imagefile;
  String idshop = Get.arguments[0]["idshop"];
  String design = Get.arguments[1]["design"];
  double progress = 0.0;
  final Stream<QuerySnapshot> _streamcategorie = FirebaseFirestore.instance
      .collection('categorie')
      .where("idcompte", isEqualTo: Get.arguments[0]["idshop"])
      .orderBy("range", descending: true)
      .snapshots();
  final Stream<QuerySnapshot> _emplacement = FirebaseFirestore.instance
      .collection('emplacement')
      .where("idcompte", isEqualTo: Get.arguments[0]["idshop"])
      .orderBy("range", descending: true)
      .snapshots();
  String? categorie;
  String? idcategorie;
  String emplacements = "";
  final requ = Get.put(Tabsrequette());
  String idemplacement = "";
  @override
  void initState() {
    super.initState();
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });
    // EasyLoading.showSuccess('Use in initState');
    // EasyLoading.removeCallbacks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(25),
      appBar: AppBar(
          backgroundColor: Colors.black.withBlue(25),
          title: const Text("Publictaion de produit"),
          centerTitle: true,
          elevation: 0),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              height: 150,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: () {
                      selectimage(1);
                    },
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: (image1.isEmpty)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Iconsax.camera,
                                    size: 30, color: Colors.white),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Sélectionnez une image.",
                                  style:
                                      GoogleFonts.poppins(color: Colors.white),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            )
                          : ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              child: Image.network(
                                image1,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (image1.isEmpty) {
                        requ.message("Echec",
                            "Télécharger la première image de votre produit");
                      } else {
                        selectimage(2);
                      }
                    },
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: (image2.isEmpty)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Iconsax.camera,
                                    size: 30, color: Colors.white),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Sélectionnez une image.",
                                  style:
                                      GoogleFonts.poppins(color: Colors.white),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            )
                          : ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              child: Image.network(
                                image2,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (image1.isEmpty) {
                        requ.message("Echec",
                            "Télécharger la seconde image de votre produit.");
                      } else {
                        selectimage(3);
                      }
                    },
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: (image3.isEmpty)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Iconsax.camera,
                                    size: 30, color: Colors.white),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Sélectionnez une image.",
                                  style:
                                      GoogleFonts.poppins(color: Colors.white),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            )
                          : ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              child: Image.network(
                                image3,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            (viewprogressbar)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 15.0,
                        width: MediaQuery.of(context).size.width / 1.3,
                        // decoration: const BoxDecoration(
                        //     borderRadius: BorderRadius.all(Radius.circular(100))),
                        child: LiquidLinearProgressIndicator(
                          value: progress / 100,
                          borderRadius: 50,
                          valueColor: (progress < 100.0)
                              ? const AlwaysStoppedAnimation(Colors.pinkAccent)
                              : const AlwaysStoppedAnimation(
                                  Colors.greenAccent),
                          backgroundColor: Colors.white,
                          direction: Axis.horizontal,
                        ),
                      ),
                      Text(
                        "$progress%",
                        style: GoogleFonts.poppins(
                            fontSize: 20.0, color: Colors.white),
                      ),
                    ],
                  )
                : Container(),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              style: const TextStyle(color: Colors.white),
              cursorHeight: 20,
              autofocus: false,
              controller: nomcontroller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                label: const Text("Nom du produit",
                    style: TextStyle(color: Colors.white)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              style: const TextStyle(color: Colors.white),
              cursorHeight: 20,
              autofocus: false,
              controller: priscontroller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                label: const Text(
                  "Prix du produit",
                  style: TextStyle(color: Colors.white),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              cursorHeight: 20,
              autofocus: false,
              controller: descriptoncontroller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                label: const Text(
                  "Description du produit",
                  style: TextStyle(color: Colors.white),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              style: const TextStyle(color: Colors.white),
              cursorHeight: 20,
              autofocus: false,
              controller: stockcontroller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                label: const Text(
                  "Stock du produit",
                  style: TextStyle(color: Colors.white),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text("Catégorie",
                  style:
                      GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 50,
              child: StreamBuilder(
                  stream: _streamcategorie,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> _categorie) {
                    if (!_categorie.hasData) {
                      return const Text(
                        "Chargement des catégories",
                        style: TextStyle(color: Colors.white),
                      );
                    }
                    if (_categorie.connectionState == ConnectionState.waiting) {
                      return const Text(
                        "Chargement des catégories",
                        style: TextStyle(color: Colors.white),
                      );
                    }
                    return (_categorie.data!.docs.isEmpty)
                        ? const Text(
                            "Aucune catégorie ajoutée, nous vous prions d'en ajouter.",
                            style: TextStyle(color: Colors.white),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: _categorie.data!.docs.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.all(3),
                                child: ChoiceChip(
                                  padding: EdgeInsets.all(10),
                                  selectedColor: Colors.greenAccent,
                                  disabledColor: Colors.grey,
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
                                  onSelected: (value) {
                                    setState(() {
                                      categorie = _categorie.data!.docs[index]
                                          ["nomcategorie"];
                                      idcategorie =
                                          _categorie.data!.docs[index].id;
                                    });
                                  },
                                  selected: (categorie ==
                                          _categorie.data!.docs[index]
                                              ["nomcategorie"])
                                      ? true
                                      : false,
                                  label: Text(
                                    _categorie.data!.docs[index]
                                        ["nomcategorie"],
                                    style: GoogleFonts.poppins(
                                        color: Colors.black),
                                  ),
                                ),
                              );
                            });
                  }),
            ),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text("Emplacement ",
                  style:
                      GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(
              height: 10,
            ),
            (design == "1")
                ? SizedBox(
                    height: 50,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        ChoiceChip(
                          padding: const EdgeInsets.all(10),
                          label: Text("Recommander pour vous",
                              style: GoogleFonts.poppins(color: Colors.black)),
                          onSelected: (value) {
                            setState(() {
                              emplacements = "recommander";
                            });
                          },
                          selected:
                              (emplacements == "recommander") ? true : false,
                          selectedColor: Colors.greenAccent,
                          disabledColor: Colors.grey,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ChoiceChip(
                          padding: const EdgeInsets.all(10),
                          label: Text("Top produit",
                              style: GoogleFonts.poppins(color: Colors.black)),
                          onSelected: (value) {
                            setState(() {
                              emplacements = "top";
                            });
                          },
                          selected: (emplacements == "top") ? true : false,
                          selectedColor: Colors.greenAccent,
                          disabledColor: Colors.grey,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    height: 50,
                    child: StreamBuilder(
                        stream: _emplacement,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> _emplacement) {
                          if (!_emplacement.hasData) {
                            return const Text(
                              "Chargement des emplacements",
                              style: TextStyle(color: Colors.white),
                            );
                          }
                          if (_emplacement.connectionState ==
                              ConnectionState.waiting) {
                            return const Text(
                              "Chargement des emplacements",
                              style: TextStyle(color: Colors.white),
                            );
                          }
                          return (_emplacement.data!.docs.isEmpty)
                              ? const Text(
                                  "Aucun emplacement configuré, nous vous prions d'en ajouter",
                                  style: TextStyle(color: Colors.white),
                                )
                              : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: _emplacement.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.all(3),
                                      child: ChoiceChip(
                                        padding: const EdgeInsets.all(10),
                                        selectedColor: Colors.greenAccent,
                                        disabledColor: Colors.grey,
                                        labelStyle: const TextStyle(
                                            color: Colors.white),
                                        onSelected: (value) {
                                          setState(() {
                                            var test = _emplacement.data!
                                                .docs[index]["nomemplacement"];
                                            emplacements = test;

                                            idemplacement = _emplacement
                                                .data!.docs[index].id;
                                          });
                                        },
                                        selected: (emplacements ==
                                                _emplacement.data!.docs[index]
                                                    ["nomemplacement"])
                                            ? true
                                            : false,
                                        label: Text(
                                          _emplacement.data!.docs[index]
                                              ["nomemplacement"],
                                          style: GoogleFonts.poppins(
                                              color: Colors.black),
                                        ),
                                      ),
                                    );
                                  });
                        }),
                  ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  publictaion();
                },
                child: Text(
                  "Publier le produit",
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                    primary: Colors.orange.shade900,
                    fixedSize: Size(MediaQuery.of(context).size.width, 70),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            )
          ],
        )),
      ),
    );
  }

  // traitement des fonctions

  publictaion() {
    if (image1.isEmpty && image2.isEmpty && image3.isEmpty) {
      requ.message("Echec", "Nous vous prions de sélectionner une image.");
    } else if (nomcontroller.text.isEmpty) {
      requ.message(
          "Echec", "Nous vous prions de saisir le nom de votre produit");
    } else if (priscontroller.text.isEmpty) {
      requ.message("Echec", "Nous vous prions de saisir le prix du produit");
    } else if (descriptoncontroller.text.isEmpty) {
      requ.message(
          "Echec", "Nous vous prions de saisir la description du produit.");
    } else if (stockcontroller.text.isEmpty) {
      requ.message(
          "Echec", "Nous vous prions de saisir le nombre en stock du produit.");
    } else if (categorie == null || categorie!.isEmpty) {
      requ.message("Echec", "Nous vous prions de choisir une catégorie");
    } else if (design == "2" && emplacements == "") {
      requ.message(
          "Echec", "Nous vous prions de choisir un emplacement produit.");
    } else {
      _progress = 0;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
        EasyLoading.showProgress(_progress,
            maskType: EasyLoadingMaskType.black,
            status:
                '${(_progress * 100).toStringAsFixed(0)}% \n Publication de votre produit \n Ne quittez pas la page');
        _progress += 0.01;

        if (_progress >= 1) {
          _timer?.cancel();
          EasyLoading.dismiss();
          requ.message("Succes", "Votre produit a été publié avec succès.");
          nomcontroller.clear();
          priscontroller.clear();
          descriptoncontroller.clear();
          stockcontroller.clear();
          setState(() {
            categorie = null;
            emplacements = "";
          });
        }
      });
      DateTime now = DateTime.now();
      String dateformat = DateFormat("yyyy-MM-dd - kk:mm").format(now);
      FirebaseFirestore.instance.collection('produitshop').add({
        "nom": nomcontroller.text,
        "prix": priscontroller.text,
        "description": descriptoncontroller.text,
        "stock": stockcontroller.text,
        "image1": image1,
        "image2": image2,
        "image3": image3,
        "idshop": idshop,
        "date": dateformat,
        "range": DateTime.now().millisecondsSinceEpoch,
        "categorie": categorie,
        "idcategorie": idcategorie,
        "emplacement": emplacements,
        "idemplacement": idemplacement
      });
      FirebaseFirestore.instance
          .collection("noeud")
          .doc(idshop)
          .update({"nbrproduit": FieldValue.increment(1)});
    }
  }

// uplaod de fichier
  selectimage(numberimage) async {
    setState(() {
      progress = 0;
      viewprogressbar = true;
    });
    final fila = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (fila != null) {
      try {
        String fileName = fila.name;
        imagefile = File(fila.path);

        UploadTask task = FirebaseStorage.instance
            .ref()
            .child("business/$fileName")
            .putFile(File(fila.path));

        task.snapshotEvents.listen((event) {
          setState(() {
            progress = ((event.bytesTransferred.toDouble() /
                        event.totalBytes.toDouble()) *
                    100)
                .roundToDouble();

            print(progress);
          });
        });
        task.whenComplete(() => upload(fileName, numberimage));
      } on FirebaseException catch (e) {}
    }
  }

  Future<void> upload(fileName, type) async {
    String downloadURL = await FirebaseStorage.instance
        .ref()
        .child('business/$fileName')
        .getDownloadURL();
    setState(() {
      if (type == 1) {
        image1 = downloadURL;
        viewprogressbar = false;
      } else if (type == 2) {
        image2 = downloadURL;
        viewprogressbar = false;
      } else if (type == 3) {
        image3 = downloadURL;
        viewprogressbar = false;
      }
    });
    print(downloadURL);
  }
}
