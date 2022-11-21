import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:smatch/business/shop/1/activite.dart';
import 'package:smatch/business/shop/1/favoris1.dart';
import 'package:smatch/business/shop/1/home1.dart';
import 'package:smatch/business/shop/1/panier1.dart';

class Tabsmenu1shop extends StatefulWidget {
  const Tabsmenu1shop({Key? key}) : super(key: key);

  @override
  _Tabsmenu1shopState createState() => _Tabsmenu1shopState();
}

class _Tabsmenu1shopState extends State<Tabsmenu1shop> {
  String idshop = Get.arguments[0]["idshop"];
  final _pages = [home1shop(), Favoris1shop(), Panier1shop(), Activite1shop()];
  var _currentIndex = 0;
  // final creat = Get.put(CreatNoeud());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: SalomonBottomBar(
        margin: const EdgeInsets.only(bottom: 10),
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: const Icon(IconlyLight.home, size: 28),
            title: Text(
              "Home",
              style: GoogleFonts.poppins(),
            ),
            selectedColor: Colors.black.withBlue(25),
          ),

          /// Likes
          SalomonBottomBarItem(
            icon: const Icon(
              Iconsax.heart,
              size: 28,
            ),
            title: Text("Favoris", style: GoogleFonts.poppins()),
            selectedColor: Colors.black.withBlue(25),
          ),

          /// Search
          SalomonBottomBarItem(
            icon: const Icon(IconlyLight.buy, size: 28),
            title: Text(
              "Panier",
              style: GoogleFonts.poppins(),
            ),
            selectedColor: Colors.black.withBlue(25),
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: const Icon(IconlyLight.activity, size: 28),
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
