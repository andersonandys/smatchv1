import 'dart:io';
import 'dart:ui';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:audio_wave/audio_wave.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:siri_wave/siri_wave.dart';
import 'package:smatch/call/screens/startup_screen.dart';
import 'package:smatch/callclub/conference.dart';
import 'package:smatch/callclub/screens/common/join_screen.dart';
import 'package:smatch/home/empty.dart';
import 'package:smatch/home/home.dart';
import 'package:smatch/home/tabsrequette.dart';
import 'package:smatch/msgbranche/initsalon.dart';
import 'package:smatch/msgbranche/options.dart';
import 'package:smatch/msgbranche/requmessage.dart';
import 'package:smatch/noeud/creatnoeud.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:translator/translator.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:voice_message_package/voice_message_package.dart';

class Messagebranche extends StatefulWidget {
  const Messagebranche({Key? key}) : super(key: key);

  @override
  _MessagebrancheState createState() => _MessagebrancheState();
}

class _MessagebrancheState extends State<Messagebranche> {
  String idbranche = Get.arguments[0]['idbranche'];
  String nombranche = Get.arguments[1]['nombranche'];
  String idcreat = Get.arguments[2]['idcreat'];
  int admin = Get.arguments[3]['admin'];
  String mytoken = Get.arguments[4]['token'];
  List allusers = [];
  final List<String> items = [
    'Anglais',
    'Français',
    'Espagnole',
    'Russe',
    'Italien',
    'Chinois'
  ];
  bool lange = false;
  String translatemessage = "";
  String transaltetitle = "";
  String? selectedValue;
  final translator = GoogleTranslator();
  List alluserbranches = [];
  final mscontrol = Get.put(Requmessage());
  final msnoeud = Get.put(Tabsrequette());
  final sendrequ = Get.put(Changevalue());
  // String? nom;
  String userid = FirebaseAuth.instance.currentUser!.uid;
  final messagecontroler = TextEditingController();
  List allusersearch = [];
  List abonne = [];
  String nameuser = "";
  String avataruser = "";
  List listfcm = [];
  String newmessage = "";
  int? wallet;
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;
  final Stream<QuerySnapshot> _allnoeud = FirebaseFirestore.instance
      .collection('noeud')
      .where("type", isNotEqualTo: 'noeud')
      .snapshots();
  final Stream<QuerySnapshot> branchestream = FirebaseFirestore.instance
      .collection('branche')
      .where("idbranche", isEqualTo: Get.arguments[0]['idbranche'])
      .snapshots();
  final Stream<QuerySnapshot> messagestream = FirebaseFirestore.instance
      .collection('message')
      .where("idbranche", isEqualTo: Get.arguments[0]['idbranche'])
      .snapshots();

  @override
  void initState() {
    super.initState();
    alluser();
    alluserabranche();
    allabonne();
    myinfo();
    fcmuser();
  }

  alluser() {
    FirebaseFirestore.instance
        .collection("users")
        .get()
        .then((QuerySnapshot value) {
      setState(() {
        setState(() {
          allusers = value.docs;
        });
        ;
      });
    });
  }

  fcmuser() {
    FirebaseFirestore.instance
        .collection("fcm")
        .where('idbranche', isEqualTo: idbranche)
        .where("fcm", isNotEqualTo: mytoken)
        .get()
        .then((QuerySnapshot value) {
      setState(() {
        print(mytoken);
        setState(() {
          listfcm = value.docs;
        });
        ;
      });
    });
  }

