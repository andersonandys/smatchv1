import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:smatch/callclub/utils/spacer.dart';

class WaitingToJoin extends StatelessWidget {
  const WaitingToJoin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(20),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: LoadingAnimationWidget.discreteCircle(
                  color: Colors.white,
                  size: 60,
                  secondRingColor: Colors.blueAccent,
                  thirdRingColor: Colors.orangeAccent),
            ),
            const VerticalSpacer(50),
            const Center(
              child: Text("Création de votre salon, Patientez s'il vous plaît",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}
