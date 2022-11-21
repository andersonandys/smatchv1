import 'package:smatch/callnew/utils/zego_config.dart';
import 'package:smatch/callnew/utils/zego_log_view.dart';
import 'package:smatch/callnew/utils/zego_user_helper.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class AudioEffectPlayerPage extends StatefulWidget {
  const AudioEffectPlayerPage({Key? key}) : super(key: key);

  @override
  _AudioEffectPlayerPageState createState() => _AudioEffectPlayerPageState();
}

class _AudioEffectPlayerPageState extends State<AudioEffectPlayerPage> {
  final _roomID = 'audio_effect_player';
  final _streamID = 'audio_effect_player_s';

  final _audioEffect1ID = 1;
  final _audioEffect2ID = 2;

  late ZegoRoomState _roomState;
  late ZegoPublisherState _publisherState;
  late ZegoPlayerState _playerState;

  late bool _audioEffect1Publishing;
  late bool _audioEffect2Publishing;

  late TextEditingController _audioEffect1PlayCountController;
  late TextEditingController _audioEffect2PlayCountController;

  late TextEditingController _audioEffect1ResourcePathController;
  late TextEditingController _audioEffect2ResourcePathController;

  Widget? _previewViewWidget;
  Widget? _playViewWidget;

  ZegoAudioEffectPlayer? _effectPlayer;

  late ZegoAudioEffectPlayConfig _audioEffectPlayConfig1;
  late ZegoAudioEffectPlayConfig _audioEffectPlayConfig2;

  late String _audioEffect1Path;
  late String _audioEffect2Path;

  late ZegoDelegate _zegoDelegate;

  @override
  void initState() {
    super.initState();

    _zegoDelegate = ZegoDelegate();

    _roomState = ZegoRoomState.Disconnected;
    _publisherState = ZegoPublisherState.NoPublish;
    _playerState = ZegoPlayerState.NoPlay;

    _audioEffect1Publishing = false;
    _audioEffect2Publishing = false;

    _audioEffect1PlayCountController = TextEditingController();
    _audioEffect1PlayCountController.text = '1';

    _audioEffect2PlayCountController = TextEditingController();
    _audioEffect2PlayCountController.text = '1';

    _audioEffect1ResourcePathController = TextEditingController();
    _audioEffect1ResourcePathController.text = 'effect_1_stereo.wav';
    _audioEffect2ResourcePathController = TextEditingController();
    _audioEffect2ResourcePathController.text = 'effect_2_mono.wav';

    _audioEffectPlayConfig1 = ZegoAudioEffectPlayConfig(1, false);
    _audioEffectPlayConfig2 = ZegoAudioEffectPlayConfig(1, false);

    _audioEffect1Path = '';
    _audioEffect2Path = '';

    _writeAssertToLocal();

    _zegoDelegate.setZegoEventCallback(
        onRoomStateUpdate: onRoomStateUpdate,
        onPublisherStateUpdate: onPublisherStateUpdate,
        onPlayerStateUpdate: onPlayerStateUpdate);
    _zegoDelegate.createEngine().then((value) async {
      _zegoDelegate.loginRoom(_roomID);

      // audio effect player
      _effectPlayer = await _zegoDelegate.createAudioEffectPlayer();
    });
  }

  @override
  void dispose() {
    _zegoDelegate.clearZegoEventCallback();
    if (_effectPlayer != null) {
      _zegoDelegate.destroyAudioEffectPlayer(_effectPlayer!);
    }

    _zegoDelegate.dispose();
    _zegoDelegate
        .logoutRoom(_roomID)
        .then((value) => _zegoDelegate.destroyEngine());

    super.dispose();
  }

  void _writeAssertToLocal() async {
    var path = await getApplicationDocumentsDirectory();

    var lacalFilePath = path.path + '/';

    _audioEffect1Path = lacalFilePath + 'effect_1_stereo.wav';
    var audio1 = File(_audioEffect1Path);
    if (!audio1.existsSync()) {
      var data = await rootBundle.load('resources/audio/effect_1_stereo.wav');
      audio1 = await audio1.writeAsBytes(data.buffer.asUint8List());
    }

    _audioEffect2Path = lacalFilePath + 'effect_2_mono.wav';
    var audio2 = File(_audioEffect2Path);
    if (!audio2.existsSync()) {
      var data = await rootBundle.load('resources/audio/effect_2_mono.wav');
      audio2 = await audio2.writeAsBytes(data.buffer.asUint8List());
    }
  }

