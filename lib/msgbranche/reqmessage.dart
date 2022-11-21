import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Reqmessage extends GetxController {
  var message = "".obs;
  var isreponse = false.obs;
  var reponse = "".obs;
  var isinfo = false.obs;
  var imagefile = "".obs;
  var typeselecte = "".obs;
  var files = "".obs;
  var isfile = false.obs;
  var filepath = "".obs;
  var namefile = "".obs;
  var messageController = "".obs;
  var isload = false.obs;
  String token =
      "eyJhbGciOiJSUzI1NiIsImtpZCI6ImJlYmYxMDBlYWRkYTMzMmVjOGZlYTU3ZjliNWJjM2E2YWIyOWY1NTUiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vZmx1dHRlcnByb2pldC1lODg5NiIsImF1ZCI6ImZsdXR0ZXJwcm9qZXQtZTg4OTYiLCJhdXRoX3RpbWUiOjE2NTE0MTI3NDIsInVzZXJfaWQiOiJONU1meGRBbUpkUmx6NG1tRWVFdmF6Z2p2OHAyIiwic3ViIjoiTjVNZnhkQW1KZFJsejRtbUVlRXZhemdqdjhwMiIsImlhdCI6MTY1MTgxNTg0NiwiZXhwIjoxNjUxODE5NDQ2LCJwaG9uZV9udW1iZXIiOiIrMjI1MDc2OTMwMTkzNCIsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsicGhvbmUiOlsiKzIyNTA3NjkzMDE5MzQiXX0sInNpZ25faW5fcHJvdmlkZXIiOiJwaG9uZSJ9fQ.fjWaVmp0-elgtCv78wmBK45wl8YI39imh5m-ESQWpzTl-HU4ur0rKqVFih7ohyf-k67VaLb1aqXOjkn1sJZ9S3QqkKtJBXAOHAGOZYQOIr5wXJ6DbJUcg_E3YghQSPUHJIbuz7cMuVyPCxpCCVeTmNM2zYOw3ULYfhjzccMtcLOSU8NoPChkfdcHJpIRMr2E79zQ-gOpwjmRjcunpeSO515A4xmWFmg3fYujKlIcdmGlID8AUvGFy17eF3eU2yxc5f7mWVrL_rODjWn_ZqtmTydEk2W0WT0AOhmXSt4oOlntFD15R13zPKYf6JM0Sjo9vs6F5njH2AZv8VcAI5C3fg";
  commente() {}
  response(data, reponses) {
    isreponse.value = data;
    reponse.value = reponses;
  }

  information(data) {
    isinfo.value = data;
  }

  creatcompte() async {}

  selectfile(typefile) async {
    if (typefile == "image") {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file != null) {
        typeselecte.value = typefile;
        filepath.value = file.path.toString();
        print(filepath.value);
        print(file.name);
        files.value = base64Encode(File(file.path).readAsBytesSync());
        isfile.value = true;

        try {
          var data = files.value;
          var ref = FirebaseStorage.instance.ref().child("test/" + file.name);
          ref.putString(data);
          print(file.name);

          // var lien = await ref.getDownloadURL();
        } on FirebaseException catch (e) {}
      }
    } else if (typefile == "file") {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['docx', 'pdf', 'doc'],
          allowMultiple: false);
      if (result != null) {
        typeselecte.value = typefile;
        File file = File(result.files.single.path!);
        files.value = base64Encode(file.readAsBytesSync());
        namefile.value = result.files.first.name;
        isfile.value = true;
      }
    } else if (typefile == "music") {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.audio, allowMultiple: false);
      if (result != null) {
        typeselecte.value = typefile;
        File file = File(result.files.single.path!);
        files.value = base64Encode(file.readAsBytesSync());
        namefile.value = result.files.first.name;
        isfile.value = true;

        try {
          var data = files.value;
          print(data);
          var ref = FirebaseStorage.instance
              .ref()
              .child("test/" + result.files.single.name);
          ref.putString(data);
          print(result.files.single.name);

          // var lien = await ref.getDownloadURL();
        } on FirebaseException catch (e) {}
      }
    }
  }

  closefile() {
    isfile.value = false;
    filepath.value = "";
    files.value = "";
    typeselecte.value = "";
    namefile.value = "";
  }

  resetsendmessage() {
    isreponse.value = false;
    reponse.value = "";
    isfile.value = false;
    messageController.value = "";
  }

  messagechange(data) {
    messageController.value = data;
  }

  load(data) {
    isload.value = data;
  }

  test() {
    String lien = "";
    String fileName = "image_picker629290079851228038.jpg";

    UploadTask task = FirebaseStorage.instance
        .ref()
        .child("test1/$fileName")
        .putFile(File(
            "/data/user/0/com.example.newapp/cache/image_picker629290079851228038.jpg"));

    task.snapshotEvents.listen((event) {
      print(((event.bytesTransferred.toDouble() / event.totalBytes.toDouble()) *
              100)
          .roundToDouble());
    });
    task.whenComplete(() async {
      lien = await FirebaseStorage.instance
          .ref()
          .child('test1/$fileName')
          .getDownloadURL();
      print(lien);
    });
    return lien;
  }
}
