import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew//utils/zego_log_view.dart';
import 'package:smatch/callnew//utils/zego_user_helper.dart';

class PublishingMultipleStreamsPage extends StatefulWidget {
  const PublishingMultipleStreamsPage({Key? key}) : super(key: key);
  @override
  _PublishingMultipleStreamsPageState createState() =>
      _PublishingMultipleStreamsPageState();
}

class _PublishingMultipleStreamsPageState
    extends State<PublishingMultipleStreamsPage> {
  late ZegoRoomState _roomState;
  final String _roomID = "publishing_multiple_streams";
  final String _streamID_main = "streams_main";
  final String _streamID_aux = "streams_aux";

  late ZegoPublisherState _publisherState_main;
  late ZegoPublisherState _publisherState_aux;
  late ZegoPlayerState _playerState_main;
  late ZegoPlayerState _playerState_aux;

  Widget? _previewViewWidget_main;
  Widget? _previewViewWidget_aux;
  Widget? _playViewWidget_main;
  Widget? _playViewWidget_aux;

  late TextEditingController _publishStreamIDController_main;
  late TextEditingController _publishStreamIDController_aux;
  late TextEditingController _playStreamIDController_main;
  late TextEditingController _playStreamIDController_aux;

  late ZegoDelegate _zegoDelegate;

  @override
  void initState() {
    super.initState();

    _zegoDelegate = ZegoDelegate();

    _publisherState_main = ZegoPublisherState.NoPublish;
    _publisherState_aux = ZegoPublisherState.NoPublish;
    _playerState_main = ZegoPlayerState.NoPlay;
    _playerState_aux = ZegoPlayerState.NoPlay;
    _roomState = ZegoRoomState.Disconnected;

    _publishStreamIDController_main = TextEditingController();
    _publishStreamIDController_main.text = _streamID_main;

    _publishStreamIDController_aux = TextEditingController();
    _publishStreamIDController_aux.text = _streamID_aux;

    _playStreamIDController_main = TextEditingController();
    _playStreamIDController_main.text = _streamID_main;
    _playStreamIDController_aux = TextEditingController();
    _playStreamIDController_aux.text = _streamID_aux;

    _zegoDelegate.setZegoEventCallback(
      onRoomStateUpdate: onRoomStateUpdate,
      onPublisherStateUpdate: onPublisherStateUpdate,
      onPlayerStateUpdate: onPlayerStateUpdate,
    );
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

  // zego express callback
  void onRoomStateUpdate(String roomID, ZegoRoomState state, int errorCode,
      Map<String, dynamic> extendedData) {
    setState(() => _roomState = state);
  }

  void onPublisherStateUpdate(String streamID, ZegoPublisherState state,
      int errorCode, Map<String, dynamic> extendedData) {
    if (streamID == _publishStreamIDController_main.text.trim()) {
      _publisherState_main = state;
    }
    if (streamID == _publishStreamIDController_aux.text.trim()) {
      _publisherState_aux = state;
    }
    setState(() {});
  }

  void onPlayerStateUpdate(String streamID, ZegoPlayerState state,
      int errorCode, Map<String, dynamic> extendedData) {
    if (streamID == _playStreamIDController_main.text.trim()) {
      _playerState_main = state;
    }
    if (streamID == _playStreamIDController_aux.text.trim()) {
      _playerState_aux = state;
    }
    setState(() {});
  }

  // widget callback

  void onPublishStreamBtnPress(bool isMain) {
    try {
      var publishState = _publisherState_main;
      var streamID = _publishStreamIDController_main.text;
      if (!isMain) {
        publishState = _publisherState_aux;
        streamID = _publishStreamIDController_aux.text;
        if (streamID == _publishStreamIDController_main.text) {
          throw Exception('两路流请输入不同的流ID');
        }
      } else {
        if (streamID == _publishStreamIDController_aux.text) {
          throw Exception('两路流请输入不同的流ID');
        }
      }
      if (publishState == ZegoPublisherState.NoPublish && streamID.isNotEmpty) {
        _zegoDelegate.startPublishing(streamID, isMain).then((widget) {
          if (isMain) {
            _previewViewWidget_main = widget;
          } else {
            _previewViewWidget_aux = widget;
          }
          setState(() {});
        });
      } else {
        _zegoDelegate.stopPublishing(isMain);
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void onPlayStreamBtnPress(bool isMain) {
    try {
      String streamID = _playStreamIDController_main.text;
      ZegoPlayerState playState = _playerState_main;
      if (!isMain) {
        streamID = _playStreamIDController_aux.text;
        playState = _playerState_aux;
        if (streamID == _playStreamIDController_main.text) {
          throw Exception('两路流请输入不同的流ID');
        }
      } else {
        if (streamID == _playStreamIDController_aux.text) {
          throw Exception('两路流请输入不同的流ID');
        }
      }
      if (playState == ZegoPlayerState.NoPlay && streamID.isNotEmpty) {
        _zegoDelegate.startPlaying(streamID, isMain).then((widget) {
          if (isMain) {
            _playViewWidget_main = widget;
          } else {
            _playViewWidget_aux = widget;
          }
          setState(() {});
        });
      } else {
        _zegoDelegate.stopPlaying(streamID);
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("同时推多路流"),
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
            Divider(),
            Container(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: Text(
                  '推流',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                )),
            publishViewsWidget(),
            Divider(),
            Container(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: Text(
                  '拉流',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                )),
            playStreamViewsWidget(),
          ],
        ),
      )),
    );
  }

  Widget roomInfoWidget(context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("RoomID: $_roomID"),
      Text('RoomState: ${_zegoDelegate.roomStateDesc(_roomState)}')
    ]);
  }

