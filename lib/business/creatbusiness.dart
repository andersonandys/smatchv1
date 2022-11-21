import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smatch/business/dash/dashshop/tabsmenu.dart';
import 'package:smatch/home/home.dart';
import 'package:smatch/home/tabsrequette.dart';
import 'package:smatch/menu/menuwidget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Creatbusi extends StatefulWidget {
  @override
  _CreatbusiState createState() => _CreatbusiState();
}

class _CreatbusiState extends State<Creatbusi> {
  final _advancedDrawerController = AdvancedDrawerController();
  Timer? _timer;
  late double _progress;
  final nomshop = TextEditingController();
  final descriptionshop = TextEditingController();
  final commune = TextEditingController();
  String logo = "";
  double progress = 0.0;
  final requ = Get.put(Tabsrequette());
  File? imagefile;
  CollectionReference compte = FirebaseFirestore.instance.collection("noeud");
  String design = "0";

  final nommoment = TextEditingController();
  final descriptionmoment = TextEditingController();
  final pays = TextEditingController();
  String? offre;
  final prix = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  String nomuser = "";
  String avataruser = "";
  int newprix = 0;
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
    getinfouser();
  }

  getinfouser() {
    print(FirebaseAuth.instance.currentUser!.uid);
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        nomuser = querySnapshot.docs.first['nom'];
        avataruser = querySnapshot.docs.first['avatar'];
      });
      print('object');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(25),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(25),
        title: Text(
          'Business',
          style: GoogleFonts.poppins(fontSize: 30),
        ),
        leading: Menuwidget(),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
          child: Column(children: [
            Text(
              "Parce que proposer des contenus de bonne qualité et facile d'accessibilités par vos abonnés ainsi que monétiser votre business est une priorité pour vous, nous vous donnons les outils adéquats pour y parvenir. ",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(
              height: 15,
            ),
            // container pour le shop
            Container(
                // margin: const EdgeInsets.only(left: 10, right: 10),
                // padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5),
                    ),
                    color: Colors.white.withOpacity(0.2)),
                child: Column(
                  children: [
                    Container(
                        height: 200,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                            color: Colors.orange),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(5),
                              topLeft: Radius.circular(5)),
                          child: Image.asset("assets/shop1.jpg",
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "E-Commerce business",
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Que vous soyez un débutant dans le e-commerce ou un pro, nous vous proposons un compte boutique doté de toutes les fonctionnalités permettant de booster votre activité, ayé en main toutes les fonctionnalités.",
                                textAlign: TextAlign.justify,
                                style: GoogleFonts.poppins(
                                    fontSize: 15, color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  creatshop();
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.orange.shade900,
                                    fixedSize: const Size(300, 60),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                child: Text(
                                  "Créer un compte",
                                  style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            )
                          ],
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                )),
            // container pour le vlog
            const SizedBox(
              height: 20,
            ),
            Container(
                // margin: const EdgeInsets.only(left: 10, right: 10),
                // padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5),
                    ),
                    color: Colors.white.withOpacity(0.2)),
                child: Column(
                  children: [
                    Container(
                        height: 200,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                            color: Colors.white),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(5),
                              topLeft: Radius.circular(5)),
                          child: Image.asset(
                            "assets/vlog.webp",
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                          ),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Créateur de contenu.",
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Créateur de websérie, influenceur, coach, posséder une plateforme dédie à votre activité, soyez le maître d'orchestre, ayé en main toutes les fonctionnalités pour satisfaire vos fans ainsi que monétiser votre activité.",
                                textAlign: TextAlign.justify,
                                style: GoogleFonts.poppins(
                                    fontSize: 15, color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  creatmoment();
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade900,
                                    fixedSize: const Size(300, 60),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                child: Text(
                                  "Créer un compte",
                                  style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            )
                          ],
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ))
          ]),
        ),
      ),
    );
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }

  creatshop() {
    showMaterialModalBottomSheet(
        backgroundColor: Colors.black.withBlue(25),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      height: 5,
                      width: 50,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(
                        child: Text("Création de boutique",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white))),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            selectimage();
                          },
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(50)),
                                color: Colors.white.withOpacity(0.2)),
                            child: (logo.isEmpty)
                                ? const Center(
                                    child: Icon(
                                      Iconsax.camera,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(50)),
                                    child: Image.network(
                                      logo,
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            style: const TextStyle(color: Colors.white),
                            cursorHeight: 20,
                            autofocus: false,
                            controller: nomshop,
                            decoration: InputDecoration(
                              fillColor: Colors.white.withOpacity(0.2),
                              filled: true,
                              label: const Text("Nom de votre boutique"),
                              labelStyle: const TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      cursorHeight: 20,
                      autofocus: false,
                      controller: descriptionshop,
                      decoration: InputDecoration(
                        fillColor: Colors.white.withOpacity(0.2),
                        filled: true,
                        label: const Text("Description"),
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Apparence",
                        style: TextStyle(color: Colors.white70, fontSize: 20),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          child: Stack(
                            children: [
                              Container(
                                height: 120,
                                width: 150,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Icon(
                                      Icons.public_rounded,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      "Light",
                                      style: GoogleFonts.poppins(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              (design == "1")
                                  ? const Positioned(
                                      top: 1,
                                      right: 1,
                                      child: Icon(Icons.check,
                                          color: Colors.green, size: 30),
                                    )
                                  : Container()
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              design = "1";
                            });
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          child: Stack(
                            children: [
                              Container(
                                height: 120,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Icon(
                                      Iconsax.security_user,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      "Ligth +",
                                      style: GoogleFonts.poppins(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              (design == "2")
                                  ? const Positioned(
                                      top: 1,
                                      right: 1,
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 30,
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              design = "2";
                              print(design);
                            });
                          },
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(children: [
                      const Icon(
                        Icons.check_box,
                        color: Colors.green,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: Container(
                        height: 50,
                        child: const Text(
                          "Vous acceptez les termes et les conditions liés à la création d'un compte business.",
                          style: TextStyle(color: Colors.white),
                        ),
                      ))
                    ]),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (logo.isEmpty) {
                            requ.message(
                                "Echec", "Nous vous prions de choisir un logo");
                          } else if (nomshop.text.isEmpty) {
                            requ.message(
                                "Echec", "Nous vous prions de saisir un nom");
                          } else if (descriptionshop.text.isEmpty) {
                            requ.message("Echec",
                                "Nous vous prions de saisir une description");
                          } else {
                            _progress = 0;
                            _timer?.cancel();
                            _timer = Timer.periodic(
                                const Duration(milliseconds: 100),
                                (Timer timer) {
                              EasyLoading.showProgress(_progress,
                                  maskType: EasyLoadingMaskType.black,
                                  status:
                                      "${(_progress * 100).toStringAsFixed(0)}% \n Création de votre boutique \n patientez s'il vous plaît");
                              _progress += 0.01;

                              if (_progress >= 1) {
                                _timer?.cancel();
                                EasyLoading.dismiss();
                                requ.message("Succes",
                                    "Votre boutique a été créée avec succès.");
                              }
                            });
                            DateTime now = DateTime.now();
                            String dateformat =
                                DateFormat("yyyy-MM-dd - kk:mm").format(now);
                            FirebaseFirestore.instance.collection("noeud").add({
                              "nom": nomshop.text,
                              "description": descriptionshop.text,
                              "idcreat": user!.uid,
                              "logo": logo,
                              "date": dateformat,
                              "range": DateTime.now().millisecondsSinceEpoch,
                              "wallet": 0,
                              "nbrproduit": 0,
                              "nbrcommande": 0,
                              "nbretraite": 0,
                              "newcommande": 0,
                              "nbreannule": 0,
                              "type": "boutique",
                              "design": design,
                              "offre": "gratuit",
                              "mode": false,
                              "ready": 0,
                              "statut": "public",
                              "prix": 0,
                              "idcompte": "",
                              "nbreuser": 1
                            }).then((value) {
                              FirebaseFirestore.instance
                                  .collection("noeud")
                                  .doc(value.id)
                                  .update({"idcompte": value.id});
                              FirebaseFirestore.instance
                                  .collection("abonne")
                                  .add({
                                "iduser": user!.uid,
                                "idcreat": user!.uid,
                                "idcompte": value.id,
                                "nom": nomshop.text,
                                "logo": logo,
                                "date": dateformat,
                                "range": DateTime.now().millisecondsSinceEpoch,
                                "offre": "gratuit",
                                "statut": 1,
                                "type": "boutique",
                                "design": design,
                                "nomuser": user!.displayName
                              });
                              Navigator.of(context).pop;
                              Get.toNamed("/tabsmenushop", arguments: [
                                {"idshop": value.id},
                                {"nomshop": nomshop.text},
                                {"design": design}
                              ]);

                              print(value.id);
                              nomshop.clear();
                              descriptionshop.clear();
                              design = "0";
                              logo = "";
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade900,
                            fixedSize:
                                Size(MediaQuery.of(context).size.width, 70),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        child: Text(
                          "Créer mon compte",
                          style: GoogleFonts.poppins(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  creatmoment() {
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
                child: Container(
                  margin:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          height: 5,
                          width: 50,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text("Création de Space",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              selectimage();
                            },
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50)),
                                  color: Colors.white.withOpacity(0.2)),
                              child: (logo.isEmpty)
                                  ? const Center(
                                      child: Icon(
                                        Iconsax.camera,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(50)),
                                      child: Image.network(
                                        logo,
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: TextFormField(
                              style: const TextStyle(color: Colors.white),
                              cursorHeight: 20,
                              autofocus: false,
                              controller: nommoment,
                              decoration: InputDecoration(
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                label: const Text("Nom de votre Space"),
                                fillColor: Colors.white.withOpacity(0.2),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        maxLines: 2,
                        cursorHeight: 20,
                        autofocus: false,
                        controller: descriptionmoment,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          label: const Text("Description"),
                          fillColor: Colors.white.withOpacity(0.2),
                          filled: true,
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text("Offre",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            child: Stack(
                              children: [
                                Container(
                                  height: 120,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Icon(
                                        Iconsax.money,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "Libre",
                                        style: GoogleFonts.poppins(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                (offre == "gratuit")
                                    ? const Positioned(
                                        top: 1,
                                        right: 1,
                                        child: Icon(Icons.check,
                                            color: Colors.green, size: 30),
                                      )
                                    : Container()
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                offre = "gratuit";
                                print(offre);
                              });
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            child: Stack(
                              children: [
                                Container(
                                  height: 120,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Icon(
                                        IconlyLight.wallet,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "Abonnement",
                                        style: GoogleFonts.poppins(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                (offre == "payant")
                                    ? const Positioned(
                                        top: 1,
                                        right: 1,
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.green,
                                          size: 30,
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                offre = "payant";
                              });
                            },
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      (offre == "payant")
                          ? Padding(
                              padding: EdgeInsets.only(
                                  top: 20,
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: TextFormField(
                                style: const TextStyle(color: Colors.white),
                                cursorHeight: 20,
                                autofocus: false,
                                controller: prix,
                                decoration: InputDecoration(
                                  label: const Text("Prix",
                                      style: TextStyle(color: Colors.white)),
                                  fillColor: Colors.white.withOpacity(0.2),
                                  filled: true,
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 2),
                                  ),
                                ),
                                onChanged: (value) {
                                  newprix = int.parse(value);
                                  print(newprix);
                                },
                              ),
                            )
                          : Container(),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(children: const [
                        Icon(
                          Icons.check_box,
                          color: Colors.green,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: SizedBox(
                          height: 50,
                          child: Text(
                            "Vous acceptez les termes et les conditions liés à la création d'un compte business.",
                            style: TextStyle(color: Colors.white),
                          ),
                        ))
                      ]),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (logo.isEmpty) {
                              requ.message("Echec",
                                  "Nous vous prions de choisir un logo");
                            } else if (nommoment.text.isEmpty) {
                              requ.message(
                                  "Echec", "Nous vous prions de saisir un nom");
                            } else if (descriptionmoment.text.isEmpty) {
                              requ.message("Echec",
                                  "Nous vous prions de saisir une description");
                            } else if (offre!.isEmpty) {
                              requ.message("Echec",
                                  "Nous vous prions de sélectionner une offre.");
                            } else {
                              if (offre == "payant") {
                                if (prix.text.isEmpty) {
                                  requ.message("Echec",
                                      "Nous vous prions de saisir un prix");
                                } else {
                                  addchaine();
                                }
                              } else {
                                addchaine();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Colors.orange.shade900,
                              fixedSize:
                                  Size(MediaQuery.of(context).size.width, 70),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          child: Text(
                            "Créer un compte",
                            style: GoogleFonts.poppins(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
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

            print(progress);
          });
        });
        task.whenComplete(() => upload(fileName));
      } on FirebaseException catch (e) {
        print("Quelque chose, c'est mal passé, nous vous prions de réessayer.");
      }
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
    print(logo);
  }

  addchaine() {
    _progress = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      EasyLoading.showProgress(_progress,
          maskType: EasyLoadingMaskType.black,
          status:
              "${(_progress * 100).toStringAsFixed(0)}% \n Création de votre Space \n Patientez s'il vous plaît");
      _progress += 0.01;

      if (_progress >= 1) {
        _timer?.cancel();
        EasyLoading.dismiss();
        Navigator.of(context).pop;
        requ.message("Succes", "Votre chaîne a été créée avec succès.");
      }
    });
    DateTime now = DateTime.now();
    String dateformat = DateFormat("yyyy-MM-dd - kk:mm").format(now);
    FirebaseFirestore.instance.collection("noeud").add({
      "nom": nommoment.text,
      "description": descriptionmoment.text,
      "idcreat": user!.uid,
      "logo": logo,
      "date": dateformat,
      "range": DateTime.now().millisecondsSinceEpoch,
      "wallet": 0,
      "nbrevideo": 0,
      "nbreuser": 1,
      "type": "Moment",
      "offre": offre,
      "mode": true,
      "ready": 0,
      "statut": "public",
      "idcompte": "",
      "prix": newprix,
      "type_paiement": "",
      "titre": "",
      "descriptionvideo": "",
      "vignette": "",
      "lienvideo": "",
      "playliste": "",
      "idcategorie": "",
      "idvideo": ""
    }).then((value) {
      FirebaseFirestore.instance
          .collection("noeud")
          .doc(value.id)
          .update({"idcompte": value.id});
      FirebaseFirestore.instance.collection("abonne").add({
        "iduser": user!.uid,
        "idcreat": user!.uid,
        "idcompte": value.id,
        "nom": nommoment.text,
        "logo": logo,
        "date": dateformat,
        "range": DateTime.now().millisecondsSinceEpoch,
        "offre": offre,
        "statut": 1,
        "type": "Moment",
        "isuser": 1,
        "nomuser": user!.displayName
      });
      Get.toNamed("/tabsvlog", arguments: [
        {"idchaine": value.id},
        {"nomchaine": nommoment.text},
      ]);
      nommoment.clear();
      descriptionmoment.clear();
      prix.clear();
      logo = "";
      pays.clear();
      offre = null;
    });
  }
}
