import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Displayonlinefile extends StatefulWidget {
  Displayonlinefile({Key? key, required this.idmessage}) : super(key: key);
  late String idmessage;
  @override
  _DisplayonlinefileState createState() => _DisplayonlinefileState();
}

class _DisplayonlinefileState extends State<Displayonlinefile> {
  String typecontent = "";
  final instance = FirebaseFirestore.instance.collection("message");
  late Stream<QuerySnapshot> mediastream = FirebaseFirestore.instance
      .collection('message')
      .doc(widget.idmessage)
      .collection("media")
      .snapshots();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.idmessage);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: mediastream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.red,
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          );
        }
        int length = snapshot.data!.docs.length;
        List media = snapshot.data!.docs;
        return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  if (media[index]
                                  ["extension"]
                              .toString()
                              .toLowerCase() ==
                          "png" ||
                      media[index]["extension"].toString().toLowerCase() ==
                          "jpg" ||
                      media[index]["extension"].toString().toLowerCase() ==
                          "jpeg")
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 200,
                      width: 300,
                      child: (media[index]["finish"] == true)
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              child: Image.network(media[index]["urlfile"],
                                  fit: BoxFit.cover),
                            )
                          : Stack(
                              children: [
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.red,
                                  ),
                                ),
                                Positioned(
                                  bottom: 5,
                                  right: 10,
                                  child: CircularPercentIndicator(
                                    radius: 20.0,
                                    lineWidth: 3.0,
                                    percent: media[index]["percente"] / 100,
                                    center: const Icon(
                                      Icons.download,
                                      color: Colors.white,
                                    ),
                                    backgroundColor: Colors.grey,
                                    progressColor: Colors.redAccent,
                                  ),
                                )
                              ],
                            ),
                    ),
                  if (media[index]["extension"].toString().toLowerCase() ==
                      "mp4")
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(5),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(0.1)),
                      height: 300,
                      child: (media[index]["finish"] == true)
                          ? ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              child: displayvideonly(
                                  videourl: media[index]["urlfile"]),
                            )
                          : Container(
                              height: 300,
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey.withOpacity(0.2)),
                              child: Stack(
                                children: [
                                  const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 5,
                                    right: 10,
                                    child: CircularPercentIndicator(
                                      radius: 20.0,
                                      lineWidth: 3.0,
                                      percent: media[index]["percente"] / 100,
                                      center: const Icon(
                                        Icons.download,
                                        color: Colors.white,
                                      ),
                                      backgroundColor: Colors.grey,
                                      progressColor: Colors.redAccent,
                                    ),
                                  )
                                ],
                              ),
                            ),
                    ),
                  if (typecontent == 'audio')
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.green),
                      height: 50,
                    ),
                  if (typecontent == 'document')
                    Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(3),
                              margin: const EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  Text(
                                    'Document',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                  Chip(
                                    backgroundColor: Colors.blue,
                                    avatar: Icon(
                                      Iconsax.document,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      'Document',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              margin: const EdgeInsets.only(right: 10),
                              child: const Icon(
                                Icons.file_download,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        )),
                ],
              );
            });
      },
    );
  }
}

class displayvideonly extends StatefulWidget {
  displayvideonly({Key? key, required this.videourl}) : super(key: key);
  String videourl;
  @override
  _displayvideonlyState createState() => _displayvideonlyState();
}

class _displayvideonlyState extends State<displayvideonly> {
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;
  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.videourl)
      ..initialize().then((value) => setState(() {}));
    _customVideoPlayerController = CustomVideoPlayerController(
        context: context,
        videoPlayerController: videoPlayerController,
        customVideoPlayerSettings:
            const CustomVideoPlayerSettings(settingsButtonAvailable: false));
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomVideoPlayer(
          customVideoPlayerController: _customVideoPlayerController),
    );
  }
}
