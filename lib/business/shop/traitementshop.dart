import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class Traitment1shop extends GetxController {
  var streamtest =
      FirebaseFirestore.instance.collection('produitshop').snapshots().obs;
  var emplacement =
      FirebaseFirestore.instance.collection('emplacement').snapshots().obs;
  var categories = "".obs;
  addpanier(
    nom,
    prix,
    idshop,
    idproduit,
    image1,
    idsuer,
  ) {
    DateTime now = DateTime.now();
    String dateformat = DateFormat("yyyy-MM-dd - kk:mm").format(now);
    try {
      FirebaseFirestore.instance.collection("panierproduit").add({
        "nom": nom,
        "prix": prix,
        "idshop": idshop,
        "idproduit": idproduit,
        "image1": image1,
        "statut": 0,
        "date": dateformat,
        "range": DateTime.now().millisecondsSinceEpoch,
        "iduser": idsuer,
        "nbre": 1
      });
      message("Succes", "Produit ajouté au panier avec succès");
    } catch (e) {
      message("echec",
          "Oups quelque chose, c'est mal passé, nous vous prions de ressayer");
    }
  }

  addcommande(idshop, commune, number) {
    try {
      if (commune == null) {
        message(
            "echec", "Nous vous prions de choisir votre commune de livraison ");
      } else {
        DateTime now = DateTime.now();
        String dateformat = DateFormat("yyyy-MM-dd - kk:mm").format(now);
        FirebaseFirestore.instance
            .collection('panierproduit')
            .where("idshop", isEqualTo: idshop)
            .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((QuerySnapshot querySnapshot) {
          if (querySnapshot.docs.isEmpty) {
            message("Echec", "Vous n'avez pas de produit dans votre panier");
          } else {
            for (var doc in querySnapshot.docs) {
              FirebaseFirestore.instance.collection("commandeproduit").add({
                "iduser": doc["iduser"],
                "idproduit": doc.id,
                "idshop": idshop,
                "nom": doc["nom"],
                "prix": doc["prix"],
                "statut": 0,
                "nbre": doc["nbre"],
                "date": dateformat,
                "range": DateTime.now().millisecondsSinceEpoch,
                "image1": doc['image1'],
                "commune": commune,
                "number": number
              });
              FirebaseFirestore.instance
                  .collection("panierproduit")
                  .doc(doc.id)
                  .delete();
            }
            FirebaseFirestore.instance.collection("noeud").doc(idshop).update({
              "nbrcommande": FieldValue.increment(querySnapshot.docs.length),
              "newcommande": FieldValue.increment(1),
            });
            print(idshop);
            message("Succes",
                "Votre commande a été prise en compte et sera traitée dans les brefs délais.");
          }
        });
      }
    } catch (e) {
      message("echec",
          "Oups quelque chose, c'est mal passé, nous vous prions de ressayer");
    }
  }

  addfavoris(idproduit, idshop, nom, prix, image1) {
    try {
      FirebaseFirestore.instance.collection("favorisproduit").add({
        "idproduit": idproduit,
        "idshop": idshop,
        "iduser": FirebaseAuth.instance.currentUser!.uid,
        "nom": nom,
        "prix": prix,
        "image1": image1,
        "nbre": 1,
        "range": DateTime.now().millisecondsSinceEpoch
      });
      message("Succes", "Produit ajouté au favoris");
    } catch (e) {
      message("echec",
          "Oups quelque chose, c'est mal passé, nous vous prions de ressayer");
    }
  }

  deletefavoris(idproduit) {
    try {
      FirebaseFirestore.instance
          .collection("favorisproduit")
          .doc(idproduit)
          .delete();
      message("Succes", "Produit retiré des favoris");
    } catch (e) {
      message("echec",
          "Oups quelque chose, c'est mal passé, nous vous prions de ressayer");
    }
  }

  message(type, message) {
    if (type == "echec") {
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
    } else {
      Get.snackbar(
          "Succès", // title
          message, // message
          shouldIconPulse: true,
          colorText: Colors.white,
          barBlur: 20,
          isDismissible: true,
          duration: Duration(seconds: 5),
          backgroundColor: Colors.greenAccent);
    }
  }

  streamproduit2(idshop, categorie) {
    categories.value = categorie;
    if (categorie == "tout") {
      streamtest.value = FirebaseFirestore.instance
          .collection('produitshop')
          .where("idshop", isEqualTo: idshop)
          .orderBy("range", descending: true)
          .snapshots();
    } else {
      streamtest.value = FirebaseFirestore.instance
          .collection('produitshop')
          .where("idshop", isEqualTo: idshop)
          .where("categorie", isEqualTo: categorie)
          .orderBy("range", descending: true)
          .snapshots();
    }
  }

  emplacementproduit(idshop) {
    emplacement.value = FirebaseFirestore.instance
        .collection('emplacement')
        .where("idcompte", isEqualTo: Get.arguments[0]["idshop"])
        .orderBy("range", descending: true)
        .snapshots();
  }
}
