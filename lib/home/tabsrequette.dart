import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smatch/home/home.dart';

class Tabsrequette extends GetxController {
  CollectionReference branche =
      FirebaseFirestore.instance.collection("branche");
  CollectionReference abonnement =
      FirebaseFirestore.instance.collection("abonne");
  CollectionReference compteUser =
      FirebaseFirestore.instance.collection("users");
  CollectionReference compte = FirebaseFirestore.instance.collection("noeud");
  CollectionReference achat = FirebaseFirestore.instance.collection("payment");
  CollectionReference userbranche =
      FirebaseFirestore.instance.collection("userbranche");
  User? user = FirebaseAuth.instance.currentUser;
  var displaynoeud = false.obs;
  final execute = 1;
  var valide = false.obs;
  var affiche = "".obs;
  Future creatbranche(nom, description, statut, idNoeud, avatar, nomuser, offre,
      prix, token, typebranche, affiche, publi) async {
    DateTime now = DateTime.now();
    String dateformat = DateFormat("yyyy-MM-dd - kk:mm").format(now);
    branche.add({
      "nom": nom,
      "affiche": affiche,
      "description": description,
      "statut": statut,
      "id_noeud": idNoeud,
      "nbreuser": 1,
      "idcreat": user!.uid,
      "public": publi,
      "typebranche": typebranche,
      "datecreat": dateformat,
      "range": DateTime.now().millisecondsSinceEpoch,
      "isnv": false,
      "isreponse": false,
      "ismention": false,
      "ismessage": false,
      "ismusic": false,
      "isfile": false,
      "isvideo": false,
      "isimage": false,
      "invitation": 0,
      "avatar": avatar,
      "idbranche": "",
      "iscall": false,
      "offre": offre,
      "prix": prix
    }).then((value) async {
      branche.doc(value.id).update({"idbranche": value.id});
      userbranche.add({
        "iduser": user!.uid,
        "idbranche": value.id,
        "date": dateformat,
        "statut": 1,
        "avatar": avatar,
        "nbremsg": 0,
        "nomuser": nomuser,
        "message": 0
      });
      FirebaseFirestore.instance
          .collection('fcm')
          .add({"fcm": token, "idbranche": value.id});
    }).catchError((error) {
      message("Echec",
          "Quelque chose, c'est mal passe, nous vous prions de ressayer");
    });
  }

