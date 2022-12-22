import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smatch/message/messagecontroller.dart';

class Displaylocalfile extends StatefulWidget {
  const Displaylocalfile({Key? key}) : super(key: key);

  @override
  _DisplaylocalfileState createState() => _DisplaylocalfileState();
}

class _DisplaylocalfileState extends State<Displaylocalfile> {
  final smscontroller = Get.put(Messagecontroller());
  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(
          children: [
            Column(
              children: <Widget>[
                if (smscontroller.typereponse.value == 'sms')
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    width: MediaQuery.of(context).size.width / 1.3,
                    child: Flexible(
                        child: Text(
                      smscontroller.messagereponse.value,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    )),
                  ),
                if (smscontroller.typereponse.value == "image" ||
                    smscontroller.typereponse.value == "video")
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    margin: const EdgeInsets.only(left: 10),
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
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              Chip(
                                backgroundColor: Colors.blue,
                                avatar:
                                    (smscontroller.typereponse.value == "image")
                                        ? const Icon(
                                            Icons.image,
                                            color: Colors.white,
                                          )
                                        : const Icon(
                                            Icons.video_library,
                                            color: Colors.white,
                                          ),
                                label: (smscontroller.typereponse.value ==
                                        "image")
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          margin: const EdgeInsets.only(left: 10),
                        ),
                      ],
                    ),
                  ),
                if (smscontroller.typereponse.value == "audio" ||
                    smscontroller.typereponse.value == "document")
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    margin: const EdgeInsets.only(left: 10),
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
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              Chip(
                                backgroundColor: Colors.blue,
                                avatar: (smscontroller.typereponse.value ==
                                        "document")
                                    ? const Icon(
                                        Iconsax.document,
                                        color: Colors.white,
                                      )
                                    : const Icon(
                                        Iconsax.microphone_2,
                                        color: Colors.white,
                                      ),
                                label: (smscontroller.typereponse.value ==
                                        "document")
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
            ),
            Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () {
                    smscontroller.typereponse.value = "";
                  },
                  child: const CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close),
                  ),
                ))
          ],
        ));
  }
}
