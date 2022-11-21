import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../utils/spacer.dart';

import '../widgets/meeting_controls/meeting_action_button.dart';
import 'meeting_screen.dart';

// Join Screen
class JoinScreen extends StatefulWidget {
  final String meetingId;
  final String token;
  final String avatar, nombranche, nomuser;

  const JoinScreen({
    Key? key,
    required this.meetingId,
    required this.token,
    required this.avatar,
    required this.nombranche,
    required this.nomuser,
  }) : super(key: key);

  @override
  _JoinScreenState createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  // Display Name
  String displayName = "";

  // Control Status
  bool isMicOn = true;
  bool isCameraOn = true;

  // Camera Controller
  CameraController? cameraController;

  @override
  void initState() {
    super.initState();

    // Get available cameras
    availableCameras().then((availableCameras) {
      // stores selected camera id
      int selectedCameraId = availableCameras.length > 1 ? 1 : 0;

      cameraController = CameraController(
        availableCameras[selectedCameraId],
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      cameraController!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    }).catchError((err) {
      log("Error: $err");
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        // Screen Title
        title: Text(widget.nombranche),
        elevation: 0,
        backgroundColor: const Color(0xFF242424),
      ),
      backgroundColor: const Color(0xFF242424),
      body: SafeArea(
        child: !(cameraController?.value.isInitialized ?? false)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Camera Preview
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: (MediaQuery.of(context).size.height / 2),
                        ),
                        child: Stack(
                          // fit: StackFit.expand,
                          children: [
                            isCameraOn
                                ? Center(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(7)),
                                      child: CameraPreview(cameraController!),
                                    ),
                                  )
                                : Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(7)),
                                        color: Colors.black),
                                    child: const Center(
                                      child: Text(
                                        "Camera est désactivée",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,

                              // Meeting ActionBar
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  // Mic Action Button
                                  MeetingActionButton(
                                    icon: isMicOn ? Icons.mic : Icons.mic_off,
                                    backgroundColor: isMicOn
                                        ? Theme.of(context).primaryColor
                                        : Colors.red,
                                    iconColor: Colors.white,
                                    radius: 30,
                                    onPressed: () => setState(
                                      () => isMicOn = !isMicOn,
                                    ),
                                  ),

                                  // Camera Action Button
                                  MeetingActionButton(
                                    backgroundColor: isCameraOn
                                        ? Theme.of(context).primaryColor
                                        : Colors.red,
                                    iconColor: Colors.white,
                                    radius: 30,
                                    onPressed: () {
                                      if (isCameraOn) {
                                        cameraController?.pausePreview();
                                      } else {
                                        cameraController?.resumePreview();
                                      }
                                      setState(() => isCameraOn = !isCameraOn);
                                    },
                                    icon: isCameraOn
                                        ? Icons.videocam
                                        : Icons.videocam_off,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Join Button
                  Padding(
                    // padding: EdgeInsets.only(left: 10, right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        // By default Guest is used as display name
                        if (displayName.isEmpty) {
                          displayName = "Guest";
                        }

                        // Dispose Camera Controller before leaving screen
                        await cameraController?.dispose();

                        // Open meeting screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MeetingScreen(
                              token: widget.token,
                              meetingId: widget.meetingId,
                              displayName: widget.nomuser,
                              micEnabled: isMicOn,
                              camEnabled: isCameraOn,
                              avatar: widget.avatar,
                              nombranche: widget.nombranche,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Rejoindre",
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.orange.shade900,
                          fixedSize: Size(size.width, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose Camera Controller
    cameraController?.dispose();
    super.dispose();
  }
}
