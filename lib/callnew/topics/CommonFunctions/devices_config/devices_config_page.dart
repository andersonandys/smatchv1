import 'dart:async';
import 'package:universal_io/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew/utils/zego_log_view.dart';
import 'package:smatch/callnew/utils/zego_user_helper.dart';

class DevicesConfigPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DevicesConfigState();
}

class _DevicesConfigState extends State<DevicesConfigPage>
    with WidgetsBindingObserver {
  static const _roomID = 'devices_config';
  late ZegoRoomState _roomState;
  List microphones = [];
  List cameras = [];
  List speakers = [];
  late int _previewViewID;
  Widget? _previewViewWidget;
  late ZegoPublisherState _publisherState;
  late Key _previewViewContainerKey;
  late String _preCamera;
  late String _preMicrophone;
  late TextEditingController _publishingStreamIDController;

  late int _playviewViewID;
  Widget? _playViewWidget;
  late ZegoPlayerState _playerState;
  late Key _playViewContainerKey;
  late String _playSpeaker;
  late TextEditingController _playingStreamIDController;

  late TextEditingController _encodingResolutionWController;
  late TextEditingController _encodingResolutionHController;

  late TextEditingController _frameRateController;
  late TextEditingController _bitRateController;
  static const double viewRatio = 3.0 / 6.0;
  late ZegoVideoMirrorMode _mirrorMode;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addObserver(this);

    _roomState = ZegoRoomState.Disconnected;

    _previewViewID = -1;
    _publisherState = ZegoPublisherState.NoPublish;
    _previewViewContainerKey = GlobalKey();
    _preCamera = "default";
    _preMicrophone = "default";
    _publishingStreamIDController = new TextEditingController();
    _publishingStreamIDController.text = "devices_config_room";

    _playviewViewID = -1;
    _playerState = ZegoPlayerState.NoPlay;
    _playViewContainerKey = GlobalKey();
    _playSpeaker = "default";
    _playingStreamIDController = new TextEditingController();
    _playingStreamIDController.text = "devices_config_room";

    _encodingResolutionWController = new TextEditingController();
    _encodingResolutionWController.text = "360";
    _encodingResolutionHController = new TextEditingController();
    _encodingResolutionHController.text = "720";

    _frameRateController = new TextEditingController();
    _frameRateController.text = "15";
    _bitRateController = new TextEditingController();
    _bitRateController.text = "600";
    _mirrorMode = ZegoVideoMirrorMode.NoMirror;

    getEngineConfig();
    setZegoEventCallback();
    createEngine();
    loginRoom();
    setDevices();
    // 兼容部分浏览器在第一次获取到的deviceName为空
    Future.delayed(Duration(seconds: 2), () {
      setDevices();
    });
  }

  void setDevices() {
    ZegoExpressEngine.instance.getVideoDeviceList().then((list) async {
      if (!kIsWeb) {
        _preCamera = await ZegoExpressEngine.instance.getDefaultVideoDeviceID();
      } else if (list.length > 0) {
        _preCamera = list[0].deviceID;
      }
      cameras = list;
      // print(cameras[0].deviceName);
      print(list[0].deviceName);
      setState(() {});
    });
    ZegoExpressEngine.instance
        .getAudioDeviceList(ZegoAudioDeviceType.Input)
        .then((list) async {
      if (!kIsWeb) {
        _preMicrophone = await ZegoExpressEngine.instance
            .getDefaultAudioDeviceID(ZegoAudioDeviceType.Input);
      } else if (list.length > 0) {
        _preMicrophone = list[0].deviceID;
      }
      microphones = list;
      setState(() {});
    });
    ZegoExpressEngine.instance
        .getAudioDeviceList(ZegoAudioDeviceType.Output)
        .then((list) async {
      if (!kIsWeb) {
        _playSpeaker = await ZegoExpressEngine.instance
            .getDefaultAudioDeviceID(ZegoAudioDeviceType.Output);
      } else if (list.length > 0) {
        _playSpeaker = list[0].deviceID;
      }
      speakers = list;
      setState(() {});
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // In iOS, there is no done key on the numeric keyboard, and the onEditingComplete of TextField cannot be triggered
      // Set video configuration parameters by listening for keyboard hiding
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    // Can destroy the engine when you don't need audio and video calls
    //
    // Destroy engine will automatically logout room and stop publishing/playing stream.
    clearZegoEventCallback();
    clearPreviewView();
    clearPlayView();
    logoutRoom().then((value) => ZegoExpressEngine.destroyEngine());
    ZegoLog().addLog('🏳️ Destroy ZegoExpressEngine');

    super.dispose();
  }

  // widget callback

  void onStartPlayingStreamButtonPressed() {
    if (_playingStreamIDController.value.text.isEmpty) {
      return;
    }
    var streamID = _playingStreamIDController.value.text;
    if (_playerState == ZegoPlayerState.Playing) {
      ZegoExpressEngine.instance.stopPlayingStream(streamID);
      ZegoLog().addLog('Stop playing stream, streamID: ${streamID}');
    } else {
      if (Platform.isIOS ||
          Platform.isAndroid ||
          Platform.isWindows ||
          Platform.isMacOS ||
          kIsWeb) {
        ZegoExpressEngine.instance.createCanvasView((viewID) {
          _playviewViewID = viewID;
          ZegoExpressEngine.instance.startPlayingStream(streamID,
              canvas: ZegoCanvas(_playviewViewID));
          ZegoLog().addLog('📥 Start playing stream, streamID: ${streamID}');
        }).then((widget) {
          setState(() {
            _playViewWidget = widget;
          });
        });
      } else {
        ZegoExpressEngine.instance.startPlayingStream(streamID);
      }
    }
  }

  void onPreCameraChanged(String deviceID) {
    setState(() {
      _preCamera = deviceID;
    });
    ZegoExpressEngine.instance.useVideoDevice(deviceID);
    ZegoLog().addLog('🚀 set PreView Camera : $deviceID');
    setState(() {});
  }

  void onPlaySpeakerChanged(String deviceID) {
    setState(() {
      _playSpeaker = deviceID;
    });
    ZegoExpressEngine.instance
        .useAudioDevice(ZegoAudioDeviceType.Output, deviceID);
    // ZegoExpressEngine.instance.useAudioOutputDevice(_playviewViewID, deviceID);
    ZegoLog().addLog('🚀 set Play Speaker : $deviceID');
    setState(() {});
  }

  void onPreMicrophonesChanged(String deviceID) {
    setState(() {
      _preMicrophone = deviceID;
      _preMicrophone = deviceID;
    });
    ZegoExpressEngine.instance
        .useAudioDevice(ZegoAudioDeviceType.Input, deviceID);
    ZegoLog().addLog('🚀 set PreView Microphones : $deviceID');
    setState(() {});
  }

  // widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Devices config')),
      body: SafeArea(
          child: GestureDetector(
        child: mainContent(context),
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      )),
    );
  }

  Widget mainContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            child: ZegoLogView(),
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          roomInfoWidget(),
          streamViewWidget(),
        ],
      ),
    );
  }

  Widget roomInfoWidget() {
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(children: [
          Text("RoomID: $_roomID"),
          Spacer(),
          Text(roomStateDesc()),
        ]));
  }

  Widget streamViewWidget() {
    return Container(
        height: MediaQuery.of(context).size.width,
        child: GridView(
          padding: const EdgeInsets.all(10.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: viewRatio,
          ),
          children: [viewsWidget(true), viewsWidget(false)],
        ));
  }

  Widget viewsWidget(bool isPreView) {
    getDropdownButtonRowByList(
        List list, String value, String title, Function onChange) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: list.length == 0
              ? []
              : [
                  Text(title, style: TextStyle(fontSize: 12.0)),
                  list.length > 0
                      ? DropdownButton(
                          value: !list.isEmpty && value == 'default'
                              ? list[0].deviceID
                              : value,
                          items: list
                              .map((e) {
                                return DropdownMenuItem(
                                    child: Text(e.deviceName,
                                        style: TextStyle(fontSize: 12.0)),
                                    value: e.deviceID);
                              })
                              .toSet()
                              .toList(),
                          onChanged: (val) {
                            onChange(val);
                          })
                      : Text(list[0].deviceName ?? 'defalut',
                          style: TextStyle(fontSize: 12.0))
                ]);
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
              child: Stack(
            children: [
              Container(
                color: Colors.grey,
                child: isPreView ? _previewViewWidget : _playViewWidget,
                key: isPreView
                    ? _previewViewContainerKey
                    : _playViewContainerKey,
              ),
              Text(isPreView ? 'Local Preview View' : 'Remote Play View',
                  style: TextStyle(color: Colors.white))
            ],
            alignment: AlignmentDirectional.topCenter,
          )),
          isPreView
              ? getDropdownButtonRowByList(
                  cameras, _preCamera, 'cameras', onPreCameraChanged)
              : Text(''),
          isPreView
              ? getDropdownButtonRowByList(microphones, _preMicrophone,
                  'microphone', onPreMicrophonesChanged)
              : Text(''),
          isPreView
              ? Text('')
              : getDropdownButtonRowByList(
                  speakers, _playSpeaker, 'speakers', onPlaySpeakerChanged),
          TextField(
            controller: isPreView
                ? _publishingStreamIDController
                : _playingStreamIDController,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10.0),
                isDense: true,
                labelText: isPreView ? 'Play StreamID:' : 'Publish StreamID:',
                labelStyle: TextStyle(color: Colors.black54, fontSize: 14.0),
                hintText: 'Please enter streamID',
                hintStyle: TextStyle(color: Colors.black26, fontSize: 10.0),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff0e88eb)))),
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          CupertinoButton.filled(
            child: Text(
              isPreView
                  ? (_publisherState == ZegoPublisherState.Publishing
                      ? '✅ StopPublishing'
                      : 'StartPublishing')
                  : (_playerState == ZegoPlayerState.Playing
                      ? '✅ StopPlaying'
                      : 'StartPlaying'),
              style: TextStyle(fontSize: 14.0),
            ),
            onPressed: isPreView
                ? startPublishingStream
                : onStartPlayingStreamButtonPressed,
            padding: EdgeInsets.all(10.0),
          )
        ]);
  }

  void clearPreviewView() {
    if (_previewViewWidget == null) {
      return;
    }

    // Developers should destroy the [PlatformView] or [TextureRenderer] after
    // [stopPublishingStream] or [stopPreview] to release resource and avoid memory leaks
    if (Platform.isIOS ||
        Platform.isAndroid ||
        Platform.isWindows ||
        Platform.isMacOS ||
        kIsWeb) {
      ZegoExpressEngine.instance.destroyCanvasView(_previewViewID);
    }
  }

  void clearPlayView() {
    if (_playViewWidget == null) {
      return;
    }

    // Developers should destroy the [PlatformView] or [TextureRenderer]
    // after [stopPlayingStream] to release resource and avoid memory leaks
    if (Platform.isIOS ||
        Platform.isAndroid ||
        Platform.isWindows ||
        Platform.isMacOS ||
        kIsWeb) {
      ZegoExpressEngine.instance.destroyCanvasView(_playviewViewID);
    }
  }

  void getEngineConfig() {
    ZegoExpressEngine.getVersion()
        .then((value) => ZegoLog().addLog('🌞 SDK Version: $value'));
  }

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
      if (state == ZegoPublisherState.Publishing && errorCode == 0) {
        ZegoLog().addLog('🚩 📥 Publishing stream success');
      }
      if (errorCode != 0) {
        ZegoLog().addLog('🚩 ❌ 📥 Publishing stream fail');
      }
      setState(() => _publisherState = state);
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
      setState(() => _playerState = state);
    };
  }

  void clearZegoEventCallback() {
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
    ZegoExpressEngine.onPlayerStateUpdate = null;
  }

  void createEngine() {
    ZegoEngineProfile profile = ZegoEngineProfile(
        ZegoConfig.instance.appID, ZegoConfig.instance.scenario,
        enablePlatformView: ZegoConfig.instance.enablePlatformView,
        appSign: kIsWeb ? null : ZegoConfig.instance.appSign);
    ZegoExpressEngine.createEngineWithProfile(profile)
        .then((value) => startPreview());
    ZegoExpressEngine.onRemoteCameraStateUpdate = (streamid, state) {
      ZegoLog().addLog(
          'onRemoteCameraStateUpdate streamid: $streamid, state: $state');
    };
    ZegoExpressEngine.onRemoteMicStateUpdate = (streamid, state) {
      ZegoLog()
          .addLog('onRemoteMicStateUpdate streamid: $streamid, state: $state');
    };
    ZegoExpressEngine.onRemoteSoundLevelUpdate = (soundLevels) {
      ZegoLog().addLog(soundLevels.toString());
    };
    ZegoExpressEngine.onCapturedSoundLevelUpdate = (soundLevel) {
      ZegoLog().addLog(soundLevel.toString());
    };
    ZegoLog().addLog('🚀 Create ZegoExpressEngine');
  }

  void startPreview() {
    if (Platform.isIOS ||
        Platform.isAndroid ||
        Platform.isWindows ||
        Platform.isMacOS ||
        kIsWeb) {
      ZegoExpressEngine.instance.createCanvasView((viewID) {
        _previewViewID = viewID;
        ZegoLog().addLog('🔌 Start preview');
        ZegoExpressEngine.instance
            .startPreview(canvas: ZegoCanvas(_previewViewID));
      }).then((widget) {
        setState(() {
          _previewViewWidget = widget;
        });
      });
    } else {
      ZegoExpressEngine.instance.startPreview();
    }
  }

  Future<void> loginRoom() async {
    // Instantiate a ZegoUser object
    ZegoUser user = ZegoUser(
        ZegoUserHelper.instance.userID, ZegoUserHelper.instance.userName);

    // Login Room
    ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
    if (kIsWeb) {
      var token = await ZegoConfig.instance
          .getToken(ZegoUserHelper.instance.userID, _roomID);
      config.token = token;
    }
    await ZegoExpressEngine.instance.loginRoom(_roomID, user, config: config);

    ZegoLog().addLog('🚪 Start login room, roomID: $_roomID');
  }

  Future logoutRoom() async {
    ZegoLog().addLog('🚪 Start logout room, roomID: $_roomID');
    if (_roomState == ZegoRoomState.Connected) {
      await ZegoExpressEngine.instance.logoutRoom(_roomID);
    }
  }

  void startPublishingStream() {
    if (_publishingStreamIDController.value.text.isEmpty) {
      return;
    }
    if (_publisherState == ZegoPublisherState.Publishing) {
      ZegoExpressEngine.instance.stopPublishingStream();
      ZegoLog().addLog('📤 Stop publishing stream.');
    } else {
      ZegoExpressEngine.instance
          .startPublishingStream(_publishingStreamIDController.value.text);
      ZegoLog().addLog(
          '📤 Start publishing stream. streamID: ${_publishingStreamIDController.value.text}');
    }
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
