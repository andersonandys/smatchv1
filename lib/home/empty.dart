import 'package:flutter/material.dart';

class Empty extends StatelessWidget {
  const Empty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black.withBlue(20),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(30),
                  height: 230,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle),
                  child: Image.asset('assets/inbox.png'),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text('Inbox',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  "Aucun message disponible dans la branche",
                  style: TextStyle(fontSize: 20, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 32,
                ),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Astuce',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Mainetenez le bouton d'envois enfoncer pour traduire votre message avant de l'envoyer",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Vous pouvez traduire un message dans une langue desireuse, pour cela faite un clique sur le message et selction traduire dans le menu",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.justify,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
