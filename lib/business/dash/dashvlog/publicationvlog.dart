import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// import 'package:better_player/better_player.dart';
import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:smatch/home/tabsrequette.dart';
import 'package:video_player/video_player.dart';

class Publicationvlog extends StatefulWidget {
  const Publicationvlog({Key? key}) : super(key: key);

  @override
  _PublicationvlogState createState() => _PublicationvlogState();
}

class _PublicationvlogState extends State<Publicationvlog> {
  Timer? _timer;
  late double _progress;
  final titrecontroller = TextEditingController();
  final descriptoncontroller = TextEditingController();
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;

  String image1 = "";
  String video = "";
  File? imagefile;
  String idvlog = Get.arguments[0]["idchaine"];
  double progress = 0.0;
  bool viewprogressbar = false;
  final Stream<QuerySnapshot> _streamcategorie = FirebaseFirestore.instance
      .collection('categorie')
      .where("idcompte", isEqualTo: Get.arguments[0]["idchaine"])
      .orderBy("range", descending: true)
      .snapshots();
  int design = 1;
  late VideoPlayerController _controller;
  String? categorie;
  String? idcategorie;
  String emplacement = "";
  final requ = Get.put(Tabsrequette());
  bool isvideoune = false;
  bool videochoose = false;
  @override
  void initState() {
    super.initState();
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(25),
      appBar: AppBar(
          backgroundColor: Colors.black.withBlue(25),
          title: const Text("Publication d'une série"),
          centerTitle: true,
          elevation: 0),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              GestureDetector(
                onTap: () {
                  selectimage("image");
                },
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
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
                              "Sélectionnez une vignette.",
                              style: GoogleFonts.poppins(color: Colors.white),
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
              GestureDetector(
                onTap: () {
                  if (image1.isEmpty) {
                    requ.message("Echec",
                        "Télécharger la vignette avant d'ajouter la vidéo");
                  } else {
                    selectvideo("video");
                  }
                },
                child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.video,
                            size: 30, color: Colors.white),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          (video == "")
                              ? "Sélectionnez une vidéo."
                              : "Sélectionnez une autre vidéo.",
                          style: GoogleFonts.poppins(color: Colors.white),
                          textAlign: TextAlign.center,
                        )
                      ],
                    )),
              ),
            ]),
            const SizedBox(
              height: 10,
            ),
            (viewprogressbar)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 15.0,
                        width: MediaQuery.of(context).size.width / 1.5,
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
            if (videochoose == true)
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Aperçu de la vidéo",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomVideoPlayer(
                      customVideoPlayerController:
                          _customVideoPlayerController),
                ],
              ),
            const SizedBox(
              height: 30,
            ),
            TextFormField(
              style: const TextStyle(color: Colors.white),
              cursorHeight: 20,
              autofocus: false,
              controller: titrecontroller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                label: const Text("Titre de la vidéo",
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
              maxLines: 3,
              cursorHeight: 20,
              autofocus: false,
              controller: descriptoncontroller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                label: const Text(
                  "Description de la vidéo",
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
              child: Text("Playlist",
                  style:
                      GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
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
                      return const Text("Chargement des playslit");
                    }
                    if (_categorie.connectionState == ConnectionState.waiting) {
                      return const Text('Chargement des playslit');
                    }
                    return (_categorie.data!.docs.isEmpty)
                        ? const Center(
                            child: Text(
                              "Aucune playlist ajoutée, nous vous prions d'en ajouter",
                              style: TextStyle(color: Colors.white),
                            ),
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
                                  backgroundColor:
                                      Colors.white.withOpacity(0.1),
                                  padding: const EdgeInsets.all(10),
                                  selectedColor: Colors.greenAccent,
                                  disabledColor: Colors.white.withOpacity(0.1),
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
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  "Définir comme série à la une",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
                Switch(
                    value: isvideoune,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.white,
                    activeColor: Colors.greenAccent,
                    activeTrackColor: Colors.greenAccent,
                    onChanged: (value) {
                      setState(() {
                        isvideoune = value;
                      });
                    })
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    publictaion();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade900,
                      fixedSize: Size(MediaQuery.of(context).size.width, 70),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: Text(
                    "Publier la série",
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        )),
      ),
    );
  }

  // traitement des fonctions

  publictaion() {
    if (image1.isEmpty) {
      requ.message("Echec", "Nous vous prions de sélectionner une vignetée.");
    } else if (video.isEmpty) {
      requ.message("Echec", "Nous vous prions de sélectionner une vidéo.");
    } else if (titrecontroller.text.isEmpty) {
      requ.message("Echec", "Nous vous prions de saisir le titre de la vidéo.");
    } else if (descriptoncontroller.text.isEmpty) {
      requ.message(
          "Echec", "Nous vous prions de saisir la description de la vidéo.");
    } else if (categorie == null || categorie!.isEmpty) {
      requ.message("Echec", "Nous vous prions de choisir une playlist.");
    } else {
      _progress = 0;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
        EasyLoading.showProgress(_progress,
            maskType: EasyLoadingMaskType.black,
            status:
                "${(_progress * 100).toStringAsFixed(0)}% \n Publication de la série \n Patientez s'il vous plaît. ");
        _progress += 0.01;

        if (_progress >= 1) {
          _timer?.cancel();
          EasyLoading.dismiss();
          requ.message("Succes", "Série publiée avec succès");
          titrecontroller.clear();
          descriptoncontroller.clear();

          _customVideoPlayerController.dispose();

          setState(() {
            viewprogressbar = false;
            videochoose = false;
          });
        }
      });
      DateTime now = DateTime.now();
      String dateformat = DateFormat("yyyy-MM-dd - kk:mm").format(now);
      FirebaseFirestore.instance.collection('videovlog').add({
        "titre": titrecontroller.text,
        "description": descriptoncontroller.text,
        "vignette": image1,
        "video": video,
        "idvlog": idvlog,
        "like": 0,
        "comment": 0,
        "vue": 0,
        "partage": 0,
        "date": dateformat,
        "range": DateTime.now().millisecondsSinceEpoch,
        "playliste": categorie,
        "idcategorie": idcategorie,
      }).then((value) {
        FirebaseFirestore.instance
            .collection("videovlog")
            .doc(value.id)
            .update({"idvideo": value.id});
        if (isvideoune) {
          FirebaseFirestore.instance.collection('noeud').doc(idvlog).update({
            "titre": titrecontroller.text,
            "descriptionvideo": descriptoncontroller.text,
            "vignette": image1,
            "lienvideo": video,
            "playliste": categorie,
            "idvideo": value.id
          });
        }
      });
      FirebaseFirestore.instance
          .collection("noeud")
          .doc(idvlog)
          .update({"nbrevideo": FieldValue.increment(1)});
      // setState(() {
      //   categorie = null;
      //   video = "";
      //   image1 = "";
      // });
    }
  }

// uplaod de fichier image
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
      } on FirebaseException catch (e) {
        print("erreur lors du chagement");
      }
    }
  }

// upload fichier video
  selectvideo(numberimage) async {
    setState(() {
      progress = 0;
      viewprogressbar = true;
    });
    final fila = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (fila != null) {
      try {
        setState(() {
          videochoose = true;
        });

        videoPlayerController = VideoPlayerController.file(File(fila.path))
          ..initialize().then((value) => setState(() {}));
        _customVideoPlayerController = CustomVideoPlayerController(
            context: context,
            videoPlayerController: videoPlayerController,
            customVideoPlayerSettings: const CustomVideoPlayerSettings(
                settingsButtonAvailable: false));
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
      if (type == "image") {
        image1 = downloadURL;
        viewprogressbar = false;
      } else if (type == "video") {
        video = downloadURL;
        viewprogressbar = false;
      }
    });
    print(downloadURL);
  }
}
