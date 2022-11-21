//
//  video_talk_page.dart
//  zego-express-example-topics-flutter
//
//  Created by Patrick Fu on 2020/11/16.
//  Copyright © 2020 Zego. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:smatch/callnew/topics/BestPractices/video_talk/video_talk_view_object.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew/utils/zego_log_view.dart';
import 'package:smatch/callnew/utils/zego_user_helper.dart';

class VideoTalkPage extends StatefulWidget {
  @override
  _VideoTalkPageState createState() => _VideoTalkPageState();
}

class _VideoTalkPageState extends State<VideoTalkPage> {
  final String _roomID = 'VideoTalkRoom-1';
  final String _streamID = 's-${ZegoUserHelper.instance.userID}';
  final List playStreamIDList = [];

  ZegoRoomState _roomState = ZegoRoomState.Disconnected;

  List<VideoTalkViewObject> _viewObjectList = [];

  late VideoTalkViewObject _localUserViewObject;

  bool _isEnableCamera = true;
  set isEnableCamera(bool value) {
    setState(() => _isEnableCamera = value);
    ZegoExpressEngine.instance.enableCamera(value);
  }

  bool _isMutePlayStreamAudio = true;
  set isMutePlayStreamAudio(bool value) {
    setState(() => _isMutePlayStreamAudio = value);
    playStreamIDList.forEach((streamID) {
      ZegoExpressEngine.instance.mutePlayStreamAudio(streamID, !value);
    });
  }

  bool _isEnablePlayStreamVideo = true;
  set isEnablePlayStreamVideo(bool value) {
    setState(() => _isEnablePlayStreamVideo = value);
    playStreamIDList.forEach((streamID) {
      ZegoExpressEngine.instance.mutePlayStreamVideo(streamID, !value);
    });
  }

  bool _isEnableMic = true;
  set isEnableMic(bool value) {
    setState(() => _isEnableMic = value);
    ZegoExpressEngine.instance.mutePublishStreamAudio(!value);
  }

  @override
  void initState() {
    super.initState();

    setZegoEventCallback();

    joinTalkRoom();
  }

  @override
  void dispose() {
    exitTalkRoom();

    clearZegoEventCallback();

    super.dispose();
  }

  // MARK: TalkRoom Methods

  Future<void> joinTalkRoom() async {
    // Create ZegoExpressEngine
    ZegoLog().addLog("🚀 Create ZegoExpressEngine");
    ZegoEngineProfile profile = ZegoEngineProfile(
        ZegoConfig.instance.appID, ZegoScenario.Communication,
        enablePlatformView: ZegoConfig.instance.enablePlatformView,
        appSign: kIsWeb ? null : ZegoConfig.instance.appSign);
    await ZegoExpressEngine.createEngineWithProfile(profile);

    // Login Room
    ZegoLog().addLog("🚪 Login room, roomID: $_roomID");
    ZegoUser user = ZegoUser(
        ZegoUserHelper.instance.userID, ZegoUserHelper.instance.userName);
    ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
    if (kIsWeb) {
      var token = await ZegoConfig.instance
          .getToken(ZegoUserHelper.instance.userID, _roomID);
      config.token = token;
    }
    await ZegoExpressEngine.instance.loginRoom(_roomID, user, config: config);

    // Set the publish video configuration
    ZegoLog().addLog("⚙️ Set video config: 540p preset");
    await ZegoExpressEngine.instance.setVideoConfig(
        ZegoVideoConfig.preset(ZegoVideoConfigPreset.Preset540P));

    // Start Preview
    ZegoLog().addLog("🔌 Start preview");
    _localUserViewObject = VideoTalkViewObject(true, this._streamID);
    _localUserViewObject.init(() {
      setState(() {});
      ZegoExpressEngine.instance
          .startPreview(canvas: ZegoCanvas.view(_localUserViewObject.viewID));
    });

    setState(() {
      _viewObjectList.add(_localUserViewObject);
    });

    // Start Publish
    ZegoLog().addLog("📤 Start publishing stream, streamID: $_streamID");
    await ZegoExpressEngine.instance.startPublishingStream(_streamID);
  }

  Future<void> exitTalkRoom() async {
    ZegoLog().addLog("📤 Stop publishing stream");
    await ZegoExpressEngine.instance.stopPublishingStream();

    ZegoLog().addLog("🔌 Stop preview");
    await ZegoExpressEngine.instance.stopPreview();

    // It is recommended to logout room when stopping the video call.
    ZegoLog().addLog("🚪 Logout room, roomID: $_roomID");
    await ZegoExpressEngine.instance.logoutRoom(_roomID);

    // And you can destroy the engine when there is no need to call.
    ZegoLog().addLog("🏳️ Destroy ZegoExpressEngine");
    await ZegoExpressEngine.destroyEngine();
  }

  // MARK: - ViewObject Methods

