import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smatch/nft/pages/viewnft.dart';

class NftCard extends StatelessWidget {
  final String imagePath;
  const NftCard({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            enableDrag: true,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0)),
            ),
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    height: MediaQuery.of(context).size.height / 1.3,
                    child: const Viewnft(),
                  );
                },
              );
            });
      },
      child: Padding(
          padding: const EdgeInsets.all(25),
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  height: 400,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Positioned(
                      bottom: 100,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withBlue(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(10),
                          height: 80,
                          width: MediaQuery.of(context).size.width / 1.2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  Text(
                                    'Lorem Ipsum is simply',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "Côte d'Ivoire",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  )
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  Text(
                                    '120 TZ',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '120 Up',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 16),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      )),
                )
              ],
            ),
          )),
    );
  }
}
