import 'dart:convert';
import 'dart:io';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smatch/home/settingsvideo.dart';

class Videofeedpub extends StatefulWidget {
  const Videofeedpub({Key? key}) : super(key: key);

  @override
  _VideofeedpubState createState() => _VideofeedpubState();
}

class _VideofeedpubState extends State<Videofeedpub> {
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;

  List imageselect = [];
  String comptepub = "branche";
  String nomcomptepub = Get.arguments[0]["nombranche"];
  String avatar = "";
  String nomuser = "";
  String avataruser = "";
  String nombranche = Get.arguments[0]["nombranche"];
  String affiche = Get.arguments[1]["affiche"];
  String avatarcompte = Get.arguments[1]["affiche"];
  String idbranche = Get.arguments[2]["idbranche"];
  String idcompte = Get.arguments[2]["idbranche"];
  String typepub = "compte";
  double progress = 0.0;
  String vignette = "";
  final instance = FirebaseFirestore.instance;
  String videopath = "";
  String videoname = "";
  String typecontenu = "";
  final contenucontroller = TextEditingController();
  String userid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getinfouser();
  }

  getinfouser() {
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        nomuser = value.docs.first['nom'];
        avataruser = value.docs.first['avatar'];
      });
    });
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withBlue(20),
        appBar: AppBar(
          backgroundColor: Colors.black.withBlue(30),
          elevation: 0,
          centerTitle: true,
          title: const Text("Publication"),
          actions: [
            IconButton(
                onPressed: () {
                  Get.to(() => const Settingsvideo());
                  Get.toNamed("settingsvideo", arguments: [
                    {"idbranche": idbranche}
                  ]);
                },
                icon: Icon(Icons.settings, size: 30))
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: CachedNetworkImageProvider(avatarcompte),
                ),
                title: Text(
                  nomcomptepub,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: IconButton(
                    onPressed: () {
                      option();
                    },
                    icon: const Icon(
                      Iconsax.more,
                      size: 30,
                      color: Colors.white,
                    )),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: DetectableTextField(
                  controller: contenucontroller,
                  basicStyle: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                    hintText: "Votre message",
                  ),
                  maxLines: 50,
                  detectionRegExp: detectionRegExp()!,
                  onDetectionTyped: (text) {
                    print(text);
                  },
                  onDetectionFinished: () {
                    print('finished');
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              if (videopath.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.only(bottom: 50),
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: CustomVideoPlayer(
                        customVideoPlayerController:
                            _customVideoPlayerController),
                  ),
                )
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  FloatingActionButton(
                    elevation: 0,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    onPressed: () {
                      selectvideo();
                    },
                    child: const Icon(
                      Iconsax.video,
                      size: 30,
                    ),
                  )
                ],
              ),
              FloatingActionButton(
                  onPressed: () {
                    print("object vu");
                    sendpublicatio();
                    // if (typecontenu == "video" && progress == 0.0) {
                    // } else {
                    //   print("non");
                    // }
                  },
                  child: (typecontenu == "video" && progress > 0.0)
                      ? CircularProgressIndicator(
                          color: Colors.white,
                          value: progress / 100,
                        )
                      : const Icon(Iconsax.send_1))
            ],
          ),
        ));
  }

  option() {
    return Get.bottomSheet(Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          )),
      height: 150,
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(50),
                )),
            width: 50,
            height: 5,
          ),
          const SizedBox(
            height: 10,
          ),
          ListTile(
            onTap: () {
              setState(() {
                nomcomptepub = nomuser;
                avatarcompte = avataruser;
                idcompte = userid;
                typepub = "user";
              });
              Navigator.of(context).pop();
            },
            leading: const Icon(
              Iconsax.user,
              color: Colors.white,
            ),
            title: const Text(
              'Mon compte',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          ListTile(
            onTap: () {
              setState(() {
                nomcomptepub = nombranche;
                avatarcompte = affiche;
                idcompte = idbranche;
                typepub = "compte";
              });
              Navigator.of(context).pop();
            },
            leading: const Icon(
              Iconsax.security,
              color: Colors.white,
            ),
            title: const Text(
              'Compte Administrateur',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          )
        ],
      ),
    ));
  }

  selectvideo() async {
    setState(() {
      imageselect = [];
      typecontenu = "video";
    });
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      videoPlayerController = VideoPlayerController.file(File(video.path))
        ..initialize().then((value) => setState(() {}));
      _customVideoPlayerController = CustomVideoPlayerController(
          context: context,
          videoPlayerController: videoPlayerController,
          customVideoPlayerSettings:
              const CustomVideoPlayerSettings(settingsButtonAvailable: false));
      setState(() {
        imageselect = [];
        typecontenu = "video";
        videopath = video.path;
        videoname = video.name;
      });
    }
  }

  sendpublicatio() {
    if (contenucontroller.text.isNotEmpty && videoname.isNotEmpty) {
      instance.collection("publication").add({
        "text": contenucontroller.text,
        "idpub": idcompte,
        "typepub": typepub,
        "nbreimage": imageselect.length,
        "nbrelike": 0,
        "range": DateTime.now().millisecondsSinceEpoch,
        "nbrecomment": 0,
        "typecontenu": typecontenu,
        "date": DateTime.now(),
        "typebranche": "video",
        "idbranche": idbranche,
        "id": "",
        'video': ""
      }).then((value) {
        print("enregistre");
        print(value.id);
        instance
            .collection("publication")
            .doc(value.id)
            .update({"id": value.id});
        if (videoname.isNotEmpty) {
          uploadfile(value.id);
        }
      });
    }
  }

  uploadfile(value) {
    print("En cours d envois de media");
    UploadTask task = FirebaseStorage.instance
        .ref()
        .child("business/$videoname")
        .putFile(File(videopath));

    task.snapshotEvents.listen((event) {
      setState(() {
        progress =
            ((event.bytesTransferred.toDouble() / event.totalBytes.toDouble()) *
                    100)
                .roundToDouble();
        print(progress / 100);
      });
    });
    task.whenComplete(() => upload("video", value, videoname));
    setState(() {
      contenucontroller.text = "";
      imageselect = [];
    });
  }

  Future<void> upload(type, valueid, name) async {
    String downloadURL = await FirebaseStorage.instance
        .ref()
        .child('business/$name')
        .getDownloadURL();

    instance
        .collection("publication")
        .doc(valueid)
        .update({'video': downloadURL});
    setState(() {
      videoname = "";
      videopath = "";
      progress = 0.0;
    });
    print("cest ok");
    print(valueid);
  }
}
