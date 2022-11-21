import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Reqdisc extends GetBuilderState {
  User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference _messageList =
      FirebaseFirestore.instance.collection("messagenoeud");
  int send = 1;
  sendmessage(message, idbranche, response, nom, avatar, nomresponse) {
    try {
      _messageList
          .add({
            "idsend": user!.uid,
            "idbranche": idbranche,
            "message": message,
            "date": DateTime.now(),
            "vu": DateTime.now().millisecondsSinceEpoch,
            "response": response,
            "nomresponse": nomresponse,
            "avatar": avatar,
            "nom": nom
          })
          .then((value) {})
          .catchError((error) {
            message("erreur", "quelque chose cest mal passe");
          });
      return send;
    } catch (e) {
      return message("erreur", "Quelque chose c est mal passe, ressayer svp");
    }
  }

  message(type, message) {
    Get.snackbar(
        type, // title
        message, // message
        icon: const Icon(Iconsax.activity),
        shouldIconPulse: true,
        // onTap: (){},
        barBlur: 20,
        isDismissible: true,
        duration: Duration(seconds: 5),
        backgroundColor: Color(0xff3937bf));
  }
}
