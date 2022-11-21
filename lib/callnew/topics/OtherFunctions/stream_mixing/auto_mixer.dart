import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew//utils/zego_log_view.dart';
import 'package:smatch/callnew//utils/zego_user_helper.dart';

class AutoMixerPage extends StatefulWidget {
  const AutoMixerPage({Key? key}) : super(key: key);

  @override
  _AutoMixerPageState createState() => _AutoMixerPageState();
}

class _AutoMixerPageState extends State<AutoMixerPage> {
  late Map<String, ZegoStream> _streamMap;
  late TextEditingController _taskIDController;
  late TextEditingController _mixerOutController;
  late TextEditingController _streamIDController;
  late TextEditingController _cdnUrlController;
  late bool _isMix;
  late ZegoPlayerState _playerState;

  final _roomID = 'mixer';

  late ZegoDelegate _zegoDelegate;

  @override
  void initState() {
    super.initState();

    _zegoDelegate = ZegoDelegate();

    _streamMap = {};

    _taskIDController = TextEditingController();
    _mixerOutController = TextEditingController();
    _streamIDController = TextEditingController();
    _cdnUrlController = TextEditingController();

    _zegoDelegate.setZegoEventCallback(
        onPlayerStateUpdate: onPlayerStateUpdate,
        onRoomStreamUpdate: onRoomStreamUpdate);

    _isMix = false;
    _playerState = ZegoPlayerState.NoPlay;

    _zegoDelegate.createEngine().then((value) {
      _zegoDelegate.loginRoom(_roomID);
    });
  }

  @override
  void dispose() {
    _zegoDelegate.dispose();
    _zegoDelegate.clearZegoEventCallback();
    _zegoDelegate
        .logoutRoom(_roomID)
        .then((value) => _zegoDelegate.destroyEngine());

    super.dispose();
  }

  void onPlayerStateUpdate(String streamID, ZegoPlayerState state,
      int errorCode, Map<String, dynamic> extendedData) {
    if (streamID == _mixerOutController.text && errorCode == 0) {
      setState(() {
        _playerState = state;
      });
    }
  }

  void onRoomStreamUpdate(String roomID, ZegoUpdateType updateType,
      List<ZegoStream> streamList, Map<String, dynamic> extendedData) {
    if (updateType == ZegoUpdateType.Add) {
      for (var stream in streamList) {
        _streamMap[stream.streamID] = stream;
      }
    } else {
      for (var stream in streamList) {
        _streamMap.remove(stream.streamID);
      }
    }
    setState(() {});
  }

  void onStartBtnPress() {
    if (_isMix) {
      _zegoDelegate
          .stopAutoMixerTask(
              _taskIDController.text, 'mixer', _mixerOutController.text)
          .then((value) {
        if (value.errorCode == 0) {
          setState(() {
            _isMix = false;
          });
        }
      });
    } else {
      _zegoDelegate
          .startAutoMixerTask(
              _taskIDController.text, 'mixer', _mixerOutController.text)
          .then((value) {
        if (value.errorCode == 0) {
          setState(() {
            _isMix = true;
          });
        }
      });
    }
  }

  void onPlayBtnPress() {
    if (_playerState != ZegoPlayerState.NoPlay) {
      _zegoDelegate.stopPlaying(_streamIDController.text);
    } else {
      _zegoDelegate.startPlaying(_streamIDController.text, needShow: false);
    }
  }

