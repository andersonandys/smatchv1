import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Noeud extends StatefulWidget {
  Noeud({Key? key, required this.idnoeud}) : super(key: key);
  String idnoeud;
  @override
  _NoeudState createState() => _NoeudState();
}

class _NoeudState extends State<Noeud> {
  late Stream<QuerySnapshot> streamnoeud = FirebaseFirestore.instance
      .collection('noeud')
      .where("idcompte", isEqualTo: "")
      .snapshots();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    streamnoeud = FirebaseFirestore.instance
        .collection('noeud')
        .where("idcompte", isEqualTo: widget.idnoeud)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamnoeud,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          // TODO: do something with the error
          return Text(snapshot.error.toString());
        }
        // TODO: the data is not ready, show a loading indicator
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                // accontrol.displaynoeud.value =
                //     false;
              },
              child: FadeIn(
                  child: CircleAvatar(
                radius: 35,
                backgroundImage: CachedNetworkImageProvider(
                    snapshot.data!.docs.first["logo"]),
              )),
            )
          ],
        );
      },
    );
  }
}
