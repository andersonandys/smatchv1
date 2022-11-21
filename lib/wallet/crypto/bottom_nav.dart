import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smatch/wallet/crypto/home_screen.dart';
import 'package:smatch/wallet/crypto/homecrypto.dart';
import 'package:smatch/wallet/crypto/market.dart';
import 'package:smatch/wallet/crypto/swap.dart';

class BottomNav extends StatefulWidget {
  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  //const BottomNav({Key? key}) : super(key: key);
  final _bucket = PageStorageBucket();

  Widget currentScreen = Homecrypto();

  int indexScreen = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageStorage(
        bucket: _bucket,
        child: currentScreen,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        color: const Color(0xff261863),
        child: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          )),
          padding: const EdgeInsets.all(10),
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MaterialButton(
                onPressed: () {
                  setState(
                    () {
                      indexScreen = 0;
                      currentScreen = Homecrypto();
                    },
                  );
                },
                child: Column(
                  children: [
                    const Icon(Iconsax.home, color: Colors.white),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      "Home",
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 38,
              ),
              MaterialButton(
                onPressed: () {
                  setState(() {
                    indexScreen = 2;
                    currentScreen = Market();
                  });
                },
                child: Column(
                  children: [
                    const Image(
                      image: AssetImage("assets/crypto/market.png"),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      "Market",
                      style: GoogleFonts.lato(
                          textStyle: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.orange.shade900,
            borderRadius: BorderRadius.circular(38),
          ),
          child: const Icon(Icons.swap_horiz_outlined,
              size: 40, color: Colors.white),
        ),
      ),
    );
  }
}
