import 'package:universal_io/io.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew//utils/zego_log_view.dart';
import 'package:smatch/callnew//utils/zego_user_helper.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({Key? key}) : super(key: key);

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  final _roomID = 'recording';
  final _streamID = 'recording_s';

  late ZegoRoomState _roomState;
  late ZegoPublisherState _publisherState;
  late ZegoMediaPlayerState _playerState;

  late String _startRecodingText;
  late String _stopRecodingText;

  String? recordPath;

  Widget? _previewViewWidget;
  Widget? _playViewWidget;

  late ZegoDelegate _zegoDelegate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _zegoDelegate = ZegoDelegate();

    _roomState = ZegoRoomState.Disconnected;
    _publisherState = ZegoPublisherState.NoPublish;
    _playerState = ZegoMediaPlayerState.NoPlay;

    _startRecodingText = '开始录制';
    _stopRecodingText = '停止录制';

    _zegoDelegate.setZegoEventCallback(
        onRoomStateUpdate: onRoomStateUpdate,
        onPublisherStateUpdate: onPublisherStateUpdate,
        onCapturedDataRecordStateUpdate: onCapturedDataRecordStateUpdate,
        onMediaPlayerStateUpdate: onMediaPlayerStateUpdate);
    _zegoDelegate.createEngine().then((value) {
      _zegoDelegate.loginRoom(_roomID);
    });

    if (Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isWindows ||
        Platform.isMacOS) {
      getApplicationSupportDirectory().then((value) {
        recordPath = value.absolute.path + '/record.mp4';
        ZegoLog().addLog('recordPath : $recordPath');
      });
    } else {}
  }

  @override
  void dispose() {
    _zegoDelegate.dispose();
    _zegoDelegate.clearZegoEventCallback();
    if (_roomState == ZegoRoomState.Connected) {
      _zegoDelegate
          .logoutRoom(_roomID)
          .then((value) => _zegoDelegate.destroyEngine());
    } else {
      _zegoDelegate.destroyEngine();
    }
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
    if (streamID == _streamID) {
      setState(() {
        _publisherState = state;
      });
    }
  }

  void onCapturedDataRecordStateUpdate(ZegoDataRecordState state, int errorCode,
      ZegoDataRecordConfig config, ZegoPublishChannel channel) {
    if (state == ZegoDataRecordState.NoRecord) {
      _startRecodingText = '开始录制';
      _stopRecodingText = '停止录制';
    } else if (state == ZegoDataRecordState.Recording) {
      _startRecodingText = '${errorCode == 0 ? '✅' : '❌'} 开始录制';
    } else {
      _stopRecodingText = '${errorCode == 0 ? '✅' : '❌'} 停止录制';
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              titlePadding: EdgeInsets.all(0),
              title: Center(child: Text('录制成功')),
              children: [SelectableText('日志路径：$recordPath')],
            );
          });
    }
    setState(() {});
  }

  void onMediaPlayerStateUpdate(state, errorCode) {
    setState(() {
      _playerState = state;
    });
  }

  // widget callback

  void onPublishBtnPress() {
    if (_publisherState == ZegoPublisherState.Publishing) {
      _zegoDelegate.stopPublishing();
    } else {
      _zegoDelegate
          .startPublishing(
        _streamID,
      )
          .then((widget) {
        setState(() {
          _previewViewWidget = widget;
        });
      });
    }
  }

  void onPlayBtnPress() {
    if (recordPath != null) {
      if (_playerState == ZegoMediaPlayerState.NoPlay) {
        _zegoDelegate.startPlay(recordPath!).then((widget) {
          setState(() {
            _playViewWidget = widget;
          });
        });
      } else {
        _zegoDelegate.stopPlay();
      }
    }
  }

  void onStartRecordingBtnPress() {
    if (recordPath != null) {
      _zegoDelegate.startRecordingCapturedData(
          ZegoDataRecordConfig(recordPath!, ZegoDataRecordType.AudioAndVideo));
    }
  }

  void onStopRecordingBtnPress() {
    _zegoDelegate.stopRecordingCapturedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('录制'),
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
          step1Widget(context),
          Padding(
            padding: EdgeInsets.all(5),
          ),
          step2Widget(),
          Padding(
            padding: EdgeInsets.all(5),
          ),
          step3Widget(),
          Padding(
            padding: EdgeInsets.all(5),
          ),
          step4Widget(context)
        ],
      ),
    );
  }

  Widget roomInfoWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("RoomID: $_roomID"),
      Text('RoomState: ${_zegoDelegate.roomStateDesc(_roomState)}')
    ]);
  }

  Widget step1Widget(BuildContext context) {
    return Column(
      children: [
        Text(
          'Step1',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        Container(
            height: MediaQuery.of(context).size.height * 0.35,
            child: Stack(
              children: [
                Container(
                  color: Colors.grey[300],
                  child: _previewViewWidget,
                ),
                preWidgetTopWidget()
              ],
              alignment: AlignmentDirectional.topCenter,
            ))
      ],
    );
  }

  Widget step2Widget() {
    return Row(
      children: [
        Text(
          'Step2',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        CupertinoButton.filled(
            child: Text(
              _startRecodingText,
              style: TextStyle(fontSize: 14.0),
            ),
            onPressed: onStartRecordingBtnPress,
            padding: EdgeInsets.all(10.0))
      ],
    );
  }

  Widget step3Widget() {
    return Row(
      children: [
        Text(
          'Step3',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        CupertinoButton.filled(
            child: Text(
              _stopRecodingText,
              style: TextStyle(fontSize: 14.0),
            ),
            onPressed: onStopRecordingBtnPress,
            padding: EdgeInsets.all(10.0))
      ],
    );
  }

  Widget step4Widget(BuildContext context) {
    return Column(
      children: [
        Text(
          'Step4',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        Container(
            height: MediaQuery.of(context).size.height * 0.35,
            child: Stack(
              children: [
                Container(
                  color: Colors.grey[300],
                  child: _playViewWidget,
                ),
                playWidgetTopWidget()
              ],
              alignment: AlignmentDirectional.topCenter,
            ))
      ],
    );
  }

  Widget preWidgetTopWidget() {
    return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Center(child: Text('推流预览', style: TextStyle(color: Colors.white))),
          Expanded(child: Container()),
          Padding(padding: EdgeInsets.only(top: 5)),
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

  Widget playWidgetTopWidget() {
    return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Center(child: Text('录制内容预览', style: TextStyle(color: Colors.white))),
          Expanded(child: Container()),
          Padding(padding: EdgeInsets.only(top: 5)),
          Container(
            padding: EdgeInsets.only(left: 10),
            width: MediaQuery.of(context).size.width * 0.4,
            child: CupertinoButton.filled(
                child: Text(
                  _playerState != ZegoMediaPlayerState.NoPlay
                      ? '✅ StopPlaying'
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
typedef CapturedDataRecordStateUpdateCallback = void Function(
    ZegoDataRecordState state,
    int errorCode,
    ZegoDataRecordConfig config,
    ZegoPublishChannel channel);
typedef MediaPlayerStateUpdateCallback = Function(ZegoMediaPlayerState, int);

class ZegoDelegate {
  RoomStateUpdateCallback? _onRoomStateUpdate;
  PublisherStateUpdateCallback? _onPublisherStateUpdate;
  CapturedDataRecordStateUpdateCallback? _onCapturedDataRecordStateUpdate;
  MediaPlayerStateUpdateCallback? _onMediaPlayerStateUpdate;

  late int _preViewID;
  late int _playViewID;
  ZegoMediaPlayer? _player;

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
    if (_player != null) {
      ZegoExpressEngine.instance.destroyMediaPlayer(_player!);
      _player = null;
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

    ZegoExpressEngine.onCapturedDataRecordStateUpdate =
        (ZegoDataRecordState state, int errorCode, ZegoDataRecordConfig config,
            ZegoPublishChannel channel) {
      ZegoLog().addLog(
          '🚩 📤 captured data record state: $state, errorCode: $errorCode, filePath: ${config.filePath}, recordType: ${config.recordType}}');
      _onCapturedDataRecordStateUpdate?.call(state, errorCode, config, channel);
    };

    ZegoExpressEngine.onCapturedDataRecordProgressUpdate =
        (ZegoDataRecordProgress progress, ZegoDataRecordConfig config,
            ZegoPublishChannel channel) {
      ZegoLog().addLog(
          '🚩 📤 captured data record progress duration: ${progress.duration}, currentFileSize: ${progress.currentFileSize}, filePath: ${config.filePath}, recordType: ${config.recordType}}');
    };

    ZegoExpressEngine.onMediaPlayerStateUpdate =
        (mediaPlayer, state, errorCode) {
      ZegoLog()
          .addLog('🚩 📤 media player state: $state, errorCode: $errorCode');
      if (mediaPlayer == _player) {
        _onMediaPlayerStateUpdate?.call(state, errorCode);
      }
    };
  }

  void setZegoEventCallback(
      {RoomStateUpdateCallback? onRoomStateUpdate,
      PublisherStateUpdateCallback? onPublisherStateUpdate,
      CapturedDataRecordStateUpdateCallback? onCapturedDataRecordStateUpdate,
      MediaPlayerStateUpdateCallback? onMediaPlayerStateUpdate}) {
    if (onRoomStateUpdate != null) {
      _onRoomStateUpdate = onRoomStateUpdate;
    }
    if (onPublisherStateUpdate != null) {
      _onPublisherStateUpdate = onPublisherStateUpdate;
    }
    if (onCapturedDataRecordStateUpdate != null) {
      _onCapturedDataRecordStateUpdate = onCapturedDataRecordStateUpdate;
    }
    if (onMediaPlayerStateUpdate != null) {
      _onMediaPlayerStateUpdate = onMediaPlayerStateUpdate;
    }
  }

  void clearZegoEventCallback() {
    _onRoomStateUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = null;

    _onPublisherStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;

    _onCapturedDataRecordStateUpdate = null;
    ZegoExpressEngine.onCapturedDataRecordStateUpdate = null;

    _onMediaPlayerStateUpdate = null;
    ZegoExpressEngine.onMediaPlayerStateUpdate = null;
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
          .startPreview(canvas: ZegoCanvas(viewID, backgroundColor: 0xf4f4f4));
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

  void startRecordingCapturedData(ZegoDataRecordConfig config) {
    ZegoExpressEngine.instance.startRecordingCapturedData(config);
    ZegoLog().addLog('🚀 startRecordingCapturedData');
  }

  void stopRecordingCapturedData() {
    ZegoExpressEngine.instance.stopRecordingCapturedData();
    ZegoLog().addLog('🚀 stopRecordingCapturedData');
  }

  Future<Widget?> startPlay(String path) async {
    if (_player == null) {
      _player = await ZegoExpressEngine.instance.createMediaPlayer();
      playWidget = await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _playViewID = viewID;
        if (_player != null) {
          _player!.setPlayerCanvas(
              ZegoCanvas(_playViewID, backgroundColor: 0xf4f4f4));
          ZegoLog().addLog('📥 MediaPlayer set player canvas');
        }
      });
    }

    var result = await _player?.loadResource(path);
    if (result != null && result.errorCode == 0) {
      ZegoLog().addLog('📥 MediaPlayer load resource: $path success');
      _player!.start();
      ZegoLog().addLog('📥 MediaPlayer start');
    } else {
      ZegoLog().addLog(
          '📥 MediaPlayer load resource: $path fail, errorCode: ${result?.errorCode}');
    }

    return playWidget;
  }

  void stopPlay() {
    if (_player != null) {
      _player!.stop();
      ZegoLog().addLog('📥 MediaPlayer stop');
    }
  }
}
