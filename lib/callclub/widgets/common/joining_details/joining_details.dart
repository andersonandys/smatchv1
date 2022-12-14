import 'package:flutter/material.dart';
import 'package:smatch/callclub/constants/colors.dart';
import 'package:smatch/callclub/utils/spacer.dart';
import 'package:smatch/callclub/utils/toast.dart';

class JoiningDetails extends StatefulWidget {
  bool isCreateMeeting;
  Function onClickMeetingJoin;

  JoiningDetails(
      {Key? key,
      required this.isCreateMeeting,
      required this.onClickMeetingJoin})
      : super(key: key);

  @override
  State<JoiningDetails> createState() => _JoiningDetailsState();
}

class _JoiningDetailsState extends State<JoiningDetails> {
  String _meetingId = "";
  String _displayName = "";
  String _callType = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.isCreateMeeting)
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), color: black750),
            child: TextField(
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              onChanged: ((value) => _meetingId = value),
              decoration: const InputDecoration(
                  hintText: "Enter meeting code",
                  hintStyle: TextStyle(
                    color: textGray,
                  ),
                  border: InputBorder.none),
            ),
          ),
        const VerticalSpacer(16),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: black750),
          child: TextField(
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
            onChanged: ((value) => _displayName = value),
            decoration: const InputDecoration(
                hintText: "Enter your name",
                hintStyle: TextStyle(
                  color: textGray,
                ),
                border: InputBorder.none),
          ),
        ),
        const VerticalSpacer(16),
        MaterialButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: purple,
            child: const Text("Rejoindre la r??union",
                style: TextStyle(fontSize: 16)),
            onPressed: () {
              if (_displayName.trim().isEmpty) {
                showSnackBarMessage(
                    message: "Veuillez entrer le nom", context: context);
                return;
              }
              if (!widget.isCreateMeeting && _meetingId.trim().isEmpty) {
                showSnackBarMessage(
                    message: "Veuillez entrer l'identifiant de la r??union",
                    context: context);
                return;
              }
              widget.onClickMeetingJoin(
                  _meetingId.trim(), _callType, _displayName.trim());
            }),
      ],
    );
  }
}