  /// Add a view of user who has entered the room and play the user stream
  void addRemoteViewObjectWithStreamID(String streamID) {
    VideoTalkViewObject viewObject = VideoTalkViewObject(false, streamID);

    viewObject.init(() {
      setState(() {});

      ZegoCanvas playCanvas = ZegoCanvas.view(viewObject.viewID);
      playCanvas.viewMode = ZegoViewMode.AspectFill;

      ZegoLog().addLog('📥 Start playing stream, streamID: $streamID');
      ZegoExpressEngine.instance
          .startPlayingStream(streamID, canvas: playCanvas);
    });

    setState(() {
      _viewObjectList.add(viewObject);
    });
  }

  void removeViewObjectWithStreamID(String streamID) {
    ZegoLog().addLog('📥 Stop playing stream, streamID: $streamID');
    ZegoExpressEngine.instance.stopPlayingStream(streamID);

    for (VideoTalkViewObject viewObject in _viewObjectList) {
      if (viewObject.streamID == streamID) {
        viewObject.uninit();
        _viewObjectList.remove(viewObject);
        break;
      }
    }
    setState(() {});
  }

  // MARK: - Zego Event

  void setZegoEventCallback() {
    ZegoExpressEngine.onRoomStateUpdate = (String roomID, ZegoRoomState state,
        int errorCode, Map<String, dynamic> extendedData) {
      ZegoLog().addLog(
          "🚩 🚪 Room state update, state: $state, errorCode: $errorCode, roomID: $roomID");
      setState(() {
        _roomState = state;
      });
    };

    ZegoExpressEngine.onRoomStreamUpdate = (String roomID,
        ZegoUpdateType updateType,
        List<ZegoStream> streamList,
        Map<String, dynamic> extendedData) {
      ZegoLog().addLog(
          "🚩 🌊 Room stream update, type: $updateType, streamsCount: ${streamList.length}, roomID: $roomID");

      List allStreamIDList = _viewObjectList.map((e) => e.streamID).toList();

      if (updateType == ZegoUpdateType.Add) {
        setState(() {
          for (ZegoStream stream in streamList) {
            ZegoLog().addLog(
                "🚩 🌊 --- [Add] StreamID: ${stream.streamID}, UserID: ${stream.user.userID}");

            if (!allStreamIDList.contains(stream.streamID)) {
              addRemoteViewObjectWithStreamID(stream.streamID);
              playStreamIDList.add(stream.streamID);
            }
          }
        });
      } else if (updateType == ZegoUpdateType.Delete) {
        setState(() {
          for (ZegoStream stream in streamList) {
            ZegoLog().addLog(
                "🚩 🌊 --- [Delete] StreamID: ${stream.streamID}, UserID: ${stream.user.userID}");

            removeViewObjectWithStreamID(stream.streamID);
            playStreamIDList.remove(stream.streamID);
          }
        });
      }
    };
  }

  void clearZegoEventCallback() {
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onRoomStreamUpdate = null;
  }

  // MARK: Widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("VideoTalk"),
      ),
      body: SafeArea(
        child: mainContent(),
      ),
    );
  }

  Widget mainContent() {
    return Column(
      children: [
        SizedBox(
          child: ZegoLogView(),
          height: MediaQuery.of(context).size.height * 0.1,
        ),
        Container(
          child: roomInfoWidget(),
          padding: EdgeInsets.all(5.0),
        ),
        Expanded(
          child: GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 5.0,
              crossAxisSpacing: 5.0,
              childAspectRatio: 3.0 / 4.0,
            ),
            children:
                _viewObjectList.map((e) => e.view ?? Container()).toList(),
            padding: EdgeInsets.all(5.0),
          ),
        ),
        togglesWidget(),
      ],
    );
  }

  Widget togglesWidget() {
    return Row(children: [
      Column(children: [
        Text('Camera'),
        Switch(
            value: _isEnableCamera,
            onChanged: (value) => isEnableCamera = value),
      ]),
      Column(children: [
        Text('MutePublishStreamAudio'),
        Switch(value: _isEnableMic, onChanged: (value) => isEnableMic = value),
      ]),
      Column(children: [
        Text('PlayStreamAudio'),
        Switch(
            value: _isMutePlayStreamAudio,
            onChanged: (value) => isMutePlayStreamAudio = value),
      ]),
      Column(children: [
        Text('PlayStreamVideo'),
        Switch(
            value: _isEnablePlayStreamVideo,
            onChanged: (value) => isEnablePlayStreamVideo = value),
      ])
    ], mainAxisAlignment: MainAxisAlignment.spaceEvenly);
  }

  Widget roomInfoWidget() {
    return Row(children: [
      Text("RoomID: $_roomID"),
      Spacer(),
      Text(roomStateDesc()),
    ]);
  }

  String roomStateDesc() {
    switch (_roomState) {
      case ZegoRoomState.Disconnected:
        return "Disconnected 🔴";
        break;
      case ZegoRoomState.Connecting:
        return "Connecting 🟡";
        break;
      case ZegoRoomState.Connected:
        return "Connected 🟢";
        break;
      default:
        return "Unknown";
    }
  }
}
