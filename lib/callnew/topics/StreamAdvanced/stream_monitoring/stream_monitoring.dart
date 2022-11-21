import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew//utils/zego_log_view.dart';
import 'package:smatch/callnew//utils/zego_user_helper.dart';

class StreamMonitoringPage extends StatefulWidget {
  const StreamMonitoringPage({Key? key}) : super(key: key);
  @override
  _StreamMonitoringPageState createState() => _StreamMonitoringPageState();
}

class _StreamMonitoringPageState extends State<StreamMonitoringPage> {
  late ZegoRoomState _roomState;
  final String _roomID = "stream_info";
  final String _streamID = "stream_info";

  late ZegoPublisherState _publisherState;
  late ZegoPlayerState _playerState;

  late int _preViewWidth;
  late int _preViewHeight;
  late int _playViewWidth;
  late int _playViewHeight;

  late double _preVideoSendBitrate;
  late double _playVideoSendBitrate;

  late double _preFPS;
  late double _playFPS;

  late int _preRTT;
  late int _playRTT;

  late int _playDelay;

  late double _prePacketLoss;
  late double _playPacketLoss;

  Widget? _previewViewWidget;
  Widget? _playViewWidget;

  late TextEditingController _publishStreamIDController;
  late TextEditingController _playStreamIDController;

  late ZegoDelegate _zegoDelegate;

  @override
  void initState() {
    super.initState();

    _zegoDelegate = ZegoDelegate();

    _publisherState = ZegoPublisherState.NoPublish;
    _playerState = ZegoPlayerState.NoPlay;
    _roomState = ZegoRoomState.Disconnected;

    _preViewWidth = 360;
    _preViewHeight = 640;
    _playViewWidth = 360;
    _playViewHeight = 640;

    _preVideoSendBitrate = 0;
    _playVideoSendBitrate = 0;

    _preFPS = 0;
    _playFPS = 0;

    _preRTT = 0;
    _playRTT = 0;

    _playDelay = 0;

    _prePacketLoss = 0;
    _playPacketLoss = 0;

    _publishStreamIDController = TextEditingController();
    _publishStreamIDController.text = _streamID;

    _playStreamIDController = TextEditingController();
    _playStreamIDController.text = _streamID;

    _zegoDelegate.setZegoEventCallback(
        onRoomStateUpdate: onRoomStateUpdate,
        onPublisherStateUpdate: onPublisherStateUpdate,
        onPlayerStateUpdate: onPlayerStateUpdate,
        onPlayerQualityUpdate: onPlayerQualityUpdate,
        onPublisherQualityUpdate: onPublisherQualityUpdate,
        onPublisherVideoSizeChanged: onPublisherVideoSizeChanged,
        onPlayerVideoSizeChanged: onPlayerVideoSizeChanged);
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

    ZegoLog().addLog('🏳️ Destroy ZegoExpressEngine');
    super.dispose();
  }

  void onRoomStateUpdate(String roomID, ZegoRoomState state, int errorCode,
      Map<String, dynamic> extendedData) {
    setState(() => _roomState = state);
  }

  void onPublisherStateUpdate(String streamID, ZegoPublisherState state,
      int errorCode, Map<String, dynamic> extendedData) {
    setState(() => _publisherState = state);
  }

  void onPlayerStateUpdate(String streamID, ZegoPlayerState state,
      int errorCode, Map<String, dynamic> extendedData) {
    setState(() => _playerState = state);
  }

  void onPublisherQualityUpdate(
      String streamID, ZegoPublishStreamQuality quality) {
    setState(() {
      _preFPS = quality.videoSendFPS;
      _prePacketLoss = quality.packetLostRate;
      _preRTT = quality.rtt;
      _preVideoSendBitrate = quality.videoKBPS;
    });
  }

  void onPlayerQualityUpdate(String streamID, ZegoPlayStreamQuality quality) {
    setState(() {
      _playFPS = quality.videoRecvFPS;
      _playPacketLoss = quality.packetLostRate;
      _playRTT = quality.rtt;
      _playVideoSendBitrate = quality.videoKBPS;
      _playDelay = quality.delay;
    });
  }

  void onPublisherVideoSizeChanged(
      int width, int height, ZegoPublishChannel channel) {
    setState(() {
      _preViewWidth = width;
      _preViewHeight = height;
    });
  }

  void onPlayerVideoSizeChanged(String streamID, int width, int height) {
    setState(() {
      _playViewWidth = width;
      _playViewHeight = height;
    });
  }

