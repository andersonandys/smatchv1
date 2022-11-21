//
//  quick_start_page.dart
//  zego-express-example-topics-flutter
//
//  Created by Patrick Fu on 2020/12/04.
//  Copyright © 2020 Zego. All rights reserved.
//

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew//utils/zego_log_view.dart';
import 'package:smatch/callnew//utils/zego_user_helper.dart';

class QuickStartPage extends StatefulWidget {
  @override
  _QuickStartPageState createState() => _QuickStartPageState();
}

class _QuickStartPageState extends State<QuickStartPage> {
  final String _roomID = 'QuickStartRoom-1';

  late int _previewViewID;
  late int _playViewID;
  Widget? _previewViewWidget;
  Widget? _playViewWidget;

  bool _isEngineActive = false;
  ZegoRoomState _roomState = ZegoRoomState.Disconnected;
  ZegoPublisherState _publisherState = ZegoPublisherState.NoPublish;
  ZegoPlayerState _playerState = ZegoPlayerState.NoPlay;

  TextEditingController _publishingStreamIDController =
      new TextEditingController();
  TextEditingController _playingStreamIDController =
      new TextEditingController();

  @override
  void initState() {
    super.initState();
    _previewViewID = -1;
    _playViewID = -1;
    ZegoExpressEngine.getVersion()
        .then((value) => ZegoLog().addLog('🌞 SDK Version: $value'));

    setZegoEventCallback();
  }

  @override
  void dispose() {
    clearPreviewView();
    clearPlayView();

    clearZegoEventCallback();
    // Can destroy the engine when you don't need audio and video calls
    //
    // Destroy engine will automatically logout room and stop publishing/playing stream.
    ZegoExpressEngine.destroyEngine();

    ZegoLog().addLog('🏳️ Destroy ZegoExpressEngine');

    super.dispose();
  }

  // MARK: - Step 1: CreateEngine

  void createEngine() {
    ZegoEngineProfile profile = ZegoEngineProfile(
        ZegoConfig.instance.appID, ZegoConfig.instance.scenario,
        enablePlatformView: ZegoConfig.instance.enablePlatformView,
        appSign: kIsWeb ? null : ZegoConfig.instance.appSign);
    ZegoExpressEngine.createEngineWithProfile(profile);

    ZegoExpressEngine.onRoomUserUpdate = (roomID, updateType, userList) {
      userList.forEach((e) {
        var userID = e.userID;
        var userName = e.userName;
        ZegoLog().addLog(
            '🚩 🚪 Room user update, roomID: $roomID, updateType: $updateType userID: $userID userName: $userName');
      });
    };

    ZegoExpressEngine.onPlayerVideoSizeChanged = (streamID, width, height) {
      ZegoLog().addLog(
          'onPlayerVideoSizeChanged streamID: $streamID size:${width}x${height}');
    };
    ZegoExpressEngine.onRoomTokenWillExpire = (roomid, expiretime) async {
      var token = await ZegoConfig.instance
          .getToken(ZegoUserHelper.instance.userID, _roomID);
      ZegoExpressEngine.instance.renewToken(roomid, token);
      ZegoLog().addLog(
          '🚩 🚪 Room Token Will Expire, roomID: $roomid, expiretime: $expiretime');
    };
    // Notify View that engine state changed
    setState(() => _isEngineActive = true);

    ZegoLog().addLog('🚀 Create ZegoExpressEngine');
  }

  // MARK: - Step 2: LoginRoom

  void loginRoom() async {
    // Instantiate a ZegoUser object
    ZegoUser user = ZegoUser(
        ZegoUserHelper.instance.userID, ZegoUserHelper.instance.userName);

    ZegoLog().addLog('🚪 Start login room, roomID: $_roomID');
    ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
    if (kIsWeb) {
      var token = await ZegoConfig.instance
          .getToken(ZegoUserHelper.instance.userID, _roomID);
      config.token = token;
      config.isUserStatusNotify = true;
    }
    // Login Room
    ZegoExpressEngine.instance.loginRoom(_roomID, user, config: config);
  }

  void logoutRoom() {
    // Logout room will automatically stop publishing/playing stream.
    //
    // But directly logout room without destroying the [PlatformView]
    // or [TextureRenderer] may cause a memory leak.
    ZegoExpressEngine.instance.logoutRoom(_roomID);
    ZegoLog().addLog('🚪 logout room, roomID: $_roomID');

    clearPreviewView();
    clearPlayView();
  }

  // MARK: - Step 3: StartPublishingStream

