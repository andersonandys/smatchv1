import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smatch/message/messagecontroller.dart';
import 'package:translator/translator.dart';

class Optionmessage extends StatefulWidget {
  Optionmessage(
      {Key? key,
      required this.idmessage,
      required this.message,
      required this.idsend,
      required this.typemessage})
      : super(key: key);
  String idmessage;
  String message;
  String idsend;
  String typemessage;
  @override
  _OptionmessageState createState() => _OptionmessageState();
}

class _OptionmessageState extends State<Optionmessage> {
  String iduser = FirebaseAuth.instance.currentUser!.uid;
  final smscontroller = Get.put(Messagecontroller());
  style() {
    return const TextStyle(
      fontSize: 18,
    );
  }

  color() {
    return Colors.black;
  }

  final instance = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 80,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircleAvatar(
                      radius: 25,
                    ),
                  );
                }),
          ),
          ListTile(
            onTap: () {
              smscontroller.typereponse.value = widget.typemessage;
              smscontroller.messagereponse.value = widget.message;
              Navigator.pop(context);
            },
            leading: Icon(
              Icons.reply,
              color: color(),
            ),
            title: Text(
              'Repondre',
              style: style(),
            ),
          ),
          if (widget.idsend == iduser)
            ListTile(
              onTap: () {
                Navigator.of(context).pop();
                Get.bottomSheet(SingleChildScrollView(
                  child: updatemessage(
                    idmessage: widget.idmessage,
                    message: widget.message,
                  ),
                ));
              },
              leading: Icon(
                Icons.edit,
                color: color(),
              ),
              title: Text(
                'Modifier',
                style: style(),
              ),
            ),
          ListTile(
            onTap: () {
              Navigator.of(context).pop();
              Get.bottomSheet(SingleChildScrollView(
                child: Translatemessage(
                  message: widget.message,
                ),
              ));
            },
            leading: Icon(
              Icons.translate,
              color: color(),
            ),
            title: Text(
              'Traduire',
              style: style(),
            ),
          ),
          if (widget.idsend == iduser)
            ListTile(
              onTap: () {
                instance.collection("message").doc(widget.idmessage).delete();
                Navigator.of(context).pop();
              },
              leading: Icon(
                Icons.edit,
                color: color(),
              ),
              title: Text(
                'Supprimer',
                style: style(),
              ),
            )
        ],
      ),
    );
  }
}

class updatemessage extends StatefulWidget {
  updatemessage({Key? key, required this.idmessage, required this.message})
      : super(key: key);
  String idmessage;
  String message;
  @override
  _updatemessageState createState() => _updatemessageState();
}

class _updatemessageState extends State<updatemessage> {
  final updasms = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 5,
          ),
          Center(
            child: Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                  color: Colors.black.withBlue(30),
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            widget.message,
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: updasms,
                    decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        fillColor: Colors.white70,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        hintText: 'Message'),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(100)),
                  child: IconButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection("message")
                          .doc(widget.idmessage)
                          .update({"message": updasms.text});
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Iconsax.send1,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Translatemessage extends StatefulWidget {
  Translatemessage({Key? key, required this.message}) : super(key: key);
  String message;
  @override
  _TranslatemessageState createState() => _TranslatemessageState();
}

class _TranslatemessageState extends State<Translatemessage> {
  List langue = [
    {"lg": "Français", "code": "fr"},
    {"lg": "Anglais", "code": "en"},
    {"lg": "Russe", "code": "ru"},
    {"lg": "Espagnole", "code": "es"},
    {"lg": "Chinois", "code": "zh-cn"}
  ];
  final translator = GoogleTranslator();
  String selectedlangue = "";
  String texttranslate = "";
  bool load = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                  color: Colors.black.withBlue(30),
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(widget.message,
              style: const TextStyle(color: Colors.black, fontSize: 18)),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
                itemCount: langue.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: ActionChip(
                        padding: const EdgeInsets.all(10),
                        backgroundColor:
                            (selectedlangue == langue[index]["code"])
                                ? Colors.blueAccent
                                : Colors.green,
                        onPressed: () async {
                          setState(() {
                            selectedlangue = langue[index]["code"];
                            load = true;
                          });
                          var translation = await translator.translate(
                              widget.message,
                              to: langue[index]["code"]);

                          setState(() {
                            texttranslate = translation.toString();
                            load = false;
                          });
                        },
                        label: Text(
                          langue[index]["lg"],
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        )),
                  );
                }),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Traduction',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          if (load)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (!load)
            Text(
              texttranslate,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )
        ],
      ),
    );
  }
}

class Translatesmssend extends StatefulWidget {
  Translatesmssend({Key? key, required this.message}) : super(key: key);
  String message;
  @override
  _TranslatesmssendState createState() => _TranslatesmssendState();
}

class _TranslatesmssendState extends State<Translatesmssend> {
  List langue = [
    {"lg": "Français", "code": "fr"},
    {"lg": "Anglais", "code": "en"},
    {"lg": "Russe", "code": "ru"},
    {"lg": "Espagnole", "code": "es"},
    {"lg": "Chinois", "code": "zh-cn"}
  ];
  final translator = GoogleTranslator();
  String selectedlangue = "";
  String texttranslate = "";
  bool load = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                  color: Colors.black.withBlue(30),
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(widget.message,
              style: const TextStyle(color: Colors.black, fontSize: 18)),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
                itemCount: langue.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: ActionChip(
                        padding: const EdgeInsets.all(10),
                        backgroundColor:
                            (selectedlangue == langue[index]["code"])
                                ? Colors.blueAccent
                                : Colors.green,
                        onPressed: () async {
                          setState(() {
                            selectedlangue = langue[index]["code"];
                            load = true;
                          });
                          var translation = await translator.translate(
                              widget.message,
                              to: langue[index]["code"]);

                          setState(() {
                            texttranslate = translation.toString();
                            load = false;
                          });
                        },
                        label: Text(
                          langue[index]["lg"],
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        )),
                  );
                }),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Traduction',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          if (load)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (!load)
            Text(
              texttranslate,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: CircleAvatar(
              radius: 30,
              child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Iconsax.send1,
                    size: 30,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
