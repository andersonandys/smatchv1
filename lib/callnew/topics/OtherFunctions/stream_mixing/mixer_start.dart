import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew//utils/zego_log_view.dart';
import 'package:smatch/callnew//utils/zego_user_helper.dart';

class MixerStartPage extends StatefulWidget {
  const MixerStartPage({Key? key}) : super(key: key);

  @override
  _MixerStartPageState createState() => _MixerStartPageState();
}

class _MixerStartPageState extends State<MixerStartPage> {
  Widget? _view;
  late bool _useCamera;
  late bool _useMic;
  late Map<String, bool> _streamMap;
  final _mixStreamID = 'mixer_start';

  late List<String> _startStreamIDs;

  final _roomID = 'mixer';

  late ZegoDelegate _zegoDelegate;

  @override
  void initState() {
    super.initState();

    _zegoDelegate = ZegoDelegate();

    _useCamera = true;
    _useMic = true;

    _streamMap = {};

    _startStreamIDs = [];

    _zegoDelegate.setZegoEventCallback(onRoomStreamUpdate: onRoomStreamUpdate);
    _zegoDelegate.createEngine().then((value) {
      _zegoDelegate.loginRoom(_roomID);
    });
  }

  @override
  void dispose() {
    _zegoDelegate.clearZegoEventCallback();
    _zegoDelegate.dispose();
    _zegoDelegate
        .logoutRoom(_roomID)
        .then((value) => _zegoDelegate.destroyEngine());

    super.dispose();
  }

  void onStartBtnPress() async {
    var streamIDList = <String>[];
    for (var stream in _streamMap.keys) {
      if (_streamMap[stream]!) {
        streamIDList.add(stream);
      }
    }
    if (streamIDList.length < 2) {
      return;
    }

    ZegoMixerStartResult result =
        await _zegoDelegate.startMixerTask(streamIDList, _mixStreamID);
    if (result.errorCode == 0) {
      _startStreamIDs = streamIDList;
    }
    ZegoLog().addLog(
        'startMixerTask: errorCode: ${result.errorCode}  extendedData:${result.extendedData}');

    _view = await _zegoDelegate.startPlaying(
      _mixStreamID,
    );
    setState(() {});
  }

  void onStopBtnPress() {
    _zegoDelegate.stopPlaying(_mixStreamID);
  }

  void onStopMixingBtnPress() {
    _zegoDelegate.stopMixerTask(_startStreamIDs, _mixStreamID).then((value) {
      ZegoLog().addLog('stopMixerTask: errorCode: ${value.errorCode}');
    });
  }

  void onCamareBtnPress() {
    setState(() {
      _useCamera = !_useCamera;
    });
    _zegoDelegate.enableCamare(_useCamera);
  }

  void onMicBtnPress() {
    setState(() {
      _useMic = !_useMic;
    });
    _zegoDelegate.enableAudioCaptureDevice(_useMic);
  }

  void onRoomStreamUpdate(String roomID, ZegoUpdateType updateType,
      List<ZegoStream> streamList, Map<String, dynamic> extendedData) {
    if (updateType == ZegoUpdateType.Add) {
      for (var stream in streamList) {
        _streamMap[stream.streamID] = false;
      }
    } else {
      for (var stream in streamList) {
        _streamMap.remove(stream.streamID);
      }
    }
    setState(() {});
  }

