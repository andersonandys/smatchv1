import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smatch/callclub/conference.dart';

class Initsalon extends StatefulWidget {
  Initsalon(
      {Key? key,
      required this.nombranche,
      required this.idbranche,
      required this.avataruser,
      required this.nomuser})
      : super(key: key);
  String nombranche;
  String idbranche;
  String avataruser;
  String nomuser;
  @override
  _InitsalonState createState() => _InitsalonState();
}

class _InitsalonState extends State<Initsalon> {
  late Stream<QuerySnapshot> branchestream = FirebaseFirestore.instance
      .collection('branche')
      .where("idbranche", isEqualTo: widget.idbranche)
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(10),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black.withBlue(10),
      ),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Image.asset("assets/meetinit.png"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Allégez votre travail',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Connectez-vous en toute sécurité et collaborez pour mieux travailler ensemble. Simple à gérer et un plaisir à utiliser, Smatch call dynamise la main-d'œuvre moderne.",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w200),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            StreamBuilder(
              stream: branchestream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Column(
                  children: <Widget>[
                    if (!snapshot.data!.docs.first["iscall"])
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade900,
                              fixedSize:
                                  Size(MediaQuery.of(context).size.width, 70),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VideoConferencePage(
                                        conferenceID: widget.idbranche,
                                        username: widget.nomuser,
                                        avataruser: widget.avataruser,
                                        nombranche: widget.nombranche,
                                      )),
                            );
                          },
                          child: const Text(
                            "Demarrer un salon",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )),
                    const SizedBox(
                      height: 20,
                    ),
                    if (snapshot.data!.docs.first["iscall"])
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.1),
                              fixedSize:
                                  Size(MediaQuery.of(context).size.width, 70),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection("branche")
                                .doc(widget.idbranche)
                                .update({"iscall": true});
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VideoConferencePage(
                                        conferenceID: widget.idbranche,
                                        username: widget.nomuser,
                                        avataruser: widget.avataruser,
                                        nombranche: widget.nombranche,
                                      )),
                            );
                          },
                          child: const Text(
                            "Rejoindre le salon",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )),
                    const SizedBox(
                      height: 20,
                    ),
                    if (snapshot.data!.docs.first["iscall"])
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              fixedSize:
                                  Size(MediaQuery.of(context).size.width, 70),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection("branche")
                                .doc(widget.idbranche)
                                .update({"iscall": false});
                            ;
                          },
                          child: const Text(
                            "Fermer le salon",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ))
                  ],
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      )),
    );
  }
}
