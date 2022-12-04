import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smatch/home/social.dart';
import 'package:smatch/home/tabsrequette.dart';

class Settingsvideo extends StatefulWidget {
  const Settingsvideo({Key? key}) : super(key: key);

  @override
  _SettingsvideoState createState() => _SettingsvideoState();
}

class _SettingsvideoState extends State<Settingsvideo> {
  final Stream<QuerySnapshot> streamuserbranche = FirebaseFirestore.instance
      .collection("userbranche")
      .where("idbranche", isEqualTo: Get.arguments[0]["idbranche"])
      .snapshots();
  final Stream<QuerySnapshot> streamepublication = FirebaseFirestore.instance
      .collection("publication")
      .where("idpub", isEqualTo: Get.arguments[0]["idbranche"])
      .snapshots();
  final instance = FirebaseFirestore.instance;
  final req = Get.put(Tabsrequette());
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.black.withBlue(20),
          appBar: AppBar(
            backgroundColor: Colors.black.withBlue(20),
            bottom: const TabBar(
              tabs: [
                Tab(
                  child: Text(
                    'Membres',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Tab(
                  child: Text(
                    'Publication',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    StreamBuilder(
                      stream: streamuserbranche,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        int length = snapshot.data!.docs.length;
                        List userinfo = snapshot.data!.docs;
                        return ListView.builder(
                            itemCount: length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext, index) {
                              return ListTile(
                                contentPadding: EdgeInsets.all(10),
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: CachedNetworkImageProvider(
                                      userinfo[index]["avatar"]),
                                ),
                                title: Text(
                                  userinfo[index]["nomuser"],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: ActionChip(
                                  onPressed: () {
                                    Get.defaultDialog(
                                        title: "Confirmation",
                                        textCancel: "Annuler",
                                        textConfirm: "Supprimer",
                                        confirmTextColor: Colors.white,
                                        onConfirm: () {
                                          instance
                                              .collection("userbranche")
                                              .doc(
                                                  snapshot.data!.docs[index].id)
                                              .delete();
                                          req.message("Echec",
                                              "Utilisateur supprimer avec success");
                                        },
                                        content: const Text(
                                            'Vous etes sur le point de retirer cet utilisateur'));
                                  },
                                  label: const Text(
                                    'Retirer',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            });
                      },
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: StreamBuilder(
                  stream: streamepublication,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    int length = snapshot.data!.docs.length;
                    List datavideo = snapshot.data!.docs;
                    return (datavideo.isEmpty)
                        ? EmptyWidget(
                            hideBackgroundAnimation: true,
                            image: "assets/inbox.png",
                            packageImage: null,
                            title: 'Aucun contenu',
                            subTitle: "Aucun contenu publier pour l'intant",
                            titleTextStyle: const TextStyle(
                              fontSize: 22,
                              color: Color(0xff9da9c7),
                              fontWeight: FontWeight.w500,
                            ),
                            subtitleTextStyle: const TextStyle(
                              fontSize: 18,
                              color: Color(0xffabb8d6),
                            ),
                          )
                        : ListView.builder(
                            itemCount: length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext, index) {
                              return Container(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    if (datavideo[index]["typecontenu"] ==
                                        "image")
                                      Displayimage(
                                          idpub: datavideo[index]["id"],
                                          type: datavideo[index]["typecontenu"],
                                          textpub: datavideo[index]["text"]),
                                    if (datavideo[index]["typecontenu"] ==
                                        "video")
                                      Container(
                                        height: 300,
                                        child: DisplaySettingsvideo(
                                            url: datavideo[index]["video"]),
                                      ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      datavideo[index]["text"],
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Chip(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                avatar:
                                                    const Icon(Iconsax.heart),
                                                label: Text(
                                                  "${datavideo[index]["nbrelike"]} ",
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                )),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Chip(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                avatar:
                                                    const Icon(Iconsax.message),
                                                label: Text(
                                                  "${datavideo[index]["nbrecomment"]} ",
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ))
                                          ],
                                        ),
                                        ActionChip(
                                            onPressed: () {
                                              Get.defaultDialog(
                                                  onConfirm: () {
                                                    instance
                                                        .collection(
                                                            "publication")
                                                        .doc(snapshot.data!
                                                            .docs[index].id)
                                                        .delete();
                                                    Navigator.of(context).pop();
                                                    req.message("success",
                                                        "Publication supprime avec succes");
                                                  },
                                                  textCancel: "Annuler",
                                                  textConfirm: "Supprimer",
                                                  title: "Confirmation",
                                                  content: const Text(
                                                      "Voulez vous vraiment supprimer cette publication ?"),
                                                  confirmTextColor:
                                                      Colors.white);
                                            },
                                            backgroundColor: Colors.redAccent,
                                            padding: const EdgeInsets.all(10),
                                            avatar: const Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                            ),
                                            label: const Text(
                                              'Supprimer',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white),
                                            ))
                                      ],
                                    )
                                  ],
                                ),
                              );
                            });
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

class DisplaySettingsvideo extends StatefulWidget {
  DisplaySettingsvideo({Key? key, required this.url}) : super(key: key);
  String url;
  @override
  _DisplaySettingsvideoState createState() => _DisplaySettingsvideoState();
}

class _DisplaySettingsvideoState extends State<DisplaySettingsvideo> {
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.url)
      ..initialize().then((value) => setState(() {}));
    _customVideoPlayerController = CustomVideoPlayerController(
        context: context,
        videoPlayerController: videoPlayerController,
        customVideoPlayerSettings:
            const CustomVideoPlayerSettings(settingsButtonAvailable: false));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      height: 200,
      width: MediaQuery.of(context).size.width,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: CustomVideoPlayer(
            customVideoPlayerController: _customVideoPlayerController),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _customVideoPlayerController.dispose();
  }
}
