import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';

import 'package:smatch/business/dash/dashvlog/allvideo.dart';
import 'package:smatch/business/dash/dashvlog/dashvlog.dart';
import 'package:smatch/business/dash/dashvlog/reglagevlog.dart';

class Tabsvlog extends StatefulWidget {
  const Tabsvlog({Key? key}) : super(key: key);

  @override
  _TabsvlogState createState() => _TabsvlogState();
}

class _TabsvlogState extends State<Tabsvlog> {
  String idchaine = Get.arguments[0]["idchaine"];
  final _pages = [
    Dashvlog(),
    Allvideo(),
    Settingsvlog(),
  ];
  var _currentIndex = 0;
  // final creat = Get.put(CreatNoeud());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: SalomonBottomBar(
        // margin: const EdgeInsets.only(bottom: 10),
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: const Icon(IconlyLight.activity, size: 28),
            title: const Text(
              "Activité",
              style: TextStyle(fontSize: 15),
            ),
            selectedColor: Colors.black.withBlue(25),
          ),

          /// toutes les videos
          SalomonBottomBarItem(
            icon: const Icon(Icons.list_sharp, size: 28),
            title: const Text("Publication", style: TextStyle(fontSize: 15)),
            selectedColor: Colors.black.withBlue(25),
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: const Icon(IconlyLight.setting, size: 28),
            title: const Text(
              "Paramèttre",
              style: TextStyle(fontSize: 15),
            ),
            selectedColor: Colors.black.withBlue(25),
          ),
        ],
      ),
    );
  }
}
