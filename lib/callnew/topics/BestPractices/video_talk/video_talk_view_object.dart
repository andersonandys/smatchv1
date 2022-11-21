//
//  video_talk_view_object.dart
//  zego-express-example-topics-flutter
//
//  Created by Patrick Fu on 2020/11/19.
//  Copyright © 2020 Zego. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:smatch/callnew/utils/zego_log_view.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class VideoTalkViewObject {
  final bool isLocal;
  final String streamID;

  late int viewID;
  Widget? view;

  VideoTalkViewObject(this.isLocal, this.streamID);

  void init(Function() completed) async {
    ZegoLog().addLog("createCanvasView start");
    this.view = await ZegoExpressEngine.instance.createCanvasView((viewID) {
      this.viewID = viewID;
      completed();
    }, key: UniqueKey());
  }

  void uninit() {
    ZegoExpressEngine.instance.destroyCanvasView(this.viewID);
  }
}
