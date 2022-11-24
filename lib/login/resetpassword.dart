import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smatch/home/tabsrequette.dart';

class Resetpassword extends StatefulWidget {
  const Resetpassword({Key? key}) : super(key: key);

  @override
  _ResetpasswordState createState() => _ResetpasswordState();
}

class _ResetpasswordState extends State<Resetpassword> {
  final mail = TextEditingController();
  bool load = false;
  final req = Get.put(Tabsrequette());
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withBlue(20),
      child: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 20),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(50),
                ),
                color: Colors.white),
            height: 5,
            width: 50,
          ),
          const Text(
            'Réinitialisation de votre mot de passe',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30), color: Colors.white),
              child: TextFormField(
                controller: mail,
                decoration: InputDecoration(
                    hintText: "Votre adresse mail",
                    hintStyle: GoogleFonts.ubuntu(color: Colors.grey),
                    contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
                    prefixIcon: const Icon(
                      Icons.mail_lock,
                      color: Colors.grey,
                    ),
                    border: const UnderlineInputBorder(
                        borderSide: BorderSide.none)),
              ),
            ),
          ),
          GestureDetector(
              onTap: resetmdp,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                      color: const Color(0xffFFA17F),
                      borderRadius: BorderRadius.circular(30)),
                  height: 50,
                  child: Center(
                      child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (load)
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Valider",
                        style: GoogleFonts.ubuntu(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
                ),
              ))
        ],
      ),
    );
  }

  resetmdp() async {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: mail.text)
        .then((value) {
      Navigator.of(context).pop();
      req.message("success",
          "Un mail vous a ete envoye pour reinitialiser votre mot de passe");
      print("envoye");
    }).catchError((e) {});
  }
}
