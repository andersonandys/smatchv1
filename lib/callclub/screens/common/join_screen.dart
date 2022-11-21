// ignore_for_file: non_constant_identifier_names, dead_code

import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smatch/callclub/utils/api.dart';
import 'package:smatch/callclub/widgets/common/joining_details/joining_details.dart';

import '../../constants/colors.dart';
import '../../utils/spacer.dart';
import '../../utils/toast.dart';
import '../one-to-one/one_to_one_meeting_screen.dart';

// Join Screen
class JoinScreen extends StatefulWidget {
  JoinScreen({Key? key, required this.nameuser, required this.idbranche})
      : super(key: key);
  String nameuser;
  var idbranche;
  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  String _token = "";

  // Control Status
  bool isMicOn = false;
  bool isCameraOn = false;

  bool? isJoinMeetingSelected;
  bool? isCreateMeetingSelected;

  // Camera Controller
  CameraController? cameraController;

  @override
  void initState() {
    initCameraPreview();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    FirebaseFirestore.instance.collection("call").get().then((value) {
      print(value.docs.first['token']);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final token = await fetchToken(context, value.docs.first['token']);
        setState(() => _token = token);
      });
    });

    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   final token = await fetchToken(context,'');
    //   setState(() => _token = token);
    // });
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPopScope,
        child: Scaffold(
          backgroundColor: primaryColor,
          body: SafeArea(
            child: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Camera Preview
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 100, horizontal: 36),
                            child: SizedBox(
                              height: 300,
                              width: 200,
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  (cameraController == null) && isCameraOn
                                      ? !(cameraController
                                                  ?.value.isInitialized ??
                                              false)
                                          ? Container(
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                            )
                                          : Container(
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                            )
                                      : AspectRatio(
                                          aspectRatio: 1 / 1.55,
                                          child: isCameraOn
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: CameraPreview(
                                                    cameraController!,
                                                  ))
                                              : Container(
                                                  decoration: BoxDecoration(
                                                      color: black800,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                  child: const Center(
                                                    child: Text(
                                                      "Votre camera est désactivée",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                  Positioned(
                                    bottom: 16,

                                    // Meeting ActionBar
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Mic Action Button
                                          ElevatedButton(
                                            onPressed: () => setState(
                                              () => isMicOn = !isMicOn,
                                            ),
                                            child: Icon(
                                                isMicOn
                                                    ? Icons.mic
                                                    : Icons.mic_off,
                                                color: isMicOn
                                                    ? grey
                                                    : Colors.white),
                                            style: ElevatedButton.styleFrom(
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.all(12),
                                              primary:
                                                  isMicOn ? Colors.white : red,
                                              onPrimary: Colors.black,
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (isCameraOn) {
                                                cameraController?.dispose();
                                                cameraController = null;
                                              } else {
                                                initCameraPreview();
                                                // cameraController?.resumePreview();
                                              }
                                              setState(() =>
                                                  isCameraOn = !isCameraOn);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.all(12),
                                              backgroundColor: isCameraOn
                                                  ? Colors.white
                                                  : red,
                                            ),
                                            child: Icon(
                                              isCameraOn
                                                  ? Icons.videocam
                                                  : Icons.videocam_off,
                                              color: isCameraOn
                                                  ? grey
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('branche')
                                .where("idbranche", isEqualTo: widget.idbranche)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                // TODO: do something with the error
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              return Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(36.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        if (!snapshot
                                            .data!.docs.first["iscall"])
                                          MaterialButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              color: purple,
                                              child: const Text(
                                                  "Creer un salon",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white)),
                                              onPressed: () => {
                                                    createAndJoinMeeting("", "")
                                                  }),
                                        const VerticalSpacer(16),
                                        if (snapshot.data!.docs.first["iscall"])
                                          MaterialButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              color: black500,
                                              child: const Text(
                                                  "Rejoindre le salon",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white)),
                                              onPressed: () => {
                                                    joinMeeting(
                                                        "callType",
                                                        widget.nameuser,
                                                        snapshot.data!.docs
                                                            .first["meetingid"])
                                                  }),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }

  Future<bool> _onWillPopScope() async {
    if (isJoinMeetingSelected != null && isCreateMeetingSelected != null) {
      setState(() {
        isJoinMeetingSelected = null;
        isCreateMeetingSelected = null;
      });
      return false;
    } else {
      return true;
    }
  }

  void initCameraPreview() {
    // Get available cameras
    availableCameras().then((availableCameras) {
      // stores selected camera id
      int selectedCameraId = availableCameras.length > 1 ? 1 : 0;

      cameraController = CameraController(
        availableCameras[selectedCameraId],
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      log("Starting Camera");
      cameraController!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    }).catchError((err) {
      log("Error: $err");
    });
  }

  void _onClickMeetingJoin(meetingId, callType, displayName) async {
    cameraController?.dispose();
    cameraController = null;
    if (displayName.toString().isEmpty) {
      displayName = "Guest";
    }
    if (isCreateMeetingSelected!) {
      createAndJoinMeeting(callType, displayName);
    } else {
      joinMeeting(callType, displayName, meetingId);
    }
  }

  Future<void> createAndJoinMeeting(callType, displayName) async {
    print(widget.idbranche);

    var _meetingID = await createMeeting(_token);
    FirebaseFirestore.instance
        .collection("branche")
        .doc(widget.idbranche)
        .update({"iscall": true, "meetingid": _meetingID});
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OneToOneMeetingScreen(
          token: _token,
          meetingId: _meetingID,
          displayName: widget.nameuser,
          micEnabled: isMicOn,
          camEnabled: isCameraOn,
        ),
      ),
    );
  }

  Future<void> joinMeeting(callType, displayName, meetingId) async {
    if (meetingId.isEmpty) {
      showSnackBarMessage(
          message: "Please enter Valid Meeting ID", context: context);
      return;
    }

    var validMeeting = await validateMeeting(_token, meetingId);
    if (validMeeting) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OneToOneMeetingScreen(
            token: _token,
            meetingId: meetingId,
            displayName: displayName,
            micEnabled: isMicOn,
            camEnabled: isCameraOn,
          ),
        ),
      );
    } else {
      showSnackBarMessage(message: "Invalid Meeting ID", context: context);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}
