import 'package:universal_io/io.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew//utils/zego_log_view.dart';
import 'package:smatch/callnew//utils/zego_user_helper.dart';

class CameraPage extends StatefulWidget {
  CameraPage();

  @override
  State<StatefulWidget> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final _roomID = 'camera';
  final _streamID = 'camera_s';
  late TextEditingController _streamIDController;

  late ZegoPublisherState _publisherState;
  late ZegoRoomState _roomState;
  Widget? _view;

  late bool _useFrontCamera;
  late bool _enableCameraFocus;
  late bool _enableCameraExposure;
  late ZegoCameraExposureMode _cameraExposureMode;
  late ZegoCameraFocusMode _cameraFocusMode;
  late double _zoomFactor;
  late double _minZoomFactor;
  late double _maxZoomFactor;
  late double _exposureCompensation;

  late bool _isSupportCmeraFocus;

  late ZegoDelegate _zegoDelegate;

  Size? _size;

  @override
  void initState() {
    super.initState();

    _zegoDelegate = ZegoDelegate();

    _roomState = ZegoRoomState.Disconnected;
    _streamIDController = TextEditingController();
    _streamIDController.text = _streamID;
    _publisherState = ZegoPublisherState.NoPublish;

    _useFrontCamera = false;
    _enableCameraFocus = false;
    _enableCameraExposure = false;
    _cameraExposureMode = ZegoCameraExposureMode.AutoExposure;
    _cameraFocusMode = ZegoCameraFocusMode.AutoFocus;
    _zoomFactor = 1;
    _minZoomFactor = 1;
    _maxZoomFactor = 2;
    _exposureCompensation = 0;
    _isSupportCmeraFocus = true;

    _zegoDelegate.setZegoEventCallback(
        onRoomStateUpdate: onRoomStateUpdate,
        onPublisherStateUpdate: onPublisherStateUpdate,
        onPublisherCapturedVideoFirstFrame: onPublisherCapturedVideoFirstFrame);
    _zegoDelegate.createEngine().then((value) {
      _zegoDelegate.loginRoom(_roomID);
      _zegoDelegate.useFrontCamera(_useFrontCamera);
    });
  }

  @override
  void dispose() {
    // Can destroy the engine when you don't need audio and video calls
    //
    // Destroy engine will automatically logout room and stop publishing/playing stream.

    _zegoDelegate.dispose();

    _zegoDelegate.clearZegoEventCallback();

    _zegoDelegate
        .logoutRoom(_roomID)
        .then((value) => _zegoDelegate.destroyEngine());

    ZegoLog().addLog('🏳️ Destroy ZegoExpressEngine');
    super.dispose();
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
    if (streamID == _streamIDController.text.trim()) {
      setState(() {
        _publisherState = state;
      });
    }
  }

  void onPublisherCapturedVideoFirstFrame(ZegoPublishChannel channel) async {
    _zegoDelegate.isCameraFocusSupported().then((value) {
      ZegoLog().addLog('isCameraFocusSupported $value');
      setState(() {
        _isSupportCmeraFocus = value;
      });
    });
    _zegoDelegate.getCameraMaxZoomFactor().then((value) {
      ZegoLog().addLog('getCameraMaxZoomFactor $value');
      setState(() {
        _maxZoomFactor = value;
      });
    });
  }

  // widget callback
  void onUseFrontCameraSwitchChanged(bool isChecked) {
    _useFrontCamera = isChecked;
    _zegoDelegate.useFrontCamera(isChecked);
    setState(() {});
  }

  void onEnableCameraFocusSwitchChanged(bool isChecked) {
    _enableCameraFocus = isChecked;
    setState(() {});
  }

  void onEnableCameraExposureSwitchChanged(bool isChecked) {
    _enableCameraExposure = isChecked;
    setState(() {});
  }

  void onCameraFocusModeChanged(ZegoCameraFocusMode? mode) {
    if (mode != null) {
      _cameraFocusMode = mode;
      _zegoDelegate.setCameraFocusMode(mode);
      setState(() {});
    }
  }

  void onCameraExposureModeChanged(ZegoCameraExposureMode? mode) {
    if (mode != null) {
      _cameraExposureMode = mode;
      _zegoDelegate.setCameraExposureMode(mode);
      setState(() {});
    }
  }

  void onZoomFactorChanged(double value) {
    _zoomFactor = value;
    _zegoDelegate.setCameraZoomFactor(_zoomFactor);
    setState(() {});
  }

  void onExposureCompensationChanged(double value) {
    _exposureCompensation = value;
    _zegoDelegate.setCameraExposureCompensation(_exposureCompensation);
    setState(() {});
  }

  void onPublishBtnPress() {
    if (_publisherState == ZegoPublisherState.Publishing) {
      _zegoDelegate.stopPublishing();
    } else {
      _zegoDelegate
          .startPublishing(
        _streamIDController.text.trim(),
      )
          .then((widget) {
        setState(() {
          _view = widget;
        });
      });
    }
  }