  myinfo() {
    FirebaseFirestore.instance
        .collection("users")
        .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot value) {
      for (var data in value.docs) {
        setState(() {
          nameuser = data["nom"];
          avataruser = data["avatar"];
          wallet = data['wallet'];
        });
      }
    });
  }

  alluserabranche() {
    FirebaseFirestore.instance
        .collection("userbranche")
        .where("idbranche", isEqualTo: idbranche)
        .get()
        .then((QuerySnapshot value) {
      setState(() {
        alluserbranches = value.docs;
      });
      print(alluserbranches);
    });
  }

  allabonne() {
    FirebaseFirestore.instance
        .collection("abonne")
        .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot value) {
      setState(() {
        abonne = value.docs;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(20),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(20),
        title: Text(nombranche),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Initsalon(
                            avataruser: avataruser,
                            idbranche: idbranche,
                            nombranche: nombranche,
                            nomuser: nameuser,
                          )),
                );
              },
              icon: const Icon(Icons.call)),
          IconButton(
              onPressed: () {
                Get.toNamed('settingsbranche', arguments: [
                  {
                    "idbranche": idbranche,
                  },
                  {
                    "admin": admin,
                  },
                  {"nom": nombranche},
                  {"idcreat": idcreat}
                ]);
              },
              icon: const Icon(Icons.settings)),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: displaymessage()),
          Obx(() => (mscontrol.typemessage.value == "image" &&
                  mscontrol.display.isTrue)
              ? displayimage()
              : const SizedBox()),
          Obx(() => (mscontrol.typemessage.value == "video" &&
                  mscontrol.display.isTrue)
              ? displayvideo()
              : const SizedBox()),
          Obx(() =>
              (mscontrol.typemessage.value == "doc" && mscontrol.display.isTrue)
                  ? displaydoc()
                  : const SizedBox()),
          Obx(() => (mscontrol.typemessage.value == "music" &&
                  mscontrol.display.isTrue)
              ? displaymusic()
              : const SizedBox()),
          Obx(() => (mscontrol.recnv.isTrue) ? displaynv() : const SizedBox()),
          Obx(() => (mscontrol.nomreponse.isNotEmpty)
              ? displayreponseall()
              : const SizedBox()),
          if (allusersearch.isNotEmpty) mentionuser(),
          StreamBuilder(
            stream: branchestream,
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> permission) {
              if (!permission.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else if (permission.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: permission.data!.docs.length,
                  itemBuilder: (context, index) {
                    return (permission.data!.docs[index]['ismessage'] == true ||
                            idcreat == userid ||
                            admin == 1)
                        ? bottombar(
                            permission.data!.docs[index]['ismessage'],
                            permission.data!.docs[index]['isnv'],
                            permission.data!.docs[index]['isimage'],
                            permission.data!.docs[index]['isvideo'],
                            permission.data!.docs[index]['isfile'],
                            permission.data!.docs[index]['ismusic'],
                            permission.data!.docs[index]['ismention'])
                        : const Center(
                            child: Text(
                              "Vous ne pouvez pas envoyer de message",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                  });
            },
          ),
          proposition()
        ],
      ),
    );
  }

  Widget bottombar(bool ismessage, bool isnv, bool isimage, bool isvideo,
      bool isfile, bool ismusic, bool ismention) {
    return DetectableTextField(
      enableSuggestions: true,
      maxLines: null,
      basicStyle: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
          prefixIcon: (isimage ||
                  isvideo ||
                  isfile ||
                  ismusic ||
                  idcreat == userid ||
                  admin == 1)
              ? IconButton(
                  onPressed: () {
                    choosefile(isimage, isvideo, isfile, ismusic);
                  },
                  icon: const Icon(
                    Iconsax.attach_square,
                    size: 30,
                    color: Colors.white,
                  ))
              : null,
          suffixIcon: (isnv || idcreat == userid || admin == 1)
              ? Obx(() => (mscontrol.tape.isFalse)
                  ? IconButton(
                      onPressed: () {
                        if (mscontrol.recnv.isTrue) {
                          mscontrol.stop();
                          sendmessage();
                        } else {
                          mscontrol.recordnv();
                        }
                      },
                      icon: (mscontrol.recnv.isTrue)
                          ? const Icon(Iconsax.stop,
                              color: Colors.white, size: 30)
                          : const Icon(Iconsax.microphone_2,
                              color: Colors.white, size: 30))
                  : GestureDetector(
                      onTap: () {
                        sendmessage();
                      },
                      onLongPress: () {
                        translatemessagesend();
                      },
                      child: const Icon(Iconsax.send1,
                          color: Colors.white, size: 30)))
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: InputBorder.none,
          hintStyle: const TextStyle(color: Colors.white),
          hintText: "message..."),
      controller: messagecontroler,
      detectionRegExp: detectionRegExp()!,
      onChanged: (value) {
        mscontrol.write(value);
      },
      onDetectionTyped: (text) {},
      onDetectionFinished: () {
        setState(() {
          allusersearch = [];
        });
      },
    );
  }

  Widget displayimage() {
    return Container(
        padding: EdgeInsets.all(5),
        height: 150,
        width: MediaQuery.of(context).size.width,
        color: Colors.white.withOpacity(0.2),
        child: Stack(
          children: [
            Row(
              children: <Widget>[
                Container(
                  height: 150,
                  width: 120,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      color: Colors.white),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                    child: Obx(
                      () => Image.file(
                        File(mscontrol.pathfile.value),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
              ],
            ),
            Positioned(
              top: 1,
              right: 5,
              child: IconButton(
                  onPressed: () {
                    mscontrol.closefile();
                  },
                  icon: const Icon(Icons.close, color: Colors.white)),
            )
          ],
        ));
  }

  translatemessagesend() {
    showModalBottomSheet(
        enableDrag: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.black.withBlue(20),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Center(
                          child: Container(
                            height: 5,
                            width: 100,
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100))),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        messagecontroler.text,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        (transaltetitle.isEmpty)
                            ? "Traduction"
                            : transaltetitle,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (lange && translatemessage.isNotEmpty)
                        Text(
                          translatemessage,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      if (lange && translatemessage.isEmpty)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.spaceBetween,
                        children: <Widget>[
                          DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              hint: const Text(
                                'Langue',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              items: items
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ))
                                  .toList(),
                              value: selectedValue,
                              onChanged: (value) async {
                                setState(() {
                                  selectedValue = value as String;
                                  setState(() {
                                    translatemessage = "";
                                    lange = true;
                                  });
                                });
                                print(value);
                                if (value == "Anglais") {
                                  var translation = await translator.translate(
                                      messagecontroler.text,
                                      to: 'en');
                                  var translation1 = await translator
                                      .translate("Traduction", to: 'en');
                                  print(translation.text);
                                  setState(() {
                                    translatemessage =
                                        translation.text.toString();
                                    transaltetitle =
                                        translation1.text.toString();
                                  });
                                }
                                if (value == "Français") {
                                  var translation = await translator.translate(
                                      messagecontroler.text,
                                      to: 'fr');
                                  var translation1 = await translator
                                      .translate("Traduction", to: 'fr');
                                  print(translation.text);
                                  setState(() {
                                    translatemessage =
                                        translation.text.toString();
                                    transaltetitle =
                                        translation1.text.toString();
                                  });
                                }
                                if (value == "Espagnole") {
                                  var translation = await translator.translate(
                                      messagecontroler.text,
                                      to: 'es');
                                  var translation1 = await translator
                                      .translate("Traduction", to: 'es');
                                  print(translation.text);
                                  setState(() {
                                    translatemessage =
                                        translation.text.toString();
                                    transaltetitle =
                                        translation1.text.toString();
                                  });
                                }
                                if (value == "Russe") {
                                  var translation = await translator.translate(
                                      messagecontroler.text,
                                      to: 'ru');
                                  var translation1 = await translator
                                      .translate("Traduction", to: 'ru');
                                  print(translation.text);
                                  setState(() {
                                    translatemessage =
                                        translation.text.toString();
                                    transaltetitle =
                                        translation1.text.toString();
                                  });
                                }
                                if (value == "Italien") {
                                  var translation = await translator.translate(
                                      messagecontroler.text,
                                      to: 'it');
                                  var translation1 = await translator
                                      .translate("Traduction", to: 'it');
                                  print(translation.text);
                                  setState(() {
                                    translatemessage =
                                        translation.text.toString();
                                    transaltetitle =
                                        translation1.text.toString();
                                  });
                                }
                                if (value == "Chinois") {
                                  var translation = await translator.translate(
                                      messagecontroler.text,
                                      to: 'zh-cn');
                                  var translation1 = await translator
                                      .translate("Traduction", to: 'zh-cn');
                                  print(translation.text);
                                  setState(() {
                                    translatemessage =
                                        translation.text.toString();
                                    transaltetitle =
                                        translation1.text.toString();
                                  });
                                }
                              },
                              buttonHeight: 40,
                              itemHeight: 40,
                              icon: const Icon(
                                Icons.arrow_downward_rounded,
                              ),
                              iconSize: 20,
                              iconEnabledColor: Colors.white,
                              iconDisabledColor: Colors.white,
                              buttonPadding:
                                  const EdgeInsets.only(left: 14, right: 14),
                              buttonDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.black26,
                                ),
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ),
                          ActionChip(
                            onPressed: () {
                              setState(() {
                                messagecontroler.text =
                                    translatemessage.toString();
                                Navigator.of(context).pop();
                              });
                            },
                            label: const Text(
                              'Valider',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            padding: const EdgeInsets.all(10),
                            backgroundColor: Colors.orange.shade900,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  Widget displayvideo() {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(5),
          height: 200,
          width: MediaQuery.of(context).size.width,
          color: Colors.white.withOpacity(0.2),
          child: CustomVideoPlayer(
              customVideoPlayerController: _customVideoPlayerController),
        ),
        Positioned(
            child: GestureDetector(
          onTap: () {
            mscontrol.closereponse();
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(Icons.close, color: Colors.white, size: 30),
          ),
        ))
      ],
    );
  }

  Widget displaydoc() {
    return Container(
        padding: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        color: Colors.white.withOpacity(0.2),
        child: Stack(
          children: [
            Row(
              children: <Widget>[
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(7)),
                      color: Colors.white.withOpacity(0.2)),
                  child: const Icon(
                    Iconsax.document_1,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Obx(() => Flexible(
                        child: Text(
                      mscontrol.namefile.value,
                      style: const TextStyle(color: Colors.white),
                    ))),
                IconButton(
                    onPressed: () {
                      mscontrol.closefile();
                    },
                    icon: const Icon(Icons.close, color: Colors.white))
              ],
            ),
          ],
        ));
  }

  Widget displaymusic() {
    return Container(
        padding: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        color: Colors.white.withOpacity(0.2),
        child: Stack(
          children: [
            Row(
              children: <Widget>[
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(7)),
                      color: Colors.white.withOpacity(0.2)),
                  child: const Icon(
                    Iconsax.music,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Obx(() => Flexible(
                        child: Text(
                      mscontrol.namefile.value,
                      style: const TextStyle(color: Colors.white),
                    ))),
                IconButton(
                    onPressed: () {
                      mscontrol.closefile();
                    },
                    icon: const Icon(Icons.close, color: Colors.white))
              ],
            ),
          ],
        ));
  }

  Widget displaynv() {
    return Container(
        padding: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        color: Colors.white.withOpacity(0.2),
        child: SiriWave(
          options: const SiriWaveOptions(
              height: 50, backgroundColor: Colors.transparent),
          style: SiriWaveStyle.ios_7,
          controller: SiriWaveController(
            amplitude: 0.5,
            color: Colors.red,
            frequency: 4,
            speed: 0.15,
          ),
        ));
  }

  Widget displaymessage() {
    return StreamBuilder(
      stream: messagestream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> msgtream) {
        if (!msgtream.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else if (msgtream.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return (msgtream.data!.docs.isEmpty)
            ? Empty()
            : StickyGroupedListView(
                reverse: true,
                floatingHeader: true,
                elements: msgtream.data!.docs,
                groupBy: (dynamic element) => element['range'],
                order: StickyGroupedListOrder.DESC, // optional
                groupSeparatorBuilder: (dynamic element) {
                  return const SizedBox();
                },
                itemBuilder: (context, dynamic msgtream) {
                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: (msgtream['idsend'] == userid)
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: (msgtream['idsend'] == userid)
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: <Widget>[
                        if (msgtream['typemessage'] == "image")
                          Row(
                            mainAxisAlignment: (msgtream['idsend'] == userid)
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: (msgtream['idsend'] == userid)
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: <Widget>[
                              if (msgtream['idsend'] != userid)
                                for (var alluser in allusers)
                                  if (alluser['iduser'] == msgtream['idsend'])
                                    CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              alluser['avatar']),
                                    ),
                              const SizedBox(
                                width: 5,
                              ),
                              displayonlineimage(
                                  msgtream['idsend'],
                                  msgtream['urlfile'],
                                  msgtream['finish'],
                                  msgtream['idsend'],
                                  msgtream["typemessage"],
                                  msgtream['message'],
                                  msgtream['urlfile'],
                                  msgtream['idmessage']),
                            ],
                          ),
                        if (msgtream['typemessage'] == "video")
                          Row(
                            mainAxisAlignment: (msgtream['idsend'] == userid)
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: (msgtream['idsend'] == userid)
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: <Widget>[
                              if (msgtream['idsend'] != userid)
                                for (var alluser in allusers)
                                  if (alluser['iduser'] == msgtream['idsend'])
                                    CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              alluser['avatar']),
                                    ),
                              const SizedBox(
                                width: 5,
                              ),
                              displayonlineivideo(
                                  msgtream['idsend'],
                                  msgtream['vignette'],
                                  msgtream['finish'],
                                  msgtream['urlfile'],
                                  msgtream['idsend'],
                                  msgtream["typemessage"],
                                  msgtream['message'],
                                  msgtream['vignette'],
                                  msgtream['idmessage']),
                            ],
                          ),
                        if (msgtream['typemessage'] == "music" ||
                            msgtream['typemessage'] == "nv")
                          Row(
                            mainAxisAlignment: (msgtream['idsend'] == userid)
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: (msgtream['idsend'] == userid)
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: <Widget>[
                              if (msgtream['idsend'] != userid)
                                for (var alluser in allusers)
                                  if (alluser['iduser'] == msgtream['idsend'])
                                    CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              alluser['avatar']),
                                    ),
                              const SizedBox(
                                width: 5,
                              ),
                              displayonlinemusic(
                                  msgtream['idsend'],
                                  msgtream['urlfile'],
                                  msgtream['finish'],
                                  msgtream['idsend'],
                                  msgtream["typemessage"],
                                  msgtream['message'],
                                  msgtream['urlfile'],
                                  msgtream['idmessage']),
                            ],
                          ),
                        if (msgtream['typemessage'] == "doc")
                          Row(
                            mainAxisAlignment: (msgtream['idsend'] == userid)
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: (msgtream['idsend'] == userid)
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: <Widget>[
                              if (msgtream['idsend'] != userid)
                                for (var alluser in allusers)
                                  if (alluser['iduser'] == msgtream['idsend'])
                                    CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              alluser['avatar']),
                                    ),
                              const SizedBox(
                                width: 5,
                              ),
                              displayonlinedoc(
                                  msgtream['idsend'],
                                  msgtream['urlfile'],
                                  msgtream['finish'],
                                  msgtream['namefile'],
                                  msgtream['idsend'],
                                  msgtream["typemessage"],
                                  msgtream['message'],
                                  msgtream['urlfile'],
                                  msgtream['idmessage'])
                            ],
                          ),
                        if (msgtream['message'] != "")
                          GestureDetector(
                              onLongPress: () {
                                if (msgtream['typemessage'] == "video") {
                                  optionselect(
                                      msgtream['idsend'],
                                      msgtream["typemessage"],
                                      msgtream['message'],
                                      msgtream['urlfile'],
                                      msgtream['idmessage']);
                                } else {
                                  optionselect(
                                      msgtream['idsend'],
                                      msgtream["typemessage"],
                                      msgtream['message'],
                                      msgtream['urlfile'],
                                      msgtream['idmessage']);
                                }
                              },
                              onTap: () {
                                optionselect(
                                    msgtream['idsend'],
                                    msgtream["typemessage"],
                                    msgtream['message'],
                                    msgtream['urlfile'],
                                    msgtream['idmessage']);
                              },
                              child: Row(
                                mainAxisAlignment:
                                    (msgtream['idsend'] == userid)
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                crossAxisAlignment:
                                    (msgtream['idsend'] == userid)
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: <Widget>[
                                  if (msgtream['idsend'] != userid)
                                    for (var alluser in allusers)
                                      if (alluser['iduser'] ==
                                          msgtream['idsend'])
                                        CircleAvatar(
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  alluser['avatar']),
                                        ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.only(top: 5),
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.8,
                                    ),
                                    decoration: BoxDecoration(
                                        color: (msgtream['idsend'] == userid)
                                            ? Colors.orange.shade900
                                            : Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.only(
                                            topLeft:
                                                (msgtream['idsend'] == userid)
                                                    ? const Radius.circular(15)
                                                    : const Radius.circular(0),
                                            topRight: const Radius.circular(15),
                                            bottomLeft:
                                                (msgtream['idsend'] == userid)
                                                    ? const Radius.circular(15)
                                                    : const Radius.circular(15),
                                            bottomRight: (msgtream['idsend'] ==
                                                    userid)
                                                ? const Radius.circular(0)
                                                : const Radius.circular(15))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        if (msgtream['idsend'] != userid)
                                          for (var alluser in allusers)
                                            if (alluser['iduser'] ==
                                                msgtream['idsend'])
                                              Text(
                                                alluser['nom'],
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                        if (msgtream['nomreponse'] != "")
                                          displayreponseinmessage(
                                              msgtream['typereponse'],
                                              msgtream['messagereponse'],
                                              msgtream['urlreponse'],
                                              msgtream['nomreponse']),
                                        DetectableText(
                                          trimExpandedText: "montrer moins",
                                          trimCollapsedText: "montrer plus",
                                          text: msgtream['message'],
                                          detectionRegExp: RegExp(
                                            "(?!\\n)(?:^|\\s)([#@]([$detectionContentLetters]+))|$urlRegexContent",
                                            multiLine: true,
                                          ),
                                          detectedStyle: TextStyle(
                                            color:
                                                (msgtream['idsend'] == userid)
                                                    ? Colors.white
                                                    : Colors.orange,
                                          ),
                                          basicStyle: TextStyle(
                                            fontSize: 18,
                                            color:
                                                (msgtream['idsend'] == userid)
                                                    ? Colors.black
                                                    : Colors.white,
                                          ),
                                          onTap: (tappedText) {
                                            Get.toNamed("/checklien",
                                                arguments: [
                                                  {"url": tappedText}
                                                ]);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        Container(
                          margin: (msgtream['idsend'] == userid)
                              ? null
                              : const EdgeInsets.only(left: 0),
                          child: Text(msgtream['date'],
                              style: const TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  );
                });
      },
    );
  }

  Widget displayreponseall() {
    return Obx(() => Container(
        padding: const EdgeInsets.all(5),
        color: Colors.white.withOpacity(0.3),
        child: Column(
          children: <Widget>[
            if (mscontrol.typereponse.value == "sms")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(mscontrol.messagereponse.value,
                      maxLines: 1, style: const TextStyle(color: Colors.white)),
                  IconButton(
                      onPressed: () {
                        mscontrol.closereponse();
                      },
                      icon: const Icon(Icons.close, color: Colors.white))
                ],
              ),
            if (mscontrol.typereponse.value == "image")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7))),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7)),
                            child: CachedNetworkImage(
                                imageUrl: mscontrol.urlreponse.value,
                                fit: BoxFit.cover),
                          )),
                      const SizedBox(width: 5),
                      const Text('Repondre à une image',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        mscontrol.closereponse();
                      },
                      icon: const Icon(Icons.close, color: Colors.white))
                ],
              ),
            if (mscontrol.typereponse.value == "video")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7))),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7)),
                            child: CachedNetworkImage(
                                imageUrl: mscontrol.urlreponse.value,
                                fit: BoxFit.cover),
                          )),
                      const SizedBox(width: 5),
                      const Text('Repondre à une vidéo',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        mscontrol.closereponse();
                      },
                      icon: Icon(Icons.close, color: Colors.white))
                ],
              ),
            if (mscontrol.typereponse.value == "music" ||
                mscontrol.typereponse.value == "nv")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7))),
                          child: Icon(Icons.audio_file, color: Colors.white)),
                      const SizedBox(width: 5),
                      const Text('Repondre à un audio',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        mscontrol.closereponse();
                      },
                      icon: Icon(Icons.close, color: Colors.white))
                ],
              ),
            if (mscontrol.typereponse.value == "doc")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7))),
                          child: const Icon(Iconsax.document_1,
                              color: Colors.white)),
                      const SizedBox(width: 5),
                      const Text("Reponse à un document",
                          maxLines: 1, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        mscontrol.closereponse();
                      },
                      icon: const Icon(Icons.close, color: Colors.white))
                ],
              ),
          ],
        )));
  }

  Widget displayreponseinmessage(
      typemessage, messagereponse, urlreponse, idreponse) {
    return Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(7)),
          color: Colors.white.withOpacity(0.3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (var alluser in allusers)
              if (alluser['iduser'] == idreponse)
                Text(
                  alluser['nom'],
                  style: const TextStyle(color: Colors.white),
                ),
            if (typemessage == "sms")
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child: Flexible(
                  child: Text(messagereponse,
                      maxLines: 4, style: const TextStyle(color: Colors.white)),
                ),
              ),
            if (typemessage == "image")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7))),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7)),
                            child: CachedNetworkImage(
                                imageUrl: urlreponse, fit: BoxFit.cover),
                          )),
                      const SizedBox(width: 5),
                      const Text('Image',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            if (typemessage == "video")
              Row(
                children: <Widget>[
                  Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(7))),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(7)),
                        child: CachedNetworkImage(
                            imageUrl: urlreponse, fit: BoxFit.cover),
                      )),
                  const SizedBox(width: 5),
                  const Text('Vidéo', style: TextStyle(color: Colors.white)),
                ],
              ),
            if (typemessage == "music" || typemessage == "nv")
              Row(
                children: <Widget>[
                  Container(
                      height: 30,
                      width: 30,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(7))),
                      child: const Icon(Icons.audio_file, color: Colors.white)),
                  const SizedBox(width: 5),
                  const Text('Audio', style: TextStyle(color: Colors.white)),
                ],
              ),
            if (typemessage == "doc")
              Row(
                children: <Widget>[
                  Container(
                      height: 30,
                      width: 30,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(7))),
                      child:
                          const Icon(Iconsax.document_1, color: Colors.white)),
                  const SizedBox(width: 5),
                  const Text("Document",
                      maxLines: 1, style: TextStyle(color: Colors.white)),
                ],
              ),
          ],
        ));
  }

  Widget displayonlineimage(idsend, String urfile, bool finish, nomreponses,
      typereponses, messagereponses, urlreponses, idmessage) {
    return (finish)
        ? GestureDetector(
            onTap: () {
              Get.toNamed('/viewimage', arguments: [
                {"urlfile": urfile}
              ]);
            },
            onLongPress: () {
              optionselect(idsend, typereponses, messagereponses, urlreponses,
                  idmessage);
            },
            child: Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.all(5),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height / 2.8,
                maxWidth: MediaQuery.of(context).size.width / 1.2,
              ),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  // image: DecorationImage(
                  //   image: CachedNetworkImageProvider(urfile),
                  // ),
                  borderRadius: const BorderRadius.all(Radius.circular(7))),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(7)),
                child: CachedNetworkImage(
                  imageUrl: urfile,
                ),
              ),
            ))
        : Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5),
                height: 200,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(Radius.circular(7))),
                child: const Center(child: CircularProgressIndicator()),
              ),
              Positioned(
                  bottom: 5,
                  right: 5,
                  child: Row(
                    children: const <Widget>[
                      Text(
                        "Chargement de l'image",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ))
            ],
          );
  }

  Widget displayonlineivideo(idsend, String vignette, bool finish, urfile,
      nomreponses, typereponses, messagereponses, urlreponses, idmessage) {
    return (finish)
        ? Stack(
            children: [
              GestureDetector(
                  onLongPress: () {
                    optionselect(idsend, typereponses, messagereponses,
                        urlreponses, idmessage);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.all(5),
                    width: 300,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 2.8,
                      maxWidth: MediaQuery.of(context).size.width / 1.2,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(7))),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(7)),
                      child: Videoread(urlvideo: urfile),
                    ),
                  )),
            ],
          )
        : Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5),
                height: 200,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(Radius.circular(7))),
                child: const Center(child: CircularProgressIndicator()),
              ),
              Positioned(
                  bottom: 5,
                  right: 5,
                  child: Row(
                    children: const <Widget>[
                      Text(
                        "Chargement de la vidéo",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ))
            ],
          );
  }

  Widget proposition() {
    return Container(
      padding: const EdgeInsets.only(right: 10),
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder(
          stream: _allnoeud,
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> allnoeudview) {
            if (!allnoeudview.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (allnoeudview.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: allnoeudview.data!.docs.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: ActionChip(
                        label: Text(allnoeudview.data!.docs[index]["nom"]),
                        avatar: CircleAvatar(
                          foregroundImage: NetworkImage(
                              allnoeudview.data!.docs[index]["logo"]),
                        ),
                        onPressed: () {
                          print("object");
                          FirebaseFirestore.instance
                              .collection('abonne')
                              .where('idcompte',
                                  isEqualTo: allnoeudview.data!.docs[index]
                                      ['idcompte'])
                              .where("iduser", isEqualTo: userid)
                              .get()
                              .then((QuerySnapshot value) {
                            if (value.docs.isEmpty) {
                              viewinfo(
                                  allnoeudview.data!.docs[index]['logo'],
                                  allnoeudview.data!.docs[index]['nom'],
                                  allnoeudview.data!.docs[index]['type'],
                                  allnoeudview.data!.docs[index]['offre'],
                                  allnoeudview.data!.docs[index]['statut'],
                                  allnoeudview.data!.docs[index].id,
                                  allnoeudview.data!.docs[index]['statut'],
                                  allnoeudview.data!.docs[index]
                                      ['description']);
                            } else {
                              if (allnoeudview.data!.docs[index]['type'] ==
                                  "boutique") {
                                // redirection a la boutique

                                Get.toNamed(
                                    "/" +
                                        allnoeudview.data!.docs[index]
                                            ["design"],
                                    arguments: [
                                      {
                                        "idshop": allnoeudview.data!.docs[index]
                                            ["idcompte"]
                                      },
                                      {
                                        "nomshop": allnoeudview
                                            .data!.docs[index]["nom"]
                                      },
                                    ]);
                              }
                              if (allnoeudview.data!.docs[index]['type'] ==
                                  "Moment") {
                                // redirection moment
                                if (allnoeudview.data!.docs[index]
                                        ["lienvideo"] ==
                                    "") {
                                  msnoeud.message("Echec",
                                      "Désolé, vous ne pouvez pas accéder.");
                                } else {
                                  Get.toNamed("/vlog", arguments: [
                                    {
                                      "idchaine": allnoeudview.data!.docs[index]
                                          ["idcompte"]
                                    },
                                    {
                                      "nomchaine":
                                          allnoeudview.data!.docs[index]["nom"]
                                    },
                                    {
                                      "logo": allnoeudview.data!.docs[index]
                                          ['logo']
                                    },
                                    {
                                      "vignette": allnoeudview.data!.docs[index]
                                          ['vignette']
                                    },
                                    {
                                      "titre": allnoeudview.data!.docs[index]
                                          ['titre']
                                    }
                                  ]);
                                }
                              }
                            }
                          });
                        }),
                  );
                });
          }),
    );
  }

  Widget displayonlinemusic(idsend, String urfile, bool finish, nomreponses,
      typereponses, messagereponses, urlreponses, idmessage) {
    return (finish)
        ? GestureDetector(
            onTap: () {
              optionselect(idsend, typereponses, messagereponses, urlreponses,
                  idmessage);
            },
            onLongPress: () {
              optionselect(idsend, typereponses, messagereponses, urlreponses,
                  idmessage);
            },
            child: Container(
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: (idsend == userid)
                          ? const Radius.circular(15)
                          : const Radius.circular(0),
                      topRight: const Radius.circular(15),
                      bottomLeft: (idsend == userid)
                          ? const Radius.circular(15)
                          : const Radius.circular(15),
                      bottomRight: (idsend == userid)
                          ? const Radius.circular(0)
                          : const Radius.circular(15))),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(7)),
                child: VoiceMessage(
                  contactPlayIconColor: Colors.red,
                  audioSrc: urfile,
                  played: true, // To show played badge or not.
                  me: (idsend == userid) ? true : false, // Set message side.
                  onPlay: () {}, // Do something when voice played.
                ),
              ),
            ))
        : Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 20),
                width: 200,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.only(
                        topLeft: (idsend == userid)
                            ? const Radius.circular(15)
                            : const Radius.circular(0),
                        topRight: const Radius.circular(15),
                        bottomLeft: (idsend == userid)
                            ? const Radius.circular(15)
                            : const Radius.circular(15),
                        bottomRight: (idsend == userid)
                            ? const Radius.circular(0)
                            : const Radius.circular(15))),
                child: AudioWave(
                  height: 60,
                  width: 180,
                  spacing: 2.5,
                  bars: [
                    AudioWaveBar(
                        color: Colors.lightBlueAccent, heightFactor: 0.1),
                    AudioWaveBar(heightFactor: 0.3, color: Colors.blue),
                    AudioWaveBar(heightFactor: 0.7, color: Colors.black),
                    AudioWaveBar(heightFactor: 0.4),
                    AudioWaveBar(heightFactor: 0.2, color: Colors.orange),
                    AudioWaveBar(
                        heightFactor: 0.1, color: Colors.lightBlueAccent),
                    AudioWaveBar(heightFactor: 0.3, color: Colors.blue),
                    AudioWaveBar(heightFactor: 0.7, color: Colors.black),
                    AudioWaveBar(heightFactor: 0.4),
                    AudioWaveBar(heightFactor: 0.2, color: Colors.orange),
                    AudioWaveBar(
                        heightFactor: 0.1, color: Colors.lightBlueAccent),
                    AudioWaveBar(heightFactor: 0.3, color: Colors.blue),
                    AudioWaveBar(heightFactor: 0.7, color: Colors.black),
                    AudioWaveBar(heightFactor: 0.4),
                    AudioWaveBar(heightFactor: 0.2, color: Colors.orange),
                    AudioWaveBar(
                        heightFactor: 0.1, color: Colors.lightBlueAccent),
                    AudioWaveBar(heightFactor: 0.3, color: Colors.blue),
                    AudioWaveBar(heightFactor: 0.7, color: Colors.black),
                    AudioWaveBar(heightFactor: 0.4),
                    AudioWaveBar(heightFactor: 0.2, color: Colors.orange),
                  ],
                ),
              ),
              Positioned(
                  bottom: 5,
                  right: 5,
                  child: Row(
                    children: const <Widget>[
                      Text(
                        "Chargement de l'audio",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        height: 10,
                        width: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ],
                  ))
            ],
          );
  }

  Widget displayonlinedoc(idsend, String urfile, bool finish, namefile,
      nomreponses, typereponses, messagereponses, urlreponses, idmessage) {
    return (finish)
        ? GestureDetector(
            onTap: () {
              optionselect(idsend, typereponses, messagereponses, urlreponses,
                  idmessage);
            },
            onLongPress: () {
              optionselect(idsend, typereponses, messagereponses, urlreponses,
                  idmessage);
            },
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              margin: const EdgeInsets.only(top: 5),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(7))),
              child: Row(
                children: <Widget>[
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(7)),
                        color: Colors.white.withOpacity(0.2)),
                    child: const Icon(
                      Iconsax.document_1,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                      child: Text(
                    namefile,
                    style: const TextStyle(color: Colors.white),
                  )),
                ],
              ),
            ))
        : Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5),
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(Radius.circular(7))),
              ),
              Positioned(
                  bottom: 5,
                  right: 5,
                  child: Row(
                    children: const <Widget>[
                      Text(
                        "Chargement du document",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        height: 10,
                        width: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ],
                  ))
            ],
          );
  }

  Widget mentionuser() {
    return Container(
        constraints: const BoxConstraints(maxHeight: 200),
        color: Colors.white.withOpacity(0.3),
        child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: allusersearch.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  for (var item in allusers)
                    if (item['iduser'] == allusersearch[index]['iduser'])
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            allusersearch = [];
                          });
                          addmention(item['nom']);
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(item['avatar']),
                          ),
                          title: Text(
                            item['nom'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                ],
              );
            }));
  }

  // LES FUNCTIONS
  void _runFilter(String enteredKeyword) {
    List results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = [];
    } else {
      results = alluserbranches
          .where((user) => user["nomuser"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }
    // Refresh the UI
    setState(() {
      allusersearch = results;
    });
    print(allusersearch);
  }

  addmention(nomuser) {
    setState(() {
      // message = message + nomuser;
      messagecontroler.text = messagecontroler.text + nomuser;
    });
  }

  sendmessage() {
    DateTime now = DateTime.now();
    String dateformat = DateFormat("kk:mm").format(now);
    FirebaseFirestore.instance.collection("message").add({
      "message": messagecontroler.text,
      "idbranche": idbranche,
      "idsend": userid,
      "urlfile": "",
      "typemessage": mscontrol.typemessage.value,
      "vignette": "",
      "range": DateTime.now().millisecondsSinceEpoch,
      "date": dateformat,
      "messagereponse": mscontrol.messagereponse.value,
      "nomreponse": mscontrol.nomreponse.value,
      "namefile": mscontrol.namefile.value,
      "idnoeud": "",
      "typereponse": mscontrol.typereponse.value,
      "urlreponse": mscontrol.urlreponse.value,
      "idmessage": "",
      "finish": false
    }).then((value) {
      FirebaseFirestore.instance
          .collection('message')
          .doc(value.id)
          .update({"idmessage": value.id});
      if (mscontrol.typemessage.value != "sms") {
        mscontrol.launchupload(value.id);
      }
      FirebaseFirestore.instance
          .collection("userbranche")
          .where("idbranche", isEqualTo: idbranche)
          .get()
          .then((value) {
        for (var element in value.docs) {
          if (element['iduser'] != userid) {
            FirebaseFirestore.instance
                .collection("userbranche")
                .doc(element.id)
                .update({"nbremsg": FieldValue.increment(1)});
          }
        }
      });
      mscontrol.resettemessage();
      mscontrol.restfast();
      mscontrol.launchnotification(
        newmessage,
        listfcm,
        sendrequ.nomnoeuds.value,
        nombranche,
        idbranche,
        sendrequ.idnoeuds.value,
      );
    });
    mscontrol.typemessage.value = "sms";
    setState(() {
      newmessage = messagecontroler.text;
      messagecontroler.text = "";
      translatemessage = "";
    });
  }

  choosefile(isimage, isvideo, isfile, ismusic) {
    showModalBottomSheet(
        backgroundColor: Colors.black.withBlue(30),
        enableDrag: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                      ),
                    ),
                    if (isimage || admin == 1 || idcreat == userid)
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              mscontrol.selectfile("image");
                            },
                            child: ListTile(
                              leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(50)),
                                    color: Colors.white.withOpacity(0.2)),
                                child: const Icon(Iconsax.camera,
                                    color: Colors.white),
                              ),
                              title: const Text(
                                "Image",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    if (isvideo || admin == 1 || idcreat == userid)
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              selectvideo();
                            },
                            child: ListTile(
                              leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(50)),
                                    color: Colors.white.withOpacity(0.2)),
                                child: const Icon(Iconsax.video,
                                    color: Colors.white),
                              ),
                              title: const Text(
                                "Video",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    if (isfile || admin == 1 || idcreat == userid)
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              mscontrol.selectfile("doc");
                            },
                            child: ListTile(
                              leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(50)),
                                    color: Colors.white.withOpacity(0.2)),
                                child: const Icon(Icons.file_present_rounded,
                                    color: Colors.white),
                              ),
                              title: const Text(
                                "Document",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    if (ismusic || admin == 1 || idcreat == userid)
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          mscontrol.selectfile("music");
                        },
                        child: ListTile(
                          leading: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(50)),
                                color: Colors.white.withOpacity(0.2)),
                            child:
                                const Icon(Iconsax.music, color: Colors.white),
                          ),
                          title: const Text(
                            "Music",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      )
                  ],
                ),
              );
            },
          );
        });
  }

  optionselect(idsend, typemessage, message, urlfile, idmessage) {
    Get.bottomSheet(SingleChildScrollView(
        child: Options(
      idmessage: idmessage,
      idsend: idsend,
      message: message,
      typemessage: typemessage,
      urlfile: urlfile,
    )));
  }

  selectvideo() async {
    final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (file!.path != "") {
      videoPlayerController = VideoPlayerController.file(File(file.path))
        ..initialize().then((value) => setState(() {}));
      _customVideoPlayerController = CustomVideoPlayerController(
          context: context,
          videoPlayerController: videoPlayerController,
          customVideoPlayerSettings:
              const CustomVideoPlayerSettings(settingsButtonAvailable: false));

      mscontrol.selectvideo(file.path, file.name, "");
    } else {}
  }

  viewinfo(logo, nom, type, offre, statut, idcomptes, prix, descriptions) {
    showMaterialModalBottomSheet(
      backgroundColor: Colors.black.withBlue(30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      context: context,
      builder: (context) => SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                height: 5,
                width: 50,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Container(
                height: 80,
                width: 80,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  child: Image.network(
                    (logo),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 80,
                width: MediaQuery.of(context).size.width / 1.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        nom,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        type,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )
            ]),
            const SizedBox(
              height: 10,
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Description",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              descriptions,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (offre == "gratuit")
                      ? "Libre d'accès"
                      : "accès par abonnement",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.orange),
                    onPressed: () {
                      if (statut == "public") {
                        installer(offre, idcomptes, logo, type, prix, nom);
                        Navigator.of(context).pop();
                      } else {
                        sendinvitation(logo, idcomptes, offre, type, nom);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      (statut == "public") ? "Obtenir" : "Envitation",
                      // "Obtenir",
                    ))
              ],
            )
          ],
        ),
      )),
    );
  }

  installer(offre, idcompte, logo, type, prix, nom) {
    if (offre == "gratuit") {
      msnoeud.rejoindre(nom, idcompte, logo, offre, type, idcreat);
    } else {
      msnoeud.byAbonnement(
          prix, wallet, idcompte, nom, logo, offre, type, idcreat);
    }
  }

  sendinvitation(logo, idcompte, offre, type, nom) {
    FirebaseFirestore.instance.collection("invitation").add({
      "iduser": userid,
      "idcompte": idcompte,
      "nom": nom,
      "logo": logo,
      "date": DateTime.now(),
      "range": DateTime.now().millisecondsSinceEpoch,
      "offre": offre,
      "statut": 0,
      "type": type,
      "nomuser": nameuser
    });
    for (var abonne in abonne) {
      if (abonne["statut"] == 1 && abonne["idcompte"] == idcompte) {
        FirebaseFirestore.instance.collection("notification").add({
          "message": "$nameuser souhaite integrer votre noeud",
          "logo": logo,
          "type": "invitation",
          "iduser": abonne["iduser"],
          "idcompte": idcompte
        });
        FirebaseFirestore.instance
            .collection("users")
            .doc(abonne["iduser"])
            .update({"notification": FieldValue.increment(1)});
      }
    }
    FirebaseFirestore.instance
        .collection("noeud")
        .doc(idcompte)
        .update({"invitation": FieldValue.increment(1)});
    msnoeud.message("Sucess",
        "Votre demande d'adhesion au noeud $nom a été envoyé avec accès");
  }
}

