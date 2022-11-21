import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/state_manager.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isolate_flutter/isolate_flutter.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;

class Requmessage extends GetxController {
  var tape = false.obs;
  var typemessage = "sms".obs;
  var pathfile = "".obs;
  var namefile = "".obs;
  var vignette = "".obs;
  var recnv = false.obs;
  final _audioRecorder = Record();
  var messagereponse = "".obs;
  var nomreponse = "".obs;
  var typereponse = "".obs;
  var urlreponse = "".obs;
  var options = false.obs;
  var smsawait = "".obs;
  var mention = false.obs;
  var display = false.obs;
  var idnoeud = "".obs;
  var idmessagedelete = "".obs;
  write(String data) {
    if (data.isEmpty) {
      tape.value = false;
    } else {
      tape.value = true;
    }
  }

  selectfile(typefile) async {
    if (typefile == "image") {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file != null) {
        pathfile.value = file.path;
        namefile.value = file.name;
        typemessage.value = "image";
        tape.value = true;
        display.value = true;
      }
    } else if (typefile == "doc") {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['docx', 'pdf', 'doc'],
          allowMultiple: false);
      if (result != null) {
        pathfile.value = result.files.single.path!;
        namefile.value = result.files.single.name;
        typemessage.value = "doc";
        tape.value = true;
        display.value = true;
      }
    } else if (typefile == "music") {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['mp3'],
          allowMultiple: false);
      if (result != null) {
        pathfile.value = result.files.single.path!;
        namefile.value = result.files.single.name;
        typemessage.value = "music";
        tape.value = true;
        display.value = true;
      }
    }
  }

  Future<void> recordnv() async {
    try {
      typemessage.value = "nv";
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();

        bool isRecording = await _audioRecorder.isRecording();
        recnv.value = isRecording;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> stop() async {
    final path = await _audioRecorder.stop();
    pathfile.value = path!;
    recnv.value = false;
    print(path);
  }

  selectvideo(path, name, vignettes) {
    pathfile.value = path;
    namefile.value = name;
    typemessage.value = "video";
    tape.value = true;
    vignette.value = vignettes;
    display.value = true;
  }

  closefile() {
    tape.value = false;
    namefile.value = "";
    pathfile.value = "";
    typemessage.value = "sms";
  }

  restfast() {
    display.value = false;
  }

  resettemessage() {
    namefile.value = "";
    pathfile.value = "";
    typemessage.value = "sms";
    typereponse.value = "";
    tape.value = false;
    vignette.value = "";
    messagereponse.value = "";
    urlreponse.value = "";
    nomreponse.value = "";
    options.value = false;
    display.value = false;
  }

  //  Gestion d'envoi en arriere plan de la messagerie
  void launchupload(idmessage) async {
    var nom = namefile.value + idmessage;
    var datafile = [
      {"nom": nom},
      {"path": pathfile.value}
    ];

    final value = await IsolateFlutter.createAndStart(_sendfunction, datafile);
    upddateelemnt(value!);
  }

  displayreponses(nomreponses, typereponses, messagereponses, urlreponses) {
    nomreponse.value = nomreponses;
    typereponse.value = typereponses;
    messagereponse.value = messagereponses;
    urlreponse.value = urlreponses;
  }

  displayoption(
      nomreponses, typereponses, messagereponses, urlreponses, idmessage) {
    messagereponse.value = messagereponses;
    typereponse.value = typereponses;
    urlreponse.value = urlreponses;
    smsawait.value = nomreponses;
    options.value = true;
    idmessagedelete.value = idmessage;
  }

  reply() {
    nomreponse.value = smsawait.value;
  }

  closereponse() {
    nomreponse.value = "";
    typereponse.value = "";
    messagereponse.value = "";
    urlreponse.value = "";
    idmessagedelete.value = "";
    typemessage.value = "sms";
    options.value = false;
  }

  static Future<String> _sendfunction(dynamic message) async {
    final cloudinary = Cloudinary.full(
      apiKey: "489522481445921",
      apiSecret: "H9DpbxyRYerllQ4XGnWf6_SOczI",
      cloudName: "smatch",
    );
    var nomfile = message[0]['nom'];
    var pathfile = message[1]['path'];

    final response = await cloudinary.uploadResource(CloudinaryUploadResource(
        filePath: pathfile,
        resourceType: CloudinaryResourceType.auto,
        folder: "newsmatch",
        fileName: nomfile,
        progressCallback: (count, total) {
          print('Uploading image from file with progress: $count/$total');
        }));

    if (response.isSuccessful) {}
    return response.secureUrl!;
  }

  upddateelemnt(String data) {
    FirebaseFirestore.instance
        .collection('message')
        .get()
        .then((QuerySnapshot value) {
      for (var element in value.docs) {
        if (data.contains(element.id)) {
          print(element.id);
          FirebaseFirestore.instance
              .collection('message')
              .doc(element.id)
              .update({"urlfile": data, "finish": true});
        }
      }
    });
    if (typemessage.value == "video") {
      resettemessage();
    }
  }

  //  envois de la vignette

  void launchuploadvignette(idmessage) async {
    var nom = "${namefile.value} $idmessage";
    var datafile = [
      {"nom": nom},
      {"path": vignette.value}
    ];
    final _value =
        await IsolateFlutter.createAndStart(functionvignette, datafile);
    updloadvignette(_value!);
  }

  static Future<String> functionvignette(dynamic message) async {
    final cloudinary = Cloudinary.full(
      apiKey: "489522481445921",
      apiSecret: "H9DpbxyRYerllQ4XGnWf6_SOczI",
      cloudName: "smatch",
    );
    var nomfile = message[0]['nom'];
    var pathfile = message[1]['path'];

    final response = await cloudinary.uploadResource(CloudinaryUploadResource(
        filePath: pathfile,
        resourceType: CloudinaryResourceType.auto,
        folder: "newsmatch",
        fileName: nomfile,
        progressCallback: (count, total) {
          print('Uploading image from file with progress: $count/$total');
        }));

    if (response.isSuccessful) {}

    return response.secureUrl!;
  }

  updloadvignette(String data) {
    FirebaseFirestore.instance
        .collection('message')
        .get()
        .then((QuerySnapshot value) {
      for (var element in value.docs) {
        if (data.contains(element.id)) {
          print(element.id);
          FirebaseFirestore.instance
              .collection('message')
              .doc(element.id)
              .update({"vignette": data, "finish": true});
        }
      }
    });
  }

  // systeme de notification
  void launchnotification(
      messagenotif, listfcm, nomnoeud, nombranche, idbranche, idneoud) async {
// message, idbranche, liste fcm,idunique(date),nombranche,nom noeud
    var title = "$nomnoeud / $nombranche";
    var newlist = [
      {"message": messagenotif},
      {"listfcm": listfcm},
      {"title": title},
      {
        "date": DateTime.now().millisecondsSinceEpoch.toString().substring(0, 5)
      },
      {"idbranche": idbranche},
      {"idnoeud": idneoud},
    ];
    final value =
        await IsolateFlutter.createAndStart(_sendnotification, newlist);
    updatenoeudandbranche(value!);
  }

  updatenoeudandbranche(sendparam) {
    String idnoeud = sendparam[0]['idnoeud'];
    String idbranche = sendparam[1]['idbranche'];

    FirebaseFirestore.instance
        .collection("abonne")
        .where('idcompte', isEqualTo: idnoeud)
        .get()
        .then((value) {
      for (var element in value.docs) {
        print(element.id);
        if (element['iduser'] != FirebaseAuth.instance.currentUser!.uid) {
          FirebaseFirestore.instance
              .collection('abonne')
              .doc(element.id)
              .update({"message": 1});
        } else {
          print("ok");
        }
      }
    });

    FirebaseFirestore.instance
        .collection("userbranche")
        .where('idbranche', isEqualTo: idbranche)
        .get()
        .then((value) {
      for (var element in value.docs) {
        print(element.id);
        if (element['iduser'] != FirebaseAuth.instance.currentUser!.uid) {
          FirebaseFirestore.instance
              .collection('userbranche')
              .doc(element.id)
              .update({"nbremsg": FieldValue.increment(1)});
        } else {
          print('ok');
        }
      }
    });
  }

  static Future<dynamic> _sendnotification(newlist) async {
    print(newlist[0]['message']);
    print(newlist[2]['title']);
    print(newlist[4]['idbranche']);
    print(newlist[5]['idnoeud']);
    List notifuserlist = newlist[1]['listfcm'];
    List sendparam = [
      {'idnoeud': newlist[5]['idnoeud']},
      {"idbranche": newlist[4]['idbranche']}
    ];
    try {
      for (var element in notifuserlist) {
        await http
            .post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAAbGRj14A:APA91bFdRN50Bk0f7-s6120NTNylZtjTR9NueHu1lE9NDCm7XrMFkmQVYESVq1j6IfEeb6vB0Yt_Mycbdv5Ha8MwJOmJ-rYPYDUBex7hm4fHBzOdF2z6GdB5sp03ntjlrBcRvyVRBbz6',
          },
          body: jsonEncode(
            {
              "to": element['fcm'],
              "message": {
                "notification": <String, String>{},
              },
              "priority": "high",
              "data": <String, dynamic>{
                "content": {
                  "id": newlist[3]['date'],
                  "channelKey": "basic_channel",
                  "title": newlist[2]['title'],
                  "body": newlist[0]['message'],
                },
                "actionButtons": [
                  {
                    "key": "REPLY",
                    "label": "Consulter",
                    "isDangerousOption": "true"
                  },
                ],
              },
            },
          ),
        )
            .then((value) {
          print("envoye avec sucess");
        });
      }
    } catch (e) {}
    return sendparam;
  }

  deletemessage() {
    FirebaseFirestore.instance
        .collection("message")
        .doc(idmessagedelete.value)
        .delete();
    idmessagedelete.value = "";
    closereponse();
  }
}

// systeme de notification
// revoir le systemed'envois des medias