  // zego express callback

  void onRoomStateUpdate(String roomID, ZegoRoomState state, int errorCode,
      Map<String, dynamic> extendedData) {
    if (roomID == _roomID) {
      setState(() {
        _roomState = state;
      });
    }
  }

  void onPublisherStateUpdate(String streamID, ZegoPublisherState state,
      int errorCode, Map<String, dynamic> extendedData) {
    if (streamID == _streamID) {
      setState(() {
        _publisherState = state;
      });
    }
  }

  void onPlayerStateUpdate(String streamID, ZegoPlayerState state,
      int errorCode, Map<String, dynamic> extendedData) {
    if (streamID == _streamID) {
      setState(() {
        _playerState = state;
      });
    }
  }

  // widget callback

  void onPublishBtnPress() {
    if (_publisherState == ZegoPublisherState.Publishing) {
      _zegoDelegate.stopPublishing();
    } else {
      _zegoDelegate.startPublishing(_streamID).then((widget) {
        setState(() {
          _previewViewWidget = widget;
        });
      });
    }
  }

  void onPlayBtnPress() {
    if (_playerState != ZegoPlayerState.NoPlay) {
      _zegoDelegate.stopPlaying(_streamID);
    } else {
      _zegoDelegate.startPlaying(_streamID).then((widget) {
        setState(() {
          _playViewWidget = widget;
        });
      });
    }
  }

  // AudioEffect1

  void onAudioEffect1PublishingSwitchChanged(bool b) {
    setState(() {
      _audioEffect1Publishing = b;
    });
    _audioEffectPlayConfig1.isPublishOut = b;
    _effectPlayer?.stop(_audioEffect1ID);
  }

  void onAudioEffect1PlayBtnPress() {
    _audioEffectPlayConfig1.playCount =
        int.parse(_audioEffect1PlayCountController.text);
    _effectPlayer?.start(_audioEffect1ID, config: _audioEffectPlayConfig1);
  }

  void onAudioEffect1PauseBtnPress() {
    _effectPlayer?.pause(_audioEffect1ID);
  }

  void onAudioEffect1ResumeBtnPress() {
    _effectPlayer?.resume(_audioEffect1ID);
  }

  void onAudioEffect1StopBtnPress() {
    _effectPlayer?.stop(_audioEffect1ID);
  }

  void onAudioEffect1LoadResourceBtnPress() {
    _effectPlayer?.loadResource(_audioEffect1ID, _audioEffect1Path);
  }

  void onAudioEffect1UnloadResourceBtnPress() {
    _effectPlayer?.unloadResource(_audioEffect1ID);
  }

  // AudioEffect2

  void onAudioEffect2PublishingSwitchChanged(bool b) {
    setState(() {
      _audioEffect2Publishing = b;
    });
    _audioEffectPlayConfig2.isPublishOut = b;
    _effectPlayer?.stop(_audioEffect2ID);
  }

  void onAudioEffect2PlayBtnPress() {
    _audioEffectPlayConfig2.playCount =
        int.parse(_audioEffect2PlayCountController.text);
    _effectPlayer?.start(_audioEffect2ID, config: _audioEffectPlayConfig2);
  }

  void onAudioEffect2PauseBtnPress() {
    _effectPlayer?.pause(_audioEffect2ID);
  }

  void onAudioEffect2ResumeBtnPress() {
    _effectPlayer?.resume(_audioEffect2ID);
  }

  void onAudioEffect2StopBtnPress() {
    _effectPlayer?.stop(_audioEffect2ID);
  }

  void onAudioEffect2LoadResourceBtnPress() {
    _effectPlayer?.loadResource(_audioEffect2ID, _audioEffect2Path);
  }

  void onAudioEffect2UnloadResourceBtnPress() {
    _effectPlayer?.unloadResource(_audioEffect2ID);
  }

  // controller

  void onAllPauseBtnPress() {
    _effectPlayer?.pauseAll();
  }

  void onAllResumeBtnPress() {
    _effectPlayer?.resumeAll();
  }

