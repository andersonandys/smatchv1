import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smatch/message/displaylocalfile.dart';
import 'package:smatch/message/displayonlinefile.dart';
import 'package:smatch/message/isole/homeisole.dart';
import 'package:smatch/message/messagecontroller.dart';
import 'package:smatch/message/optionmessage.dart';
import 'package:smatch/message/responseonline.dart';
import 'package:smatch/message/selectlocalfile.dart';
import 'package:smatch/message/suggestion.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:http/http.dart' as http;

class Message extends StatefulWidget {
  const Message({Key? key}) : super(key: key);

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  String path = "";
  final instance = FirebaseFirestore.instance;
  double progress = 0.0;
  String filename = "";
  String data = "";
  final smscontrol = Get.put(Messagecontroller());
  String iduser = FirebaseAuth.instance.currentUser!.uid;
  final Stream<QuerySnapshot> messagestream = FirebaseFirestore.instance
      .collection('message')
      // .where("idbranche", isEqualTo: Get.arguments[0]['idbranche'])
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(20),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(20),
        elevation: 0,
        title: const Text('Message'),
      ),
      body: Obx(() => Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: StreamBuilder(
                  stream: messagestream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          var message = snapshot.data!.docs[index];
                          return Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Get.bottomSheet(SingleChildScrollView(
                                    child: Optionmessage(
                                      idmessage: message.id,
                                      idsend: message["idsend"],
                                      typemessage: message["typemessage"],
                                      message: message["message"],
                                    ),
                                  ));
                                },
                                child: Column(
                                  mainAxisAlignment:
                                      (message["idsend"] == iduser)
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      (message["idsend"] == iduser)
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Displayonlinefile(
                                      idmessage: message.id,
                                    ),
                                    ChatBubble(
                                      elevation: 0,
                                      shadowColor: Colors.black,
                                      clipper: ChatBubbleClipper1(
                                          type: (message["idsend"] == iduser)
                                              ? BubbleType.sendBubble
                                              : BubbleType.receiverBubble),
                                      alignment: (message["idsend"] == iduser)
                                          ? Alignment.topRight
                                          : null,
                                      margin: const EdgeInsets.only(top: 5),
                                      backGroundColor: Colors.blue,
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            const Responsonline(),
                                            Text(
                                              message["message"],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        });
                  },
                )),
                const SizedBox(
                  height: 10,
                ),
                const Displaylocalfile(),
                const Selectlocalfile(),
                barmessage(),
                const Suggestion()
              ],
            ),
          )),
    );
  }

  Widget barmessage() {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      // color: Colors.white.withOpacity(0.1),
      child: Row(
        children: <Widget>[
          Expanded(
              child: DetectableTextField(
            onChanged: (value) {
              if (smscontrol.messagediting.value.text.isNotEmpty) {
                smscontrol.write.value = true;
              } else {
                smscontrol.write.value = false;
              }
            },
            controller: smscontrol.messagediting.value,
            enableSuggestions: true,
            maxLines: null,
            basicStyle: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              prefixIcon: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Iconsax.document,
                    color: Colors.white,
                  )),
              suffixIcon: IconButton(
                  onPressed: () async {
                    smscontrol.selectmedia(context);
                  },
                  icon: const Icon(
                    Iconsax.camera,
                    color: Colors.white,
                    size: 27,
                  )),
              border: const OutlineInputBorder(
                gapPadding: 2,
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              hintText: 'Taper votre message',
              hintStyle: const TextStyle(
                color: Colors.white,
              ),
            ),
            detectionRegExp: detectionRegExp()!,
            decoratedStyle: const TextStyle(
              // fontSize: 20,
              color: Colors.blue,
            ),
          )),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              if (smscontrol.write.isTrue) {
                smscontrol.sendmessage("");
              } else {
                // smscontrol.startrecord();
              }
            },
            onLongPress: () {
              if (smscontrol.write.isTrue) {
                Get.bottomSheet(SingleChildScrollView(
                  child: Translatesmssend(
                      message: smscontrol.messagediting.value.text),
                ));
              }
            },
            child: CircleAvatar(
                radius: 25,
                child: (smscontrol.write.isTrue)
                    ? const Icon(
                        Iconsax.send1,
                        color: Colors.white,
                        size: 30,
                      )
                    : const Icon(
                        Iconsax.microphone_2,
                        color: Colors.white,
                        size: 30,
                      )),
          )
        ],
      ),
    );
  }
}
