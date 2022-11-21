import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:smatch/business/creatbusiness.dart';
import 'package:smatch/home/home.dart';
import 'package:smatch/space/module.dart';
import 'package:smatch/noeud/noeud.dart';

class menuvlog {
  Widget allmenu() {
    return Container(
      child: ListTileTheme(
        textColor: Colors.white,
        iconColor: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 24.0,
                bottom: 64.0,
              ),
              // child: CircleAvatar(
              //   radius: 60,
              //   backgroundImage: NetworkImage(avataruser),
              // )
            ),
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
              onTap: () {},
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
                Icons.settings,
                size: 30,
              ),
              title: Text(
                'Module',
                style: GoogleFonts.poppins(fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {
                Get.to(() => Creatbusi());
              },
              leading: const Icon(
                Icons.settings,
                size: 30,
              ),
              title: Text(
                'Business',
                style: GoogleFonts.poppins(fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(
                Icons.settings,
                size: 30,
              ),
              title: Text(
                'Papoter',
                style: GoogleFonts.poppins(fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.settings, size: 30),
              title: Text(
                'Nft',
                style: GoogleFonts.poppins(fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(
                IconlyLight.wallet,
                size: 30,
              ),
              title: Text(
                'Wallet',
                style: GoogleFonts.poppins(fontSize: 20),
              ),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(
                IconlyLight.setting,
                size: 30,
              ),
              title: Text(
                'Paramettre',
                style: GoogleFonts.poppins(fontSize: 20),
              ),
            ),
            const Spacer(),
            DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text('From Amg group',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                      )),
                )),
          ],
        ),
      ),
    );
  }
}
