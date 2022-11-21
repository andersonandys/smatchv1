import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew//utils/zego_log_view.dart';
import 'package:smatch/callnew//utils/zego_user_helper.dart';

class DirectPublishingToCDNActivityPage extends StatefulWidget {
  const DirectPublishingToCDNActivityPage({Key? key}) : super(key: key);

  @override
  _DirectPublishingToCDNActivityPageState createState() =>
      _DirectPublishingToCDNActivityPageState();
}

class _DirectPublishingToCDNActivityPageState
    extends State<DirectPublishingToCDNActivityPage> {
  late ZegoRoomState _roomState;
  final String _roomID = "stream_cdn";
  final String _streamID = "stream_cdn";

  late ZegoPublisherState _publisherState;
  late ZegoPlayerState _playerState;

  Widget? _previewViewWidget;
  Widget? _playViewWidget;

  late TextEditingController _publishCdnUrlController;
  late TextEditingController _playCdnUrlController;

  late bool _enablePublishDirectToCDN;

  late ZegoDelegate _zegoDelegate;

  @override
  void initState() {
    super.initState();

    _zegoDelegate = ZegoDelegate();

    _publisherState = ZegoPublisherState.NoPublish;
    _playerState = ZegoPlayerState.NoPlay;
    _roomState = ZegoRoomState.Disconnected;

    _publishCdnUrlController = TextEditingController();

    _playCdnUrlController = TextEditingController();

    _enablePublishDirectToCDN = false;

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

  void onPublishStreamBtnPress() {
    if (_publishCdnUrlController.text.isNotEmpty) {
      if (_publisherState != ZegoPublisherState.Publishing) {
        // if (_enablePublishDirectToCDN) {
        _zegoDelegate.enablePublishDirectToCDN(
            _enablePublishDirectToCDN, _publishCdnUrlController.text);
        _zegoDelegate
            .startPublishing(
          _streamID,
        )
            .then((widget) {
          setState(() {
            _previewViewWidget = widget;
          });
        });
        // } else {
        //   _zegoDelegate.enablePublishDirectToCDN(
        //       _enablePublishDirectToCDN, _publishCdnUrlController.text);
        // }
      } else {
        _zegoDelegate.stopPublishing();
      }
    }
  }

  void onPlayStreamBtnPress() {
    if (_playerState == ZegoPlayerState.NoPlay) {
      if (_playCdnUrlController.text.isNotEmpty) {
        _zegoDelegate
            .startPlaying(_streamID, cdnURL: _playCdnUrlController.text)
            .then((widget) {
          setState(() {
            _playViewWidget = widget;
          });
        });
      }
    } else {
      _zegoDelegate.stopPlaying(_streamID);
    }
  }

  void onEnablePublishDirectToCDNSwitchChanged(bool enable) {
    setState(() {
      _enablePublishDirectToCDN = enable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text("直推CDN"),
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
                publishStreamByCdnWidget(),
                playStreamByCdnWidget(),
              ],
            ),
          )),
        ),
        onWillPop: _onWillPop);
  }

  Future<bool> _onWillPop() async {
    ZegoLog().addLog('pop');
    _zegoDelegate.stopPlaying(_streamID);
    _zegoDelegate.stopPublishing();
    _zegoDelegate.stopPreview();
    _zegoDelegate.dispose();
    await _zegoDelegate.logoutRoom(_roomID);
    await _zegoDelegate.destroyEngine();

    return true;
  }

  Widget roomInfoWidget(context) {
    return Padding(
        padding: EdgeInsets.only(left: 10),
        child: Text(
            'RoomID: $_roomID UserID: ${ZegoUserHelper.instance.userID} \nRoomState: ${_zegoDelegate.roomStateDesc(_roomState)}'));
  }

  Widget publishStreamByCdnWidget() {
    return Card(
        child: Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('直推CDN ', style: TextStyle(fontSize: 18, color: Colors.black)),
          Text('将音视频流直接从本地客户端直接推送到CDN',
              style: TextStyle(fontSize: 12, color: Colors.black38)),
          Padding(padding: EdgeInsets.only(top: 10)),
          Row(
            children: [
              Expanded(
                  child: RichText(
                      text: TextSpan(children: <InlineSpan>[
                TextSpan(
                    text: 'Step1 ',
                    style: TextStyle(fontSize: 18, color: Colors.black)),
                TextSpan(
                    text: 'EnablePublishDirectToCDN',
                    style: TextStyle(fontSize: 16, color: Colors.black38))
              ]))),
              Switch(
                  value: _enablePublishDirectToCDN,
                  onChanged: _publisherState == ZegoPublisherState.NoPublish
                      ? onEnablePublishDirectToCDNSwitchChanged
                      : null)
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          Row(children: [
            Text('推流 CDN URL ',
                style: TextStyle(fontSize: 14, color: Colors.black)),
            Expanded(
                child: TextField(
              controller: _publishCdnUrlController,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10.0),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff0e88eb)))),
            ))
          ]),
          Padding(padding: EdgeInsets.only(top: 10)),
          Row(
            children: [
              Expanded(
                  child: RichText(
                      text: TextSpan(children: <InlineSpan>[
                TextSpan(
                    text: 'Step2 ',
                    style: TextStyle(fontSize: 18, color: Colors.black)),
                TextSpan(
                    text: '开始推流',
                    style: TextStyle(fontSize: 16, color: Colors.black38))
              ]))),
              CupertinoButton.filled(
                  child: Text(
                    _publisherState == ZegoPublisherState.Publishing
                        ? '✅ 停止推流'
                        : '开始推流',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  onPressed: onPublishStreamBtnPress,
                  padding: EdgeInsets.all(10.0)),
            ],
          )
        ],
      ),
    ));
  }

  Widget playStreamByCdnWidget() {
    return Card(
        child: Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('从 URL 拉流 ',
              style: TextStyle(fontSize: 18, color: Colors.black)),
          Padding(padding: EdgeInsets.only(top: 10)),
          Row(children: [
            Text('CDN URL ',
                style: TextStyle(fontSize: 14, color: Colors.black)),
            Expanded(
                child: TextField(
              controller: _playCdnUrlController,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10.0),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff0e88eb)))),
            ))
          ]),
          Padding(padding: EdgeInsets.only(top: 10)),
          SizedBox(
              width: MediaQuery.of(context).size.width,
              child: CupertinoButton.filled(
                  child: Text(
                    _playerState != ZegoPlayerState.NoPlay
                        ? (_playerState == ZegoPlayerState.Playing
                            ? '✅ 停止拉流'
                            : '❌ 停止拉流')
                        : '从 URL 拉流',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  onPressed: onPlayStreamBtnPress,
                  padding: EdgeInsets.all(10.0))),
        ],
      ),
    ));
  }

  // Buttons and titles on the preview widget
  Widget preWidgetTopWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Text('Local Preview View', style: TextStyle(color: Colors.white)),
    );
  }

  // Buttons and titles on the play widget
  Widget playWidgetTopWidget() {
    return Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text('Remote Play View', style: TextStyle(color: Colors.white)));
  }

  Widget streamViewsWidget() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.4,
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
            Expanded(
              child: Container(),
              flex: 1,
            ),
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
                )),
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

  Future<void> destroyEngine() {
    return ZegoExpressEngine.destroyEngine();
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

  Future<void> setRoomMode(ZegoRoomMode mode) {
    return ZegoExpressEngine.setRoomMode(mode);
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

  void stopPreview() {
    ZegoExpressEngine.instance.stopPreview();
  }

  void enablePublishDirectToCDN(bool enable, String url) {
    ZegoExpressEngine.instance
        .enablePublishDirectToCDN(enable, config: ZegoCDNConfig(url, ""));
  }

  Future<int> addPublishCdnUrl(String streamID, String targetURL) async {
    var result =
        await ZegoExpressEngine.instance.addPublishCdnUrl(streamID, targetURL);
    return result.errorCode;
  }

  Future<int> removePublishCdnUrl(String streamID, String targetURL) async {
    var result = await ZegoExpressEngine.instance
        .removePublishCdnUrl(streamID, targetURL);
    return result.errorCode;
  }
}