  Widget streamWidget(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.2,
        child: ListView.builder(
          itemBuilder: (context, index) {
            var userID = _streamMap.values.toList()[index].user.userID;
            var streamID = _streamMap.keys.toList()[index];
            return Text('userID:$userID \n streamID: $streamID');
          },
          itemCount: _streamMap.length,
        ));
  }

  Widget startAutoMixWidget(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text('Task ID: ')),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: TextField(
                  controller: _taskIDController,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff0e88eb)))),
                ))
          ],
        ),
        Padding(padding: EdgeInsets.only(bottom: 10)),
        Row(
          children: [
            Expanded(child: Text('Mixer out: ')),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: TextField(
                  controller: _mixerOutController,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff0e88eb)))),
                ))
          ],
        )
      ],
    );
  }

  Widget startPlayWidget(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text('stream ID: ')),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: TextField(
                  controller: _streamIDController,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff0e88eb)))),
                ))
          ],
        ),
        Padding(padding: EdgeInsets.only(bottom: 10)),
        Row(
          children: [
            Expanded(child: Text('CDN url: ')),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: TextField(
                  controller: _cdnUrlController,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff0e88eb)))),
                ))
          ],
        )
      ],
    );
  }

  Widget mainWidget() {
    return Column(children: [
      SizedBox(
        child: ZegoLogView(),
        height: MediaQuery.of(context).size.height * 0.1,
      ),
      Center(
          child: Container(
        padding: EdgeInsets.only(top: 20),
        width: MediaQuery.of(context).size.width * 0.7,
        child: Column(
          children: [
            Text('RoomID:    mixer'),
            Padding(padding: EdgeInsets.only(top: 10)),
            Text('streamList(${_streamMap.length})'),
            Padding(padding: EdgeInsets.only(top: 10)),
            streamWidget(context),
            Padding(padding: EdgeInsets.only(top: 10)),
            startAutoMixWidget(context),
            Padding(padding: EdgeInsets.only(top: 10)),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: CupertinoButton.filled(
                  child: Text(
                    _isMix ? '✅ 停止自动混流' : '开始自动混流',
                  ),
                  onPressed: onStartBtnPress,
                  padding: EdgeInsets.only(top: 10, bottom: 10)),
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            startPlayWidget(context),
            Padding(padding: EdgeInsets.only(top: 10)),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: CupertinoButton.filled(
                  child: Text(
                    _playerState != ZegoPlayerState.NoPlay
                        ? (_playerState == ZegoPlayerState.Playing
                            ? '✅ 停止拉流'
                            : '❌ 停止拉流')
                        : '开始拉流',
                  ),
                  onPressed: onPlayBtnPress,
                  padding: EdgeInsets.only(top: 10, bottom: 10)),
            ),
          ],
        ),
      ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("混流"),
      ),
      body: SafeArea(child: SingleChildScrollView(child: mainWidget())),
    );
  }
}

typedef PlayerStateUpdateCallback = void Function(
    String, ZegoPlayerState, int, Map<String, dynamic>);
typedef RoomStreamUpdateCallback = void Function(
    String roomID,
    ZegoUpdateType updateType,
    List<ZegoStream> streamList,
    Map<String, dynamic> extendedData);

class ZegoDelegate {
  PlayerStateUpdateCallback? _onPlayerStateUpdate;
  RoomStreamUpdateCallback? _onRoomStreamUpdate;

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

    ZegoExpressEngine.onRoomStreamUpdate = (String roomID,
        ZegoUpdateType updateType,
        List<ZegoStream> streamList,
        Map<String, dynamic> extendedData) {
      ZegoLog().addLog(
          '🚩 📥 onRoomStreamUpdate: roomID: $roomID, updateType: $updateType, streamList:${streamList.length}, streamList: [');
      for (var stream in streamList) {
        ZegoLog().addLog('streamID: ${stream.streamID}');
      }
      ZegoLog().addLog(']');
      _onRoomStreamUpdate?.call(roomID, updateType, streamList, extendedData);
    };
  }

  void setZegoEventCallback({
    PlayerStateUpdateCallback? onPlayerStateUpdate,
    RoomStreamUpdateCallback? onRoomStreamUpdate,
  }) {
    if (onPlayerStateUpdate != null) {
      _onPlayerStateUpdate = onPlayerStateUpdate;
    }

    if (onRoomStreamUpdate != null) {
      _onRoomStreamUpdate = onRoomStreamUpdate;
    }
  }

  void clearZegoEventCallback() {
    _onPlayerStateUpdate = null;
    ZegoExpressEngine.onPlayerStateUpdate = null;

    _onRoomStreamUpdate = null;
    ZegoExpressEngine.onPublisherQualityUpdate = null;
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

  Future<ZegoMixerStartResult> startAutoMixerTask(
      String taskID, String roomID, String outputID) {
    ZegoAutoMixerTask task = ZegoAutoMixerTask();

    task.taskID = taskID; //"task1";
    task.roomID = roomID;
    List<ZegoMixerOutput> outputList = [];
    ZegoMixerOutput output = new ZegoMixerOutput(outputID);
    ZegoMixerAudioConfig audioConfig = new ZegoMixerAudioConfig.defaultConfig();

    task.audioConfig = audioConfig;
    outputList.add(output);
    task.enableSoundLevel = true;
    task.outputList = outputList;

    return ZegoExpressEngine.instance.startAutoMixerTask(task);
  }

  Future<ZegoMixerStopResult> stopAutoMixerTask(
      String taskID, String roomID, String outputID) {
    ZegoAutoMixerTask task = ZegoAutoMixerTask();

    task.taskID = taskID; //"task1";
    task.roomID = roomID;
    List<ZegoMixerOutput> outputList = [];
    ZegoMixerOutput output = new ZegoMixerOutput(outputID);
    ZegoMixerAudioConfig audioConfig = new ZegoMixerAudioConfig.defaultConfig();

    task.audioConfig = audioConfig;
    outputList.add(output);
    task.enableSoundLevel = true;
    task.outputList = outputList;

    return ZegoExpressEngine.instance.stopAutoMixerTask(task);
  }
}
