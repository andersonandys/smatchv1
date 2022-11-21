import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew//utils/zego_log_view.dart';
import 'package:smatch/callnew//utils/zego_user_helper.dart';

class EncodingAndDecodingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EncodingAndDecodingPageState();
}

class _EncodingAndDecodingPageState extends State<EncodingAndDecodingPage> {
  late String _roomID;
  late ZegoRoomState _roomState;
  Widget? _previewViewWidget;
  late ZegoPublisherState _publisherState;
  late TextEditingController _publishingStreamIDController;

  Widget? _playViewWidget;
  late ZegoPlayerState _playerState;
  late TextEditingController _playingStreamIDController;

  late bool _hardEncoding;
  late bool _hardDecoding;

  late ZegoVideoConfig _videoConfig;

  late bool _scalableVideoCoding;

  late ZegoVideoStreamType _videoLayerSpinner;

  late ZegoDelegate _zegoDelegate;

  @override
  void initState() {
    super.initState();

    _zegoDelegate = ZegoDelegate();

    _roomID = 'encoding_and_decoding';
    _roomState = ZegoRoomState.Disconnected;
    _publisherState = ZegoPublisherState.NoPublish;
    _publishingStreamIDController = new TextEditingController();
    _publishingStreamIDController.text = "encoding_and_decoding";

    _playerState = ZegoPlayerState.NoPlay;
    _playingStreamIDController = new TextEditingController();
    _playingStreamIDController.text = "encoding_and_decoding";

    _hardEncoding = false;
    _hardDecoding = false;

    _videoConfig = ZegoVideoConfig.preset(ZegoVideoConfigPreset.Preset360P);
    _videoConfig.codecID = ZegoVideoCodecID.Default;
    if (Platform.isWindows || Platform.isMacOS) {
      _videoConfig.captureHeight = 360;
      _videoConfig.encodeHeight = 360;
      _videoConfig.captureWidth = 640;
      _videoConfig.encodeWidth = 640;
    }

    _scalableVideoCoding = false;

    _videoLayerSpinner = ZegoVideoStreamType.Default;

    _zegoDelegate.setZegoEventCallback(
        onRoomStateUpdate: onRoomStateUpdate,
        onPublisherStateUpdate: onPublisherStateUpdate,
        onPlayerStateUpdate: onPlayerStateUpdate);
    _zegoDelegate.createEngine().then((value) {
      _zegoDelegate.loginRoom(_roomID);
    });
  }

  @override
  void dispose() {
    // Can destroy the engine when you don't need audio and video calls
    //
    // Destroy engine will automatically logout room and stop publishing/playing stream.
    ZegoLog().addLog('🏳️ Destroy ZegoExpressEngine');

    _zegoDelegate.dispose();
    _zegoDelegate.clearZegoEventCallback();
    _zegoDelegate
        .logoutRoom(_roomID)
        .then((value) => _zegoDelegate.destroyEngine());

    super.dispose();
  }

  void onRoomStateUpdate(String roomID, ZegoRoomState state, int errorCode,
      Map<String, dynamic> extendedData) {
    ZegoLog().addLog(
        '🚩 🚪 Room state update, state: $state, errorCode: $errorCode, roomID: $roomID');
    if (roomID == _roomID) {
      setState(() {
        _roomState = state;
      });
    }
  }

  void onPublisherStateUpdate(String streamID, ZegoPublisherState state,
      int errorCode, Map<String, dynamic> extendedData) {
    if (streamID == _publishingStreamIDController.text) {
      setState(() {
        _publisherState = state;
      });
    }
  }

  void onPlayerStateUpdate(String streamID, ZegoPlayerState state,
      int errorCode, Map<String, dynamic> extendedData) {
    if (streamID == _playingStreamIDController.text) {
      setState(() {
        _playerState = state;
      });
    }
  }

