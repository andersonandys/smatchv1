import 'package:flutter/material.dart';

class Homeclub extends StatefulWidget {
  const Homeclub({Key? key}) : super(key: key);

  @override
  _HomeclubState createState() => _HomeclubState();
}

class _HomeclubState extends State<Homeclub> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(30),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(30),
        centerTitle: true,
        title: const Text(
          'Club',
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
