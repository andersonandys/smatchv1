import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:iconsax/iconsax.dart';

class Menuwidget extends StatelessWidget {
  const Menuwidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => IconButton(
      onPressed: () => ZoomDrawer.of(context)!.toggle(),
      icon: const Icon(
        Icons.menu,
        color: Colors.white,
        size: 30,
      ));
}