  void startPublishingStream(String streamID) async {
    void _startPreview(int viewID) {
      ZegoCanvas canvas = ZegoCanvas.view(viewID);
      ZegoExpressEngine.instance.startPreview(canvas: canvas);
      ZegoLog().addLog('🔌 Start preview, viewID: $viewID');
    }

    void _startPublishingStream(String streamID) {
      ZegoExpressEngine.instance.startPublishingStream(streamID);
      Future.delayed(Duration(seconds: 1), () {
        ZegoExpressEngine.instance.setStreamExtraInfo('ceshi');
      });
    }

    if (_previewViewID == -1) {
      _previewViewWidget =
          await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _previewViewID = viewID;
        _startPreview(viewID);
        _startPublishingStream(streamID);
      }, key: ValueKey(DateTime.now()));

      setState(() {});
    } else {
      _startPreview(_previewViewID);
      _startPublishingStream(streamID);
    }
  }

  void stopPublishingStream() {
    ZegoExpressEngine.instance.stopPublishingStream();
    ZegoExpressEngine.instance.stopPreview();
  }

  // MARK: - Step 4: StartPlayingStream

  void startPlayingStream(String streamID) async {
    void _startPlayingStream(int viewID, String streamID) {
      ZegoCanvas canvas = ZegoCanvas.view(viewID);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
      ZegoLog().addLog(
          '📥 Start playing stream, streamID: $streamID, viewID: $viewID');
    }

    if (_playViewID == -1) {
      _playViewWidget =
          await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _playViewID = viewID;
        _startPlayingStream(viewID, streamID);
      }, key: ValueKey(DateTime.now()));
      setState(() {});
    } else {
      _startPlayingStream(_playViewID, streamID);
    }
  }

  void stopPlayingStream(String streamID) {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
  }

  // MARK: - Exit

  void destroyEngine() async {
    clearPreviewView();
    clearPlayView();
    // Can destroy the engine when you don't need audio and video calls
    //
    // Destroy engine will automatically logout room and stop publishing/playing stream.
    ZegoExpressEngine.destroyEngine();

    ZegoLog().addLog('🏳️ Destroy ZegoExpressEngine');

    // Notify View that engine state changed
    setState(() {
      _isEngineActive = false;
      _roomState = ZegoRoomState.Disconnected;
      _publisherState = ZegoPublisherState.NoPublish;
      _playerState = ZegoPlayerState.NoPlay;
    });
  }

  // MARK: - Zego Event

  void setZegoEventCallback() {
    ZegoExpressEngine.onRoomStateUpdate = (String roomID, ZegoRoomState state,
        int errorCode, Map<String, dynamic> extendedData) {
      ZegoLog().addLog(
          '🚩 🚪 Room state update, state: $state, errorCode: $errorCode, roomID: $roomID');
      setState(() => _roomState = state);
    };

    ZegoExpressEngine.onPublisherStateUpdate = (String streamID,
        ZegoPublisherState state,
        int errorCode,
        Map<String, dynamic> extendedData) {
      ZegoLog().addLog(
          '🚩 📤 Publisher state update, state: $state, errorCode: $errorCode, streamID: $streamID');
      setState(() => _publisherState = state);
    };

    ZegoExpressEngine.onPlayerStateUpdate = (String streamID,
        ZegoPlayerState state,
        int errorCode,
        Map<String, dynamic> extendedData) {
      ZegoLog().addLog(
          '🚩 📥 Player state update, state: $state, errorCode: $errorCode, streamID: $streamID');
      setState(() => _playerState = state);
    };
  }

  void clearZegoEventCallback() {
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
    ZegoExpressEngine.onPlayerStateUpdate = null;
  }

  void clearPreviewView() {
    // Developers should destroy the [CanvasView] after
    // [stopPublishingStream] or [stopPreview] to release resource and avoid memory leaks
    if (_previewViewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_previewViewID);
      _previewViewID = -1;
    }
  }

  void clearPlayView() {
    // Developers should destroy the [CanvasView]
    // after [stopPlayingStream] to release resource and avoid memory leaks
    if (_playViewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_playViewID);
      _playViewID = -1;
    }
  }

  // MARK: Widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QuickStart')),
      body: SafeArea(
          child: GestureDetector(
        child: mainContent(),
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      )),
    );
  }

  Widget mainContent() {
    return SingleChildScrollView(
        child: Column(children: [
      SizedBox(
        child: ZegoLogView(),
        height: MediaQuery.of(context).size.height * 0.1,
      ),
      Divider(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(children: [
          viewsWidget(),
          stepOneCreateEngineWidget(),
          stepTwoLoginRoomWidget(),
          stepThreeStartPublishingStreamWidget(),
          stepFourStartPlayingStreamWidget(),
          Padding(padding: const EdgeInsets.only(bottom: 20.0)),
          CupertinoButton.filled(
            child: Text(
              'DestroyEngine',
              style: TextStyle(fontSize: 14.0),
            ),
            onPressed: destroyEngine,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
          )
        ]),
      ),
    ]));
  }

  Widget viewsWidget() {
    return Container(
      height: MediaQuery.of(context).size.width * 0.5,
      child: Row(
        children: [
          Expanded(
              flex: 15,
              child: Stack(children: [
                Container(
                  color: Colors.grey,
                  child: _previewViewWidget,
                ),
                Text('Local Preview View',
                    style: TextStyle(color: Colors.white))
              ], alignment: AlignmentDirectional.topCenter)),
          Expanded(
            child: Container(),
            flex: 1,
          ),
          Expanded(
              flex: 15,
              child: Stack(children: [
                Container(
                  color: Colors.grey,
                  child: _playViewWidget,
                ),
                Text('Remote Play View', style: TextStyle(color: Colors.white))
              ], alignment: AlignmentDirectional.topCenter)),
        ],
      ),
    );
  }

  Widget stepOneCreateEngineWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step1:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(children: [
          Column(
            children: [
              Text('AppID: ${ZegoConfig.instance.appID}',
                  style: TextStyle(fontSize: 10)),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          Spacer(),
          Container(
            width: MediaQuery.of(context).size.width / 2.5,
            child: CupertinoButton.filled(
              child: Text(
                _isEngineActive ? '✅ CreateEngine' : 'CreateEngine',
                style: TextStyle(fontSize: 14.0),
              ),
              onPressed: createEngine,
              padding: EdgeInsets.all(10.0),
            ),
          )
        ]),
        Divider(),
      ],
    );
  }

  Widget stepTwoLoginRoomWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'Step2:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Row(children: [
        Column(
          children: [
            Text('RoomID: $_roomID', style: TextStyle(fontSize: 10)),
            Text('UserID: ${ZegoUserHelper.instance.userID}',
                style: TextStyle(fontSize: 10)),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        Spacer(),
        Container(
          width: MediaQuery.of(context).size.width / 2.5,
          child: CupertinoButton.filled(
            child: Text(
              _roomState == ZegoRoomState.Connected
                  ? '✅ LoginRoom'
                  : 'LoginRoom',
              style: TextStyle(fontSize: 14.0),
            ),
            onPressed: _roomState == ZegoRoomState.Disconnected
                ? loginRoom
                : logoutRoom,
            padding: EdgeInsets.all(10.0),
          ),
        )
      ]),
      Divider(),
    ]);
  }

  Widget stepThreeStartPublishingStreamWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'Step3:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10),
      Row(children: [
        Container(
          width: MediaQuery.of(context).size.width / 2.5,
          child: TextField(
            enabled: _publisherState == ZegoPublisherState.NoPublish,
            controller: _publishingStreamIDController,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10.0),
                isDense: true,
                labelText: 'Publish StreamID:',
                labelStyle: TextStyle(color: Colors.black54, fontSize: 14.0),
                hintText: 'Please enter streamID',
                hintStyle: TextStyle(color: Colors.black26, fontSize: 10.0),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff0e88eb)))),
          ),
        ),
        Spacer(),
        Container(
          width: MediaQuery.of(context).size.width / 2.5,
          child: CupertinoButton.filled(
            child: Text(
              _publisherState == ZegoPublisherState.Publishing
                  ? '✅ StartPublishing'
                  : 'StartPublishing',
              style: TextStyle(fontSize: 14.0),
            ),
            onPressed: _publisherState == ZegoPublisherState.NoPublish
                ? () {
                    startPublishingStream(
                        _publishingStreamIDController.text.trim());
                  }
                : () {
                    stopPublishingStream();
                  },
            padding: EdgeInsets.all(10.0),
          ),
        )
      ]),
      Divider(),
    ]);
  }

  Widget stepFourStartPlayingStreamWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'Step4:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10),
      Row(children: [
        Container(
          width: MediaQuery.of(context).size.width / 2.5,
          child: TextField(
            enabled: _playerState == ZegoPlayerState.NoPlay,
            controller: _playingStreamIDController,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10.0),
                isDense: true,
                labelText: 'Play StreamID:',
                labelStyle: TextStyle(color: Colors.black54, fontSize: 14.0),
                hintText: 'Please enter streamID',
                hintStyle: TextStyle(color: Colors.black26, fontSize: 10.0),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff0e88eb)))),
          ),
        ),
        Spacer(),
        Container(
          width: MediaQuery.of(context).size.width / 2.5,
          child: CupertinoButton.filled(
            child: Text(
              _playerState != ZegoPlayerState.NoPlay
                  ? (_playerState == ZegoPlayerState.Playing
                      ? '✅ StopPlaying'
                      : '❌ StopPlaying')
                  : 'StartPlaying',
              style: TextStyle(fontSize: 14.0),
            ),
            onPressed: _playerState == ZegoPlayerState.NoPlay
                ? () {
                    startPlayingStream(_playingStreamIDController.text.trim());
                  }
                : () {
                    stopPlayingStream(_playingStreamIDController.text.trim());
                  },
            padding: EdgeInsets.all(10.0),
          ),
        )
      ]),
      Divider(),
    ]);
  }
}
