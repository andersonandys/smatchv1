import 'dart:convert';
import 'dart:io';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smatch/home/settingsvideo.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Socialpub extends StatefulWidget {
  const Socialpub({Key? key}) : super(key: key);

  @override
  _SocialpubState createState() => _SocialpubState();
}

class _SocialpubState extends State<Socialpub> {
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
                icon: Icon(Icons.settings, color: Colors.white, size: 30))
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
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
                DetectableTextField(
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
                  ),
                if (typecontenu == "image")
                  SizedBox(
                    height: 150,
                    // color: Colors.white,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: imageselect.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext, index) {
                          return Stack(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    )),
                                height: 200,
                                width: 200,
                                margin: const EdgeInsets.only(left: 10),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  child: Image.file(
                                    File(imageselect[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                  right: 2,
                                  top: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.5),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(1),
                                    child: IconButton(
                                        onPressed: () {
                                          deleteimage(imageselect[index]);
                                        },
                                        icon: const Icon(
                                          Iconsax.close_circle,
                                          size: 30,
                                        )),
                                  ))
                            ],
                          );
                        }),
                  ),
              ],
            ),
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
                      selectimage();
                    },
                    child: const Icon(
                      Iconsax.camera,
                      size: 30,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
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
                    if (contenucontroller.text.isNotEmpty) {
                      if (typecontenu == "image") {
                        sendpublicatio();
                      }
                      if (typecontenu == "video" && progress == 0.0) {
                        sendpublicatio();
                        print("object");
                      } else {
                        print("non");
                      }
                    }
                  },
                  child: (typecontenu == "image")
                      ? const Icon(Iconsax.send_1)
                      : (typecontenu == "video" && progress > 0.0)
                          ? CircularProgressIndicator(
                              color: Colors.white,
                              value: progress / 100,
                            )
                          : const Icon(Iconsax.send_1))
            ],
          ),
        ));
  }

  deleteimage(index) {
    imageselect.remove(index);
    setState(() {
      imageselect = imageselect;
    });
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

  selectimage() async {
    setState(() {
      typecontenu = "image";
      videoname = "";
      videopath = "";
      imageselect = [];
    });
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      for (var element in images) {
        setState(() {
          imageselect.add(element.path);
        });
      }
    } else {}
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
    if (contenucontroller.text.isNotEmpty ||
        imageselect.isNotEmpty ||
        videoname.isNotEmpty) {
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
        "typebranche": "social",
        "idbranche": idbranche,
        "id": "",
        'video': ""
      }).then((value) {
        instance
            .collection("publication")
            .doc(value.id)
            .update({"id": value.id});
        if (typecontenu == "image") {
          int nbre = 0;
          for (String element in imageselect) {
            UploadTask task = FirebaseStorage.instance
                .ref()
                .child("business/$element")
                .putFile(File(element));

            task.snapshotEvents.listen((event) {
              setState(() {
                progress = ((event.bytesTransferred.toDouble() /
                            event.totalBytes.toDouble()) *
                        100)
                    .roundToDouble();
                print(progress / 100);
              });
            });
            task.whenComplete(() => upload("image", value.id, element));
            print(nbre++);
          }
        }
        if (typecontenu == "video") {
          UploadTask task = FirebaseStorage.instance
              .ref()
              .child("business/$videoname")
              .putFile(File(videopath));

          task.snapshotEvents.listen((event) {
            setState(() {
              progress = ((event.bytesTransferred.toDouble() /
                          event.totalBytes.toDouble()) *
                      100)
                  .roundToDouble();
              print(progress / 100);
            });
          });
          task.whenComplete(() => upload("video", value.id, videoname));
        }
        setState(() {
          contenucontroller.text = "";
          imageselect = [];
        });
      });
    }
  }

  Future<void> upload(type, valueid, name) async {
    String downloadURL = await FirebaseStorage.instance
        .ref()
        .child('business/$name')
        .getDownloadURL();
    if (type == "image") {
      instance
          .collection("publication")
          .doc(valueid)
          .collection(type)
          .add({type: downloadURL});
    } else {
      instance
          .collection("publication")
          .doc(valueid)
          .update({'video': downloadURL});
    }
    setState(() {
      videoname = "";
      videopath = "";
      progress = 0.0;
    });
    print("cest ok");
    print(valueid);
  }
}

class Readvideo extends StatefulWidget {
  const Readvideo({Key? key}) : super(key: key);

  @override
  _ReadvideoState createState() => _ReadvideoState();
}

class _ReadvideoState extends State<Readvideo> {
  String path = Get.arguments[0]["path"];
  late final FlickManager flickManager;
  @override
  void initState() {
    super.initState();

    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.file(File(path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(30),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(30),
      ),
      body: VisibilityDetector(
        key: ObjectKey(flickManager),
        onVisibilityChanged: (visibility) {
          if (visibility.visibleFraction == 0 && mounted) {
            flickManager.flickControlManager?.autoPause();
          } else if (visibility.visibleFraction == 1) {
            flickManager.flickControlManager?.autoResume();
          }
        },
        child: Container(
          height: 100,
          child: FlickVideoPlayer(
            flickManager: flickManager,
            flickVideoWithControls: const FlickVideoWithControls(
              closedCaptionTextStyle: TextStyle(fontSize: 8),
              controls: FlickPortraitControls(),
            ),
            flickVideoWithControlsFullscreen: const FlickVideoWithControls(
              controls: FlickLandscapeControls(),
            ),
          ),
        ),
      ),
    );
  }
}
