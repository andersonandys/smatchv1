import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:smatch/business/shop/2/activite2.dart';
import 'package:smatch/business/shop/2/home2.dart';
import 'package:smatch/business/shop/2/panier2.dart';

class Tabsmenu2shop extends StatefulWidget {
  const Tabsmenu2shop({Key? key}) : super(key: key);

  @override
  _Tabsmenu2shopState createState() => _Tabsmenu2shopState();
}

class _Tabsmenu2shopState extends State<Tabsmenu2shop> {
  String idshop = Get.arguments[0]["idshop"];
  String nomshop = Get.arguments[1]["nomshop"];
  final _pages = [
    Home2shop(),
    Panier2shop(),
    Activite2shop(),
  ];
  var _currentIndex = 0;
  // final creat = Get.put(CreatNoeud());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: const Icon(Iconsax.home, size: 28),
            title: Text(
              "Home",
              style: GoogleFonts.poppins(),
            ),
            selectedColor: Colors.black.withBlue(25),
          ),

          /// Search
          SalomonBottomBarItem(
            icon: const Icon(Iconsax.shopping_bag, size: 28),
            title: Text(
              "Panier",
              style: GoogleFonts.poppins(),
            ),
            selectedColor: Colors.black.withBlue(25),
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: const Icon(Iconsax.activity, size: 28),
            title: Text(
              "Commande",
              style: GoogleFonts.poppins(),
            ),
            selectedColor: Colors.black.withBlue(25),
          ),
        ],
      ),
    );
  }
}
