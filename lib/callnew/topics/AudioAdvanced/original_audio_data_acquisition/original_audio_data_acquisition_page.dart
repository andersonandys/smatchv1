import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew/utils/zego_config.dart';
import 'package:smatch/callnew/utils/zego_log_view.dart';
import 'package:smatch/callnew/utils/zego_user_helper.dart';

class OriginalAudioDataAcquisitionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      _OriginalAudioDataAcquisitionPageState();
}

class _OriginalAudioDataAcquisitionPageState
    extends State<OriginalAudioDataAcquisitionPage> {
  final String _roomID = 'original_audio_data_acquisition';
  late ZegoRoomState _roomState;
  Widget? _previewViewWidget;
  late ZegoPublisherState _publisherState;
  late TextEditingController _publishingStreamIDController;

  Widget? _playViewWidget;
  late ZegoPlayerState _playerState;
  late TextEditingController _playingStreamIDController;

  late bool _isStartCaptureAudioData;

  late ZegoDelegate _zegoDelegate;

  @override
  void initState() {
    super.initState();

    _zegoDelegate = ZegoDelegate();

    _roomState = ZegoRoomState.Disconnected;
    _publisherState = ZegoPublisherState.NoPublish;
    _publishingStreamIDController = new TextEditingController();
    _publishingStreamIDController.text = "original_audio_data_acquisition";

    _playerState = ZegoPlayerState.NoPlay;
    _playingStreamIDController = new TextEditingController();
    _playingStreamIDController.text = "original_audio_data_acquisition";

    _isStartCaptureAudioData = false;

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
        _publishingStreamIDController.text,
      )
          .then((widget) {
        setState(() {
          _playViewWidget = widget;
        });
      });
    }
  }

  void onStartCaptureAudioDataSwitchChanged(bool isChecked) {
    _isStartCaptureAudioData = isChecked;
    if (_isStartCaptureAudioData) {
      _zegoDelegate.startAudioDataObserver();
    } else {
      _zegoDelegate.stopAudioDataObserver();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('原始音频数据采集')),
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
          audioDataCaptureWidget()
        ],
      ),
    );
  }

  Widget roomInfoWidget() {
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(children: [
          Text("RoomID: $_roomID"),
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

  Widget audioDataCaptureWidget() {
    return Row(
      children: [
        Expanded(child: Text('开始原始音频数据回调')),
        Switch(
            value: _isStartCaptureAudioData,
            onChanged: onStartCaptureAudioDataSwitchChanged)
      ],
    );
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

  bool _isAudioDataObserverStart = false;
  int _capturedTime = 0;
  int _playbackTime = 0;
  int _mixedTime = 0;

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

    ZegoExpressEngine.onCapturedAudioData = (data, dataLength, param) {
      if (_isAudioDataObserverStart) {
        if (_capturedTime > 1000 || _capturedTime == 0) {
          _capturedTime = 0;
          ZegoLog().addLog(
              '🚩 📥 onCapturedAudioData, dataLength: $dataLength, param.sampleRate: ${param.sampleRate}, param.channel: ${param.channel}');
        }
        _capturedTime += 1;
      }
    };

    ZegoExpressEngine.onPlaybackAudioData = (data, dataLength, param) {
      if (_isAudioDataObserverStart) {
        if (_playbackTime > 1000 || _playbackTime == 0) {
          _playbackTime = 0;
          ZegoLog().addLog(
              '🚩 📥 onPlaybackAudioData, dataLength: $dataLength, param.sampleRate: ${param.sampleRate}, param.channel: ${param.channel}');
        }
        _playbackTime += 1;
      }
    };

    ZegoExpressEngine.onMixedAudioData = (data, dataLength, param) {
      if (_isAudioDataObserverStart) {
        if (_mixedTime > 1000 || _mixedTime == 0) {
          _mixedTime = 0;
          ZegoLog().addLog(
              '🚩 📥 onMixedAudioData, dataLength: $dataLength, param.sampleRate: ${param.sampleRate}, param.channel: ${param.channel}');
        }
        _mixedTime += 1;
      }
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

  void startAudioDataObserver() {
    // Add bitmask and turn on the switch of collecting audio data
    // The bitmask values corresponding to capture, playback and mixing are: CAPTURED=1, PLAYBACK=2, MIXED=4.
    // The final value of bitmask is 7, which means that capture callback,
    // playback callback, and mixing callback will be triggered at the same time.
    // 采集，拉流，混合对应的位掩码值分别是：CAPTURED=1，PLAYBACK=2, MIXED=4，bitmask最终得到的值为7，表示会同时触发采集、拉流、混合的原始数据回调。
    int observerBitMask = 0;
    observerBitMask |= ZegoAudioDataCallbackBitMask.Captured;
    observerBitMask |= ZegoAudioDataCallbackBitMask.Mixed;
    observerBitMask |= ZegoAudioDataCallbackBitMask.Playback;
    ZegoExpressEngine.instance.startAudioDataObserver(
        observerBitMask,
        ZegoAudioFrameParam(
            ZegoAudioSampleRate.SampleRate8K, ZegoAudioChannel.Stereo));
    _isAudioDataObserverStart = true;
  }

  void stopAudioDataObserver() {
    ZegoExpressEngine.instance.stopAudioDataObserver();
    _isAudioDataObserverStart = false;
  }
}
