import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class Accontols extends GetxController {
  var displaynoeud = false.obs;
  final Rx<Stream<QuerySnapshot<Map<String, dynamic>>>> abonnenoeuds =
      FirebaseFirestore.instance
          .collection('abonne')
          .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots()
          .obs;
}
