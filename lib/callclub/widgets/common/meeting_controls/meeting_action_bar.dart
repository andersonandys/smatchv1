import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smatch/callclub/utils/spacer.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';

import '../../../constants/colors.dart';

// Meeting ActionBar
class MeetingActionBar extends StatelessWidget {
  // control states
  final bool isMicEnabled, isCamEnabled, isScreenShareEnabled;
  final String recordingState;

  // callback functions
  final void Function() onCallEndButtonPressed,
      onCallLeaveButtonPressed,
      onMicButtonPressed,
      onCameraButtonPressed,
      onChatButtonPressed;

  final void Function(String) onMoreOptionSelected;

  final void Function(TapDownDetails) onSwitchMicButtonPressed;
  const MeetingActionBar({
    Key? key,
    required this.isMicEnabled,
    required this.isCamEnabled,
    required this.isScreenShareEnabled,
    required this.recordingState,
    required this.onCallEndButtonPressed,
    required this.onCallLeaveButtonPressed,
    required this.onMicButtonPressed,
    required this.onSwitchMicButtonPressed,
    required this.onCameraButtonPressed,
    required this.onMoreOptionSelected,
    required this.onChatButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PopupMenuButton(
              position: PopupMenuPosition.under,
              padding: EdgeInsets.all(0),
              color: black700,
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: red),
                  color: red,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.call_end,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              offset: Offset(0, -185),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) => {
                    if (value == "leave")
                      onCallLeaveButtonPressed()
                    else if (value == "end")
                      onCallEndButtonPressed()
                  },
              itemBuilder: (context) => <PopupMenuEntry>[
                    _buildMeetingPoupItem(
                      "leave",
                      "Quitter",
                      "Vous seul quitterez l'appel",
                      const Icon(
                        Icons.call_end_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const PopupMenuDivider(),
                    _buildMeetingPoupItem(
                      "end",
                      "Fin de l'appel",
                      "Fin de l'appel pour tous les participants",
                      const Icon(
                        Icons.call_end_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ]),

          // Mic Control
          TouchRippleEffect(
            borderRadius: BorderRadius.circular(12),
            rippleColor: isMicEnabled ? primaryColor : Colors.white,
            onTap: onMicButtonPressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: secondaryColor),
                color: isMicEnabled ? primaryColor : Colors.white,
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    isMicEnabled ? Icons.mic : Icons.mic_off,
                    size: 30,
                    color: isMicEnabled ? Colors.white : primaryColor,
                  ),
                  GestureDetector(
                      onTapDown: (details) =>
                          {onSwitchMicButtonPressed(details)},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: isMicEnabled ? Colors.white : primaryColor,
                        ),
                      )),
                ],
              ),
            ),
          ),

          // Camera Control
          TouchRippleEffect(
            borderRadius: BorderRadius.circular(12),
            rippleColor: primaryColor,
            onTap: onCameraButtonPressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: secondaryColor),
                color: isCamEnabled ? primaryColor : Colors.white,
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(
                isCamEnabled ? Icons.videocam : Icons.videocam_off,
                size: 30,
                color: isCamEnabled ? Colors.white : primaryColor,
              ),
            ),
          ),

          TouchRippleEffect(
            borderRadius: BorderRadius.circular(12),
            rippleColor: primaryColor,
            onTap: onChatButtonPressed,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: secondaryColor),
                  color: primaryColor,
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(Iconsax.message1,
                    size: 30, color: Colors.white)),
          ),

          // More options
          PopupMenuButton(
              position: PopupMenuPosition.under,
              padding: EdgeInsets.all(0),
              color: black700,
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: secondaryColor),
                  // color: red,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              offset: Offset(0, -250),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) => {onMoreOptionSelected(value.toString())},
              itemBuilder: (context) => <PopupMenuEntry>[
                    const PopupMenuDivider(),
                    _buildMeetingPoupItem(
                      "screenshare",
                      isScreenShareEnabled
                          ? "Arrêter le partage d'écran"
                          : "Démarrer le partage d'écran",
                      null,
                      const Icon(Icons.screen_share_rounded,
                          color: Colors.white, size: 30),
                    ),
                    const PopupMenuDivider(),
                    _buildMeetingPoupItem(
                      "participants",
                      "Participants",
                      null,
                      const Icon(Iconsax.user1, color: Colors.white, size: 30),
                    ),
                  ]),
        ],
      ),
    );
  }

  PopupMenuItem<dynamic> _buildMeetingPoupItem(
      String value, String title, String? description, Widget leadingIcon) {
    return PopupMenuItem(
      value: value,
      padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
      child: Row(children: [
        const HorizontalSpacer(5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
            if (description != null) VerticalSpacer(4),
            if (description != null)
              Text(
                description,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500, color: black400),
              )
          ],
        )
      ]),
    );
  }
}
