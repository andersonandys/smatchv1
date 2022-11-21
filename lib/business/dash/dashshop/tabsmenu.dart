import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:smatch/business/dash/dashshop/commandeshop.dart';
import 'package:smatch/business/dash/dashshop/dashshop.dart';
import 'package:smatch/business/dash/dashshop/produitshop.dart';
import 'package:smatch/business/dash/dashshop/publicationshop.dart';
import 'package:smatch/business/dash/dashshop/settingsshop.dart';

class Tabsmenushop extends StatefulWidget {
  const Tabsmenushop({Key? key}) : super(key: key);

  @override
  _TabsmenushopState createState() => _TabsmenushopState();
}

class _TabsmenushopState extends State<Tabsmenushop> {
  final Stream<QuerySnapshot> newscomande = FirebaseFirestore.instance
      .collection('noeud')
      .where("idcompte", isEqualTo: Get.arguments[0]["idshop"])
      .snapshots();
  String idshop = Get.arguments[0]["idshop"];
  final _pages = [
    const Dashshop(),
    Produitshop(),
    const Commandeshop(),
    Settingsshop()
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
        onTap: (i) {
          setState(() => _currentIndex = i);
          print(i);
          if (i == 2) {
            FirebaseFirestore.instance
                .collection('noeud')
                .doc(idshop)
                .update({"newcommande": 0});
          }
        },
        items: [
          /// Home
          SalomonBottomBarItem(
              icon: const Icon(IconlyLight.activity, size: 28),
              title: const Text(
                "Activité",
                style: TextStyle(),
              ),
              selectedColor: Colors.black.withBlue(25)),

          /// Likes
          SalomonBottomBarItem(
            icon: const Icon(Iconsax.shopping_bag, size: 28),
            title: const Text("Produit", style: TextStyle()),
            selectedColor: Colors.black.withBlue(25),
          ),

          /// Search
          SalomonBottomBarItem(
            icon: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('noeud')
                  .where("idcompte", isEqualTo: idshop)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> newcommande) {
                if (!newcommande.hasData) {
                  return const Icon(
                    IconlyLight.buy,
                    size: 28,
                  );
                }
                if (newcommande.connectionState == ConnectionState.waiting) {
                  return const Icon(
                    IconlyLight.buy,
                    size: 28,
                  );
                }

                return (newcommande.data!.docs.first['newcommande'] != 0)
                    ? Badge(
                        child: const Icon(IconlyLight.buy, size: 28),
                      )
                    : const Icon(
                        IconlyLight.buy,
                        size: 28,
                      );
              },
            ),
            title: const Text(
              "Commande",
              style: TextStyle(),
            ),
            selectedColor: Colors.black.withBlue(25),
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: const Icon(IconlyLight.setting, size: 28),
            title: const Text(
              "Paramètre",
              style: TextStyle(),
            ),
            selectedColor: Colors.black.withBlue(25),
          ),
        ],
      ),
    );
  }
}