  Widget view() {
    return Stack(
      children: [
        Container(
          color: Colors.grey,
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.width * 0.8,
          child: _view,
        ),
        Positioned(
            right: 55,
            bottom: 5,
            width: 40,
            height: 40,
            child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _useCamera ? Colors.white : Colors.black38),
                child: IconButton(
                    color: _useCamera ? Colors.black : Colors.white,
                    onPressed: onCamareBtnPress,
                    icon: Icon(Icons.camera_alt)))),
        Positioned(
            right: 5,
            bottom: 5,
            width: 40,
            height: 40,
            child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _useMic ? Colors.white : Colors.black38),
                child: IconButton(
                    color: _useMic ? Colors.black : Colors.white,
                    onPressed: onMicBtnPress,
                    icon: Icon(Icons.mic))))
      ],
    );
  }

  Widget streamWidget(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.2,
        child: ListView.builder(
          itemBuilder: (context, index) {
            return Row(
              children: [
                Checkbox(
                    value: _streamMap.values.toList()[index],
                    onChanged: (bool? b) {
                      if (b != null) {
                        setState(() {
                          _streamMap[_streamMap.keys.toList()[index]] = b;
                        });
                      }
                    }),
                Text('${_streamMap.keys.toList()[index]}')
              ],
            );
          },
          itemCount: _streamMap.length,
        ));
  }

  Widget mainWidget() {
    return Column(children: [
      SizedBox(
        child: ZegoLogView(),
        height: MediaQuery.of(context).size.height * 0.1,
      ),
      Container(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Text('RoomID:    mixer'),
            Padding(padding: EdgeInsets.only(top: 10)),
            Center(
              child: view(),
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            Text('请选择2条远端的流参与混流'),
            Padding(padding: EdgeInsets.only(top: 10)),
            streamWidget(context),
            Padding(padding: EdgeInsets.only(top: 10)),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: CupertinoButton.filled(
                  child: Text(
                    '1.发起并观看混流',
                  ),
                  onPressed: onStartBtnPress,
                  padding: EdgeInsets.only(top: 10, bottom: 10)),
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: CupertinoButton.filled(
                  child: Text(
                    '2.停止观看混流',
                  ),
                  onPressed: onStopBtnPress,
                  padding: EdgeInsets.only(top: 10, bottom: 10)),
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: CupertinoButton.filled(
                  child: Text(
                    '3.停止混流',
                  ),
                  onPressed: onStopMixingBtnPress,
                  padding: EdgeInsets.only(top: 10, bottom: 10)),
            )
          ],
        ),
      )
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

typedef RoomStreamUpdateCallback = void Function(
    String roomID,
    ZegoUpdateType updateType,
    List<ZegoStream> streamList,
    Map<String, dynamic> extendedData);

class ZegoDelegate {
  RoomStreamUpdateCallback? _onRoomStreamUpdate;

  late int _playViewID;
  Widget? playWidget;

  ZegoDelegate() : _playViewID = -1;

  dispose() {
    if (_playViewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_playViewID);
      _playViewID = -1;
    }
  }

  void _initCallback() {
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
    RoomStreamUpdateCallback? onRoomStreamUpdate,
  }) {
    if (onRoomStreamUpdate != null) {
      _onRoomStreamUpdate = onRoomStreamUpdate;
    }
  }

  void clearZegoEventCallback() {
    _onRoomStreamUpdate = null;
    ZegoExpressEngine.onPublisherQualityUpdate = null;
  }

  void enableCamare(bool enable) {
    ZegoExpressEngine.instance.enableCamera(enable);
  }

  void enableAudioCaptureDevice(bool enable) {
    ZegoExpressEngine.instance.enableAudioCaptureDevice(enable);
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

  Future<ZegoMixerStartResult> startMixerTask(
      List<String> streamIDList, String mixStreamID) {
    var task = ZegoMixerTask("task1");
    List<ZegoMixerInput> inputList = [];
    int index = 0;
    for (var streamID in streamIDList) {
      ZegoMixerInput input = ZegoMixerInput.defaultConfig();
      input.streamID = streamID;
      input.layout = Rect.fromLTWH(0, index * 320, 360, 320);
      input.soundLevelID = index;
      inputList.add(input);
      index++;
    }

    List<ZegoMixerOutput> outputList = [];
    ZegoMixerOutput output = ZegoMixerOutput(mixStreamID);
    ZegoMixerAudioConfig audioConfig = ZegoMixerAudioConfig.defaultConfig();
    ZegoMixerVideoConfig videoConfig = ZegoMixerVideoConfig.defaultConfig();
    task.videoConfig = videoConfig;
    task.audioConfig = audioConfig;
    outputList.add(output);
    task.enableSoundLevel = true;
    task.inputList = inputList;
    task.outputList = outputList;

    ZegoWatermark watermark = new ZegoWatermark(
        "preset-id://zegowp.png", Rect.fromLTRB(0, 0, 180, 120));
    task.watermark = watermark;

    task.backgroundImageURL = "preset-id://zegobg.png";

    return ZegoExpressEngine.instance.startMixerTask(task);
  }

  Future<ZegoMixerStopResult> stopMixerTask(
      List<String> streamIDList, String mixStreamID) {
    var task = ZegoMixerTask("task1");
    List<ZegoMixerInput> inputList = [];
    int index = 0;
    for (var streamID in streamIDList) {
      ZegoMixerInput input = ZegoMixerInput.defaultConfig();
      input.streamID = streamID;
      input.layout = Rect.fromLTRB(0, 0, 360, 320);
      input.soundLevelID = index;
      inputList.add(input);
      index++;
    }

    List<ZegoMixerOutput> outputList = [];
    ZegoMixerOutput output = ZegoMixerOutput(mixStreamID);
    ZegoMixerAudioConfig audioConfig = ZegoMixerAudioConfig.defaultConfig();
    ZegoMixerVideoConfig videoConfig = ZegoMixerVideoConfig.defaultConfig();
    task.videoConfig = videoConfig;
    task.audioConfig = audioConfig;
    outputList.add(output);
    task.enableSoundLevel = true;
    task.inputList = inputList;
    task.outputList = outputList;

    ZegoWatermark watermark = new ZegoWatermark(
        "preset-id://zegowp.png", Rect.fromLTRB(0, 0, 300, 200));
    task.watermark = watermark;

    task.backgroundImageURL = "preset-id://zegobg.png";

    return ZegoExpressEngine.instance.stopMixerTask(task);
  }
}
