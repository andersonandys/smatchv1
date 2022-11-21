import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Homecrypto extends StatefulWidget {
  const Homecrypto({Key? key}) : super(key: key);

  @override
  _HomecryptoState createState() => _HomecryptoState();
}

class _HomecryptoState extends State<Homecrypto> {
  List transaction = [0, 1, 0, 0, 1];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF9AB2),
      appBar: AppBar(
        backgroundColor: Color(0xFFFF9AB2),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Anderson',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: const [
          CircleAvatar(
            radius: 25,
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Positioned(
                      left: 10,
                      bottom: 10,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        padding: const EdgeInsets.all(10),
                        width: 200,
                        child: RichText(
                          text: const TextSpan(
                            text: 'Solde \n \n',
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.normal),
                            children: <TextSpan>[
                              TextSpan(
                                text: "200 TZ",
                                style: TextStyle(
                                    fontSize: 40, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      )),
                  Positioned(
                      bottom: -50,
                      right: 1,
                      child: Image.asset("assets/crypto/other1.png"))
                ],
              )),
          Expanded(
              child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.black.withBlue(20),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ActionChip(
                            onPressed: () {},
                            padding: const EdgeInsets.all(10),
                            backgroundColor: const Color(0xFFDFF0FF),
                            avatar: const Icon(Iconsax.receive_square_2),
                            label: const Text(
                              'Recevoir',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            )),
                        ActionChip(
                            onPressed: () {},
                            padding: const EdgeInsets.all(10),
                            backgroundColor: const Color(0xFFDFF0FF),
                            avatar: const Icon(Iconsax.send_square),
                            label: const Text(
                              'Envoyer',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ActionChip(
                            onPressed: () {},
                            padding: const EdgeInsets.all(10),
                            backgroundColor: const Color(0xFFDFF0FF),
                            avatar: const Icon(Iconsax.arrow_swap_horizontal),
                            label: const Text(
                              'Swap',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            )),
                        ActionChip(
                            onPressed: () {},
                            padding: const EdgeInsets.all(10),
                            backgroundColor: const Color(0xFFDFF0FF),
                            avatar: const Icon(Icons.stacked_bar_chart),
                            label: const Text(
                              'Stakin',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Transaction',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: transaction.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            decoration: const BoxDecoration(
                                color: Color(0xFFEBEFF1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: ListTile(
                              style: ListTileStyle.list,
                              leading: CircleAvatar(
                                backgroundColor: ((transaction[index] == 0)
                                    ? Color(0xFF5FC88F)
                                    : Color(0xFFFF6464)),
                                child: Icon(
                                    (transaction[index] == 0)
                                        ? Iconsax.send_square
                                        : Iconsax.receive_square,
                                    color: ((transaction[index] == 0)
                                        ? Color(0xFFDEF5E9)
                                        : Color(0xFFFFDBDB))),
                              ),
                              title: const Text(
                                'Tezos',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Tz'),
                              trailing: RichText(
                                text: const TextSpan(
                                  text: '+ 200 tz \n',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "date",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })
                  ],
                ),
              ),
            ),
          ))
        ],
      ),
    );
  }
}
