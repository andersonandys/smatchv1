import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart' as users;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smatch/business/shop/2/favoris2.dart';
import 'package:smatch/business/vlog/pages/home_page.dart';
import 'package:smatch/business/vlog/pages/video_detail_page.dart';
import 'package:smatch/call/screens/startup_screen.dart';
import 'package:smatch/home/settingsvideo.dart';
import 'package:smatch/home/social.dart';
import 'package:smatch/home/socialpub.dart';
import 'package:smatch/home/videofeed.dart';
import 'package:smatch/home/videofeedpub.dart';
import 'package:smatch/home/viewsocial.dart';
import 'package:smatch/menu/menuhome.dart';
import 'package:smatch/business/dash/dashshop/publicationshop.dart';
import 'package:smatch/business/dash/dashshop/tabsmenu.dart';
import 'package:smatch/business/dash/dashvlog/publicationvlog.dart';
import 'package:smatch/business/dash/dashvlog/tabsvlog.dart';
import 'package:smatch/business/shop/1/home1.dart';
import 'package:smatch/business/shop/1/panier1.dart';
import 'package:smatch/business/shop/1/tabmenus1.dart';
import 'package:smatch/business/shop/2/home2.dart';
import 'package:smatch/business/shop/2/panier2.dart';
import 'package:smatch/business/shop/2/tabsmenu2.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:smatch/home/home.dart';
import 'package:smatch/msgbranche/message.dart';
import 'package:smatch/msgbranche/settings.dart';
import 'package:smatch/msgbranche/viewimage.dart';
import 'package:smatch/msgbranche/viewvideo.dart';
import 'package:smatch/navigator_key.dart';
import 'package:smatch/noeud/settingsnoeud.dart';
import 'package:smatch/onboarding.dart';
import 'package:smatch/wallet/walletuser.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:timeago/timeago.dart' as timeago;

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  AwesomeNotifications().initialize(
      // 'resource://drawable/ic_launcher',
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: "content body",
          defaultColor: Colors.teal,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'basic group')
      ],
      debug: true);
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: 'recaptcha-v3-site-key',
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      AwesomeNotifications().createNotificationFromJsonData(message.data);
    }
    AwesomeNotifications().createNotificationFromJsonData(message.data);
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
  configLoading();
  timeago.setLocaleMessages('fr', timeago.FrMessages());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('non');
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  AwesomeNotifications().createNotificationFromJsonData(message.data);
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false
    ..customAnimation = CustomAnimation();
}

EasyLoadingAnimation? CustomAnimation() {}

class MyApp extends StatelessWidget {
  users.User? user = users.FirebaseAuth.instance.currentUser;

  // This widget is the root of your application.
  MyApp({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: const Locale("fr"),
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(name: '/', page: () => home()),
        GetPage(name: '/onboarding', page: () => OnBoarding()),
        GetPage(name: '/tabsmenushop/', page: () => const Tabsmenushop()),
        GetPage(name: '/publicationshop/', page: () => const publicationshop()),
        GetPage(name: '/1/', page: () => const Tabsmenu1shop()),
        GetPage(name: '/viewproduit1/', page: () => const Viewproduit1()),
        GetPage(name: '/panier1shop/', page: () => const Panier1shop()),
        GetPage(name: '/2/', page: () => const Tabsmenu2shop()),
        GetPage(name: '/panier2shop/', page: () => const Panier2shop()),
        GetPage(name: '/viewproduit2/', page: () => const Viewproduit2()),
        GetPage(name: '/tabsvlog/', page: () => const Tabsvlog()),
        GetPage(name: '/publicationvlog/', page: () => const Publicationvlog()),
        GetPage(name: '/vlog/', page: () => HomePage()),
        GetPage(name: '/lecturevideo/', page: () => const VideoDetailPage()),
        GetPage(name: '/settingsnoeud/', page: () => Settingsnoeud()),
        GetPage(name: '/transactions/', page: () => const Transactions()),
        GetPage(name: '/readactualite/', page: () => const Readactualite()),
        GetPage(name: '/favoris2/', page: () => const Favoris2shop()),
        GetPage(name: '/messagebrache/', page: () => const Messagebranche()),
        GetPage(name: '/viewimage/', page: () => const Viewimage()),
        GetPage(name: '/viewvideo/', page: () => const Viewvideo()),
        GetPage(name: '/salon/', page: () => StartupScreen()),
        GetPage(name: '/settingsbranche/', page: () => const Settingsbranche()),
        GetPage(name: '/checklien/', page: () => const Checklien()),
        GetPage(name: '/social/', page: () => const Social()),
        GetPage(name: '/videofeed/', page: () => const Videofeed()),
        GetPage(name: '/viewsocial/', page: () => const Viewsocial()),
        GetPage(name: '/socialpub/', page: () => const Socialpub()),
        GetPage(name: '/readvideo/', page: () => const Readvideo()),
        GetPage(name: '/videofeedpub/', page: () => const Videofeedpub()),
        GetPage(name: '/settingsvideo/', page: () => const Settingsvideo()),
        GetPage(name: '/mypubsocial/', page: () => const Mypublicationsocial()),
      ],
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          )),
      home: (user != null) ? Menuhome() : OnboardingExample(),
      navigatorKey: navigatorKey,
      builder: EasyLoading.init(),
    );
  }
}

// configuration
// verifier la configuration fb
// verifier les logo et splash screen
// effectuer un dernier test

      // permettre le statte sur modal bottom sheet
        // creatmoment() {
  //   showModalBottomSheet(
  //       enableDrag: true,
  //       isScrollControlled: true,
  //       shape: const RoundedRectangleBorder(
  //         borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
  //       ),
  //       context: context,
  //       builder: (BuildContext context) {
  //         return StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setState) {
  //             return
  //           },
  //         );
  //       });
  // }
//  permet de pouvoir effectuer une recherche 
  // void _runFilter(String enteredKeyword) {
  //   List results = [];
  //   if (enteredKeyword.isEmpty) {
  //     // if the search field is empty or only contains white-space, we'll display all users
  //     results = compte;
  //   } else {
  //     results = compte
  //         .where((user) =>
  //             user["nom"].toLowerCase().contains(enteredKeyword.toLowerCase()))
  //         .toList();
  //     // we use the toLowerCase() method to make it case-insensitive
  //   }

  //   // Refresh the UI
  //   setState(() {
  //     allcomptesearch = results;
  //   });
  //   print(allcomptesearch);
  // }
  //https:firebasestorage.googleapis.com/v0/b/flutterprojet-e8896.appspot.com/o/business%2Favatar.png?alt=media&token=1c03953b-cd2d-4df3-808f-68e47ba0a8f

//   void uploadFileToServer(File imagePath) async {
//   var request = new http.MultipartRequest(
//       "POST", Uri.parse('your api url her'));
// request.fields['name'] = 'Rohan';
// request.fields['title'] = 'My first image';
// request.files.add(await http.MultipartFile.fromPath('profile_pic', imagePath.path));
//   request.send().then((response) {
//     http.Response.fromStream(response).then((onValue) {
//       try {
//         // get your response here...
//       } catch (e) {
//         // handle exeption
//       }
//     });
//   });
// }



// 070A0D
// 2D2F2F
// 1C1E22
// 13151B
// 070A0D
// 101418
// 00193D
// E9F2FF
// 000000