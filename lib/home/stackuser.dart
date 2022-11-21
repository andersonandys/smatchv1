import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Stackuser extends StatefulWidget {
  Stackuser({Key? key, required this.idbranche}) : super(key: key);
  String idbranche;
  @override
  _StackuserState createState() => _StackuserState();
}

class _StackuserState extends State<Stackuser> {
  List usersavatar = [];
  final settings = RestrictedAmountPositions(
    maxAmountItems: 7,
    maxCoverage: 0.3,
    minCoverage: 0.1,
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection('userbranche')
        .where("idbranche", isEqualTo: widget.idbranche)
        .get()
        .then((value) {
      setState(() {
        usersavatar = value.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (usersavatar.isNotEmpty)
          AvatarStack(
            settings: settings,
            height: 50,
            avatars: [
              for (var user in usersavatar)
                CachedNetworkImageProvider(user["avatar"])
            ],
          )
      ],
    );
  }
}
