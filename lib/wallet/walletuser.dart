import 'dart:math';
import 'package:adjeminpay_flutter/adjeminpay_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinetpay/cinetpay.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smatch/home/tabsrequette.dart';
import 'package:smatch/menu/menuwidget.dart';

import 'package:http/http.dart' as http;
import 'package:smatch/wallet/crypto/get_started_screen.dart';
import 'dart:convert';

import 'package:smatch/wallet/info.dart';

class Walletuser extends StatefulWidget {
  @override
  _WalletuserState createState() => _WalletuserState();
}

class _WalletuserState extends State<Walletuser> {
  final _advancedDrawerController = AdvancedDrawerController();
  final bool _isLoading = false;
  Map<String, dynamic> myOrder = {
    // ! required transactionId or orderId
    'transaction_id': "UniqueTransactionId",
    // ! required total amount
    'total_amount': 1000,
    // optional your orderItems data
    'items': [
      {
        'id': '1',
        'productId': 'prod1',
        'price': 100,
        'quantity': 1,
        'title': 'Product 1 title',
      },
      {
        'id': '2',
        'productId': 'prod9',
        'price': 300,
        'quantity': 3,
        'title': 'Product 9 title',
      },
    ],
    'currency_code': "XOF",
    'designation': "Order Title",
    'client_name': "ClientName",
  };
  final Stream<QuerySnapshot> usersdata = FirebaseFirestore.instance
      .collection("users")
      .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
  final Stream<QuerySnapshot> usertransfert = FirebaseFirestore.instance
      .collection("payment")
      .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .orderBy("range", descending: true)
      .snapshots();
  bool masque = false;
  String nomuser = "";
  String avataruser = "";
  final montantcontroller = TextEditingController();
  String lientext = "";
  String? token = "";
  String userid = FirebaseAuth.instance.currentUser!.uid;
  bool load = false;
  final requ = Get.put(Tabsrequette());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getinfouser();
  }

  getinfouser() {
    print(FirebaseAuth.instance.currentUser!.uid);
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        nomuser = querySnapshot.docs.first['nom'];
        avataruser = querySnapshot.docs.first['avatar'];
      });
      print('object');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(25),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(25),
        title: Text(
          'Wallette',
          style: GoogleFonts.poppins(fontSize: 30),
        ),
        leading: const Menuwidget(),
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => GetStartedScreen());
              },
              icon: Icon(Iconsax.buy_crypto, size: 30, color: Colors.white))
        ],
      ),
      body: Container(
          child: SingleChildScrollView(
              child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // affichage normal
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: usercredit(),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Dernière transaction",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(
                  height: 20,
                ),
                StreamBuilder(
                    stream: usertransfert,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> rechagement) {
                      if (!rechagement.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (rechagement.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return (rechagement.data!.docs.isEmpty)
                          ? const Center(
                              heightFactor: 0.9,
                              child: Text(
                                "Aucune transaction effectuée",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 20),
                              ),
                            )
                          : GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 1.0,
                                      mainAxisSpacing: 10.0,
                                      crossAxisSpacing: 5.0,
                                      mainAxisExtent: 270),
                              shrinkWrap: true,
                              itemCount: rechagement.data!.docs.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          (rechagement.data!.docs[index]
                                                      ["type"] ==
                                                  "depot")
                                              ? const Icon(
                                                  Icons.call_received_rounded,
                                                  color: Colors.white,
                                                )
                                              : const Icon(
                                                  Iconsax.send_21,
                                                  color: Colors.white,
                                                ),
                                          Text(
                                            "${rechagement.data!.docs[index]["type"]} ",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "${rechagement.data!.docs[index]["montant"]} FCFA",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      (rechagement.data!.docs[index]["type"] ==
                                              "achat")
                                          ? Column(
                                              children: <Widget>[
                                                const Text(
                                                  "Achat vers :",
                                                  style: TextStyle(
                                                      color: Colors.white70),
                                                ),
                                                Text(
                                                  rechagement.data!.docs[index]
                                                      ["nom"],
                                                  style: const TextStyle(
                                                      color: Colors.white70),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: const <Widget>[
                                                Text(
                                                  "Réçu de ",
                                                  style: TextStyle(
                                                      color: Colors.white70),
                                                ),
                                                Text(
                                                  "Mobile money ",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Center(
                                        child: Chip(
                                            backgroundColor: (rechagement
                                                            .data!.docs[index]
                                                        ["statut"] ==
                                                    "Annulée")
                                                ? Colors.redAccent
                                                : (rechagement.data!.docs[index]
                                                            ["statut"] ==
                                                        "Succès")
                                                    ? Colors.greenAccent
                                                    : (rechagement.data!
                                                                    .docs[index]
                                                                ["statut"] ==
                                                            "en cours")
                                                        ? null
                                                        : null,
                                            label: Text(rechagement
                                                .data!.docs[index]["statut"])),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${rechagement.data!.docs[index]["date"]} ",
                                            style: const TextStyle(
                                                color: Colors.white70),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              });
                    })
              ],
            )
          ],
        ),
      ))),
    );
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }

  void payWithAdjeminPay(dynamic orderData, idtransaction) async {
    // paymentResult will yield {transactionId, status, message }
    // once the payment gate is closed by the user
    // ! IMPORTANT : make sure to save the orderData in your database first
    // ! before calling this function
    Map<String, dynamic> paymentResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              // The AdjeminPay class
              AdjeminPay(
            // ! required clientId
            clientId: Information.ADJEMINPAY_CLIENT_ID,
            // ! required clientScret
            clientSecret: Information.ADJEMINPAY_CLIENT_SECRET,
            // ! required transactionId required
            // for you to follow the transaction
            //    or retrieve it later
            //    should be a string < 191 and unique for your application
            merchantTransactionId: "${orderData['transaction_id']}",
            // ! required designation
            //   the name the user will see as what they're paying for
            designation: orderData['designation'],
            // notifyUrl for your web backend
            notificationUrl: Information.ADJEMINPAY_NOTIFICATION_URL,
            // amount: int.parse("${orderData['totalAmount']}"),
            // ! required amount
            //    amount the user is going to pay
            //    should be an int
            amount: int.parse("${orderData['total_amount']}"),
            // currency code
            // currently supported currency is XOF
            currencyCode: orderData['currency_code'],
            // designation: widget.element.title,
            // the name of your user
            buyerName: orderData['client_name'], //optional
          ),
        ));

    print(">>> ADJEMINPAY PAYMENT RESULTS <<<");
    print(paymentResult);
    // * Here you define your callbacks
    // Callback if the paymentResult is null
    //    the payment gate got closed without sending back any data
    if (paymentResult == null) {
      FirebaseFirestore.instance
          .collection("payment")
          .doc(idtransaction)
          .update({"statut": "Annulée"});
      Navigator.of(context).pop();
      print("<<< Payment Gate Unexpectedly closed");
      return;
    }
    // print(${paymentResult['status']});
    // Scaffold.of(context).showSnackBar(SnackBar(content: Text("Payment Status is ${paymentResult['status']}")));
    // Callback on payment successfully
    if (paymentResult['status'] == "SUCCESSFUL") {
      print("<<< AdjeminPay success");
      FirebaseFirestore.instance
          .collection("payment")
          .doc(idtransaction)
          .update({"statut": "Succès"});
      FirebaseFirestore.instance.collection("users").doc(userid).update(
          {"wallet": FieldValue.increment(int.parse(montantcontroller.text))});
      Navigator.of(context).pop();
      print(paymentResult);
      // redirect to or show another screen
      return;
    }
    // Callback on payment failed
    if (paymentResult['status'] == "FAILED") {
      print("<<< AdjeminPay failed");
      FirebaseFirestore.instance
          .collection("payment")
          .doc(idtransaction)
          .update({"statut": "Annulée"});
      Navigator.of(context).pop();
      print(paymentResult);
      // the reason with be mentionned in the paymentResult['message']
      print("Reason is : " + paymentResult['message']);
      // redirect to or show another screen
      return;
    }
    // Callback on payment cancelled
    if (paymentResult['status'] == "CANCELLED") {
      print("<<< AdjeminPay cancelled");
      FirebaseFirestore.instance
          .collection("payment")
          .doc(idtransaction)
          .update({"statut": "Annulée"});
      print(paymentResult);
      Navigator.of(context).pop();
      // the reason with be mentionned in the paymentResult['message']
      print("Reason is : " + paymentResult['message']);
      // redirect to or show another screen
      return;
    }
    // Callback on payment cancelled
    if (paymentResult['status'] == "EXPIRED") {
      FirebaseFirestore.instance
          .collection("payment")
          .doc(idtransaction)
          .update({"statut": "Annulée"});
      print("<<< AdjeminPay expired");
      print(paymentResult);
      Navigator.of(context).pop();
      // The user took too long to approve or refuse payment
      print("Reason is : " + paymentResult['message']);
      // redirect to or show another screen
      return;
    }
    // Callback on initialisation error
    if (paymentResult['status'] == "INVALID_PARAMS") {
      FirebaseFirestore.instance
          .collection("payment")
          .doc(idtransaction)
          .update({"statut": "Annulée"});
      print("<<< AdjeminPay Init error");
      // You didn't specify a required field
      print(paymentResult);
      return;
    }

    if (paymentResult['status'] == "INVALID_CREDENTIALS") {
      FirebaseFirestore.instance
          .collection("payment")
          .doc(idtransaction)
          .update({"statut": "Annulée"});
      print("<<< AdjeminPay Init error");
      // You didn't specify a required field
      // or your clientId or clientSecret are not valid
      print(paymentResult);
      return;
    }
    // Callback when AdjeminPay requests aren't completed
    if (paymentResult['status'] == "ERROR_HTTP") {
      FirebaseFirestore.instance
          .collection("payment")
          .doc(idtransaction)
          .update({"statut": "Annulée"});
      return;
    }
  }

  Widget usercredit() {
    return StreamBuilder(
        stream: usersdata,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> datauser) {
          if (!datauser.hasData) {
            return const Center(
                heightFactor: 0.5, child: CircularProgressIndicator());
          }
          if (datauser.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.dotsTriangle(
                color: Colors.blueAccent,
                size: 100,
              ),
            );
          }
          return Container(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello " + datauser.data!.docs.first["nom"],
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      height: 200,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.blue.shade800,
                              Colors.orange.shade900,
                            ],
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Text(
                                "Smatch pay",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  const Text(
                                    "Votre solde",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    (masque)
                                        ? "******** FCFA"
                                        : "${datauser.data!.docs.first["wallet"]} FCFA",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                  onTap: () {
                                    depot();
                                  },
                                  child: Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(50))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const <Widget>[
                                        Icon(Icons.vertical_align_bottom_sharp,
                                            color: Colors.white),
                                        Text('Dépot',
                                            style:
                                                TextStyle(color: Colors.white))
                                      ],
                                    ),
                                  ))
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Validité",
                            style: TextStyle(color: Colors.white),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "12/2023",
                                style: TextStyle(color: Colors.white),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    if (masque) {
                                      setState(() {
                                        masque = false;
                                      });
                                    } else {
                                      setState(() {
                                        masque = true;
                                      });
                                    }
                                  },
                                  child: (masque)
                                      ? const Icon(
                                          Iconsax.eye_slash,
                                          color: Colors.white,
                                        )
                                      : const Icon(
                                          Iconsax.eye,
                                          color: Colors.white,
                                        ))
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ],
          ));
        });
  }

  depot() {
    showModalBottomSheet(
        backgroundColor: Colors.black.withBlue(25),
        enableDrag: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                  padding: const EdgeInsets.all(10),
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: Stack(children: [
                    if (load == true)
                      Positioned(
                        top: MediaQuery.of(context).size.height / 2.3,
                        right: MediaQuery.of(context).size.width / 2.6,
                        child: const CircularProgressIndicator(
                          color: Colors.red,
                        ),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(50),
                                )),
                            width: 50,
                            height: 5,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Center(
                          child: Text(
                            "Rechargement de votre wallet",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Center(
                          child: Text('Nous vous prions de rentrer un montant',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 15)),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          cursorHeight: 20,
                          autofocus: false,
                          controller: montantcontroller,
                          decoration: InputDecoration(
                            label: const Text("Montant",
                                style: TextStyle(color: Colors.white)),
                            fillColor: Colors.white.withOpacity(0.2),
                            filled: true,
                            labelStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text('Recharge rapide',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 50,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            children: [
                              ActionChip(
                                  padding: const EdgeInsets.all(10),
                                  label: const Text('200 Fcfa'),
                                  onPressed: () {
                                    montantrapide("200");
                                  }),
                              const SizedBox(
                                width: 5,
                              ),
                              ActionChip(
                                  padding: const EdgeInsets.all(10),
                                  label: const Text('400 Fcfa'),
                                  onPressed: () {
                                    montantrapide("400");
                                  }),
                              const SizedBox(
                                width: 5,
                              ),
                              ActionChip(
                                  padding: const EdgeInsets.all(10),
                                  label: const Text('600 Fcfa'),
                                  onPressed: () {
                                    montantrapide("600");
                                  }),
                              const SizedBox(
                                width: 5,
                              ),
                              ActionChip(
                                  padding: const EdgeInsets.all(10),
                                  label: const Text('1000 Fcfa'),
                                  onPressed: () {
                                    montantrapide("1000");
                                  })
                            ],
                          ),
                        ),
                        Expanded(
                            child: ListView(
                          reverse: true,
                          shrinkWrap: true,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (montantcontroller.text.isEmpty) {
                                  requ.message('Echec',
                                      "Nous vous prions de saisir un montant");
                                } else if (int.parse(montantcontroller.text) <
                                    100) {
                                  requ.message("Echec",
                                      "Le montant minimum de rechargement est de 100 FCFA");
                                } else {
                                  setState(() {
                                    load = true;
                                  });
                                  send();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade900,
                                  fixedSize: Size(
                                      MediaQuery.of(context).size.width, 70),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5))),
                              child: const Text(
                                'Valider',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ))
                      ],
                    )
                  ]));
            },
          );
        });
  }

  montantrapide(data) {
    setState(() {
      montantcontroller.text = data;
    });
  }

  send() {
    DateTime now = DateTime.now();
    String dateformat = DateFormat("yyyy-MM-dd - kk:mm").format(now);
    FirebaseFirestore.instance.collection("payment").add({
      "iduser": userid,
      "montant": montantcontroller.text,
      "type": "depot",
      "date": dateformat,
      "statut": "en cours",
      "token": token,
      "lienpayement": lientext,
      "nom": "Wallet",
      "range": DateTime.now().millisecondsSinceEpoch,
      "idrechargement": ""
    }).then((value) {
      FirebaseFirestore.instance
          .collection("payment")
          .doc(value.id)
          .update({"idrechargement": value.id});
      // Map<String, dynamic> myOrders = {
      //   // ! required transactionId or orderId
      //   'transaction_id': value.id,
      //   // ! required total amount
      //   'total_amount': montantcontroller.text,
      //   'currency_code': "XOF",
      //   'designation': "Rechargement de compte",
      //   'client_name': nomuser,
      // };
      print("ok test");
      setState(() {
        load = false;
      });
      CinetPayCheckout(
          title: 'YOUR_TITLE',
          configData: const <String, dynamic>{
            'apikey': '12845785286114ff4e94f6e9.88416188',
            'site_id': 608304,
            'notify_url': 'https://smatchs.000webhostapp.com/'
          },
          paymentData: <String, dynamic>{
            'transaction_id': value.id,
            'amount': 100,
            'currency': 'XOF',
            'channels': 'ALL',
            'description': 'YOUR_DESCRIPTION'
          },
          waitResponse: (response) {
            print(response);
          },
          onError: (error) {
            print(error);
          });
      // payWithAdjeminPay(myOrders, value.id);
    });
  }
}

class Transactions extends StatefulWidget {
  const Transactions({
    Key? key,
  }) : super(key: key);

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final GlobalKey webViewKey = GlobalKey();
  String url = Get.arguments[0]["url"];

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  double progress = 0;
  final urlController = TextEditingController();
  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        webViewController?.reload();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withBlue(20),
        appBar: AppBar(
          backgroundColor: Colors.black.withBlue(20),
          title: const Text("Rechargement"),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
            child: Column(children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(url: Uri.parse(url)),
                  initialOptions: options,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri.scheme)) {
                      // if (await canLaunch(url)) {
                      //   // Launch the App
                      //   await launch(
                      //     url,
                      //   );
                      //   // and cancel the request
                      //   return NavigationActionPolicy.CANCEL;
                      // }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController.endRefreshing();
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onLoadError: (controller, url, code, message) {
                    pullToRefreshController.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = this.url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print(consoleMessage);
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            ),
          ),
        ])));
  }
}
