import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smatch/homes/accontrols.dart';
import 'package:smatch/homes/noeud.dart';

class Acceui extends StatefulWidget {
  const Acceui({Key? key}) : super(key: key);

  @override
  _AcceuiState createState() => _AcceuiState();
}

class _AcceuiState extends State<Acceui> {
  final accontrol = Get.put(Accontols());
  final settings = RestrictedAmountPositions(
    maxAmountItems: 9,
    maxCoverage: 0.3,
    minCoverage: 0.1,
  );
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.all(0),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Container(
              padding: const EdgeInsets.only(left: 5, right: 5),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.blue.shade800,
                      Colors.orange.shade900,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Nom de la branche',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () {
                            optionsnoeud();
                          },
                          icon: const Icon(
                            Iconsax.more,
                            color: Colors.white,
                            size: 30,
                          ))
                    ],
                  ),
                  SizedBox(
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
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
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ActionChip(
                        onPressed: () {},
                        backgroundColor: Colors.black.withBlue(20),
                        disabledColor: Colors.black.withBlue(20),
                        padding: const EdgeInsets.all(10),
                        labelStyle: TextStyle(color: Colors.white),
                        label: const Text(
                          'Messages',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        avatar: const Icon(
                          Iconsax.message,
                          color: Colors.white,
                        ),
                      ),
                      ActionChip(
                        onPressed: () {},
                        backgroundColor: Colors.black.withBlue(20),
                        disabledColor: Colors.black.withBlue(20),
                        padding: const EdgeInsets.all(10),
                        labelStyle: const TextStyle(color: Colors.white),
                        label: const Text(
                          'Social',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        avatar: const Icon(
                          Iconsax.message,
                          color: Colors.white,
                        ),
                      ),
                      ActionChip(
                        onPressed: () {},
                        backgroundColor: Colors.black.withBlue(20),
                        disabledColor: Colors.black.withBlue(20),
                        padding: const EdgeInsets.all(10),
                        labelStyle: TextStyle(color: Colors.white),
                        label: const Text(
                          'Video',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        avatar: const Icon(
                          Iconsax.message,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: 5,
                          itemBuilder: (BuildContext, index) {
                            return Container(
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    height: 150,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const ListTile(
                                    leading: Text(
                                      '@ Presentation',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    trailing: Icon(
                                      Iconsax.unlock,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Text(
                                      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                      maxLines: 3,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: AvatarStack(
                                      settings: settings,
                                      height: 50,
                                      avatars: [
                                        for (var n = 0; n < 15; n++)
                                          NetworkImage(
                                              'https://i.pravatar.cc/150?img=$n'),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Chip(
                                              backgroundColor:
                                                  Colors.black.withBlue(20),
                                              label: const Text(
                                                '10',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              avatar: const Icon(
                                                Iconsax.user,
                                                size: 28,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Chip(
                                              backgroundColor:
                                                  Colors.black.withBlue(20),
                                              label: const Text(
                                                '10',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              avatar: const Icon(
                                                Iconsax.message,
                                                size: 28,
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }))
                ],
              ),
            )),
            Obx(() => (accontrol.displaynoeud.isTrue)
                ? SizedBox(
                    width: 60,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: StreamBuilder(
                            stream: accontrol.abonnenoeuds.value,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              int length = snapshot.data!.docs.length;
                              List noeud = snapshot.data!.docs;
                              return (noeud.isNotEmpty)
                                  ? ListView.builder(
                                      reverse: true,
                                      shrinkWrap: true,
                                      itemCount: length,
                                      itemBuilder: (BuildContext, index) {
                                        return Noeud(
                                            idnoeud: noeud[index]["idcompte"]);
                                      })
                                  : ListView.builder(
                                      itemCount: 10,
                                      shrinkWrap: true,
                                      itemBuilder: (BuildContext, index) {
                                        return const CircleAvatar(
                                          radius: 35,
                                          backgroundColor: Colors.white,
                                        );
                                      });
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            accontrol.displaynoeud.value = false;
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: const BoxDecoration(
                                color: Colors.red,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50))),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : const SizedBox())
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Obx(() => (accontrol.displaynoeud.isFalse)
          ? FloatingActionButton(
              backgroundColor: Colors.orangeAccent,
              onPressed: () {
                accontrol.displaynoeud.value = true;
              },
              child: const Icon(Iconsax.more),
            )
          : const SizedBox()),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }

  optionsnoeud() {
    showMaterialModalBottomSheet(
        backgroundColor: Colors.transparent,
        barrierColor: Colors.transparent,
        expand: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black.withBlue(25),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      height: 5,
                      width: 100,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      onTap: () {},
                      leading: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Ajouter une branche',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ListTile(
                      onTap: () {},
                      leading: const Icon(
                        Icons.insert_invitation,
                        color: Colors.white,
                      ),
                      title: const Text('Invitation',
                          style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }
}