class Checklien extends StatefulWidget {
  const Checklien({
    Key? key,
  }) : super(key: key);

  @override
  State<Checklien> createState() => _ChecklienState();
}

class _ChecklienState extends State<Checklien> {
  final GlobalKey webViewKey = GlobalKey();
  String url = Get.arguments[0]["url"];

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  double progress = 0;
  final urlController = TextEditingController();
  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        webViewController?.reload();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withBlue(20),
        appBar: AppBar(
          backgroundColor: Colors.black.withBlue(20),
          title: Text(url),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
            child: Column(children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(url: Uri.parse(url)),
                  initialOptions: options,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri.scheme)) {
                      // if (await canLaunch(url)) {
                      //   // Launch the App
                      //   await launch(
                      //     url,
                      //   );
                      //   // and cancel the request
                      //   return NavigationActionPolicy.CANCEL;
                      // }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController.endRefreshing();
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onLoadError: (controller, url, code, message) {
                    pullToRefreshController.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = this.url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print(consoleMessage);
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            ),
          ),
        ])));
  }
}

class Videoread extends StatefulWidget {
  Videoread({Key? key, required this.urlvideo}) : super(key: key);
  String urlvideo;
  @override
  _VideoreadState createState() => _VideoreadState();
}

class _VideoreadState extends State<Videoread> {
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.urlvideo)
      ..initialize().then((value) => setState(() {}));
    _customVideoPlayerController = CustomVideoPlayerController(
        context: context,
        videoPlayerController: videoPlayerController,
        customVideoPlayerSettings:
            CustomVideoPlayerSettings(settingsButtonAvailable: false));
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomVideoPlayer(
        customVideoPlayerController: _customVideoPlayerController);
  }
}
