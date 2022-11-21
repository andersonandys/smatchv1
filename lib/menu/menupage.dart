import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:smatch/menu/menuitem.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

class Menupage extends StatefulWidget {
  final Menuitem currentItem;
  final ValueChanged<Menuitem> onselectedItem;
  const Menupage(
      {Key? key, required this.currentItem, required this.onselectedItem})
      : super(key: key);

  @override
  State<Menupage> createState() => _MenupageState();
}

class _MenupageState extends State<Menupage> {
  String nomuser = "";
  String avataruser = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getinfouser();
  }

  getinfouser() {
    print(FirebaseAuth.instance.currentUser!.uid);
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        nomuser = querySnapshot.docs.first['nom'];
        avataruser = querySnapshot.docs.first['avatar'];
      });
      print('object');
    });
  }

  @override
  Widget build(BuildContext context) => Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        backgroundColor: const Color(0xFF101418),
        body: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage(avataruser),
                  radius: 35,
                ),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                    child: Text(
                  nomuser,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ))
              ],
            ),
            // Text("0769301934"),
            const SizedBox(
              height: 30,
            ),
            ...MenuItems.all.map(builMenuItem).toList(),
            const SizedBox(
              height: 10,
            ),

            const SizedBox(
              height: 20,
            ),

            Expanded(
                child: Container(
                    child: ListView(
              reverse: true,
              shrinkWrap: true,
              children: const [
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Center(
                    child: Text(
                      "Copyrigth by AMJ Group",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                )
              ],
            )))
          ],
        )),
      ));
  builMenuItem(Menuitem item) => ListTileTheme(
      selectedColor: Colors.white,
      child: ListTile(
        selectedTileColor: Colors.black26,
        selected: widget.currentItem == item,
        minLeadingWidth: 20,
        leading: Icon(
          item.icone,
          size: 25,
        ),
        title: Text(
          item.title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            // color: Color(0xff3A4276),
            fontWeight: FontWeight.w700,
          ),
        ),
        onTap: () => widget.onselectedItem(item),
      ));

  deconexion() {
    print("object");
    Get.defaultDialog(
        onConfirm: () async {
          // await FirebaseAuth.instance
          //     .signOut()
          //     .then((value) => Get.to(() => ContinueWithPhone()));
        },
        onCancel: () {},
        title: "Confirmation",
        textCancel: "Annuler",
        textConfirm: "Oui me déconnecter",
        confirmTextColor: Colors.white,
        middleText: "Voulez vous être déconnecté ?");
  }
}

class MenuItems {
  static const home = Menuitem('Home', Iconsax.home);
  static const djolo = Menuitem('Djolo (NFT)', Ionicons.construct_outline);
  static const discovery = Menuitem(
    'Discovery',
    IconlyLight.discovery,
  );
  static const noeud = Menuitem('Mes Noeuds', Ionicons.git_merge_outline);
  static const boutique =
      Menuitem("Mes boutiques", Ionicons.storefront_outline);
  static const space = Menuitem("Mes Spaces", FontAwesomeIcons.clapperboard);
  static const spacebusiness = Menuitem('Business', Ionicons.business_outline);
  static const wallet = Menuitem(
    'Wallet',
    IconlyLight.wallet,
  );
  static const profil = Menuitem(
    'Profil',
    Iconsax.profile_circle,
  );
  static const all = <Menuitem>[
    home,
    discovery,
    djolo,
    noeud,
    boutique,
    space,
    spacebusiness,
    wallet,
    profil
  ];
}
