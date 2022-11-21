import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:smatch/callclub/constants/colors.dart';
import 'package:smatch/callclub/utils/spacer.dart';
import 'package:videosdk/videosdk.dart';

class ParticipantLimitReached extends StatelessWidget {
  Room meeting;
  ParticipantLimitReached({Key? key, required this.meeting}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "OOPS!!",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700),
            ),
            const VerticalSpacer(20),
            const Text(
              "Maximum 2 participants peuvent rejoindre cette réunion",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
            const VerticalSpacer(10),
            const Text(
              "Veuillez réessayer plus tard",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
            const VerticalSpacer(20),
            MaterialButton(
              onPressed: () {
                meeting.leave();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: purple,
              child: const Text("Ok", style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}
