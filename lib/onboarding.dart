import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:get/get.dart';
import 'package:smatch/business/vlog/pages/home_page.dart';
import 'package:smatch/login/login.dart';
import 'package:smatch/loginpage.dart';

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializesplash();
  }

  initializesplash() async {
    await Future.delayed(const Duration(seconds: 5))
        .then((value) => FlutterNativeSplash.remove());
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Container(
        padding: const EdgeInsets.only(right: 10),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Bienvenue sur Smatch',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      // color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  // Image.asset('assets/logo.png'),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Messagerie, E-commerce, websérie, Retrouver toutes ses fonctions en une application. Permettez à Smatch de vous transporter dans une aventure sans précédent.",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Container(
        color: Colors.black.withBlue(25),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Image.asset('assets/marketing2.png'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Noeud',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Vous avez toujours rêvé d'avoir un group dont vous pouvez la structurer par des sous-groupes facilement, tout en pouvant la rendre publique ou prive, gratuit ou payant ? Alors découvrez la fonction Nœud et les branches, donnent vie à vos rêves en un simple geste.",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Container(
        color: Color(0xFF17181D),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 100, left: 10, right: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Vous êtes prêt pour l'aventure ?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 25,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Que vous soyez un créateur de contenu, e-commerçant, ou que vous aspirez à une discussion ou une vente organisée avec vos proches ou fans SMATCH est fait pour vous.",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            )),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.orange.shade900,
                  fixedSize: const Size(300, 60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))),
              onPressed: () {
                Get.off(() => Login());
              },
              child: const Text(
                "Commençons l'aventure",
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    ];
    return Scaffold(
      body: LiquidSwipe(
        pages: pages,
        positionSlideIcon: 0.1,
        enableSideReveal: true,
        waveType: WaveType.circularReveal,
        slideIconWidget: const Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
