import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:get/get.dart';
import 'package:smatch/business/vlog/pages/home_page.dart';
import 'package:smatch/login/login.dart';
import 'package:smatch/loginpage.dart';
import 'package:concentric_transition/concentric_transition.dart';

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

final pages = [
  const PageData(
      icon: Icons.bubble_chart,
      title: "Smatch noeud",
      bgColor: Color(0xFF0043D0),
      textColor: Colors.white,
      subtitle:
          "Créer votre nœud, organiser la avec les branches. Rendez-vous la vie simple."),
  const PageData(
      icon: Icons.format_size,
      title: "Smatch webserie",
      textColor: Colors.white,
      bgColor: Color(0xFFFDBFDD),
      subtitle: ""),
  const PageData(
      icon: Icons.hdr_weak,
      title: "Drag and\ndrop to move",
      bgColor: Color(0xFFFFFFFF),
      subtitle: ""),
];

class OnboardingExample extends StatefulWidget {
  const OnboardingExample({Key? key}) : super(key: key);

  @override
  _OnboardingExampleState createState() => _OnboardingExampleState();
}

class _OnboardingExampleState extends State<OnboardingExample> {
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: ConcentricPageView(
        colors: pages.map((p) => p.bgColor).toList(),
        radius: screenWidth * 0.1,
        curve: Curves.decelerate,
        onFinish: () {
          Get.to(() => Login());
        },
        onChange: (page) {
          print(page);
        },
        nextButtonBuilder: (context) => Padding(
          padding: const EdgeInsets.only(left: 3), // visual center
          child: Icon(
            Icons.navigate_next,
            size: screenWidth * 0.08,
          ),
        ),
        itemBuilder: (index) {
          final page = pages[index % pages.length];
          return SafeArea(
            child: _Page(page: page),
          );
        },
      ),
    );
  }
}

class PageData {
  final String? title;
  final String subtitle;
  final IconData? icon;
  final Color bgColor;
  final Color textColor;

  const PageData({
    this.title,
    required this.subtitle,
    this.icon,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
  });
}

class _Page extends StatelessWidget {
  final PageData page;

  const _Page({Key? key, required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    space(double p) => SizedBox(height: screenHeight * p / 100);
    return Column(
      children: [
        space(10),
        _Image(
          page: page,
          size: 190,
          iconSize: 170,
        ),
        space(8),
        _Text(
          page: page,
          style: TextStyle(
            fontSize: screenHeight * 0.046,
          ),
        ),
        space(5),
        Subtitle(
          page: page,
          style: TextStyle(
            fontSize: screenHeight * 0.03,
          ),
        )
      ],
    );
  }
}

class Subtitle extends StatelessWidget {
  const Subtitle({Key? key, required this.page, this.style}) : super(key: key);
  final PageData page;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    return Text(
      page.subtitle,
      style: TextStyle(
        color: page.textColor,
        // fontWeight: FontWeight.w600,
        fontFamily: 'Helvetica',
        letterSpacing: 0.0,
        fontSize: 15,
        height: 1.2,
      ).merge(style),
      textAlign: TextAlign.center,
    );
  }
}

class _Text extends StatelessWidget {
  const _Text({
    Key? key,
    required this.page,
    this.style,
  }) : super(key: key);

  final PageData page;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      page.title ?? '',
      style: TextStyle(
        color: page.textColor,
        fontWeight: FontWeight.w600,
        fontFamily: 'Helvetica',
        letterSpacing: 0.0,
        fontSize: 18,
        height: 1.2,
      ).merge(style),
      textAlign: TextAlign.center,
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({
    Key? key,
    required this.page,
    required this.size,
    required this.iconSize,
  }) : super(key: key);

  final PageData page;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final bgColor = page.bgColor
        // .withBlue(page.bgColor.blue - 40)
        .withGreen(page.bgColor.green + 20)
        .withRed(page.bgColor.red - 100)
        .withAlpha(90);

    final icon1Color =
        page.bgColor.withBlue(page.bgColor.blue - 10).withGreen(220);
    final icon2Color = page.bgColor.withGreen(66).withRed(77);
    final icon3Color = page.bgColor.withRed(111).withGreen(220);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(60.0)),
        color: bgColor,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: RotatedBox(
              quarterTurns: 2,
              child: Icon(
                page.icon,
                size: iconSize + 20,
                color: icon1Color,
              ),
            ),
            right: -5,
            bottom: -5,
          ),
          Positioned.fill(
            child: RotatedBox(
              quarterTurns: 5,
              child: Icon(
                page.icon,
                size: iconSize + 20,
                color: icon2Color,
              ),
            ),
          ),
          Icon(
            page.icon,
            size: iconSize,
            color: icon3Color,
          ),
        ],
      ),
    );
  }
}

class RouteExample extends StatefulWidget {
  const RouteExample({Key? key}) : super(key: key);

  @override
  _RouteExampleState createState() => _RouteExampleState();
}

class _RouteExampleState extends State<RouteExample> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Page1(),
    );
  }
}

class Page1 extends StatelessWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent,
      appBar: AppBar(title: Text("Page 1")),
      body: Center(
        child: MaterialButton(
          child: const Text("Next"),
          onPressed: () {
            Navigator.push(context, ConcentricPageRoute(builder: (ctx) {
              return const Page2();
            }));
          },
        ),
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
//      appBar: AppBar(title: Text("Page 2")),
      body: Center(
        child: MaterialButton(
          child: const Text("Back"),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