  void onPointerDown(PointerDownEvent event) {
    ZegoLog().addLog('position: ${event.localPosition} size: $_size');
    if (_size != null) {
      if (_enableCameraFocus) {
        _zegoDelegate.setCameraFocusPointInPreview(
            event.localPosition.dx / _size!.width,
            event.localPosition.dy / _size!.height);
      }
      if (_enableCameraExposure) {
        _zegoDelegate.setCameraExposurePointInPreview(
            event.localPosition.dx / _size!.width,
            event.localPosition.dy / _size!.height);
      }
    }
  }

  // widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('摄像头'),
        ),
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          final double pixelRatio = MediaQuery.of(context).devicePixelRatio;
          _size = constraints.biggest;
          return Listener(
            onPointerDown: onPointerDown,
            child: SafeArea(
                child: Stack(children: [
              Container(
                color: Colors.white,
                child: _view,
                padding: EdgeInsets.zero,
              ),
              paramWidget()
            ])),
          );
        }));
  }

  Widget paramWidget() {
    return Padding(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Column(
          children: [
            roomInfoWidget(),
            Expanded(child: Container()),
            streamIDWidget(),
            Padding(padding: EdgeInsets.only(bottom: 10)),
            cameraWidget(),
            startButton(),
            Padding(padding: EdgeInsets.only(bottom: 10)),
          ],
        ));
  }

  Widget roomInfoWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("RoomID: $_roomID"),
      Text('RoomState: ${_zegoDelegate.roomStateDesc(_roomState)}')
    ]);
  }

  Widget streamIDWidget() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('StreamID: '),
      Expanded(
          child: TextField(
        controller: _streamIDController,
        onEditingComplete: () {},
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10.0),
            isDense: true,
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff0e88eb)))),
      ))
    ]);
  }

  Widget cameraWidget() {
    return Column(
      children: [
        // 摄像头切换
        Row(
          children: [
            Expanded(child: Text('前后摄像头切换')),
            Switch(
                value: _useFrontCamera,
                onChanged: onUseFrontCameraSwitchChanged)
          ],
        ),
        // 摄像头对焦
        Row(
          children: [
            Expanded(child: Text('摄像头对焦')),
            Switch(
                value: _enableCameraFocus,
                onChanged: onEnableCameraFocusSwitchChanged)
          ],
        ),
        // 摄像头曝光
        Row(
          children: [
            Expanded(child: Text('摄像头曝光')),
            Switch(
                value: _enableCameraExposure,
                onChanged: onEnableCameraExposureSwitchChanged)
          ],
        ),
        // 摄像头对焦模式
        Row(
          children: [
            Expanded(child: Text('摄像头对焦模式')),
            DropdownButton<ZegoCameraFocusMode>(
              items: [
                DropdownMenuItem(
                    child: Text(ZegoCameraFocusMode.AutoFocus.name),
                    value: ZegoCameraFocusMode.AutoFocus),
                DropdownMenuItem(
                    child: Text(ZegoCameraFocusMode.ContinuousAutoFocus.name),
                    value: ZegoCameraFocusMode.ContinuousAutoFocus)
              ],
              onChanged: _isSupportCmeraFocus ? onCameraFocusModeChanged : null,
              value: _cameraFocusMode,
            )
          ],
        ),
        // 摄像头曝光模式
        Row(
          children: [
            Expanded(child: Text('摄像头曝光模式')),
            DropdownButton<ZegoCameraExposureMode>(
              items: [
                DropdownMenuItem(
                    child: Text(ZegoCameraExposureMode.AutoExposure.name),
                    value: ZegoCameraExposureMode.AutoExposure),
                DropdownMenuItem(
                    child: Text(
                        ZegoCameraExposureMode.ContinuousAutoExposure.name),
                    value: ZegoCameraExposureMode.ContinuousAutoExposure)
              ],
              onChanged: onCameraExposureModeChanged,
              value: _cameraExposureMode,
            )
          ],
        ),
        // 摄像头变焦倍数
        Row(
          children: [
            Text('摄像头变焦倍数  '),
            Text(_zoomFactor.toStringAsFixed(1)),
            Expanded(
                child: Slider(
              value: _zoomFactor,
              onChanged: onZoomFactorChanged,
              min: _minZoomFactor,
              max: _maxZoomFactor,
            )),
            Text(_maxZoomFactor.toStringAsFixed(1)),
          ],
        ),
        // 曝光补偿
        Row(
          children: [
            Text('曝光补偿  '),
            Text(_exposureCompensation.toStringAsFixed(1)),
            Expanded(
                child: Slider(
              value: _exposureCompensation,
              onChanged: onExposureCompensationChanged,
              min: -1,
              max: 1,
              divisions: 20,
            )),
            Text('Range: [-1, 1]'),
          ],
        ),
      ],
    );
  }

  Widget startButton() {
    return CupertinoButton.filled(
        child: Text(
          _publisherState == ZegoPublisherState.Publishing ? '✅ 停止推流' : '开始推流',
          style: TextStyle(fontSize: 14.0),
        ),
        onPressed: onPublishBtnPress,
        padding: EdgeInsets.all(10.0));
  }
}