  message(type, message) {
    if (type == "Echec") {
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

  // rejoindre un noeud ou une app
  // function for abonnement noeud and module(app)
  rejoindre(nom, idcompte, logo, offre, type, idcreate) {
    DateTime now = DateTime.now();
    String dateformat = DateFormat("yyyy-MM-dd - kk:mm").format(now);
    abonnement.add({
      "iduser": user!.uid,
      "idcompte": idcompte,
      "nom": nom,
      "logo": logo,
      "date": dateformat,
      "offre": offre,
      "statut": 0,
      "type": type,
      "idcreat": idcreate,
      "message": 0,
      "range": DateTime.now().millisecondsSinceEpoch
    }).then((value) {
      message("success", "Vous avez rejoint le nœud avec succès.");
    }).catchError((onError) {
      message("Echec",
          "Quelque chose, c'est mal passe, nous vous prions de ressayer.");
    });
    FirebaseFirestore.instance
        .collection("noeud")
        .doc(idcompte)
        .update({"nbreuser": FieldValue.increment(1)});
  }

// recuperation des comptes
  Future getUsersList() async {
    List itemsList = [];

    try {
      await abonnement
          .where("iduser", isEqualTo: user!.uid)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          itemsList.add(element.data());
        });
      });
      return itemsList;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

// recuperation de tout les utilisateur
  Future getallUsersList() async {
    List useralllist = [];

    try {
      await compteUser.get().then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          useralllist.add(element.data());
        });
      });
      return useralllist;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // recuperation des noeud
  Future getallnoeud() async {
    List allnoeud = [];

    try {
      await compte.get().then((querySnapshot) {
        for (var element in querySnapshot.docs) {
          allnoeud.add(element.data());
        }
      });
      return allnoeud;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future infoUser() async {
    List usercompteList = [];
    try {
      await compteUser.doc(user!.uid).get().then((querySnapshot) {
        usercompteList.add(querySnapshot.data());
      });
      return usercompteList;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future userbranches() async {
    List userbrancheList = [];
    try {
      await userbranche.get().then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          userbrancheList.add(element.data());
        });
      });
      return userbrancheList;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // desabonner un utilisateur d"un noeud ou d'un module(app)
  desinstall(data, idcompte) {
    for (var item in data) {
      if (item["idcompte"] == idcompte) {
        print("cest exa");
      }
    }
  }

  // payer un abonnement
  byAbonnement(prix, wallet, idcompte, nom, logo, offre, type, idcreate) async {
    print(prix);
    print(idcompte);
    print(wallet);
    DateTime now = DateTime.now();
    String dateformat = DateFormat("yyyy-MM-dd - kk:mm").format(now);

    int newprix = prix;
    num calcule = (wallet - newprix);
    if (newprix > wallet) {
      message("Echec",
          "Votre solde est insuffisant, nous vous prions de recharger votre wallet");
    } else {
      compte.doc(idcompte).update({
        'wallet': FieldValue.increment(newprix),
        "nbreuser": FieldValue.increment(1)
      }).catchError((onError) {
        message("Echec",
            "Quelque chose, c'est mal passé, nous vous prions de ressayer");
      });
      compteUser
          .doc(user!.uid)
          .update({'wallet': calcule}).catchError((onError) {
        message("Echec",
            "Quelque chose, c'est mal passé, nous vous prions de ressayer");
      });
      var jour = DateFormat("dd").format(now);
      var djour = int.parse(jour) - 1;
      var mois = DateFormat("MM").format(now);
      abonnement.add({
        "iduser": user!.uid,
        "idcompte": idcompte,
        "nom": nom,
        "logo": logo,
        "date": dateformat,
        "offre": offre,
        "statut": 0,
        "type": type,
        "expirejour": djour,
        "expiremois": mois,
        "range": DateTime.now().millisecondsSinceEpoch,
        "idcreat": idcreate,
        "message": 0
      }).then((value) {
        print(value.id);
        FirebaseFirestore.instance.collection("payment").add({
          "date": dateformat,
          "iduser": user!.uid,
          "idcompte": idcompte,
          "nom": nom,
          "montant": prix,
          "type": "achat",
          "statut": "Effectue",
          "token": "",
          "lienpayement": "",
          "range": DateTime.now().millisecondsSinceEpoch
        });
        message("success", "Vous avez rejoint le nœud avec succès.");
      }).catchError((onError) {
        message("Echec",
            "Quelque chose, c'est mal passé, nous vous prions de ressayer");
      });
    }
  }

  byBranche(
      prix, wallet, idcompte, idbranche, offre, avatar, nomuser, nombranche) {
    DateTime now = DateTime.now();
    String dateformat = DateFormat("yyyy-MM-dd - kk:mm").format(now);
    try {
      int newprix = int.parse(prix);
      num calcule = (wallet - newprix);
      if (newprix > wallet) {
        message("Echec",
            "Votre solde est insuffisant, nous vous prions de recharger votre wallet");
      } else {
        compte.doc(idcompte).update({
          'wallet': FieldValue.increment(newprix),
        });
        compteUser
            .doc(user!.uid)
            .update({'wallet': FieldValue.increment(-calcule)});
        branche.doc(idbranche).update({
          'nbreuser': FieldValue.increment(1),
        });
        var jour = DateFormat("dd").format(now);
        var djour = int.parse(jour) - 1;
        var mois = DateFormat("MM").format(now);
        userbranche.add({
          "offre": offre,
          "iduser": user!.uid,
          "idbranche": idbranche,
          "date": dateformat,
          "statut": 0,
          "avatar": avatar,
          "nbremsg": 0,
          "nomuser": nomuser,
          "expirejour": djour,
          "expiremois": mois,
          "range": DateTime.now().millisecondsSinceEpoch
        });
        valide.value = true;
        FirebaseFirestore.instance.collection("payment").add({
          "date": dateformat,
          "iduser": user!.uid,
          "idcompte": idcompte,
          "nom": nombranche,
          "montant": prix,
          "type": "achat",
          "statut": "Effectue",
          "token": "",
          "lienpayement": "",
          "range": DateTime.now().millisecondsSinceEpoch
        });
      }
    } catch (e) {
      message("Echec",
          "Quelque chose, c'est mal passé, nous vous prions de ressayer");
    }
  }
}
