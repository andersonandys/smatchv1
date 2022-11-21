import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget {
  final String title;
  VoidCallback onSearchTap;

  MyAppBar({
    Key? key,
    required this.onSearchTap,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 25, left: 25, bottom: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.bebasNeue(fontSize: 52, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
