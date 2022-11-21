import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final mailcontroller = TextEditingController();
    final mdpcontroller = TextEditingController();
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: DrawClip2(),
                  child: Container(
                    width: size.width,
                    height: size.height * 0.8,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xffa58fd2), Color(0xffddc3fc)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.bottomRight)),
                  ),
                ),
                ClipPath(
                  clipper: DrawClip(),
                  child: Container(
                    width: size.width,
                    height: size.height * 0.8,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xffddc3fc), Color(0xff91c5fc)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          backgroundImage:
                              const AssetImage('assets/logoapp.png')),
                      const SizedBox(
                        height: 10,
                      ),
                      FadeInUp(
                          duration: const Duration(microseconds: 1400),
                          delay: const Duration(milliseconds: 300),
                          child: Text(
                            'AKWABA,',
                            style: GoogleFonts.ubuntu(
                                color: Colors.white,
                                fontSize: 35,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )),
                      Text(
                        "Content de te revoir.",
                        style: GoogleFonts.ubuntu(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //input textfields
                      mail("Username", false),
                      mdp("Password", true),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                          onTap: null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 40),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: const Color(0xff6a74ce),
                                  borderRadius: BorderRadius.circular(30)),
                              height: 50,
                              child: Center(
                                child: Text(
                                  "Connexion",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          )),
                      Text(
                        "Mot de passe oublié ?",
                        style: GoogleFonts.ubuntu(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                )
              ],
            ),
            Text(
              "Ou connectez-vous avec",
              style: GoogleFonts.ubuntu(
                  color: Colors.blueGrey, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.black.withBlue(50),
                    ),
                    height: 40,
                    width: 160,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // Image.asset(
                          //   "assets/facebook.png",
                          //   color: Colors.white,
                          // ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Facebook",
                            style: GoogleFonts.ubuntu(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.black.withBlue(50),
                    ),
                    height: 40,
                    width: 160,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // Image.asset(
                          //   "assets/twitter.png",
                          //   color: Colors.white,
                          // ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Google",
                            style: GoogleFonts.ubuntu(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Vous n'avez pas de compte ?",
                  style: GoogleFonts.ubuntu(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text("creer un compte",
                      style: GoogleFonts.ubuntu(
                        color: const Color(0xff5172b4),
                        fontWeight: FontWeight.bold,
                      )),
                )
              ],
            )
          ],
        ),
      ),
    ));
  }

  Widget mail(String hint, bool pass) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30), color: Colors.white),
        child: TextFormField(
          decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.ubuntu(color: Colors.grey),
              contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
              prefixIcon: pass
                  ? const Icon(
                      Icons.lock_outline,
                      color: Colors.grey,
                    )
                  : const Icon(
                      Icons.person_outline,
                      color: Colors.grey,
                    ),
              suffixIcon: pass
                  ? null
                  : const Icon(Icons.assignment_turned_in_rounded,
                      color: Colors.greenAccent),
              border: const UnderlineInputBorder(borderSide: BorderSide.none)),
        ),
      ),
    );
  }
}

Widget mdp(String hint, bool pass) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30), color: Colors.white),
      child: TextFormField(
        decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.ubuntu(color: Colors.grey),
            contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
            prefixIcon: pass
                ? const Icon(
                    Icons.lock_outline,
                    color: Colors.grey,
                  )
                : const Icon(
                    Icons.person_outline,
                    color: Colors.grey,
                  ),
            suffixIcon: pass
                ? null
                : const Icon(Icons.assignment_turned_in_rounded,
                    color: Colors.greenAccent),
            border: const UnderlineInputBorder(borderSide: BorderSide.none)),
      ),
    ),
  );
}

class DrawClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.80);
    path.cubicTo(size.width / 4, size.height, 3 * size.width / 4,
        size.height / 2, size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class DrawClip2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.80);
    path.cubicTo(size.width / 4, size.height, 3 * size.width / 4,
        size.height / 2, size.width, size.height * 0.9);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
