import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew//utils/zego_log_view.dart';
import 'package:smatch/callnew//utils/zego_user_helper.dart';

class MutilpeRoomsPage extends StatefulWidget {
  const MutilpeRoomsPage({Key? key}) : super(key: key);

  @override
  _MutilpeRoomsPageState createState() => _MutilpeRoomsPageState();
}

class _MutilpeRoomsPageState extends State<MutilpeRoomsPage> {
  late ZegoRoomState _room1State;
  late ZegoRoomState _room2State;
  late TextEditingController _roomID1Controller;
  late TextEditingController _roomID2Controller;

  late TextEditingController _preRoomIDController;
  late TextEditingController _preStreamIDController;

  late TextEditingController _playRoomIDController;
  late TextEditingController _playStreamIDController;
  Widget? _previewViewWidget;
  Widget? _playViewWidget;

  late ZegoDelegate _zegoDelegate;

  late Set<String> _playStreamIDList;
  late String _currentShowStreamID;

  @override
  void initState() {
    super.initState();

    _zegoDelegate = ZegoDelegate();

    _room1State = ZegoRoomState.Disconnected;
    _room2State = ZegoRoomState.Disconnected;

    _roomID1Controller = TextEditingController();
    _roomID1Controller.text = 'multiple_room_1';
    _roomID2Controller = TextEditingController();
    _roomID2Controller.text = 'multiple_room_2';

    _preRoomIDController = TextEditingController();
    _preRoomIDController.text = 'multiple_room_1';
    _preStreamIDController = TextEditingController();
    _preStreamIDController.text = 'multiple_stream';

    _playRoomIDController = TextEditingController();
    _playRoomIDController.text = 'multiple_room_1';
    _playStreamIDController = TextEditingController();
    _playStreamIDController.text = 'multiple_stream';

    _playStreamIDList = {};
    _currentShowStreamID = '';

    _zegoDelegate.setZegoEventCallback(
        onRoomStateUpdate: onRoomStateUpdate,
        onPlayerStateUpdate: onPlayerStateUpdate);
    _zegoDelegate
        .setRoomMode(ZegoRoomMode.MultiRoom)
        .then((value) => _zegoDelegate.createEngine());
  }

  @override
  void dispose() {
    super.dispose();
    _zegoDelegate.clearZegoEventCallback();

    _zegoDelegate.dispose();

    _zegoDelegate.logoutRoom(_roomID1Controller.text).then((value) async {
      await _zegoDelegate.logoutRoom(_roomID2Controller.text);
      await _zegoDelegate.destroyEngine();
      _zegoDelegate.setRoomMode(ZegoRoomMode.SingleRoom);
    });
  }

  // zego express callback

  void onRoomStateUpdate(String roomID, ZegoRoomState state, int errorCode,
      Map<String, dynamic> extendedData) {
    if (roomID == _roomID1Controller.text) {
      _room1State = state;
    } else if (roomID == _roomID2Controller.text) {
      _room2State = state;
    }
    setState(() {});
  }

  void onPlayerStateUpdate(String streamID, ZegoPlayerState state,
      int errorCode, Map<String, dynamic> extendedData) {
    if (state == ZegoPlayerState.Playing && errorCode == 0) {
      if (_playStreamIDList.isEmpty) {
        _currentShowStreamID = streamID;
      }
      _playStreamIDList.add(streamID);
    } else if (state == ZegoPlayerState.NoPlay) {
      _playStreamIDList.remove(streamID);
      if (_currentShowStreamID == streamID) {
        _currentShowStreamID =
            _playStreamIDList.isEmpty ? '' : _playStreamIDList.first;
        if (_currentShowStreamID.isNotEmpty) {
          onPlayStartBtnPress(_currentShowStreamID, needShow: true);
        }
      }
    }
  }

  // widget callback

