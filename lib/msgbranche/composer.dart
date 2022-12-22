import 'dart:ui';

import 'package:chat_composer/chat_composer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Composer extends StatefulWidget {
  const Composer({Key? key}) : super(key: key);

  @override
  _ComposerState createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  List<String> list = [];
  TextEditingController con = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Chat Composer'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, pos) {
                  return ListTile(title: Text(list[pos]));
                }),
          ),
          ChatComposer(
            deleteButtonColor: Colors.redAccent,
            recordIcon: Iconsax.microphone_2,
            sendButtonBackgroundColor: Colors.orange.shade900,
            textColor: Colors.white,
            textStyle: const TextStyle(color: Colors.white),
            composerColor: Colors.white.withOpacity(0),
            backgroundColor: Colors.black.withBlue(20),
            lockBackgroundColor: Colors.black.withBlue(20),
            onReceiveText: (str) {
              setState(() {
                list.add('TEXT : ${str!}');
                con.text = '';
              });
            },
            textFieldDecoration: const InputDecoration(
                fillColor: Colors.transparent,
                filled: true,
                border: InputBorder.none),
            controller: con,
            onRecordEnd: (path) {
              setState(() {
                list.add('AUDIO PATH : ${path!}');
              });
            },
            textPadding: EdgeInsets.zero,
            leading: null,
            actions: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(
                  Icons.attach_file_rounded,
                  size: 30,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