typedef RoomStateUpdateCallback = void Function(
    String, ZegoRoomState, int, Map<String, dynamic>);
typedef PublisherStateUpdateCallback = void Function(
    String, ZegoPublisherState, int, Map<String, dynamic>);
typedef PlayerStateUpdateCallback = void Function(
    String, ZegoPlayerState, int, Map<String, dynamic>);
typedef PublisherCapturedVideoFirstFrameCallback = void Function(
    ZegoPublishChannel);

class ZegoDelegate {
  RoomStateUpdateCallback? _onRoomStateUpdate;
  PublisherStateUpdateCallback? _onPublisherStateUpdate;
  PlayerStateUpdateCallback? _onPlayerStateUpdate;
  PublisherCapturedVideoFirstFrameCallback? _onPublisherCapturedVideoFirstFrame;

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

    ZegoExpressEngine.onPublisherCapturedVideoFirstFrame = (channel) {
      ZegoLog().addLog(
          '🚩 📥 onPublisherCapturedVideoFirstFrame channel: ${channel.name}');
      _onPublisherCapturedVideoFirstFrame?.call(channel);
    };
  }

  void setZegoEventCallback(
      {RoomStateUpdateCallback? onRoomStateUpdate,
      PublisherStateUpdateCallback? onPublisherStateUpdate,
      PlayerStateUpdateCallback? onPlayerStateUpdate,
      PublisherCapturedVideoFirstFrameCallback?
          onPublisherCapturedVideoFirstFrame}) {
    if (onRoomStateUpdate != null) {
      _onRoomStateUpdate = onRoomStateUpdate;
    }
    if (onPublisherStateUpdate != null) {
      _onPublisherStateUpdate = onPublisherStateUpdate;
    }
    if (onPlayerStateUpdate != null) {
      _onPlayerStateUpdate = onPlayerStateUpdate;
    }
    if (onPublisherCapturedVideoFirstFrame != null) {
      _onPublisherCapturedVideoFirstFrame = onPublisherCapturedVideoFirstFrame;
    }
  }

  void clearZegoEventCallback() {
    _onRoomStateUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = null;

    _onPublisherStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;

    _onPlayerStateUpdate = null;
    ZegoExpressEngine.onPlayerStateUpdate = null;

    _onPublisherCapturedVideoFirstFrame = null;
    ZegoExpressEngine.onPublisherCapturedVideoFirstFrame = null;
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

  void setMinVideoBitrateForTrafficControl(
      int bitrate, ZegoTrafficControlMinVideoBitrateMode mode) {
    ZegoExpressEngine.instance
        .setMinVideoBitrateForTrafficControl(bitrate, mode);
  }

  void enableTrafficControl(bool enable) {
    ZegoExpressEngine.instance
        .enableTrafficControl(enable, ZegoTrafficControlProperty.Basic);
  }

  Future<double> getCameraMaxZoomFactor() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return ZegoExpressEngine.instance.getCameraMaxZoomFactor();
    }
    return 1.0;
  }

  Future<bool> isCameraFocusSupported() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return ZegoExpressEngine.instance.isCameraFocusSupported();
    }
    return false;
  }

  void setCameraExposureCompensation(double value) {
    if (Platform.isAndroid || Platform.isIOS) {
      ZegoExpressEngine.instance.setCameraExposureCompensation(value);
    }
  }

  void setCameraZoomFactor(double value) {
    if (Platform.isAndroid || Platform.isIOS) {
      ZegoExpressEngine.instance.setCameraZoomFactor(value);
    }
  }

  void setCameraExposureMode(ZegoCameraExposureMode mode) {
    if (Platform.isAndroid || Platform.isIOS) {
      ZegoExpressEngine.instance.setCameraExposureMode(mode);
    }
  }

  void setCameraFocusMode(ZegoCameraFocusMode mode) {
    if (Platform.isAndroid || Platform.isIOS) {
      ZegoExpressEngine.instance.setCameraFocusMode(mode);
    }
  }

  void useFrontCamera(bool bUse) {
    if (Platform.isAndroid || Platform.isIOS) {
      ZegoExpressEngine.instance.useFrontCamera(bUse);
    }
  }

  void setCameraFocusPointInPreview(double x, double y) {
    if (Platform.isAndroid || Platform.isIOS) {
      ZegoExpressEngine.instance.setCameraFocusPointInPreview(x, y);
    }
  }

  void setCameraExposurePointInPreview(double x, double y) {
    if (Platform.isAndroid || Platform.isIOS) {
      ZegoExpressEngine.instance.setCameraExposurePointInPreview(x, y);
    }
  }
}
