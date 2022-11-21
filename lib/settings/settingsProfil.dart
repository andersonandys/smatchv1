import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as users;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smatch/home/tabsrequette.dart';
import 'package:smatch/login/login.dart';
import 'package:smatch/menu/menuwidget.dart';

class SettingsProfil extends StatefulWidget {
  const SettingsProfil({Key? key}) : super(key: key);

  @override
  _SettingsProfilState createState() => _SettingsProfilState();
}

class _SettingsProfilState extends State<SettingsProfil> {
  final _advancedDrawerController = AdvancedDrawerController();
  String iduser = users.FirebaseAuth.instance.currentUser!.uid;
  final Stream<QuerySnapshot> _streaminfo = FirebaseFirestore.instance
      .collection("users")
      .where("iduser", isEqualTo: users.FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
  final requette = Get.put(Tabsrequette());
  final _numcontroller = TextEditingController();
  final _nomcontroller = TextEditingController();
  File? imagefile;
  bool loading = false;
  String avataruser =
      "https://lh3.googleusercontent.com/a/AATXAJyx6FvJwAxFFzfliIk_WJERJnZ6PeI4dwWoN2T58Q=s96-c";
  String nomuser = "";
  String userdid = users.FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getinfouser();
  }

  getinfouser() {
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser",
            isEqualTo: users.FirebaseAuth.instance.currentUser!.uid)
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
          'Profil',
          style: GoogleFonts.poppins(fontSize: 30),
        ),
        leading: Menuwidget(),
        elevation: 0,
      ),
      body: StreamBuilder(
          stream: _streaminfo,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> streaminfo) {
            if (!streaminfo.hasData) {
              return Container(
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (streaminfo.connectionState == ConnectionState.waiting) {
              return Container(
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: streaminfo.data!.docs.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              selectimage();
                            },
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: CachedNetworkImageProvider(
                                      streaminfo.data!.docs[index]['avatar']),
                                ),
                                if (loading)
                                  const Positioned(
                                    child: CircularProgressIndicator(
                                      color: Colors.red,
                                      strokeWidth: 3.0,
                                    ),
                                    top: 10,
                                    left: 12,
                                  ),
                              ],
                            ),
                          ),
                          title: Text(
                            streaminfo.data!.docs[index]['nom'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: IconButton(
                              onPressed: () {
                                updatenom(streaminfo.data!.docs[index]['nom']);
                              },
                              icon: const Icon(
                                Iconsax.edit,
                                color: Colors.white,
                              )),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: ListTile(
                          leading: const Text(
                            "Code Utilisateur",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          trailing: Text(
                            streaminfo.data!.docs[index]['iduser']
                                .toString()
                                .substring(0, 6),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        margin: const EdgeInsets.all(5),
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                updatenumber(
                                    streaminfo.data!.docs[index]['number']);
                              },
                              child: ListTile(
                                leading: const Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  (streaminfo.data!.docs[index]['number'] ==
                                          null)
                                      ? "Aucun numéro"
                                      : "${streaminfo.data!.docs[index]['number']} ",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                trailing: const Icon(
                                  Iconsax.edit,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            ListTile(
                                leading: const Icon(
                                  Iconsax.notification,
                                  color: Colors.white,
                                ),
                                subtitle: const Text(
                                  'En activant Notification vous acceptez de recevoir les notifications venant des Spaces et des comptes nœuds',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                title: const Text(
                                  "Notification",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                trailing: Switch(
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.white,
                                    value: streaminfo.data!.docs[index]
                                        ['isnotif'],
                                    onChanged: (value) {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(iduser)
                                          .update({"isnotif": value});
                                    })),
                            ListTile(
                                leading: const Icon(
                                  Iconsax.add,
                                  color: Colors.white,
                                ),
                                subtitle: const Text(
                                    'En activant Ajout Space vous acceptez que les autres membres puissent vous ajouter à des Spaces ',
                                    style: TextStyle(color: Colors.white70)),
                                title: const Text(
                                  "Ajout space",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                trailing: Switch(
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.white,
                                    value: streaminfo.data!.docs[index]
                                        ['ispace'],
                                    onChanged: (value) {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(iduser)
                                          .update({"ispace": value});
                                    })),
                            ListTile(
                                leading: const Icon(
                                  Iconsax.message,
                                  color: Colors.white,
                                ),
                                subtitle: const Text(
                                    'En activant la sauvegarde vous acceptez de SMATCH puisse sauvegarder vos discussions après déconnexion ou suppression de votre compte',
                                    style: TextStyle(color: Colors.white70)),
                                title: const Text(
                                  "Sauvegarde des discussions",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                trailing: Switch(
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.white,
                                    value: streaminfo.data!.docs[index]
                                        ['issave'],
                                    onChanged: (value) {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(iduser)
                                          .update({"issave": value});
                                    })),
                            ListTile(
                                leading: const Icon(
                                  Iconsax.search_normal_1,
                                  color: Colors.white,
                                ),
                                subtitle: const Text(
                                    'En activant Recherche, vous acceptez de figurer dans les barres de recherche aléatoire.',
                                    style: TextStyle(color: Colors.white70)),
                                title: const Text(
                                  "Recherche",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                trailing: Switch(
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.white,
                                    value: streaminfo.data!.docs[index]
                                        ['issearche'],
                                    onChanged: (value) {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(iduser)
                                          .update({"issearche": value});
                                    })),
                            ListTile(
                                leading: const Icon(
                                  Iconsax.data,
                                  color: Colors.white,
                                ),
                                subtitle: const Text(
                                    "En activant données vous acceptez de partager vos informations avec les Spaces et compte business dont vous êtes membres",
                                    style: TextStyle(color: Colors.white70)),
                                title: const Text(
                                  "DonnéeS", //octroyer mes information au space dont je suis abonne
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                trailing: Switch(
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.white,
                                    value: streaminfo.data!.docs[index]
                                        ['isdata'],
                                    onChanged: (value) {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(iduser)
                                          .update({"isdata": value});
                                    }))
                          ],
                        ),
                      ),
                      // const SizedBox(
                      //   height: 20,
                      // ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: ListTile(
                          onTap: () async {
                            signout();
                          },
                          leading: const Icon(
                            Icons.power_settings_new,
                            color: Colors.white,
                            size: 30,
                          ),
                          title: Text(
                            'Déconnexion',
                            style: GoogleFonts.poppins(
                                fontSize: 20, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  );
                });
          }),
    );
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }

  updatenumber(numero) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modification'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  "Apporter une modification à votre numéro",
                  style: TextStyle(),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _numcontroller,
                  decoration: InputDecoration(
                    labelText: numero,
                    hintText: numero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
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
              child: const Text('Confirmer'),
              onPressed: () {
                if (_numcontroller.text != "") {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(iduser)
                      .update({"number": _numcontroller.text});
                  requette.message("Succes", "Numéro modifié avec succès");
                  Navigator.of(context).pop();
                  _numcontroller.clear();
                } else {
                  requette.message("Echec",
                      "Nous vous prions de saisir un numéro de téléphone");
                }
              },
            ),
          ],
        );
      },
    );
  }

  updatenom(nom) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modification'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  "Apporter une modification à votre nom utilisateur",
                  style: TextStyle(),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nomcontroller,
                  decoration: InputDecoration(
                    labelText: nom,
                    hintText: nom,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
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
              child: const Text('Confirmer'),
              onPressed: () {
                if (_nomcontroller.text != "") {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(iduser)
                      .update({"nom": _nomcontroller.text});
                  requette.message(
                      "Succes", "Nom utilisateur modifié avec succès");
                  Navigator.of(context).pop();
                  _nomcontroller.clear();
                } else {
                  requette.message(
                      "Echec", "Nous vous prions de saisir un nom utilisateur");
                }
              },
            ),
          ],
        );
      },
    );
  }

  selectimage() async {
    final fila = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (fila != null) {
      try {
        String fileName = fila.name;
        imagefile = File(fila.path);

        UploadTask task = FirebaseStorage.instance
            .ref()
            .child("business/$fileName")
            .putFile(File(fila.path));
        setState(() {
          loading = true;
        });
        task.whenComplete(() => upload(fileName));
      } on FirebaseException catch (e) {
        requette.message('Echec',
            "Quelque chose, c'est mal passe, nous vous prions de ressayer plus tard");
      }
    }
  }

  Future<void> upload(fileName) async {
    String downloadURL = await FirebaseStorage.instance
        .ref()
        .child('business/$fileName')
        .getDownloadURL();
    FirebaseFirestore.instance
        .collection("users")
        .doc(iduser)
        .update({"avatar": downloadURL}).then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  signout() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  "Êtes-vous sûr de vouloir vous déconnecter à votre compte ?",
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
              child: const Text('Déconnection'),
              onPressed: () async {
                Navigator.of(context).pop();
                await users.FirebaseAuth.instance.signOut();

                Get.to(() => Login());
              },
            ),
          ],
        );
      },
    );
  }
}