// Buttons and titles on the preview widget
  Widget preWidgetTopWidget(bool isMain) {
    var publishState = _publisherState_main;
    if (!isMain) {
      publishState = _publisherState_aux;
    }
    return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Text('预览', style: TextStyle(color: Colors.white))),
          Expanded(
              child: isMain
                  ? Container()
                  : Center(
                      child: Text(kIsWeb ? '' : '第二路流为媒体播放器播放的音频流'),
                    )),
          Padding(
              padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  Text('Stream ID: '),
                  Expanded(
                      child: TextField(
                    key: ValueKey('publishStreamID${isMain ? 'main' : 'aux'}'),
                    enabled: publishState == ZegoPublisherState.NoPublish,
                    controller: isMain
                        ? _publishStreamIDController_main
                        : _publishStreamIDController_aux,
                    style: TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10.0),
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF90CAF9))),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff0e88eb)))),
                  ))
                ],
              )),
          Center(
            child: CupertinoButton.filled(
                key: ValueKey('startPublish${isMain ? 'main' : 'aux'}'),
                child: Text(
                  publishState != ZegoPublisherState.NoPublish
                      ? (publishState == ZegoPublisherState.Publishing
                          ? '✅ StopPublish'
                          : '❌ StopPublish')
                      : 'StartPublish',
                  style: TextStyle(fontSize: 14.0),
                ),
                onPressed: () => onPublishStreamBtnPress(isMain),
                padding: EdgeInsets.all(10.0)),
          )
        ]));
  }