  void onLoginRoom1BtnPress() {
    if (_room1State == ZegoRoomState.Connected) {
      _zegoDelegate.logoutRoom(_roomID1Controller.text);
    } else {
      _zegoDelegate.loginRoom(_roomID1Controller.text);
    }
  }

  void onLoginRoom2BtnPress() {
    if (_room2State == ZegoRoomState.Connected) {
      _zegoDelegate.logoutRoom(_roomID2Controller.text);
    } else {
      _zegoDelegate.loginRoom(_roomID2Controller.text);
    }
  }

  void onPreStartBtnPress() {
    _zegoDelegate
        .startPublishing(
      _preStreamIDController.text,
      roomID: _preRoomIDController.text,
    )
        .then((widget) {
      setState(() {
        _previewViewWidget = widget;
      });
    });
  }

  void onPreStopBtnPress() {
    _zegoDelegate.stopPublishing();
  }

  void onPlayStartBtnPress(String streamID, {bool? needShow}) {
    _zegoDelegate
        .startPlaying(streamID,
            roomID: _playRoomIDController.text, needShow: needShow!)
        .then((widget) {
      setState(() {
        _playViewWidget = widget;
      });
    });
  }

  void onPlayStopBtnPress() {
    _zegoDelegate.stopPlaying(_playStreamIDController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登录多房间'),
      ),
      body: SafeArea(child: mainContent()),
    );
  }

  Widget mainContent() {
    return SingleChildScrollView(
        child: Column(
      children: [
        SizedBox(
          child: ZegoLogView(),
          height: MediaQuery.of(context).size.height * 0.1,
        ),
        roomStateWidget(),
        step1Widget(),
        step2Widget(),
        step3Widget()
      ],
    ));
  }

  Widget roomStateWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.only(top: 10)),
          Text('userID:   ${ZegoUserHelper.instance.userID}'),
          Padding(padding: EdgeInsets.only(top: 5)),
          Text('Room1 state  ${_zegoDelegate.roomStateDesc(_room1State)}'),
          Padding(padding: EdgeInsets.only(top: 5)),
          Text('Room2 state  ${_zegoDelegate.roomStateDesc(_room2State)}'),
        ],
      ),
    );
  }

  Widget step1Widget() {
    return Container(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(
                  text: 'Step1       ',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: <InlineSpan>[
                TextSpan(
                    text: 'login Room1',
                    style: TextStyle(fontSize: 13, color: Colors.grey))
              ])),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('roomID 1 ',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
              Container(
                padding: EdgeInsets.only(right: 5),
                width: MediaQuery.of(context).size.width * 0.35,
                child: TextField(
                  controller: _roomID1Controller,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff0e88eb)))),
                ),
              ),
              Expanded(
                  child: Container(
                child: CupertinoButton.filled(
                    child: Text(
                      _room1State == ZegoRoomState.Connected
                          ? 'LOGOUT ROOM 1'
                          : 'LOGIN ROOM 1',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    onPressed: onLoginRoom1BtnPress,
                    padding: EdgeInsets.all(10.0)),
              )),
            ],
          )
        ],
      ),
    );
  }

  Widget step2Widget() {
    return Container(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(
                  text: 'Step2       ',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: <InlineSpan>[
                TextSpan(
                    text: 'login Room2',
                    style: TextStyle(fontSize: 13, color: Colors.grey))
              ])),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('roomID 2 ',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
              Container(
                padding: EdgeInsets.only(right: 5),
                width: MediaQuery.of(context).size.width * 0.35,
                child: TextField(
                  controller: _roomID2Controller,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff0e88eb)))),
                ),
              ),
              Expanded(
                  child: Container(
                child: CupertinoButton.filled(
                    child: Text(
                      _room2State == ZegoRoomState.Connected
                          ? 'LOGOUT ROOM 2'
                          : 'LOGIN ROOM 2',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    onPressed: onLoginRoom2BtnPress,
                    padding: EdgeInsets.all(10.0)),
              )),
            ],
          )
        ],
      ),
    );
  }

  Widget step3Widget() {
    return Container(
      padding: EdgeInsets.only(top: 20, left: 20, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(
                  text: 'Step3       ',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: <InlineSpan>[
                TextSpan(
                    text: 'Publish & Play',
                    style: TextStyle(fontSize: 13, color: Colors.grey))
              ])),
          Container(
              height: MediaQuery.of(context).size.height * 0.4,
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                      flex: 15,
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.grey[300],
                            child: _previewViewWidget,
                          ),
                          preWidgetTopWidget()
                        ],
                        alignment: AlignmentDirectional.topCenter,
                      )),
                  Expanded(flex: 1, child: Container()),
                  Expanded(
                      flex: 15,
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.grey[300],
                            child: _playViewWidget,
                          ),
                          playWidgetTopWidget()
                        ],
                        alignment: AlignmentDirectional.topCenter,
                      )),
                ],
              ))
        ],
      ),
    );
  }

  Widget preWidgetTopWidget() {
    return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
              child: Text('Local Preview View',
                  style: TextStyle(color: Colors.white))),
          Expanded(child: Container()),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              child: Text(
                'RoomID:    ',
                style: TextStyle(fontSize: 11),
              ),
              height: 32,
              alignment: Alignment.centerLeft,
            ),
            Expanded(
                child: TextField(
              controller: _preRoomIDController,
              style: TextStyle(fontSize: 11, color: Colors.white),
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10.0),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff0e88eb)))),
            )),
          ]),
          Padding(padding: EdgeInsets.only(top: 5)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Container(
              child: Text(
                'StreamID:    ',
                style: TextStyle(fontSize: 11),
              ),
              height: 32,
              alignment: Alignment.centerLeft,
            ),
            Expanded(
                child: TextField(
              controller: _preStreamIDController,
              style: TextStyle(fontSize: 11, color: Colors.white),
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10.0),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff0e88eb)))),
            )),
          ]),
          Padding(padding: EdgeInsets.only(top: 5)),
          Container(
              padding: EdgeInsets.only(left: 10),
              width: MediaQuery.of(context).size.width * 0.4,
              child: CupertinoButton.filled(
                  child: Text(
                    'START',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  onPressed: onPreStartBtnPress,
                  padding: EdgeInsets.all(10.0))),
          Padding(padding: EdgeInsets.only(top: 5)),
          Container(
              padding: EdgeInsets.only(left: 10),
              width: MediaQuery.of(context).size.width * 0.4,
              child: CupertinoButton.filled(
                  child: Text(
                    'STOP',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  onPressed: onPreStopBtnPress,
                  padding: EdgeInsets.all(10.0)))
        ]));
  }

  // Buttons and titles on the play widget
  Widget playWidgetTopWidget() {
    return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
              child: Text('Remote Play View',
                  style: TextStyle(color: Colors.white))),
          Expanded(child: Container()),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              child: Text(
                'RoomID:    ',
                style: TextStyle(fontSize: 11),
              ),
              height: 32,
              alignment: Alignment.centerLeft,
            ),
            Expanded(
                child: TextField(
              controller: _playRoomIDController,
              style: TextStyle(fontSize: 11, color: Colors.white),
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10.0),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff0e88eb)))),
            )),
          ]),
          Padding(padding: EdgeInsets.only(top: 5)),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              child: Text(
                'StreamID:  ',
                style: TextStyle(fontSize: 11),
              ),
              height: 32,
              alignment: Alignment.centerLeft,
            ),
            Expanded(
                child: TextField(
              controller: _playStreamIDController,
              style: TextStyle(fontSize: 11, color: Colors.white),
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10.0),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff0e88eb)))),
            )),
          ]),
          Padding(padding: EdgeInsets.only(top: 5)),
          Container(
            padding: EdgeInsets.only(left: 10),
            width: MediaQuery.of(context).size.width * 0.4,
            child: CupertinoButton.filled(
                child: Text(
                  'START',
                  style: TextStyle(fontSize: 14.0),
                ),
                onPressed: () {
                  onPlayStartBtnPress(_playStreamIDController.text.trim(),
                      needShow: _currentShowStreamID.isEmpty);
                },
                padding: EdgeInsets.all(10.0)),
          ),
          Padding(padding: EdgeInsets.only(top: 5)),
          Container(
            padding: EdgeInsets.only(left: 10),
            width: MediaQuery.of(context).size.width * 0.4,
            child: CupertinoButton.filled(
                child: Text(
                  'STOP',
                  style: TextStyle(fontSize: 14.0),
                ),
                onPressed: onPlayStopBtnPress,
                padding: EdgeInsets.all(10.0)),
          )
        ]));
  }
}

