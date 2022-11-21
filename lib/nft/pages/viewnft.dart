import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class Viewnft extends StatefulWidget {
  const Viewnft({Key? key}) : super(key: key);

  @override
  _ViewnftState createState() => _ViewnftState();
}

class _ViewnftState extends State<Viewnft> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 5,
            width: 100,
            decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(100))),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text(
                      "Lorem Ipsum is simply dummy",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Côte d'Ivoire",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      )),
                )
              ],
            ),
          ),
          Expanded(
              child: Container(
            decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Positioned(
                      bottom: 100,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(10),
                          height: 150,
                          width: MediaQuery.of(context).size.width / 1.2,
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const <Widget>[
                                      Text(
                                        'Lorem Ipsum is simply',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Côte d'Ivoire",
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.white),
                                      )
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const <Widget>[
                                      Text(
                                        '120 TZ',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        '120 Up',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  ActionChip(
                                      backgroundColor:
                                          Colors.greenAccent.shade700,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      padding: const EdgeInsets.all(10),
                                      label: const Text(
                                        'Offrir NFT',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  ActionChip(
                                      backgroundColor:
                                          Colors.orangeAccent.shade700,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        showModalBottomSheet(
                                            isScrollControlled: true,
                                            context: context,
                                            backgroundColor: Colors.transparent,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0))),
                                            builder: (BuildContext context) {
                                              return Container(
                                                constraints: BoxConstraints(
                                                    maxHeight: height,
                                                    minHeight: height),
                                                color: Colors.transparent,
                                                margin:
                                                    const EdgeInsets.all(10),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaX: 10, sigmaY: 10),
                                                  child: Bynft(),
                                                ),
                                              );
                                            });
                                      },
                                      padding: const EdgeInsets.all(10),
                                      label: const Text(
                                        'Acheter',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ))
                                ],
                              )
                            ],
                          ),
                        ),
                      )),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}

class Bynft extends StatefulWidget {
  const Bynft({Key? key}) : super(key: key);

  @override
  _BynftState createState() => _BynftState();
}

class _BynftState extends State<Bynft> {
  final List<String> bloc = [
    'Tezos',
    'Upsober',
  ];
  String? selectedValue;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Achat NFT',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        )),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Vous êtes sur le point d'acheter le NFT C O I N Z de UI8",
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Détail de l'achat",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Moyen de paiement",
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    hint: Text(
                      'Selectionnez',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: bloc
                        .map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ))
                        .toList(),
                    value: selectedValue,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value as String;
                      });
                    },
                    buttonHeight: 40,
                    buttonWidth: 140,
                    itemHeight: 40,
                  ),
                ),
              ),
              const Divider(
                color: Colors.grey,
              ),
              ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: const Text(
                  'Montant',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                trailing: Text(
                  (selectedValue == null) ? '5' : '5 $selectedValue',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: const Text(
                  'Frais de transaction',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                trailing: Text(
                  (selectedValue == null) ? '0,002' : '0,002 $selectedValue',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: const Text(
                  'Montant total',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                trailing: Text(
                  (selectedValue == null) ? '5,002' : '5,002 $selectedValue',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: ActionChip(
                    padding: const EdgeInsets.all(10),
                    onPressed: () {},
                    backgroundColor: Colors.orangeAccent.shade700,
                    label: const Text(
                      'Acheter le NFT',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