  void onAllStopBtnPress() {
    _effectPlayer?.stopAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('音效播放器'),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: mainContent(context),
      )),
    );
  }

  Widget mainContent(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: ZegoLogView(),
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          roomInfoWidget(),
          viewWidget(),
          audioEffect1Widget(context),
          audioEffect2Widget(context),
          controllerWidget(context)
        ],
      ),
    );
  }

  Widget roomInfoWidget() {
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("RoomID: $_roomID"),
          Text('RoomState: ${_zegoDelegate.roomStateDesc(_roomState)}'),
          Text('StreamID: $_streamID')
        ]));
  }

  Widget viewWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height * 0.4,
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

  Widget audioEffect1Widget(BuildContext context) {
    return Column(children: [
      Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10),
        color: Colors.grey,
        child: Text(
          'AudioEffect 1',
          style: TextStyle(fontSize: 18),
        ),
      ),
      Container(
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Column(
          children: [
            Row(
              children: [
                Text('是否将音效推流'),
                Switch(
                    value: _audioEffect1Publishing,
                    onChanged: onAudioEffect1PublishingSwitchChanged),
                Expanded(
                    child: Text(
                  '播放次数  ',
                  textAlign: TextAlign.end,
                )),
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: TextField(
                    controller: _audioEffect1PlayCountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                    ],
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10.0),
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff0e88eb)))),
                  ),
                )
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CupertinoButton.filled(
                    child: Text(
                      'PLAY',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    onPressed: onAudioEffect1PlayBtnPress,
                    padding: EdgeInsets.all(10.0)),
                CupertinoButton.filled(
                    child: Text(
                      'PAUSE',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    onPressed: onAudioEffect1PauseBtnPress,
                    padding: EdgeInsets.all(10.0)),
                CupertinoButton.filled(
                    child: Text(
                      'RESUME',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    onPressed: onAudioEffect1ResumeBtnPress,
                    padding: EdgeInsets.all(10.0)),
                CupertinoButton.filled(
                    child: Text(
                      'STOP',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    onPressed: onAudioEffect1StopBtnPress,
                    padding: EdgeInsets.all(10.0))
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CupertinoButton.filled(
                    child: Text(
                      '预先加载资源',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    onPressed: onAudioEffect1LoadResourceBtnPress,
                    padding: EdgeInsets.all(10.0)),
                Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: TextField(
                      readOnly: true,
                      controller: _audioEffect1ResourcePathController,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10.0),
                          isDense: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Color(0xff0e88eb)))),
                    )),
                CupertinoButton.filled(
                    child: Text(
                      'UNLOAD',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    onPressed: onAudioEffect1UnloadResourceBtnPress,
                    padding: EdgeInsets.all(10.0)),
              ],
            )
          ],
        ),
      )
    ]);
  }

  Widget audioEffect2Widget(BuildContext context) {
    return Column(children: [
      Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10),
        color: Colors.grey,
        child: Text('AudioEffect 2', style: TextStyle(fontSize: 18)),
      ),
      Container(
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Column(
          children: [
            Row(
              children: [
                Text('是否将音效推流'),
                Switch(
                    value: _audioEffect2Publishing,
                    onChanged: onAudioEffect2PublishingSwitchChanged),
                Expanded(
                    child: Text(
                  '播放次数  ',
                  textAlign: TextAlign.end,
                )),
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: TextField(
                    controller: _audioEffect2PlayCountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                    ],
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10.0),
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff0e88eb)))),
                  ),
                )
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CupertinoButton.filled(
                    child: Text(
                      'PLAY',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    onPressed: onAudioEffect2PlayBtnPress,
                    padding: EdgeInsets.all(10.0)),
                CupertinoButton.filled(
                    child: Text(
                      'PAUSE',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    onPressed: onAudioEffect2PauseBtnPress,
                    padding: EdgeInsets.all(10.0)),
                CupertinoButton.filled(
                    child: Text(
                      'RESUME',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    onPressed: onAudioEffect2ResumeBtnPress,
                    padding: EdgeInsets.all(10.0)),
                CupertinoButton.filled(
                    child: Text(
                      'STOP',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    onPressed: onAudioEffect2StopBtnPress,
                    padding: EdgeInsets.all(10.0))
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CupertinoButton.filled(
                    child: Text(
                      '预先加载资源',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    onPressed: onAudioEffect2LoadResourceBtnPress,
                    padding: EdgeInsets.all(10.0)),
                Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: TextField(
                      readOnly: true,
                      controller: _audioEffect2ResourcePathController,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10.0),
                          isDense: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Color(0xff0e88eb)))),
                    )),
                CupertinoButton.filled(
                    child: Text(
                      'UNLOAD',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    onPressed: onAudioEffect2UnloadResourceBtnPress,
                    padding: EdgeInsets.all(10.0)),
              ],
            )
          ],
        ),
      )
    ]);
  }

  Widget controllerWidget(BuildContext context) {
    return Column(children: [
      Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10),
        color: Colors.grey,
        child: Text('Controller', style: TextStyle(fontSize: 18)),
      ),
      Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CupertinoButton.filled(
                child: Text(
                  'PAUSE ALL',
                  style: TextStyle(fontSize: 14.0),
                ),
                onPressed: onAllPauseBtnPress,
                padding: EdgeInsets.all(10.0)),
            CupertinoButton.filled(
                child: Text(
                  'RESUME ALL',
                  style: TextStyle(fontSize: 14.0),
                ),
                onPressed: onAllResumeBtnPress,
                padding: EdgeInsets.all(10.0)),
            CupertinoButton.filled(
                child: Text(
                  'STOP ALL',
                  style: TextStyle(fontSize: 14.0),
                ),
                onPressed: onAllStopBtnPress,
                padding: EdgeInsets.all(10.0))
          ],
        ),
      )
    ]);
  }

  Widget preWidgetTopWidget() {
    return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
              child: Text('Local Preview View',
                  style: TextStyle(color: Colors.white))),
          Expanded(child: Container()),
          Container(
              padding: EdgeInsets.only(left: 10),
              width: MediaQuery.of(context).size.width * 0.4,
              child: CupertinoButton.filled(
                  child: Text(
                    _publisherState == ZegoPublisherState.Publishing
                        ? '✅ StopPublishing'
                        : 'StartPublishing',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  onPressed: onPublishBtnPress,
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
          Container(
            padding: EdgeInsets.only(left: 10),
            width: MediaQuery.of(context).size.width * 0.4,
            child: CupertinoButton.filled(
                child: Text(
                  _playerState != ZegoPlayerState.NoPlay
                      ? (_playerState == ZegoPlayerState.Playing
                          ? '✅ StopPlaying'
                          : '❌ StopPlaying')
                      : 'StartPlaying',
                  style: TextStyle(fontSize: 14.0),
                ),
                onPressed: onPlayBtnPress,
                padding: EdgeInsets.all(10.0)),
          )
        ]));
  }
}

