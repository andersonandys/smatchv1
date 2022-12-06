import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smatch/home/tabsrequette.dart';
import 'package:smatch/msgbranche/requmessage.dart';
import 'package:translator/translator.dart';

class Options extends StatefulWidget {
  Options(
      {Key? key,
      required this.idsend,
      required this.typemessage,
      required this.message,
      required this.urlfile,
      required this.idmessage})
      : super(key: key);
  String urlfile;

  String typemessage;

  String message;

  String idmessage;

  String idsend;
  @override
  _OptionsState createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  final mscontrol = Get.put(Requmessage());
  final requ = Get.put(Tabsrequette());
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black.withBlue(20),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          Container(
            height: 5,
            width: 100,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(100))),
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            onTap: () {
              mscontrol.messagereponse.value = widget.message;
              mscontrol.typereponse.value = widget.typemessage;
              mscontrol.urlreponse.value = widget.urlfile;
              mscontrol.idmessagedelete.value = widget.idmessage;
              mscontrol.nomreponse.value = widget.idsend;
              Navigator.of(context).pop();
            },
            leading: const CircleAvatar(
              child: Icon(Icons.reply, size: 30),
            ),
            title: const Text(
              'Repondre',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          if (widget.message.isNotEmpty)
            ListTile(
              onTap: () {
                Navigator.of(context).pop();
                Get.bottomSheet(SingleChildScrollView(
                  child: Transaltemessage(
                    message: widget.message,
                  ),
                ));
              },
              leading: const CircleAvatar(
                child: Icon(Icons.translate_rounded, size: 30),
              ),
              title: const Text(
                'Traduire',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          if (widget.message.isNotEmpty)
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
              leading: const CircleAvatar(
                child: Icon(Icons.edit, size: 30),
              ),
              title: const Text(
                'Modifier',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          if (widget.message.isNotEmpty)
            ListTile(
              onTap: () {
                FlutterClipboard.copy(widget.message).then((value) {
                  requ.message("success", "Message copié");
                });
                Navigator.of(context).pop();
              },
              leading: const CircleAvatar(
                child: Icon(Icons.copy_rounded, size: 30),
              ),
              title: const Text(
                'Copier',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          if (widget.idsend == FirebaseAuth.instance.currentUser!.uid)
            ListTile(
              onTap: () {
                FirebaseFirestore.instance
                    .collection('message')
                    .doc(widget.idmessage);
                Navigator.of(context).pop();
              },
              leading: const CircleAvatar(
                child: Icon(Icons.delete, size: 30),
              ),
              title: const Text(
                'Supprimer',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            )
        ],
      ),
    );
  }
}

class Transaltemessage extends StatefulWidget {
  Transaltemessage({Key? key, required this.message}) : super(key: key);
  String message;
  @override
  _TransaltemessageState createState() => _TransaltemessageState();
}

class _TransaltemessageState extends State<Transaltemessage> {
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.black.withBlue(20),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
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
                    borderRadius: BorderRadius.all(Radius.circular(100))),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            widget.message,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            (transaltetitle.isEmpty) ? "Traduction" : transaltetitle,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(
            height: 20,
          ),
          if (lange && translatemessage.isNotEmpty)
            Text(
              translatemessage,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          if (lange && translatemessage.isEmpty)
            const Center(
              child: CircularProgressIndicator(),
            ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
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
                      var translation =
                          await translator.translate(widget.message, to: 'en');
                      var translation1 =
                          await translator.translate("Traduction", to: 'en');
                      print(translation.text);
                      setState(() {
                        translatemessage = translation.text.toString();
                        transaltetitle = translation1.text.toString();
                      });
                    }
                    if (value == "Français") {
                      var translation =
                          await translator.translate(widget.message, to: 'fr');
                      var translation1 =
                          await translator.translate("Traduction", to: 'fr');
                      print(translation.text);
                      setState(() {
                        translatemessage = translation.text.toString();
                        transaltetitle = translation1.text.toString();
                      });
                    }
                    if (value == "Espagnole") {
                      var translation =
                          await translator.translate(widget.message, to: 'es');
                      var translation1 =
                          await translator.translate("Traduction", to: 'es');
                      print(translation.text);
                      setState(() {
                        translatemessage = translation.text.toString();
                        transaltetitle = translation1.text.toString();
                      });
                    }
                    if (value == "Russe") {
                      var translation =
                          await translator.translate(widget.message, to: 'ru');
                      var translation1 =
                          await translator.translate("Traduction", to: 'ru');
                      print(translation.text);
                      setState(() {
                        translatemessage = translation.text.toString();
                        transaltetitle = translation1.text.toString();
                      });
                    }
                    if (value == "Italien") {
                      var translation =
                          await translator.translate(widget.message, to: 'it');
                      var translation1 =
                          await translator.translate("Traduction", to: 'it');
                      print(translation.text);
                      setState(() {
                        translatemessage = translation.text.toString();
                        transaltetitle = translation1.text.toString();
                      });
                    }
                    if (value == "Chinois") {
                      var translation = await translator
                          .translate(widget.message, to: 'zh-cn');
                      var translation1 =
                          await translator.translate("Traduction", to: 'zh-cn');
                      print(translation.text);
                      setState(() {
                        translatemessage = translation.text.toString();
                        transaltetitle = translation1.text.toString();
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
                  buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                  buttonDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.black26,
                    ),
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class updatemessage extends StatefulWidget {
  updatemessage({Key? key, required this.message, required this.idmessage})
      : super(key: key);
  String message;
  String idmessage;
  @override
  _updatemessageState createState() => _updatemessageState();
}

class _updatemessageState extends State<updatemessage> {
  final modifmessageController = TextEditingController();
  final mscontrol = Get.put(Tabsrequette());
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.black.withBlue(20),
          borderRadius: const BorderRadius.all(Radius.circular(7))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 20,
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
                    borderRadius: BorderRadius.all(Radius.circular(100))),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Modification de votre message',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            widget.message,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            style: const TextStyle(color: Colors.white),
            controller: modifmessageController,
            decoration: InputDecoration(
              fillColor: Colors.white.withOpacity(0.2),
              filled: true,
              labelStyle: const TextStyle(color: Colors.white),
              label: const Text("votre message"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ActionChip(
              onPressed: () {
                if (modifmessageController.text.isEmpty) {
                  mscontrol.message(
                      "Echec", "Nous vous prions de saisir un message");
                } else {
                  FirebaseFirestore.instance
                      .collection("message")
                      .doc(widget.idmessage)
                      .update({"message": modifmessageController.text});
                  mscontrol.message(
                      'Success', "Votre message a été modifié avec succès");
                  Navigator.of(context).pop();
                }
              },
              backgroundColor: Colors.orange.shade900,
              label: const Text(
                'Envoyer',
                style: TextStyle(color: Colors.white),
              ),
              padding: const EdgeInsets.all(10),
            ),
          )
        ],
      ),
    );
  }
}
