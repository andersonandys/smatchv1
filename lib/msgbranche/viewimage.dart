import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:get/get.dart';

class Viewimage extends StatefulWidget {
  const Viewimage({Key? key}) : super(key: key);

  @override
  _ViewimageState createState() => _ViewimageState();
}

class _ViewimageState extends State<Viewimage> {
  final url = Get.arguments[0]['urlfile'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(20),
      ),
      body: Container(
          child: PhotoView(
        imageProvider: NetworkImage(url),
      )),
    );
  }
}
