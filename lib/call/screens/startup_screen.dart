// ignore_for_file: non_constant_identifier_names, dead_code

import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../constants/colors.dart';
import '../utils/spacer.dart';
import '../utils/toast.dart';
import 'join_screen.dart';
import 'meeting_screen.dart';
import 'package:get/get.dart';

// Startup Screen
class StartupScreen extends StatefulWidget {
  StartupScreen({Key? key}) : super(key: key);

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  String _token = "";
  String _meetingID = "";
  String newmeeting = "";
  String newtoken = "";
  bool loadjoin = false;
  bool loadcreat = false;
  String idcreat = Get.arguments[0]["idcreat"];
  int admin = Get.arguments[1]['admin'];
  String avatar = Get.arguments[2]['avatar'];
  String nom = Get.arguments[3]['nom'];
  String idbranche = Get.arguments[4]['idbranche'];
  String nombranche = Get.arguments[5]['nombranche'];
  String userid = FirebaseAuth.instance.currentUser!.uid;
  bool call = false;
  bool load = false;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection("call").get().then((value) {
      print(value.docs.first['token']);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final token = await fetchToken(value.docs.first['token']);
        setState(() => _token = token);
      });
    });

    FirebaseFirestore.instance
        .collection("branche")
        .where("idbranche", isEqualTo: idbranche)
        .get()
        .then((value) {
      for (var element in value.docs) {
        print(element['iscall']);

        if (element['iscall'] == true) {
          setState(() {
            call = true;
            newmeeting = element['meetingid'];
            newtoken = element['meetingtoken'];
          });
        }
      }
    });
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nombranche),
        elevation: 0,
        backgroundColor: const Color(0xFF242424),
      ),
      backgroundColor: const Color(0xFF242424),
      body: SafeArea(
        child: _token.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    HorizontalSpacer(12),
                    Text(
                      "Initialisation",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/slide_1.jpg',
                      height: 500,
                    ),
                  ),
                  if (idcreat == userid || admin == 1)
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.black.withBlue(20),
                            fixedSize:
                                Size(MediaQuery.of(context).size.width, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        onPressed: onCreateMeetingButtonPressed,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            if (loadcreat)
                              const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  )),
                            const Text("Lancer un salon")
                          ],
                        ),
                      ),
                    ),
                  if (call)
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: onJoinMeetingButtonPressed,
                        style: ElevatedButton.styleFrom(
                            primary: Colors.orange.shade900,
                            fixedSize:
                                Size(MediaQuery.of(context).size.width, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            if (loadjoin)
                              const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  )),
                            const Text("Rejoindre le salon")
                          ],
                        ),
                      ),
                    )
                ],
              ),
      ),
    );
  }

  Future<String> fetchToken(calltoken) async {
    if (!dotenv.isInitialized) {
      // Load Environment variables
      await dotenv.load(fileName: ".env");
    }
    final String? _AUTH_URL = dotenv.env['AUTH_URL'];
    String? _AUTH_TOKEN = calltoken;

    if ((_AUTH_TOKEN?.isEmpty ?? true) && (_AUTH_URL?.isEmpty ?? true)) {
      toastMsg("Please set the environment variables");
      throw Exception("Either AUTH_TOKEN or AUTH_URL is not set in .env file");
      return "";
    }

    if ((_AUTH_TOKEN?.isNotEmpty ?? false) &&
        (_AUTH_URL?.isNotEmpty ?? false)) {
      toastMsg("Please set only one environment variable");
      throw Exception("Either AUTH_TOKEN or AUTH_URL can be set in .env file");
      return "";
    }

    if (_AUTH_URL?.isNotEmpty ?? false) {
      final Uri getTokenUrl = Uri.parse('$_AUTH_URL/get-token');
      final http.Response tokenResponse = await http.get(getTokenUrl);
      _AUTH_TOKEN = json.decode(tokenResponse.body)['token'];
    }

    // log("Auth Token: $_AUTH_TOKEN");

    return _AUTH_TOKEN ?? "";
  }

  Future<void> onCreateMeetingButtonPressed() async {
    setState(() {
      loadcreat = true;
    });
    final String? _VIDEOSDK_API_ENDPOINT = dotenv.env['VIDEOSDK_API_ENDPOINT'];

    final Uri getMeetingIdUrl = Uri.parse('$_VIDEOSDK_API_ENDPOINT/meetings');
    final http.Response meetingIdResponse =
        await http.post(getMeetingIdUrl, headers: {
      "Authorization": _token,
    });

    _meetingID = json.decode(meetingIdResponse.body)['meetingId'];

    log("Meeting ID: $_meetingID");
    FirebaseFirestore.instance.collection('branche').doc(idbranche).update(
        {"iscall": true, "meetingid": _meetingID, "meetingtoken": _token});
    setState(() {
      loadcreat = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingScreen(
          token: _token,
          meetingId: _meetingID,
          displayName: nom,
          avatar: avatar,
          nombranche: nombranche,
        ),
      ),
    );
  }

  Future<void> onJoinMeetingButtonPressed() async {
    setState(() {
      loadjoin = true;
    });
    final String? _VIDEOSDK_API_ENDPOINT = dotenv.env['VIDEOSDK_API_ENDPOINT'];

    final Uri validateMeetingUrl =
        Uri.parse('$_VIDEOSDK_API_ENDPOINT/meetings/$newmeeting');
    final http.Response validateMeetingResponse = await http
        .post(validateMeetingUrl, headers: {"Authorization": newtoken});

    if (validateMeetingResponse.statusCode == 200) {
      setState(() {
        loadjoin = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinScreen(
            meetingId: newmeeting,
            token: newtoken,
            avatar: avatar,
            nombranche: nombranche,
            nomuser: nom,
          ),
        ),
      );
    } else {
      toastMsg("Désolé, vous ne pouvez pas rejoindre le salon.");
    }
  }
}
