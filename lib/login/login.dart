import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:smatch/home/tabsrequette.dart';
import 'package:smatch/login/resetpassword.dart';
import 'package:smatch/menu/menuhome.dart';
import 'package:smatch/msgbranche/reqmessage.dart';
import 'package:smatch/onboarding.dart';
import 'package:pinput/pinput.dart';
import 'package:smatch/newuser.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  CollectionReference utilisateur =
      FirebaseFirestore.instance.collection("users");
  final requ = Get.put(Tabsrequette());
  final req1 = Get.put(Reqmessage());
  bool isload = false;
  String loadtype = "";
  String token = "";
  bool check = false;
  final TextStyle titre =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  FirebaseAuth auth = FirebaseAuth.instance;
  bool view = false;
  final mailcontroller = TextEditingController();
  final mdpcontroller = TextEditingController();
  String noimage =
      "https://firebasestorage.googleapis.com/v0/b/flutterprojet-e8896.appspot.com/o/business%2Favatar.png?alt=media&token=1c03953b-cd2d-4df3-808f-68e47ba0a8fd";

  String tittreage =
      "Conditions d'âge et responsabilité des parents et tuteurs";
  String age =
      "En accédant à nos services, vous confirmez que vous avez au moins 13 ans et que vous respectez l'âge minimum du consentement numérique dans votre pays. Nous maintenons une liste des âges minimum dans le monde comme ressource pour vous, mais nous ne sommes pas en mesure de garantir qu'elle est toujours exacte. Si vous êtes assez âgé pour accéder à nos services dans votre pays, mais pas assez âgé pour être autorisé à consentir à nos conditions, votre parent ou tuteur doit accepter nos conditions en votre nom. Veuillez demander à votre parent ou tuteur de lire ces conditions avec vous. Si vous êtes un parent ou un tuteur légal et que vous autorisez votre adolescent à utiliser les services, ces conditions s'appliquent également à vous et vous êtes responsable de l'activité de votre adolescent sur les services.";
  String titreservice = "Ce que vous pouvez attendre de nous";
  String service =
      "Nous développons activement de nouvelles fonctionnalités et de nouveaux produits pour améliorer Smacth. Dans le cadre de ces efforts, nous pouvons ajouter ou supprimer des fonctionnalités, commencer à offrir de nouveaux services ou cesser d'offrir d'anciens services. Bien que nous essayions d'éviter les interruptions, nous ne pouvons pas garantir qu'il n'y aura pas d'interruption ou de modification des services, et votre contenu peut ne pas être récupérable en raison de telles interruptions ou modifications. Nous ne sommes pas responsables de telles pannes ou changements de service.";
  String titrecompte = "Votre compte Smatch";
  String compte =
      "Pour accéder aux services de manière continue, vous devrez créer un compte Smatch. Vous pouvez fournir un nom d'utilisateur et un mot de passe, ainsi qu'un moyen de vous contacter (comme une adresse e-mail et/ou un numéro de téléphone). Pour accéder à certaines fonctionnalités ou communautés, vous devrez peut-être vérifier votre compte ou ajouter d'autres informations à votre compte. Notre politique de confidentialité décrit plus en détail les informations que nous collectons et comment nous utilisons ces informations.Vous êtes responsable de la sécurité de votre compte et vous acceptez de nous informer immédiatement si vous pensez que votre compte a été compromis. Si vous utilisez un mot de passe, il doit être fort, et nous vous recommandons (fortement) d'utiliser ce mot de passe uniquement pour votre compte Smatch et d'activer l'authentification à deux facteurs. Si votre compte est compromis, nous ne pourrons peut-être pas vous le restaurer.Vous êtes également responsable du maintien de l'exactitude des informations de contact associées à votre compte. Si vous ne parvenez pas à accéder à votre compte, nous devrons vous contacter à l'adresse e-mail ou au numéro de téléphone associé à votre compte, et nous ne pourrons peut-être pas vous restaurer votre compte Smatch si vous n'avez plus accès à ce compte de messagerie. ou numéro de téléphone. Nous pouvons également supposer que toutes les communications que nous avons reçues de votre compte ou les informations de contact associées ont été faites par vous.Vous acceptez de ne pas accorder de licence, vendre ou transférer votre compte sans notre approbation écrite préalable.";
  String titrecontenue = "Contenu des services de Smatch \n Votre contenu";
  String contenu =
      "Lorsque nous parlons de « votre contenu » dans ces termes, nous entendons toutes les choses que vous ajoutez (téléchargez, publiez, partagez ou diffusez) à nos services. Cela peut inclure du texte, des liens, des GIF, des emoji, des photos, des vidéos, des documents ou d'autres médias. Si nous proposons une autre façon pour vous d'ajouter du contenu aux services, cela inclut également cela.Vous n'avez aucune obligation d'ajouter du contenu aux services. Si vous choisissez d'ajouter du contenu aux services, vous êtes responsable de vous assurer que vous avez le droit de le faire, que vous avez le droit d'accorder les licences dans les conditions et que votre contenu est légal. Nous n'assumons aucune responsabilité pour votre contenu et nous ne sommes pas responsables de l'utilisation de votre contenu par d'autres.Nos services permettent aux utilisateurs d'ajouter du contenu de différentes manières, y compris via des messages directs et dans des communautés plus petites et plus grandes. Certains de ces espaces sont publics, et si vous y partagez du contenu, ce contenu peut être consulté par des personnes que vous ne connaissez pas. Par exemple, certains noeuds sont disponibles dans la section Découverte de noeud de l'application et ne nécessitent pas de lien d'invitation pour se joindre. D'autres propriétaires de serveurs peuvent publier leur lien d'invitation de serveur sur des sites Web publics. Tout le monde peut accéder à ces espaces. Vous devez savoir que ces autorisations sont définies par les propriétaires ou les administrateurs du serveur et qu'elles peuvent changer au fil du temps. Veuillez comprendre la différence entre publier dans des espaces publics et privés sur Discord, et choisir l'espace, les fonctionnalités et les paramètres appropriés pour vous et votre contenu. Pour comprendre comment nous traitons vos informations personnelles, consultez notre politique de confidentialité.Votre contenu vous appartient, mais vous nous en donnez une licence lorsque vous utilisez Discord. \n Votre contenu peut être protégé par certains droits de propriété intellectuelle. Nous ne les possédons pas. Mais en utilisant nos services, vous nous accordez une licence, qui est une forme d'autorisation, pour faire ce qui suit avec votre contenu, conformément aux exigences légales applicables, dans le cadre de l'exploitation, du développement et de l'amélioration de nos services :Utilisez, copiez, stockez, distribuez et communiquez votre contenu d'une manière compatible avec votre utilisation des services. (Par exemple, pour que nous puissions stocker et afficher votre contenu.)Publiez, exécutez publiquement ou affichez publiquement votre contenu si vous avez choisi de le rendre visible pour les autres. (Par exemple, afin que nous puissions afficher vos messages si vous les publiez sur des serveurs publics.)\nSurveillez, modifiez, traduisez et reformatez votre contenu. (Par exemple, nous pouvons redimensionner une image que vous publiez pour l'adapter à un appareil mobile.)\nSous-licenciez votre contenu pour permettre à nos services de fonctionner comme prévu. (Par exemple, afin que nous puissions stocker votre contenu auprès de nos fournisseurs de services cloud.).Cette licence est mondiale, non exclusive (ce qui signifie que vous pouvez toujours concéder votre contenu à d'autres), libre de droits (ce qui signifie qu'il n'y a pas de frais pour cette licence), transférable et perpétuelle.Nous nous réservons le droit de bloquer, retirer et/ou supprimer définitivement votre contenu pour quelque raison que ce soit, y compris la violation de ces conditions, de nos directives communautaires, de nos autres politiques ou de toute loi ou réglementation applicable.\nNous apprécions les commentaires sur nos services. En nous envoyant des commentaires, vous nous accordez une licence non exclusive, perpétuelle, irrévocable et transférable pour utiliser les commentaires et les idées générés à partir des commentaires sans aucune restriction, attribution ou compensation pour vous...";
  @override
  void initState() {
    super.initState();
    initializesplash();
  }

  initializesplash() async {
    await Future.delayed(const Duration(seconds: 3))
        .then((value) => FlutterNativeSplash.remove());
  }

  FirebaseFunctions functions = FirebaseFunctions.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController controller = TextEditingController();
  String initialCountry = 'CI';
  PhoneNumber number = PhoneNumber(isoCode: 'CI');
  String numbers = "";
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black.withBlue(20),
      body: SafeArea(
          child: Column(
        children: <Widget>[
          SizedBox(
            child: Column(
              children: <Widget>[
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage("assets/logoapp.png"),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'SMATCH',
                  style: GoogleFonts.sansita(color: Colors.white, fontSize: 35),
                )
              ],
            ),
          ),
          Expanded(
              child: Container(
            margin: const EdgeInsets.only(top: 20),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              // color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: <Widget>[
                  const Center(
                    child: Text(
                      'Connexion',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Container(
                      color: const Color(0xfff5f5f5),
                      child: TextFormField(
                        controller: mailcontroller,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Iconsax.user),
                          fillColor: Colors.white.withOpacity(0.2),
                          filled: true,
                          labelStyle: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          label: const Text("Adresse mail"),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Color(0xfff5f5f5),
                    child: TextFormField(
                      obscureText: view,
                      controller: mdpcontroller,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(IconlyBold.password),
                        suffixIcon: IconButton(
                            onPressed: () {
                              if (view) {
                                setState(() {
                                  view = false;
                                });
                              } else {
                                setState(() {
                                  view = true;
                                });
                              }
                            },
                            icon: (view)
                                ? const Icon(Iconsax.eye)
                                : const Icon(Iconsax.eye_slash)),
                        fillColor: Colors.white.withOpacity(0.2),
                        filled: true,
                        labelStyle: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        label: const Text("Mot de passe"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        connectmail();
                      }, //since this is only a UI app
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade900,
                          fixedSize:
                              Size(MediaQuery.of(context).size.width, 70),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'Connexion',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (loadtype == "mail")
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext) {
                            return const SingleChildScrollView(
                              child: Resetpassword(),
                            );
                          });
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        'Mot de passe oublié ?',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            loadtype = "fb";
                          });
                          signInWithFacebook();
                        },
                        child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.transparent,
                            backgroundImage:
                                const AssetImage("assets/facebook.png"),
                            child: (loadtype == 'fb')
                                ? const CircularProgressIndicator(
                                    color: Colors.redAccent,
                                  )
                                : null),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            loadtype = "goo";
                          });
                          signInWithGoogle();
                        },
                        child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.transparent,
                            backgroundImage: const AssetImage("assets/goo.png"),
                            child: (loadtype == 'goo')
                                ? const CircularProgressIndicator(
                                    color: Colors.redAccent,
                                  )
                                : null),
                      )
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      showcreatecompte();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 30, bottom: 20),
                      child: Center(
                        child: RichText(
                          text: const TextSpan(children: [
                            TextSpan(
                                text: "Vous n'avez pas de compte ? ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                )),
                            TextSpan(
                                text: "Creer un compte",
                                style: TextStyle(
                                    color: Color(0xffff2d55),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold))
                          ]),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
          Text(
            'COPYRIGHT BY AMJ GROUPE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          )
        ],
      )),
    );
  }

  connectmail() async {
    if (mailcontroller.text.isEmpty) {
      requ.message("Echec", "Nous vous prions de saisir votre adresse mail.");
    } else if (mdpcontroller.text.isEmpty) {
      requ.message("Echec", "Nous vous prions de saisir un mot de passe.");
    } else {
      setState(() {
        loadtype = "mail";
      });
      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: mailcontroller.text, password: mdpcontroller.text);
        if (credential.user != null) {
          Get.off(() => const Menuhome());
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          loadtype = "";
        });
        if (e.code == 'user-not-found') {
          requ.message("Echec",
              "Aucun utilisateur trouvé pour cet e-mail. Nous vous prions de créer un compte.");
        } else if (e.code == 'wrong-password') {
          requ.message(
              "Echec", "Mauvais mot de passe fourni pour cet utilisateur.");
        }
      }
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((value) async {
      if (value.additionalUserInfo!.isNewUser) {
        utilisateur.doc(value.user!.uid).set(
          {
            "nom": value.user!.displayName,
            "email": value.user!.email,
            "avatar": value.user!.photoURL,
            "iduser": value.user!.uid,
            "wallet": 0,
            "number": value.user!.phoneNumber,
            "notification": 0,
            "ready": false,
            "addscompte": 0,
            "isdata": true,
            "isnotif": true,
            "ispace": true,
            "issave": true,
            "issearche": true
          },
          SetOptions(merge: true),
        ).catchError((Error) {
          setState(() {
            loadtype = "";
          });
          requ.message(
              'Echec', "Quelque chose, c'est mal passé, ressayer plus tard");
        });

        FirebaseFirestore.instance
            .collection('users')
            .doc(value.user!.uid)
            .update({"token": token});
        Get.off(() => const Newuser());
        print(token);
        setState(() {
          loadtype = "";
        });
      } else {
        Get.off(() => const Menuhome());

        setState(() {
          loadtype = "";
        });
      }
    });

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  verifyNumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: numbers,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          requ.message("Echec", "Votre numéro est invalide");
        } else {
          requ.message("Echec",
              "Quelque chose, c'est mal passé, nous vous prions de reprendre");
        }
        setState(() {
          loadtype = "";
        });
        // Handle other errors
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          loadtype = "";
        });
        codeotp(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Create a PhoneAuthCredential with the code
      },
    );
  }

  codeotp(verificationid) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(10),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );
    showModalBottomSheet(
        isDismissible: false,
        backgroundColor: Colors.black.withBlue(25),
        enableDrag: false,
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
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  height: MediaQuery.of(context).size.height / 1.2,
                  child: Stack(
                    children: [
                      Obx(() => (req1.isload.value)
                          ? const Positioned(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.red,
                                ),
                              ),
                            )
                          : const SizedBox()),
                      Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 5,
                              width: 50,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          const Text(
                            'Vérification',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          const Text(
                            "Entrez le code à 6 (six) chiffres que nous avons envoyé à votre numéro.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Pinput(
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: focusedPinTheme,
                              submittedPinTheme: submittedPinTheme,
                              length: 6,
                              onCompleted: (value) async {
                                try {
                                  req1.load(true);
                                  PhoneAuthCredential credential =
                                      PhoneAuthProvider.credential(
                                          verificationId: verificationid,
                                          smsCode: value);
                                  await auth
                                      .signInWithCredential(credential)
                                      .then((value) {
                                    if (value.additionalUserInfo!.isNewUser) {
                                      utilisateur.doc(value.user!.uid).set(
                                        {
                                          "nom": value.user!.uid
                                              .toString()
                                              .substring(0, 5),
                                          "email": value.user!.email,
                                          "avatar": noimage,
                                          "iduser": value.user!.uid,
                                          "wallet": 0,
                                          "number": value.user!.phoneNumber,
                                          "notification": 0,
                                          "ready": false,
                                          "addscompte": 0,
                                          "isdata": true,
                                          "isnotif": true,
                                          "ispace": true,
                                          "issave": true,
                                          "issearche": true
                                        },
                                        SetOptions(merge: true),
                                      ).catchError((Error) {
                                        requ.message('Echec',
                                            "Quelque chose, c'est mal passé, ressayer plus tard");
                                      });
                                      Navigator.of(context).pop();
                                      Get.off(() => const Newuser());
                                      req1.load(false);
                                    } else {
                                      Navigator.of(context).pop();
                                      Get.off(() => const Menuhome());
                                      req1.load(false);
                                    }
                                  });
                                } on FirebaseAuthException catch (e) {
                                  print(e.message);
                                  req1.load(false);
                                  requ.message('Echec',
                                      "Code saisir incorrecte, nous vous prions de vérifier le code envoyé et de ressayer.");
                                }
                              }),
                          const SizedBox(
                            height: 100,
                          ),
                          const Text(
                            "Vous n'avez pas reçu de code. ?",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              "Demander un nouveau code",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          )
                        ],
                      )
                    ],
                  ));
            },
          );
        });
  }

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential)
        .then((value) async {
      if (value.additionalUserInfo!.isNewUser) {
        utilisateur.doc(value.user!.uid).set(
          {
            "nom": value.user!.displayName,
            "email": value.user!.email,
            "avatar": value.user!.photoURL,
            "iduser": value.user!.uid,
            "wallet": 0,
            "number": value.user!.phoneNumber,
            "notification": 0,
            "ready": false,
            "addscompte": 0,
            "isdata": true,
            "isnotif": true,
            "ispace": true,
            "issave": true,
            "issearche": true
          },
          SetOptions(merge: true),
        ).catchError((Error) {
          setState(() {
            loadtype = "";
          });
          requ.message(
              'Echec', "Quelque chose, c'est mal passé, ressayer plus tard");
        });

        FirebaseFirestore.instance
            .collection('users')
            .doc(value.user!.uid)
            .update({"token": token});
        Get.off(() => const Newuser());
        print(token);
        setState(() {
          loadtype = "";
        });
      } else {
        Get.off(() => const Menuhome());

        setState(() {
          loadtype = "";
        });
      }
    });

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  showcreatecompte() {
    showModalBottomSheet(
        backgroundColor: Colors.black.withBlue(20),
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
                  margin: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 5,
                          width: 50,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100))),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Center(
                          child: Text("Création de compte.",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Creatcompte()
                      ],
                    ),
                  ));
            },
          );
        });
  }

  Widget mail(String hint, bool pass) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30), color: Colors.white),
        child: TextFormField(
          controller: mailcontroller,
          decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.ubuntu(color: Colors.grey),
              contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
              prefixIcon: const Icon(
                Icons.person_outline,
                color: Colors.grey,
              ),
              border: const UnderlineInputBorder(borderSide: BorderSide.none)),
        ),
      ),
    );
  }

  Widget mdp(String hint, bool pass) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30), color: Colors.white),
        child: TextFormField(
          controller: mdpcontroller,
          decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.ubuntu(color: Colors.grey),
              contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Colors.grey,
              ),
              border: const UnderlineInputBorder(borderSide: BorderSide.none)),
        ),
      ),
    );
  }
}

class DrawClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.80);
    path.cubicTo(size.width / 4, size.height, 3 * size.width / 4,
        size.height / 2, size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class DrawClip2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.80);
    path.cubicTo(size.width / 4, size.height, 3 * size.width / 4,
        size.height / 2, size.width, size.height * 0.9);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class Creatcompte extends StatefulWidget {
  const Creatcompte({Key? key}) : super(key: key);

  @override
  _CreatcompteState createState() => _CreatcompteState();
}

class _CreatcompteState extends State<Creatcompte> {
  final mailcontroller = TextEditingController();
  final mdpcontroller = TextEditingController();
  final mdpconfcontroller = TextEditingController();
  final requ = Get.put(Tabsrequette());
  bool load = false;
  String token = "";
  String noimage =
      "https://firebasestorage.googleapis.com/v0/b/flutterprojet-e8896.appspot.com/o/business%2Favatar.png?alt=media&token=1c03953b-cd2d-4df3-808f-68e47ba0a8fd";

  CollectionReference utilisateur =
      FirebaseFirestore.instance.collection("users");
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          mail("Adress mail"),
          mdp("Mot de passe"),
          mdpcf("Confirmation mot de passe"),
          GestureDetector(
              onTap: createusermail,
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
                        "Créer mon compte",
                        style: GoogleFonts.ubuntu(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
                ),
              )),
        ],
      ),
    );
  }

  Widget mail(String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30), color: Colors.white),
        child: TextFormField(
          controller: mailcontroller,
          decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.ubuntu(color: Colors.grey),
              contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
              prefixIcon: const Icon(
                Icons.person_outline,
                color: Colors.grey,
              ),
              border: const UnderlineInputBorder(borderSide: BorderSide.none)),
        ),
      ),
    );
  }

  Widget mdp(String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30), color: Colors.white),
        child: TextFormField(
          obscureText: true,
          controller: mdpcontroller,
          decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.ubuntu(color: Colors.grey),
              contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Colors.grey,
              ),
              border: const UnderlineInputBorder(borderSide: BorderSide.none)),
        ),
      ),
    );
  }

  Widget mdpcf(String hint) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: Colors.white),
          child: TextFormField(
            obscureText: true,
            controller: mdpconfcontroller,
            decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.ubuntu(color: Colors.grey),
                contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Colors.grey,
                ),
                border:
                    const UnderlineInputBorder(borderSide: BorderSide.none)),
          ),
        ),
      ),
    );
  }

  createusermail() async {
    print("oiau");
    if (mailcontroller.text.isEmpty) {
      requ.message("Echec", "Nous vous prions de saisir votre adresse mail.");
    } else if (mdpcontroller.text.isEmpty) {
      requ.message("Echec", "Nous vous prions de saisir un mot de passe.");
    } else if (mdpconfcontroller.text.isEmpty) {
      requ.message(
          "Echec", "Nous vous prions de confirmer votre mot de passe.");
    } else {
      if (mdpconfcontroller.text != mdpcontroller.text) {
        requ.message("Echec", "Vos deux mots de passe ne correspondent pas.");
      } else {
        try {
          setState(() {
            load = true;
          });
          final credential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: mailcontroller.text,
            password: mdpcontroller.text,
          );
          if (credential.user != null) {
            FirebaseFirestore.instance
                .collection("users")
                .doc(credential.user!.uid)
                .set(
              {
                "nom": credential.user!.uid.substring(0, 5),
                "email": credential.user!.email,
                "avatar": noimage,
                "iduser": credential.user!.uid,
                "wallet": 0,
                "number": credential.user!.phoneNumber,
                "notification": 0,
                "ready": false,
                "addscompte": 0,
                "isdata": true,
                "isnotif": true,
                "ispace": true,
                "issave": true,
                "issearche": true
              },
              SetOptions(merge: true),
            );
            FirebaseFirestore.instance
                .collection('users')
                .doc(credential.user!.uid)
                .update({"token": token});
            Navigator.of(context).pop();
            Get.off(() => const Newuser());
            print(token);
            setState(() {
              load = false;
            });
          }
        } on FirebaseAuthException catch (e) {
          setState(() {
            load = false;
          });
          if (e.code == 'weak-password') {
            requ.message("Echec",
                "Le mot de passe fourni est trop faible. Le mot de passe doit contenir 6 caractères.");
          } else if (e.code == 'email-already-in-use') {
            requ.message("Echec",
                "Le compte existe déjà pour cet e-mail. Nous vous prions de vous connecter si le mail vous appartient.");
          }
        } catch (e) {
          print(e);
        }
      }
    }
  }
}
