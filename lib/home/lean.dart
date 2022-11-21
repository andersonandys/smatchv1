import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Lean extends StatefulWidget {
  const Lean({Key? key}) : super(key: key);

  @override
  _LeanState createState() => _LeanState();
}

class _LeanState extends State<Lean> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.black.withBlue(25),
        appBar: AppBar(
          backgroundColor: Colors.black.withBlue(25),
          title: const Text(
            'Smatch',
            style: TextStyle(fontSize: 30),
          ),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
                child: Container(
                    padding: EdgeInsets.all(5),
                    height: screenheight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Colors.blue.shade800,
                          Colors.orange.shade900,
                        ],
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const <Widget>[
                            Text(
                              'Techscrun Game',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            Icon(Icons.add, color: Colors.white)
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(7),
                              ),
                              color: Colors.white.withOpacity(0.2)),
                          height: 100,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(7),
                              ),
                              color: Colors.white.withOpacity(0.5)),
                          height: 100,
                        ),
                      ],
                    ))),
            Container(
              padding: EdgeInsets.all(5),
              child: Row(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const CircleAvatar(
                          backgroundColor: Colors.white, radius: 30),
                      const SizedBox(
                        height: 5,
                      ),
                      const CircleAvatar(
                          backgroundColor: Colors.white, radius: 30),
                      const SizedBox(
                        height: 5,
                      ),
                      const CircleAvatar(
                          backgroundColor: Colors.white, radius: 30),
                      const SizedBox(
                        height: 5,
                      ),
                      DottedBorder(
                        color: Colors.greenAccent,
                        dashPattern: [4, 3],
                        strokeWidth: 2,
                        strokeCap: StrokeCap.round,
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(50),
                        child: Container(
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              ),
                              color: Colors.white),
                          height: 50,
                          width: 50,
                          child: const Icon(
                            Iconsax.add,
                            size: 30,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ));
  }
}