typedef RoomStateUpdateCallback = void Function(
    String, ZegoRoomState, int, Map<String, dynamic>);
typedef PublisherStateUpdateCallback = void Function(
    String, ZegoPublisherState, int, Map<String, dynamic>);
typedef PlayerStateUpdateCallback = void Function(
    String, ZegoPlayerState, int, Map<String, dynamic>);

class ZegoDelegate {
  RoomStateUpdateCallback? _onRoomStateUpdate;
  PublisherStateUpdateCallback? _onPublisherStateUpdate;
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

    ZegoExpressEngine.onPublisherStateUpdate = (String streamID,
        ZegoPublisherState state,
        int errorCode,
        Map<String, dynamic> extendedData) {
      ZegoLog().addLog(
          '🚩 📤 Publisher state update, state: $state, errorCode: $errorCode, streamID: $streamID');
      if (state == ZegoPublisherState.Publishing && errorCode == 0) {
        ZegoLog().addLog('🚩 📥 Publishing stream success');
      }
      if (errorCode != 0) {
        ZegoLog().addLog('🚩 ❌ 📥 Publishing stream fail');
      }
      _onPublisherStateUpdate?.call(streamID, state, errorCode, extendedData);
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
    PublisherStateUpdateCallback? onPublisherStateUpdate,
    PlayerStateUpdateCallback? onPlayerStateUpdate,
  }) {
    if (onRoomStateUpdate != null) {
      _onRoomStateUpdate = onRoomStateUpdate;
    }
    if (onPublisherStateUpdate != null) {
      _onPublisherStateUpdate = onPublisherStateUpdate;
    }
    if (onPlayerStateUpdate != null) {
      _onPlayerStateUpdate = onPlayerStateUpdate;
    }
  }

  void clearZegoEventCallback() {
    _onRoomStateUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = null;

    _onPublisherStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;

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

  void destroyEngine() {
    ZegoExpressEngine.destroyEngine();
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
        ZegoExpressEngine.instance.startPlayingStream(
          streamID,
        );
      }

      ZegoLog().addLog('📥 Start publish stream, streamID: $streamID');
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

  Future<ZegoAudioEffectPlayer?> createAudioEffectPlayer() {
    return ZegoExpressEngine.instance.createAudioEffectPlayer();
  }

  void destroyAudioEffectPlayer(ZegoAudioEffectPlayer audioEffectPlayer) {
    ZegoExpressEngine.instance.destroyAudioEffectPlayer(audioEffectPlayer);
  }
}
