import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smatch/message/messagecontroller.dart';

class Responsonline extends StatefulWidget {
  const Responsonline({Key? key}) : super(key: key);

  @override
  _ResponsonlineState createState() => _ResponsonlineState();
}

class _ResponsonlineState extends State<Responsonline> {
  String typemessage = "";
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (typemessage == "image" || typemessage == "video")
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.black.withBlue(20),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(3),
                  margin: const EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Anderson',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Chip(
                        backgroundColor: Colors.blue,
                        avatar: (typemessage == "image")
                            ? const Icon(
                                Icons.image,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.video_library,
                                color: Colors.white,
                              ),
                        label: (typemessage == "image")
                            ? const Text(
                                'Image',
                                style: TextStyle(color: Colors.white),
                              )
                            : const Text(
                                'Video',
                                style: TextStyle(color: Colors.white),
                              ),
                      )
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  height: 80,
                  width: 80,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  margin: const EdgeInsets.only(left: 10),
                ),
              ],
            ),
          ),
        if (typemessage == "audio" || typemessage == "document")
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.black.withBlue(20),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            width: MediaQuery.of(context).size.width / 1.3,
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(3),
                  margin: const EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Anderson',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Chip(
                        backgroundColor: Colors.blue,
                        avatar: (typemessage == "document")
                            ? const Icon(
                                Iconsax.document,
                                color: Colors.white,
                              )
                            : const Icon(
                                Iconsax.microphone_2,
                                color: Colors.white,
                              ),
                        label: (typemessage == "document")
                            ? const Text(
                                'Nom du contenu a afficher ici',
                                style: TextStyle(color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : const Text(
                                'Audio',
                                style: TextStyle(color: Colors.white),
                              ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }
}