  void onPublishStreamBtnPress() {
    if (_publisherState != ZegoPublisherState.Publishing &&
        _publishStreamIDController.text.isNotEmpty) {
      _zegoDelegate
          .startPublishing(
        _publishStreamIDController.text,
      )
          .then((widget) {
        setState(() {
          _previewViewWidget = widget;
        });
      });
    } else {
      _zegoDelegate.stopPublishing();
    }
  }

  void onPlayStreamBtnPress() {
    if (_playerState == ZegoPlayerState.NoPlay &&
        _playStreamIDController.text.isNotEmpty) {
      _zegoDelegate
          .startPlaying(
        _playStreamIDController.text,
      )
          .then((widget) {
        setState(() {
          _playViewWidget = widget;
        });
      });
    } else {
      _zegoDelegate.stopPlaying(_playStreamIDController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stream Monitorning"),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: ZegoLogView(),
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            roomInfoWidget(context),
            streamViewsWidget(),
            streamIDWidget(context),
          ],
        ),
      )),
    );
  }

  Widget roomInfoWidget(context) {
    return Padding(
        padding: EdgeInsets.only(left: 10),
        child: Text('RoomState: ${_zegoDelegate.roomStateDesc(_roomState)}'));
  }

  Widget streamIDWidget(context) {
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          children: [
            Expanded(
                flex: 15,
                child: Row(children: [
                  Text(
                    'Publish StreamID:',
                    style: TextStyle(fontSize: 11),
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: TextField(
                        controller: _publishStreamIDController,
                        style: TextStyle(fontSize: 11),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10.0),
                            isDense: true,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff0e88eb)))),
                      ))
                ])),
            Expanded(flex: 1, child: Container()),
            Expanded(
                flex: 15,
                child: Row(children: [
                  Text('play StreamID:', style: TextStyle(fontSize: 11)),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: TextField(
                        controller: _playStreamIDController,
                        style: TextStyle(fontSize: 11),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10.0),
                            isDense: true,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff0e88eb)))),
                      ))
                ]))
          ],
        ));
  }

  // Buttons and titles on the preview widget
  Widget preWidgetTopWidget() {
    return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
              child: Text('Local Preview View',
                  style: TextStyle(color: Colors.white))),
          Text('Resolution: $_preViewWidth x $_preViewHeight',
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Text(
              'Video Send Bitrate: ${_preVideoSendBitrate.toStringAsFixed(2)}kbps',
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Text('Video Send FPS: ${_preFPS.toStringAsFixed(2)}f/s',
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Text('RTT: ${_preRTT}ms',
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Text('Packet Loss: ${_prePacketLoss.toStringAsFixed(2)}%',
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Expanded(child: Container()),
          Center(
            child: CupertinoButton.filled(
                child: Text(
                  _publisherState == ZegoPublisherState.Publishing
                      ? '✅ StopPublishing'
                      : 'StartPublishing',
                  style: TextStyle(fontSize: 14.0),
                ),
                onPressed: onPublishStreamBtnPress,
                padding: EdgeInsets.all(10.0)),
          )
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
          Text('Resolution: $_playViewWidth x $_playViewHeight',
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Text(
              'Video Send Bitrate: ${_playVideoSendBitrate.toStringAsFixed(2)}kbps',
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Text('Video Send FPS: ${_playFPS.toStringAsFixed(2)}f/s',
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Text('RTT: ${_playRTT}ms',
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Text('Delay: ${_playDelay}ms',
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Text('Packet Loss: ${_playPacketLoss.toStringAsFixed(2)}%',
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Expanded(child: Container()),
          Center(
            child: CupertinoButton.filled(
                child: Text(
                  _playerState != ZegoPlayerState.NoPlay
                      ? (_playerState == ZegoPlayerState.Playing
                          ? '✅ StopPlaying'
                          : '❌ StopPlaying')
                      : 'StartPlaying',
                  style: TextStyle(fontSize: 14.0),
                ),
                onPressed: onPlayStreamBtnPress,
                padding: EdgeInsets.all(10.0)),
          )
        ]));
  }

  Widget streamViewsWidget() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
                flex: 15,
                child: Stack(
                  children: [
                    Container(
                      color: Colors.grey,
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
                      color: Colors.grey,
                      child: _playViewWidget,
                    ),
                    playWidgetTopWidget()
                  ],
                  alignment: AlignmentDirectional.topCenter,
                ))
          ],
        ));
  }
}

typedef RoomStateUpdateCallback = void Function(
    String, ZegoRoomState, int, Map<String, dynamic>);
typedef PublisherStateUpdateCallback = void Function(
    String, ZegoPublisherState, int, Map<String, dynamic>);
typedef PlayerStateUpdateCallback = void Function(
    String, ZegoPlayerState, int, Map<String, dynamic>);
typedef PublisherQualityUpdateCallback = void Function(
    String, ZegoPublishStreamQuality);
typedef PlayerQualityUpdateCallback = void Function(
    String, ZegoPlayStreamQuality);
typedef PublisherVideoSizeChangedCallback = void Function(
    int, int, ZegoPublishChannel);
typedef PlayerVideoSizeChangedCallback = void Function(String, int, int);

class ZegoDelegate {
  RoomStateUpdateCallback? _onRoomStateUpdate;
  PublisherStateUpdateCallback? _onPublisherStateUpdate;
  PlayerStateUpdateCallback? _onPlayerStateUpdate;
  PublisherQualityUpdateCallback? _onPublisherQualityUpdate;
  PlayerQualityUpdateCallback? _onPlayerQualityUpdate;
  PublisherVideoSizeChangedCallback? _onPublisherVideoSizeChanged;
  PlayerVideoSizeChangedCallback? _onPlayerVideoSizeChanged;

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

    ZegoExpressEngine.onPublisherQualityUpdate =
        (String streamID, ZegoPublishStreamQuality quality) {
      ZegoLog().addLog('🚩 📥 onPublisherQualityUpdate: streamID: $streamID');
      _onPublisherQualityUpdate?.call(streamID, quality);
    };

    ZegoExpressEngine.onPlayerQualityUpdate =
        (String streamID, ZegoPlayStreamQuality quality) {
      ZegoLog().addLog('🚩 📥 onPlayerQualityUpdate: streamID: $streamID');
      _onPlayerQualityUpdate?.call(streamID, quality);
    };

    ZegoExpressEngine.onPublisherVideoSizeChanged = (width, height, channel) {
      ZegoLog().addLog(
          '🚩 📥 onPublisherVideoSizeChanged: width: $width height: $height channel: ${channel.name}');
      _onPublisherVideoSizeChanged?.call(width, height, channel);
    };

    ZegoExpressEngine.onPlayerVideoSizeChanged = (streamID, width, height) {
      ZegoLog().addLog(
          '🚩 📥 onPublisherVideoSizeChanged: width: $width height: $height streamID: $streamID');
      _onPlayerVideoSizeChanged?.call(streamID, width, height);
    };
  }

  void setZegoEventCallback({
    RoomStateUpdateCallback? onRoomStateUpdate,
    PublisherStateUpdateCallback? onPublisherStateUpdate,
    PlayerStateUpdateCallback? onPlayerStateUpdate,
    PublisherQualityUpdateCallback? onPublisherQualityUpdate,
    PlayerQualityUpdateCallback? onPlayerQualityUpdate,
    PublisherVideoSizeChangedCallback? onPublisherVideoSizeChanged,
    PlayerVideoSizeChangedCallback? onPlayerVideoSizeChanged,
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
    if (onPublisherQualityUpdate != null) {
      _onPublisherQualityUpdate = onPublisherQualityUpdate;
    }
    if (onPlayerQualityUpdate != null) {
      _onPlayerQualityUpdate = onPlayerQualityUpdate;
    }
    if (onPublisherVideoSizeChanged != null) {
      _onPublisherVideoSizeChanged = onPublisherVideoSizeChanged;
    }
    if (onPlayerVideoSizeChanged != null) {
      _onPlayerVideoSizeChanged = onPlayerVideoSizeChanged;
    }
  }

  void clearZegoEventCallback() {
    _onRoomStateUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = null;

    _onPublisherStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;

    _onPlayerStateUpdate = null;
    ZegoExpressEngine.onPlayerStateUpdate = null;

    _onPublisherQualityUpdate = null;
    ZegoExpressEngine.onPublisherQualityUpdate = null;

    _onPlayerQualityUpdate = null;
    ZegoExpressEngine.onPlayerQualityUpdate = null;

    _onPublisherVideoSizeChanged = null;
    ZegoExpressEngine.onPublisherVideoSizeChanged = null;

    _onPlayerVideoSizeChanged = null;
    ZegoExpressEngine.onPlayerVideoSizeChanged = null;
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
}
