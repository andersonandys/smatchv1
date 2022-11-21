import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smatch/home/tabsrequette.dart';

class Notificationhome extends StatefulWidget {
  const Notificationhome({Key? key}) : super(key: key);

  @override
  State<Notificationhome> createState() => _NotificationhomeState();
}

class _NotificationhomeState extends State<Notificationhome> {
  final Stream<QuerySnapshot> _allnotification = FirebaseFirestore.instance
      .collection("notification")
      .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .orderBy("date", descending: true)
      .snapshots();
  final Stream<QuerySnapshot> _allinivation = FirebaseFirestore.instance
      .collection("invitation")
      .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
  final requ = Get.put(Tabsrequette());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(20),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(20),
        title: const Text("Notification"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: StreamBuilder(
              stream: _allnotification,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> _allnotif) {
                if (!_allnotif.hasData) {
                  return const Center(
                    heightFactor: 20,
                    child: CircularProgressIndicator(),
                  );
                }
                if (_allnotif.connectionState == ConnectionState.waiting) {
                  return const Center(
                    heightFactor: 20,
                    child: CircularProgressIndicator(),
                  );
                }
                return (_allnotif.data!.docs.isEmpty)
                    ? const Center(
                        heightFactor: 10,
                        child: Text(
                          "Vous n'avez pas de notification",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _allnotif.data!.docs.length,
                        itemBuilder: (context, index) {
                          return Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  if (_allnotif.data!.docs[index]['type'] ==
                                      "noeud")
                                    Column(
                                      children: <Widget>[
                                        Text(
                                          'Adhésion au nœud ' +
                                              _allnotif.data!.docs[index]
                                                  ["nom"],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17),
                                          maxLines: 1,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "${"Le nœud" + _allnotif.data!.docs[index]["nom"]} a accepté votre adhésion \n Vous pouvez participer désormais à la vie du nœud. \n En intégrant le nœud vous acceptez de respecter les termes et conditions qui régissent le nœud, sous peine de bannissement.",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              "${_allnotif.data!.docs[index]["date"].toString().substring(0, 10)} ",
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  if (_allnotif.data!.docs[index]['type'] ==
                                      "branche")
                                    Column(
                                      children: <Widget>[
                                        Text(
                                          'Adhésion à la branche ' +
                                              _allnotif.data!.docs[index]
                                                  ["nom"],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17),
                                          maxLines: 1,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "${"La branche" + _allnotif.data!.docs[index]["nom"]} a accepté votre adhésion \n Vous pouvez participer désormais à la vie de la branche. \n En intégrant le nœud vous acceptez de respecter les termes et conditions qui régissent le nœud, sous peine de bannissement.",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              "${_allnotif.data!.docs[index]["date"].toString().substring(0, 10)} ",
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            )
                                          ],
                                        )
                                      ],
                                    )
                                ],
                              ));
                        });
              }),
        ),
      ),
    );
  }
}
