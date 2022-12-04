import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_pin_screen/custom_pin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:smatch/login/login.dart';
import 'package:smatch/wallet/crypto/bottom_nav.dart';
import 'package:tezster_dart/tezster_dart.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text("Wallet App")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff131B63),
              Color(0xff481162),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/nft/crypto.json'),
            const SizedBox(
              height: 90,
            ),
            Text(
              "Smatch Connect",
              style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 12),
              child: Text(
                "Créer, connecter votre compte en toute simplicité et profiter d'une fluidité de transaction et de gestion de compte.",
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PinAuthentication(
                      action: "Creation de code",
                      actionDescription:
                          "Enregistrer un mot de passe pour continuer",
                      pinTheme: PinTheme(
                        textColor: Colors.white,
                        inactiveFillColor: Colors.white.withOpacity(0.3),
                        inactiveColor: Colors.white.withOpacity(0.3),
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(5),
                        backgroundColor: Colors.black.withBlue(20),
                        keysColor: Colors.white,
                        activeFillColor:
                            const Color(0xFFF7F8FF).withOpacity(0.13),
                      ),
                      onChanged: (v) {
                        if (kDebugMode) {
                          print(v);
                        }
                      },
                      onCompleted: (v) {
                        Get.to(() => Generatephrase());
                        if (kDebugMode) {
                          print('completed: $v');
                        }
                      },
                      maxLength: 5,
                      onSpecialKeyTap: () {
                        if (kDebugMode) {
                          print('fingerprints');
                        }
                      },
                      // specialKey: const SizedBox(),
                      useFingerprint: true,
                    ),
                  ),
                );
              },
              child: Container(
                height: 80,
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(48),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: [
                      Color.fromARGB(255, 230, 174, 174),
                      Color(0xffA03E82),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 64,
                      width: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xff8462E1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_outlined,
                          size: 40, color: Colors.white),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Text(
                      "Commencer",
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Generatephrase extends StatefulWidget {
  const Generatephrase({Key? key}) : super(key: key);

  @override
  _GeneratephraseState createState() => _GeneratephraseState();
}

class _GeneratephraseState extends State<Generatephrase> {
  late List phrase = [];

  int _currentIndex = 0;
  String mnemonique = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getmnemonique();
  }

  getmnemonique() {
    final mnemonic = TezsterDart.generateMnemonic();
    mnemonique = mnemonic;
    phrase = mnemonic.split(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(20),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(20),
        title: const Text('Phrase mnemonique'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Nous vous prions de recopier votre phrase mnémonique dans un lieu important. \n \n Nous ne sommes pas responsable de la sauvegarde de vos phrases. \n \n Smatch ne garde pas une copie de vos mots alors nous ne pourrons pas vous les restituer.',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              const Text(
                'Pharse mnemonique',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 24,
                children: phrase.map(
                  (category) {
                    return Chip(
                      padding: const EdgeInsets.all(10),
                      label: Text(category),
                    );
                  },
                ).toList(),
              ),
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      fixedSize: Size(MediaQuery.of(context).size.width, 70),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    onPressed: () async {
                      // print(mnemonique);
                      List<String> keys = await TezsterDart.getKeysFromMnemonic(
                          mnemonic: mnemonique);
                      print(keys);
                      // List<String> identityWithMnemonic =
                      //     await TezsterDart.getKeysFromMnemonicAndPassphrase(
                      //         mnemonic: mnemonique, passphrase: "passw0rd");
                      // List<String> identityFundraiser =
                      //     await TezsterDart.unlockFundraiserIdentity(
                      //         mnemonic: "your mnemonic",
                      //         email: "test@example.com",
                      //         passphrase: "passw0rd");
                      // String balance = await TezsterDart.getBalance('tz1c....ozGGs', 'your rpc server');
                      // print(identityFundraiser);

                      // FirebaseFirestore.instance
                      //     .collection("users")
                      //     .doc(FirebaseAuth.instance.currentUser!.uid)
                      //     .update({
                      //   "phrase": mnemonique,
                      //   "crypto": true,
                      //   "adresstez": keystore.address,
                      //   "secretkey": keystore.secretKey,
                      //   "publickey": keystore.publicKey
                      // });
                      Get.to(() => BottomNav());
                    },
                    child: const Text(
                      'Terminer',
                      style: TextStyle(fontSize: 20),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