// Buttons and titles on the play widget
  Widget playWidgetTopWidget(bool isMain) {
    var playState = _playerState_main;
    if (!isMain) {
      playState = _playerState_aux;
    }
    return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Text('拉流', style: TextStyle(color: Colors.white))),
          Expanded(child: Container()),
          Padding(
              padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  Text('Stream ID: '),
                  Expanded(
                      child: TextField(
                    enabled: playState == ZegoPlayerState.NoPlay,
                    key: ValueKey('playStreamID${isMain ? 'main' : 'aux'}'),
                    controller: isMain
                        ? _playStreamIDController_main
                        : _playStreamIDController_aux,
                    style: TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10.0),
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF90CAF9))),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff0e88eb)))),
                  ))
                ],
              )),
          Center(
            child: CupertinoButton.filled(
                key: ValueKey('startPlay${isMain ? 'main' : 'aux'}'),
                child: Text(
                  playState != ZegoPlayerState.NoPlay
                      ? (playState == ZegoPlayerState.Playing
                          ? '✅ StopPlaying'
                          : '❌ StopPlaying')
                      : 'StartPlaying',
                  style: TextStyle(fontSize: 14.0),
                ),
                onPressed: () => onPlayStreamBtnPress(isMain),
                padding: EdgeInsets.all(10.0)),
          )
        ]));
  }

  Widget publishViewsWidget() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.45,
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
                flex: 15,
                child: Stack(
                  children: [
                    Container(
                      color: Colors.grey,
                      child: _previewViewWidget_main,
                    ),
                    preWidgetTopWidget(true)
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
                      child: _previewViewWidget_aux,
                    ),
                    preWidgetTopWidget(false)
                  ],
                  alignment: AlignmentDirectional.topCenter,
                ))
          ],
        ));
  }

  Widget playStreamViewsWidget() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.45,
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
                flex: 15,
                child: Stack(
                  children: [
                    Container(
                      color: Colors.grey,
                      child: _playViewWidget_main,
                    ),
                    playWidgetTopWidget(true)
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
                      child: _playViewWidget_aux,
                    ),
                    playWidgetTopWidget(false)
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
typedef PublisherVideoSizeChangedCallback = void Function(
    int, int, ZegoPublishChannel);
typedef PlayerVideoSizeChangedCallback = void Function(String, int, int);

class ZegoDelegate {
  RoomStateUpdateCallback? _onRoomStateUpdate;
  PublisherStateUpdateCallback? _onPublisherStateUpdate;
  PlayerStateUpdateCallback? _onPlayerStateUpdate;
  PublisherVideoSizeChangedCallback? _onPublisherVideoSizeChanged;
  PlayerVideoSizeChangedCallback? _onPlayerVideoSizeChanged;

  late int _preViewID_main;
  late int _preViewID_aux;
  late int _playViewID_main;
  late int _playViewID_aux;
  Widget? preWidget_main;
  Widget? playWidget_main;
  Widget? preWidget_aux;
  Widget? playWidget_aux;
  ZegoMediaPlayer? _mediaPlayer;
  ZegoDelegate()
      : _preViewID_main = -1,
        _preViewID_aux = -1,
        _playViewID_main = -1,
        _playViewID_aux = -1;

  dispose() {
    if (_preViewID_main != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_preViewID_main);
      _preViewID_main = -1;
    }
    if (_preViewID_aux != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_preViewID_aux);
      _preViewID_aux = -1;
    }
    if (_playViewID_main != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_playViewID_main);
      _playViewID_main = -1;
    }
    if (_playViewID_aux != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_playViewID_aux);
      _playViewID_aux = -1;
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
        appSign: kIsWeb ? null : ZegoConfig.instance.appSign);
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
      ZegoUser user = ZegoUser.id(ZegoUserHelper.instance.userID);

      // Login Room
      ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
      if (kIsWeb) {
        var token = await ZegoConfig.instance
            .getToken(ZegoUserHelper.instance.userID, roomID);
        config.token = token;
        config.isUserStatusNotify = true;
      }
      await ZegoExpressEngine.instance.loginRoom(roomID, user, config: config);

      ZegoLog().addLog('🚪 Start login room, roomID: $roomID');

      if (!kIsWeb) {
        // aux stream pushing mediaPlayer audio
        ZegoExpressEngine.instance.enableCustomAudioIO(
            true, ZegoCustomAudioConfig(ZegoAudioSourceType.MediaPlayer),
            channel: ZegoPublishChannel.Aux);
        // Create a media player for pushing the aux stream
        createMediaPlayerAndLoadResource();
      }
    }
  }

  Future<void> logoutRoom(String roomID) async {
    // close aux stream pushing mediaPlayer audio
    if (!kIsWeb) {
      ZegoExpressEngine.instance.enableCustomAudioIO(
          false, ZegoCustomAudioConfig(ZegoAudioSourceType.MediaPlayer),
          channel: ZegoPublishChannel.Aux);
    }
    // Destroy MediaPlayer
    destroyMediaPlayer();
    if (roomID.isNotEmpty) {
      await ZegoExpressEngine.instance.logoutRoom(roomID);

      ZegoLog().addLog('🚪 Start logout room, roomID: $roomID');
    }
  }

  Future<Widget?> startPublishing(String streamID, bool isMain) async {
    var publishFunc = (int viewID, bool isMain) {
      if (!isMain) {
        if (_mediaPlayer != null) {
          _mediaPlayer!.start();
        } else {
          ZegoLog().addLog('not create mediaPlayer or create mediaPlayer fail');
        }
      }
      ZegoExpressEngine.instance.startPreview(
          canvas: ZegoCanvas(viewID, backgroundColor: 0xffffff),
          channel: isMain ? ZegoPublishChannel.Main : ZegoPublishChannel.Aux);
      ZegoExpressEngine.instance.startPublishingStream(streamID,
          channel: isMain ? ZegoPublishChannel.Main : ZegoPublishChannel.Aux);
      ZegoLog().addLog(
          '📥 Start publish stream, streamID: $streamID, channel: ${isMain ? ZegoPublishChannel.Main : ZegoPublishChannel.Aux}');
    };

    var preWidget = preWidget_main;
    var preViewID = _preViewID_main;
    if (!isMain) {
      preViewID = _preViewID_aux;
      preWidget = preWidget_aux;
    }
    if (streamID.isNotEmpty) {
      if (preViewID == -1) {
        preWidget = await ZegoExpressEngine.instance.createCanvasView((viewID) {
          if (isMain) {
            _preViewID_main = viewID;
          } else {
            _preViewID_aux = viewID;
          }
          publishFunc(viewID, isMain);
        });
        if (isMain) {
          preWidget_main = preWidget;
        } else {
          preWidget_aux = preWidget;
        }
      } else {
        publishFunc(preViewID, isMain);
      }
    }
    return preWidget;
  }

  void stopPublishing(bool isMain) {
    if (!isMain) {
      if (_mediaPlayer != null) {
        _mediaPlayer!.stop();
      } else {
        ZegoLog().addLog('not create mediaPlayer or create mediaPlayer fail');
      }
    }
    ZegoExpressEngine.instance.stopPreview(
        channel: isMain ? ZegoPublishChannel.Main : ZegoPublishChannel.Aux);
    ZegoExpressEngine.instance.stopPublishingStream(
        channel: isMain ? ZegoPublishChannel.Main : ZegoPublishChannel.Aux);
  }

  Future<Widget?> startPlaying(String streamID, bool isMain,
      {ZegoStreamResourceMode? mode,
      bool needShow = true,
      String? roomID}) async {
    var playFunc = (int viewID) {
      if (needShow) {
        ZegoExpressEngine.instance.startPlayingStream(streamID,
            canvas: ZegoCanvas(viewID, backgroundColor: 0xffffff),
            config: ZegoPlayerConfig(mode ?? ZegoStreamResourceMode.Default,
                ZegoVideoCodecID.Default,
                roomID: roomID));
      } else {
        ZegoExpressEngine.instance.startPlayingStream(
          streamID,
        );
      }

      ZegoLog().addLog('📥 Start publish stream, streamID: $streamID');
    };

    var playWidget = playWidget_main;
    var playViewID = _playViewID_main;
    if (!isMain) {
      playViewID = _playViewID_aux;
      playWidget = playWidget_aux;
    }
    if (streamID.isNotEmpty) {
      if (playViewID == -1 && needShow) {
        playWidget =
            await ZegoExpressEngine.instance.createCanvasView((viewID) {
          if (isMain) {
            _playViewID_main = viewID;
          } else {
            _playViewID_aux = viewID;
          }
          playFunc(viewID);
        });
        if (isMain) {
          playWidget_main = playWidget;
        } else {
          playWidget_aux = playWidget;
        }
      } else {
        playFunc(playViewID);
      }
    }
    return playWidget;
  }

  void stopPlaying(String streamID) {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
  }

  void createMediaPlayerAndLoadResource() async {
    _mediaPlayer = await ZegoExpressEngine.instance.createMediaPlayer();
    if (_mediaPlayer != null) {
      ZegoLog().addLog('create MediaPlayer success !!!!');
      _mediaPlayer!.enableRepeat(true);
      var result = await _mediaPlayer!
          .loadResource("https://storage.zego.im/demo/201808270915.mp4");
      ZegoLog().addLog(
          'mediaPlayer loadResource ${result.errorCode == 0 ? 'success' : 'fail errorCode: ${result.errorCode}'}');
    } else {
      ZegoLog().addLog('create MediaPlayer fail !!!!');
    }
  }

  void destroyMediaPlayer() {
    if (_mediaPlayer != null) {
      ZegoExpressEngine.instance.destroyMediaPlayer(_mediaPlayer!);
      _mediaPlayer = null;
    }
  }
}
