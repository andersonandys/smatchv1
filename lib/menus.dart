import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:smatch/business/creatbusiness.dart';
import 'package:smatch/home/home.dart';
import 'package:smatch/space/module.dart';
import 'package:smatch/noeud/noeud.dart';
import 'package:smatch/wallet/walletuser.dart';
import 'discovery/discovery.dart';
import 'settings/settingsProfil.dart';

class menus {
  final vu = Get.put(home());
  Widget allmenu() {
    return Container(
      padding: const EdgeInsets.only(top: 120),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
        color: Colors.black.withBlue(30),
      ),
      child: ListTileTheme(
        textColor: Colors.white,
        iconColor: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              onTap: () {
                Get.to(() => home());
              },
              leading: const Icon(IconlyLight.home, size: 30),
              title: Text(
                'Home',
                style: GoogleFonts.poppins(fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {
                Get.to(() => HomeDicovery());
              },
              leading: const Icon(IconlyLight.discovery, size: 30),
              title: Text(
                'Discovery',
                style: GoogleFonts.poppins(fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {
                Get.to(() => Mynoeud());
              },
              leading: const Icon(
                Icons.favorite,
                size: 30,
              ),
              title: Text(
                'Noeud',
                style: GoogleFonts.poppins(fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {
                Get.to(() => Mymodule());
              },
              leading: const Icon(
                Icons.bubble_chart,
                size: 30,
              ),
              title: Text(
                'Space',
                style: GoogleFonts.poppins(fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {
                Get.to(() => Creatbusi());
              },
              leading: const Icon(
                Icons.business_rounded,
                size: 30,
              ),
              title: Text(
                'Space Business',
                style: GoogleFonts.poppins(fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {
                Get.to(() => Walletuser());
              },
              leading: const Icon(
                IconlyLight.wallet,
                size: 30,
              ),
              title: Text(
                'Wallet',
                style: GoogleFonts.poppins(fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {
                Get.to(() => SettingsProfil());
              },
              leading: const Icon(
                Iconsax.profile_circle,
                size: 30,
              ),
              title: Text(
                'Profil',
                style: GoogleFonts.poppins(fontSize: 20),
              ),
            ),
            Expanded(
                child: Container(
              height: 40,
              width: 400,
              child: ListView(
                reverse: true,
                shrinkWrap: true,
                children: const [
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text('From Amg group',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
