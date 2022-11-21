import 'package:flutter/material.dart';

class Stories extends StatefulWidget {
  const Stories({Key? key}) : super(key: key);

  @override
  _StoriesState createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          shrinkWrap: true,
          itemBuilder: (BuildContext, index) {
            return Stack(
              clipBehavior: Clip.none,
              alignment: AlignmentDirectional.topCenter,
              fit: StackFit.loose,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    height: 150,
                    width: 120,
                    decoration: const BoxDecoration(
                        color: Colors.amberAccent,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                ),
                const Positioned(
                  bottom: 1,
                  child: CircleAvatar(
                    radius: 30,
                  ),
                )
              ],
            );
          }),
    );
  }
}
