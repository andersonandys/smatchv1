import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smatch/message/isole/upload_isolate.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class Messagecontroller extends GetxController {
  var write = false.obs;
  var messagediting = TextEditingController().obs;
  var typereponse = "".obs;
  var messagereponse = "".obs;
  var typemessage = "".obs;
  var nomreponse = "".obs;
  var namefile = "".obs;
  var urlreponse = "".obs;
  var listdef = [].obs;
  var nbre = 0.obs;
  var extension = "".obs;
  String userid = FirebaseAuth.instance.currentUser!.uid;
  var filelist = [].obs;
  var pathfile = "".obs;
  sendmessage(idbranche) {
    DateTime now = DateTime.now();
    String dateformat = DateFormat("kk:mm").format(now);
    listdef.value = filelist;
    if (messagediting.value.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('message').add({
        "message": messagediting.value.text,
        "idbranche": idbranche,
        "idsend": userid,
        "urlfile": "",
        "typemessage": typemessage.value,
        "vignette": "",
        "range": DateTime.now().millisecondsSinceEpoch,
        "date": dateformat,
        "messagereponse": messagereponse.value,
        "nomreponse": nomreponse.value,
        "namefile": namefile.value,
        "idnoeud": "",
        "typereponse": typereponse.value,
        "urlreponse": urlreponse.value,
        "idmessage": "",
        "finish": false
      }).then((value) {
        print(value.id);
        FirebaseFirestore.instance
            .collection('message')
            .doc(value.id)
            .update({"idmessage": value.id});

        if (listdef.isNotEmpty) {
          for (var element in listdef) {
            if (listdef.length != nbre.value) {
              nbre.value++;
              FirebaseFirestore.instance
                  .collection("message")
                  .doc(value.id)
                  .collection("media")
                  .add({
                "urlfile": "",
                "extension": "",
                "percente": 0,
                "finish": false
              }).then((valuemedia) {
                uploadImageToFirebase(element, value.id, valuemedia.id);
              });
            } else {
              listdef.clear();
              nbre.value = 0;
              print("meme chose");
            }
          }
        } else {
          print('vide oww');
        }
        filelist.clear();
      });
      messagediting.value.clear();
      nomreponse.value = "";
      messagereponse.value = "";
      typereponse.value = "";
      urlreponse.value = "";
      namefile.value = "";
      typemessage.value = "";
    }
  }

  selectmedia(context) async {
    filelist.clear();
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(
          // textDelegate: assetPickerTextDelegates.,
          sortPathDelegate: SortPathDelegate.common),
    );
    if (result != null) {
      for (var element in result) {
        print(result);
        final file = await element.file;
        pathfile.value = file!.path;
        extension.value = getExtension(file.path);
        filelist.add([
          {"pathfile": pathfile.value},
          {"extension": extension.value}
        ]);
        filelist.add(file.path);
      }
    }
    print(filelist);
  }
}