  void onPublishBtnPress() {
    if (_publisherState == ZegoPublisherState.Publishing) {
      _zegoDelegate.stopPublishing();
    } else {
      _zegoDelegate.setVideoConfig(_videoConfig);
      _zegoDelegate
          .startPublishing(
        _publishingStreamIDController.text,
      )
          .then((widget) {
        setState(() {
          _previewViewWidget = widget;
        });
      });
    }
  }

  void onPlayBtnPress() {
    if (_playerState != ZegoPlayerState.NoPlay) {
      _zegoDelegate.stopPlaying(_playingStreamIDController.text);
    } else {
      _zegoDelegate
          .startPlaying(
        _playingStreamIDController.text,
      )
          .then((widget) {
        setState(() {
          _playViewWidget = widget;
        });
      });
    }
  }

  void onHardEncodingSwitchChanged(bool b) {
    setState(() {
      _hardEncoding = b;
    });
    _zegoDelegate.enableHardwareEncoder(b);
    if (_publisherState != ZegoPublisherState.NoPublish) {
      _zegoDelegate.stopPublishing();
    }
  }

  void onHardDecodingSwitchChanged(bool b) {
    if (_playerState != ZegoPlayerState.Playing) {
      setState(() {
        _hardDecoding = b;
      });
      _zegoDelegate.enableHardwareDecoder(b);
    }
  }

  void onCodecIDBtnChanged(ZegoVideoCodecID? codecID) {
    if (codecID != null) {
      setState(() {
        _videoConfig.codecID = codecID;
        if (_videoConfig.codecID == ZegoVideoCodecID.Svc &&
            !_scalableVideoCoding) {
          _scalableVideoCoding = true;
        } else if (_videoConfig.codecID != ZegoVideoCodecID.Svc &&
            _scalableVideoCoding) {
          _scalableVideoCoding = false;
        }
      });
    }
    if (_publisherState != ZegoPublisherState.NoPublish) {
      _zegoDelegate.stopPublishing();
    }
  }

  void onScalableVideoCodingSwitchChanged(bool b) {
    setState(() {
      _scalableVideoCoding = b;
      if (_scalableVideoCoding &&
          _videoConfig.codecID != ZegoVideoCodecID.Svc) {
        _videoConfig.codecID = ZegoVideoCodecID.Svc;
      } else if (!_scalableVideoCoding &&
          _videoConfig.codecID != ZegoVideoCodecID.Default) {
        _videoConfig.codecID = ZegoVideoCodecID.Default;
      }
    });
    if (_publisherState != ZegoPublisherState.NoPublish) {
      _zegoDelegate.stopPublishing();
    }
  }