typedef RoomStateUpdateCallback = void Function(
    String, ZegoRoomState, int, Map<String, dynamic>);
typedef PlayerStateUpdateCallback = void Function(
    String, ZegoPlayerState, int, Map<String, dynamic>);

class ZegoDelegate {
  RoomStateUpdateCallback? _onRoomStateUpdate;
  PlayerStateUpdateCallback? _onPlayerStateUpdate;

  late int _preViewID;
  late int _playViewID;

  Widget? preWidget;
  Widget? playWidget;
  ZegoDelegate()
      : _preViewID = -1,
        _playViewID = -1;

  dispose() {
    if (_preViewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_preViewID);
      _preViewID = -1;
    }
    if (_playViewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_playViewID);
      _playViewID = -1;
    }
  }

  void _initCallback() {
    ZegoExpressEngine.onRoomStateUpdate = (String roomID, ZegoRoomState state,
        int errorCode, Map<String, dynamic> extendedData) {
      ZegoLog().addLog(
          '🚩 🚪 Room state update, state: $state, errorCode: $errorCode, roomID: $roomID');
      _onRoomStateUpdate?.call(roomID, state, errorCode, extendedData);
    };

    ZegoExpressEngine.onPlayerStateUpdate = (String streamID,
        ZegoPlayerState state,
        int errorCode,
        Map<String, dynamic> extendedData) {
      ZegoLog().addLog(
          '🚩 📥 Player state update, state: $state, errorCode: $errorCode, streamID: $streamID');
      if (state == ZegoPlayerState.Playing && errorCode == 0) {
        ZegoLog().addLog('🚩 📥 Playing stream success');
      }
      if (errorCode != 0) {
        ZegoLog().addLog('🚩 ❌ 📥 Playing stream fail');
      }
      _onPlayerStateUpdate?.call(streamID, state, errorCode, extendedData);
    };
  }

  void setZegoEventCallback({
    RoomStateUpdateCallback? onRoomStateUpdate,
    PlayerStateUpdateCallback? onPlayerStateUpdate,
  }) {
    if (onRoomStateUpdate != null) {
      _onRoomStateUpdate = onRoomStateUpdate;
    }
    if (onPlayerStateUpdate != null) {
      _onPlayerStateUpdate = onPlayerStateUpdate;
    }
  }

  void clearZegoEventCallback() {
    _onRoomStateUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = null;

    _onPlayerStateUpdate = null;
    ZegoExpressEngine.onPlayerStateUpdate = null;
  }

  Future<void> createEngine({bool? enablePlatformView}) async {
    _initCallback();

    await ZegoExpressEngine.destroyEngine();

    enablePlatformView =
        enablePlatformView ?? ZegoConfig.instance.enablePlatformView;
    ZegoLog().addLog("enablePlatformView :$enablePlatformView");
    ZegoEngineProfile profile = ZegoEngineProfile(
        ZegoConfig.instance.appID, ZegoConfig.instance.scenario,
        enablePlatformView: enablePlatformView,
        appSign: ZegoConfig.instance.appSign);
    await ZegoExpressEngine.createEngineWithProfile(profile);

    ZegoLog().addLog('🚀 Create ZegoExpressEngine');
  }

  Future destroyEngine() async {
    await ZegoExpressEngine.destroyEngine();
  }

  String roomStateDesc(ZegoRoomState roomState) {
    String result = 'Unknown';
    switch (roomState) {
      case ZegoRoomState.Disconnected:
        result = "Disconnected 🔴";
        break;
      case ZegoRoomState.Connecting:
        result = "Connecting 🟡";
        break;
      case ZegoRoomState.Connected:
        result = "Connected 🟢";
        break;
      default:
        result = "Unknown";
    }
    return result;
  }

  Future<void> setRoomMode(ZegoRoomMode mode) {
    return ZegoExpressEngine.setRoomMode(mode);
  }

  Future<void> loginRoom(String roomID) async {
    if (roomID.isNotEmpty) {
      // Instantiate a ZegoUser object
      ZegoUser user = ZegoUser(
          ZegoUserHelper.instance.userID, ZegoUserHelper.instance.userName);

      // Login Room
      await ZegoExpressEngine.instance.loginRoom(roomID, user);

      ZegoLog().addLog('🚪 Start login room, roomID: $roomID');
    }
  }

  Future<void> logoutRoom(String roomID) async {
    if (roomID.isNotEmpty) {
      await ZegoExpressEngine.instance.logoutRoom(roomID);

      ZegoLog().addLog('🚪 Start logout room, roomID: $roomID');
    }
  }

  Future<Widget?> startPublishing(String streamID, {String? roomID}) async {
    var publishFunc = (int viewID) {
      ZegoExpressEngine.instance
          .startPreview(canvas: ZegoCanvas(viewID, backgroundColor: 0xffffff));
      if (roomID != null) {
        ZegoExpressEngine.instance.startPublishingStream(streamID,
            config: ZegoPublisherConfig(roomID: roomID));
      } else {
        ZegoExpressEngine.instance.startPublishingStream(streamID);
      }
      ZegoLog().addLog('📥 Start publish stream, streamID: $streamID');
    };

    if (streamID.isNotEmpty) {
      if (_preViewID == -1) {
        preWidget = await ZegoExpressEngine.instance.createCanvasView((viewID) {
          _preViewID = viewID;
          publishFunc(_preViewID);
        });
      } else {
        publishFunc(_preViewID);
      }
    }
    return preWidget;
  }

  void stopPublishing() {
    ZegoExpressEngine.instance.stopPreview();
    ZegoExpressEngine.instance.stopPublishingStream();
  }

  Future<Widget?> startPlaying(String streamID,
      {String? cdnURL, bool needShow = true, String? roomID}) async {
    var playFunc = (int viewID) {
      ZegoCDNConfig? cdnConfig;
      if (cdnURL != null) {
        cdnConfig = ZegoCDNConfig(cdnURL, "");
      }

      if (needShow) {
        ZegoExpressEngine.instance.startPlayingStream(streamID,
            canvas: ZegoCanvas(viewID, backgroundColor: 0xffffff),
            config: ZegoPlayerConfig(
                ZegoStreamResourceMode.Default, ZegoVideoCodecID.Default,
                cdnConfig: cdnConfig, roomID: roomID));
      } else {
        ZegoExpressEngine.instance.startPlayingStream(streamID,
            config: ZegoPlayerConfig(
                ZegoStreamResourceMode.Default, ZegoVideoCodecID.Default,
                roomID: roomID));
      }

      ZegoLog().addLog('📥 Start playing stream, streamID: $streamID');
    };

    if (streamID.isNotEmpty) {
      if (_playViewID == -1 && needShow) {
        playWidget =
            await ZegoExpressEngine.instance.createCanvasView((viewID) {
          _playViewID = viewID;
          playFunc(_playViewID);
        });
      } else {
        playFunc(_playViewID);
      }
    }
    return playWidget;
  }

  void stopPlaying(String streamID) {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
  }
}
