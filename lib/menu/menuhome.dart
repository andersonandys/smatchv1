import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as users;
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:smatch/boutique/boutique.dart';
import 'package:smatch/business/creatbusiness.dart';
import 'package:smatch/discovery/discovery.dart';
import 'package:smatch/home/home.dart';
import 'package:smatch/home/tabsrequette.dart';
import 'package:smatch/menu/menuitem.dart';
import 'package:smatch/menu/menupage.dart';
import 'package:smatch/newuser.dart';
import 'package:smatch/nft/djolo.dart';
import 'package:smatch/nft/pages/home_page.dart';
import 'package:smatch/space/space.dart';
import 'package:smatch/noeud/noeud.dart';
import 'package:smatch/settings/settingsProfil.dart';
import 'package:smatch/wallet/walletuser.dart';

class Menuhome extends StatefulWidget {
  const Menuhome({Key? key}) : super(key: key);

  @override
  _MenuhomeState createState() => _MenuhomeState();
}

class _MenuhomeState extends State<Menuhome> {
  Menuitem currentItem = MenuItems.home;
  final requ = Get.put(Tabsrequette());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializesplash();
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser",
            isEqualTo: users.FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      print(querySnapshot.docs.first["addscompte"]);
      if (querySnapshot.docs.first["addscompte"] == 0) {
        Get.off(() => const Newuser());
      }
    });
  }

  initializesplash() async {
    await Future.delayed(const Duration(seconds: 5))
        .then((value) => FlutterNativeSplash.remove());
  }

  @override
  Widget build(BuildContext context) => ZoomDrawer(
      shadowLayer1Color: Colors.grey.shade400,
      shadowLayer2Color: Colors.grey.shade100,
      style: DrawerStyle.defaultStyle,
      borderRadius: 24.4,
      angle: -12,
      // slideWidth: MediaQuery.of(context).size.width * 0.5,
      showShadow: true,
      menuBackgroundColor: Color(0xFF101418),
      mainScreen: getscrenn(),
      drawerShadowsBackgroundColor: Colors.red,
      menuScreen: Builder(
        builder: (context) => Menupage(
            currentItem: currentItem,
            onselectedItem: (item) {
              setState(() {
                currentItem = item;
                ZoomDrawer.of(context)!.close();
              });
            }),
      ));

  Widget getscrenn() {
    switch (currentItem) {
      case MenuItems.home:
        return home();
      case MenuItems.discovery:
        return HomeDicovery();
      case MenuItems.djolo:
        return const Djolo();
      case MenuItems.noeud:
        return Mynoeud();
      case MenuItems.space:
        return Space();
      case MenuItems.boutique:
        return Mesboutiques();
      case MenuItems.spacebusiness:
        return Creatbusi();
      case MenuItems.wallet:
        return Walletuser();
      case MenuItems.profil:
        return const SettingsProfil();
      default:
        return home();
    }
  }
}
