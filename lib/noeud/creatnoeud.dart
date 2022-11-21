import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';

import 'package:smatch/home/tabsrequette.dart';
import 'package:smatch/menu/menuhome.dart';

class Noeudcreat extends StatefulWidget {
  @override
  _NoeudcreatState createState() => _NoeudcreatState();
}

class _NoeudcreatState extends State<Noeudcreat> {
  CollectionReference noeud = FirebaseFirestore.instance.collection('noeud');
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  String? _offrechoix;
  String? _status;
  String? logo;
  String illustration =
      'https://image.freepik.com/vecteurs-libre/groupe-jeunes-posant-pour-photo_52683-18823.jpg';
  double progress = 0.0;

  User? user = FirebaseAuth.instance.currentUser;
  File? imagefile;
  Timer? _timer;
  String? nomuser;
  String? avataruser;
  int prix = 0;
  final requ = Get.put(Tabsrequette());
  CollectionReference branche =
      FirebaseFirestore.instance.collection("branche");
  CollectionReference userbranche =
      FirebaseFirestore.instance.collection("userbranche");
  CollectionReference abonnement =
      FirebaseFirestore.instance.collection("abonne");
  late FirebaseMessaging messaging;
  String? token = " ";
  @override
  void initState() {
    super.initState();
    EasyLoading.addStatusCallback((status) {
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });
    getinfouser();
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      setState(() {
        token = value;
      });
    });
  }

  getinfouser() async {
    FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc.id == user!.uid) {
          setState(() {
            nomuser = doc['nom'];
            avataruser = doc['avatar'];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
        child: Container(
      color: Colors.black.withBlue(25),
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    )),
                width: 50,
                height: 5,
                margin: EdgeInsets.only(top: 10, bottom: 10),
              ),
            ),
            const Text(
              "Création de noeud",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    selectimage();
                  },
                  child: (logo == null)
                      ? Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50)),
                              color: Colors.white.withOpacity(0.2)),
                          child: const Center(
                            child: Icon(
                              Iconsax.camera,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        )
                      : CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(logo!),
                        ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                    controller: _nomController,
                    decoration: InputDecoration(
                      fillColor: Colors.white.withOpacity(0.2),
                      filled: true,
                      label: const Text('Nom du nœud'),
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 2),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              style: const TextStyle(color: Colors.white),
              controller: _descriptionController,
              minLines: 3,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                label: const Text("Description"),
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                ),
                fillColor: Colors.white.withOpacity(0.2),
                filled: true,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Statut",
                style: TextStyle(color: Colors.white70, fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _status = "public";
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                          height: 100,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: const [
                                Icon(
                                  Icons.public,
                                  size: 35,
                                  color: Colors.white,
                                ),
                                Text(
                                  "Public",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                )
                              ])),
                      (_status == "public")
                          ? const Positioned(
                              child: Icon(
                                Icons.check,
                                size: 30,
                                color: Colors.greenAccent,
                              ),
                              top: 1,
                              right: 10,
                            )
                          : Container()
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _status = "prive";
                      _offrechoix = "gratuit";
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                          height: 100,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: const [
                                Icon(
                                  Iconsax.security_user,
                                  size: 35,
                                  color: Colors.white,
                                ),
                                Text(
                                  "Privé",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                )
                              ])),
                      (_status == 'prive')
                          ? const Positioned(
                              child: Icon(
                                Icons.check,
                                size: 30,
                                color: Colors.greenAccent,
                              ),
                              top: 1,
                              right: 10,
                            )
                          : Container()
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Offre",
                style: TextStyle(color: Colors.white70, fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _offrechoix = "gratuit";
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                          height: 100,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: const [
                                Icon(
                                  Iconsax.money,
                                  size: 35,
                                  color: Colors.white,
                                ),
                                Text(
                                  "Libre",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                )
                              ])),
                      (_offrechoix == "gratuit")
                          ? const Positioned(
                              child: Icon(
                                Icons.check,
                                size: 30,
                                color: Colors.greenAccent,
                              ),
                              top: 1,
                              right: 10,
                            )
                          : Container()
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_status == "prive") {
                        erreur(
                            "Vous ne pouvez pas activer l'abonnement pour un status privé");
                      } else {
                        _offrechoix = "payant";
                      }
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                          height: 100,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: const [
                                Icon(
                                  IconlyLight.wallet,
                                  size: 35,
                                  color: Colors.white,
                                ),
                                Text(
                                  "Abonnement",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                )
                              ])),
                      (_offrechoix == 'payant')
                          ? const Positioned(
                              child: Icon(
                                Icons.check,
                                size: 30,
                                color: Colors.greenAccent,
                              ),
                              top: 1,
                              right: 10,
                            )
                          : Container()
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            (_offrechoix == 'payant')
                ? TextFormField(
                    style: const TextStyle(color: Colors.white),
                    // controller: _prixController,
                    decoration: InputDecoration(
                      label: const Text("Prix d'abonnement"),
                      labelStyle: const TextStyle(color: Colors.white),
                      fillColor: Colors.white.withOpacity(0.2),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        prix = int.parse(value);
                      });
                    },
                  )
                : Container(),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  addnoeud();
                },
                style: ElevatedButton.styleFrom(
                    primary: Colors.orange.shade900,
                    fixedSize: Size(size.width, 70),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                child: const Text(
                  "Créer mon noeud",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

// snakbar erreur
  erreur(message) {
    Get.snackbar(
        "Échec", // title
        message, // message
        icon: const Icon(
          Iconsax.danger,
          color: Colors.white,
        ),
        shouldIconPulse: true,
        colorText: Colors.white,
        barBlur: 20,
        isDismissible: true,
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red);
  }

  message(message) {
    return Get.snackbar(
        "Succès", // title
        message, // message
        shouldIconPulse: true,
        // onTap: (){},
        barBlur: 20,
        isDismissible: true,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.greenAccent);
  }
// creation d'un noeud

  addnoeud() {
    if (logo == null) {
      erreur("Nous vous prions d'ajouter un logo");
    } else if (_nomController.text.isEmpty) {
      erreur("Nous vous prions de saisir un nom pour votre noeud");
    } else if (_descriptionController.text.isEmpty) {
      erreur("Nous vous prions de décrire votre noeud");
    } else if (_status == null) {
      erreur(
          "Nous vous prions de sélectionner le statut adéquat à votre nœud.");
    } else if (_offrechoix == null) {
      erreur(
          "Nous vous prions de sélectionner l'offre adéquate pour votre nœud.");
    } else {
      if (_offrechoix == "payant" && prix == 0) {
        erreur("Nous vous prions de saisir le prix pour l'abonnement.");
      } else {
        progress = 0;
        _timer?.cancel();
        _timer =
            Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
          EasyLoading.showProgress(progress,
              maskType: EasyLoadingMaskType.black,
              status:
                  "${(progress * 100).toStringAsFixed(0)}% \n Création de votre nœud \n Patientez s'il vous plaît.");
          progress += 0.01;

          if (progress >= 1) {
            _timer?.cancel();
            logo = null;
            _nomController.clear();
            _descriptionController.clear();
            _status = null;
            _offrechoix = null;
            _prixController.clear();
            message("Votre nœud a été créé avec succès.");
            EasyLoading.dismiss();
          }
        });
        DateTime now = DateTime.now();
        String dateformat = DateFormat("yyyy-MM-dd - kk:mm").format(now);
        noeud.add({
          "nom": _nomController.text,
          "description": _descriptionController.text,
          'type': "noeud",
          "offre": _offrechoix,
          "prix": prix,
          "statut": _status,
          "nbreuser": 1,
          "nbrebranche": 3,
          "idcreat": user!.uid,
          "logo": logo,
          "datecreat": dateformat,
          "range": DateTime.now().millisecondsSinceEpoch,
          "idcompte": "",
          "wallet": 0,
          "mode": true,
          "recomande": false,
          "notification": 0,
          "contenu": "",
          "type_paiement": 0,
          "masque": false
        }).then((value) {
          FirebaseFirestore.instance
              .collection("noeud")
              .doc(value.id)
              .update({"idcompte": value.id});
          // creation de 3 branches servant d'exemple
          for (var i = 0; i < 3; i++) {
            if (i == 0) {
              requ.creatbranche(
                  "video inoubliable",
                  "Nous vous prions de rejoindre cette branche pour connaître les règles et conditions du nœud.",
                  "public",
                  value.id,
                  illustration,
                  nomuser,
                  "gratuit",
                  0,
                  token,
                  "video",
                  "https://firebasestorage.googleapis.com/v0/b/flutterprojet-e8896.appspot.com/o/video.jpeg?alt=media&token=b643e192-0fb7-46e9-ae38-663c169ebe5c",
                  false);
            }
            if (i == 1) {
              requ.creatbranche(
                  "Partage du quotidien",
                  "Nous vous prions de poser vos préoccupations dans cette branche, vous pouvez également trouver d'autres questions et réponses.",
                  "public",
                  value.id,
                  illustration,
                  nomuser,
                  "gratuit",
                  0,
                  token,
                  "social",
                  "https://firebasestorage.googleapis.com/v0/b/flutterprojet-e8896.appspot.com/o/istockphoto-1223365194-612x612.jpeg?alt=media&token=d7c74326-f414-41d5-91ac-5bff3c2bc99f",
                  false);
            }
            if (i == 2) {
              requ.creatbranche(
                  "Discussion",
                  "Nous vous prions de vous présenter dans cette branche.",
                  "public",
                  value.id,
                  illustration,
                  nomuser,
                  "gratuit",
                  0,
                  token,
                  "inbox",
                  "https://firebasestorage.googleapis.com/v0/b/flutterprojet-e8896.appspot.com/o/inbox.jpeg?alt=media&token=14207d1a-c273-4527-aed1-b7a76ed6595f",
                  false);
            }
          }
          // ajout en tant que administrateur au noeud
          rejoindre(_nomController.text, value.id, logo, "gratuit", "noeud");
          Get.to(() => const Menuhome());
          setState(() {
            _nomController.clear();
            _descriptionController.clear();
            _status = "";
            _offrechoix = "";
            prix = 0;
          });
        });
      }
    }
  }

  // creatbranche(nom, description, statut, idNoeud, avatar) async {
  //   branche.add({
  //     "nom": nom,
  //     "description": description,
  //     "statut": statut,
  //     "id_noeud": idNoeud,
  //     "nbreuser": 1,
  //     "idcreat": user!.uid,
  //     "datecreat": DateTime.now(),
  //     "range": DateTime.now().millisecondsSinceEpoch,
  //     "isnv": false,
  //     "isreponse": false,
  //     "ismention": false,
  //     "ismessage": false,
  //     "ismusic": false,
  //     "isfile": false,
  //     "isvideo": false,
  //     "isimage": false,
  //     "invitation": 0,
  //     "iscall": false,
  //     "idbranche": ""
  //   }).then((value) {
  //     FirebaseFirestore.instance
  //         .collection("branche")
  //         .doc(value.id)
  //         .update({"idbranche": value.id});
  //     userbranche.add({
  //       "iduser": user!.uid,
  //       "idbranche": value.id,
  //       "date": DateTime.now(),
  //       "statut": 1,
  //       "avatar": avatar,
  //       "nbremsg": 0
  //     });
  //   }).catchError((error) {});
  // }

  rejoindre(nom, idcompte, logo, offre, type) {
    abonnement
        .add({
          "iduser": user!.uid,
          "idcompte": idcompte,
          "nom": nom,
          "logo": logo,
          "date": DateTime.now(),
          "range": DateTime.now().millisecondsSinceEpoch,
          "offre": offre,
          "statut": 1,
          "type": type,
          "nomuser": nomuser,
          "idcreat": user!.uid,
          "message": 0
        })
        .then((value) {})
        .catchError((onError) {});
  }

  // uplaod de fichier
  selectimage() async {
    setState(() {
      progress = 0;
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
          });
        });
        task.whenComplete(() => upload(fileName));
      } on FirebaseException catch (e) {}
    }
  }

  Future<void> upload(fileName) async {
    String downloadURL = await FirebaseStorage.instance
        .ref()
        .child('business/$fileName')
        .getDownloadURL();
    setState(() {
      logo = downloadURL;
    });
  }
}
