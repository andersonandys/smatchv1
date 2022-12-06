import 'dart:async';
import 'dart:math';
import 'package:cinetpay/cinetpay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Payement extends StatefulWidget {
  @override
  _PayementState createState() => new _PayementState();
}

class _PayementState extends State<Payement> {
  TextEditingController amountController = new TextEditingController();
  Map<String, dynamic>? response;
  Color? color;
  IconData? icon;
  bool show = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("CinetPay Demo"),
          centerTitle: true,
        ),
        body: SafeArea(
            child: Center(
                child: ListView(
          shrinkWrap: true,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                show ? Icon(icon, color: color, size: 150) : Container(),
                show ? SizedBox(height: 50.0) : Container(),
                Text(
                  "Example integration Package for Flutter",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50.0),
                Text(
                  "Cart informations.",
                  style: Theme.of(context).textTheme.headline4,
                ),
                SizedBox(height: 50.0),
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  margin: EdgeInsets.symmetric(horizontal: 50.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.green),
                  ),
                  child: new TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      hintText: "Amount",
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(height: 40.0),
                ElevatedButton(
                  child: Text("Pay with CinetPay"),
                  onPressed: () async {
                    String amount = amountController.text;
                    if (amount.isEmpty) {
                      return;
                    }
                    double _amount;
                    try {
                      _amount = double.parse(amount);

                      if (_amount < 100) {
                        print("mauvais montant");
                        return;
                      }

                      if (_amount > 1500000) {
                        return;
                      }
                    } catch (exception) {
                      return;
                    }

                    amountController.clear();

                    final String transactionId = Random()
                        .nextInt(100000000)
                        .toString(); // Mettre en place un endpoint à contacter cêté serveur pour générer des ID unique dans votre BD

                    await Get.to(() => CinetPayCheckout(
                          title: 'Payment Checkout',
                          // ignore: prefer_const_literals_to_create_immutables
                          configData: <String, dynamic>{
                            'apikey': "12845785286114ff4e94f6e9.88416188",
                            'site_id': 608304,
                            'notify_url': "https://smatchs.000webhostapp.com/",
                            // 'mode':Constants().MODE
                          },
                          paymentData: <String, dynamic>{
                            'transaction_id': transactionId,
                            'amount': _amount,
                            'currency': 'XOF',
                            'channels': 'ALL',
                            'description': 'Payment test',
                          },
                          waitResponse: (data) {
                            if (mounted) {
                              setState(() {
                                response = data;
                                print(response);
                                icon = data['status'] == 'ACCEPTED'
                                    ? Icons.check_circle
                                    : Icons.mood_bad_rounded;
                                color = data['status'] == 'ACCEPTED'
                                    ? Colors.green
                                    : Colors.redAccent;
                                show = true;
                                Get.back();
                              });
                            }
                          },
                          onError: (data) {
                            if (mounted) {
                              setState(() {
                                response = data;
                                print(response);
                                icon = Icons.warning_rounded;
                                color = Colors.yellowAccent;
                                show = true;
                                Get.back();
                              });
                            }
                          },
                        ));
                  },
                )
              ],
            ),
          ],
        ))));
  }
}