  void onVideoLayerSpinnerBtnChanged(ZegoVideoStreamType? type) {
    if (type != null) {
      setState(() {
        _videoLayerSpinner = type;
      });
      _zegoDelegate.setPlayStreamVideoType(
          _playingStreamIDController.text, type);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('视频编解码')),
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
          videoSettingWidget(),
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
          Text(_zegoDelegate.roomStateDesc(_roomState)),
        ]));
  }

  Widget streamViewWidget() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(flex: 15, child: viewsWidget(true)),
            Expanded(flex: 1, child: Container()),
            Expanded(flex: 15, child: viewsWidget(false))
          ],
        ));
  }

  Widget videoSettingWidget() {
    return Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Expanded(child: Text('硬编码')),
              Switch(
                  value: _hardEncoding, onChanged: onHardEncodingSwitchChanged)
            ],
          ),
          Row(
            children: [
              Expanded(child: Text('硬解码')),
              Switch(
                  value: _hardDecoding, onChanged: onHardDecodingSwitchChanged)
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Expanded(child: Text('codecID')),
                  DropdownButton<ZegoVideoCodecID>(
                      onChanged: onCodecIDBtnChanged,
                      value: _videoConfig.codecID,
                      items: <DropdownMenuItem<ZegoVideoCodecID>>[
                        DropdownMenuItem<ZegoVideoCodecID>(
                          child: Text('ZegoVideoCodecID.SVC'),
                          value: ZegoVideoCodecID.Svc,
                        ),
                        DropdownMenuItem<ZegoVideoCodecID>(
                          child: Text('ZegoVideoCodecID.H265'),
                          value: ZegoVideoCodecID.H265,
                        ),
                        DropdownMenuItem<ZegoVideoCodecID>(
                          child: Text('ZegoVideoCodecID.Default'),
                          value: ZegoVideoCodecID.Default,
                        ),
                        DropdownMenuItem<ZegoVideoCodecID>(
                          child: Text('ZegoVideoCodecID.Vp8'),
                          value: ZegoVideoCodecID.Vp8,
                        ),
                      ])
                ],
              ),
              Text(
                'H.265只支持硬解编码',
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
          Row(
            children: [
              Expanded(child: Text('分层视频编码')),
              Switch(
                  value: _scalableVideoCoding,
                  onChanged: onScalableVideoCodingSwitchChanged)
            ],
          ),
          Row(
            children: [
              Expanded(child: Text('拉取视频分层')),
              DropdownButton<ZegoVideoStreamType>(
                  onChanged: onVideoLayerSpinnerBtnChanged,
                  value: _videoLayerSpinner,
                  items: <DropdownMenuItem<ZegoVideoStreamType>>[
                    DropdownMenuItem<ZegoVideoStreamType>(
                      child: Text('Default'),
                      value: ZegoVideoStreamType.Default,
                    ),
                    DropdownMenuItem<ZegoVideoStreamType>(
                      child: Text('Small'),
                      value: ZegoVideoStreamType.Small,
                    ),
                    DropdownMenuItem<ZegoVideoStreamType>(
                      child: Text('Big'),
                      value: ZegoVideoStreamType.Big,
                    )
                  ])
            ],
          ),
          Text(
            '硬编码，codecID，分层视频编码设置只可以在推流之前更改',
            style: TextStyle(color: Colors.purple),
          ),
          Text('硬解码设置只可在拉流前更改', style: TextStyle(color: Colors.purple))
        ]));
  }

  Widget viewsWidget(bool isPreView) {
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
              ),
              Text(isPreView ? 'Local Preview View' : 'Remote Play View',
                  style: TextStyle(color: Colors.white))
            ],
            alignment: AlignmentDirectional.topCenter,
          )),
          Padding(padding: EdgeInsets.only(top: 10)),
          TextField(
            enabled: isPreView
                ? _publisherState == ZegoPublisherState.NoPublish
                : _playerState == ZegoPlayerState.NoPlay,
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
                  : (_playerState != ZegoPlayerState.NoPlay
                      ? (_playerState == ZegoPlayerState.Playing
                          ? '✅ StopPlaying'
                          : '❌ StopPlaying')
                      : 'StartPlaying'),
              style: TextStyle(fontSize: 14.0),
            ),
            onPressed: isPreView ? onPublishBtnPress : onPlayBtnPress,
            padding: EdgeInsets.all(10.0),
          )
        ]);
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

    ZegoExpressEngine.onPlayerVideoSizeChanged = (streamID, width, height) {
      ZegoLog().addLog(
          '🚩 📥 onPlayerVideoSizeChanged, streamID: $streamID, width: $width, height: $height');
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

  void enableHardwareEncoder(bool enable) {
    ZegoExpressEngine.instance.enableHardwareEncoder(enable);
  }

  void enableHardwareDecoder(bool enable) {
    ZegoExpressEngine.instance.enableHardwareDecoder(enable);
  }

  void setPlayStreamVideoType(String streamID, ZegoVideoStreamType streamType) {
    ZegoExpressEngine.instance.setPlayStreamVideoType(streamID, streamType);
  }

  void setVideoConfig(ZegoVideoConfig config) {
    ZegoExpressEngine.instance.setVideoConfig(config);
  }
}
