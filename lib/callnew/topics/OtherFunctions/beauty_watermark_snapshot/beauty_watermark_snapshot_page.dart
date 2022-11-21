import 'package:file_picker/file_picker.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew//utils/zego_log_view.dart';
import 'package:smatch/callnew//utils/zego_user_helper.dart';
import 'package:smatch/callnew//utils/zego_utils.dart';

class BeautyWatermarkSnapshotPage extends StatefulWidget {
  const BeautyWatermarkSnapshotPage({Key? key}) : super(key: key);

  @override
  _BeautyWatermarkSnapshotPageState createState() =>
      _BeautyWatermarkSnapshotPageState();
}

class _BeautyWatermarkSnapshotPageState
    extends State<BeautyWatermarkSnapshotPage> {
  final _roomID = 'watermark_snapshot';
  final _streamID = 'watermark_snapshot_s';
  late ZegoRoomState _roomState;
  late ZegoPublisherState _publisherState;
  late ZegoPlayerState _playerState;
  late bool _watermarkSwitch;
  late bool _watermarkShowInPre;

  late String _watermarkImage;

  String? _appDocumentsPath;

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
    _playerState = ZegoPlayerState.NoPlay;

    _watermarkSwitch = false;
    _watermarkShowInPre = false;

    _watermarkImage = '';

    _zegoDelegate.setZegoEventCallback(
        onRoomStateUpdate: onRoomStateUpdate,
        onPublisherStateUpdate: onPublisherStateUpdate,
        onPlayerStateUpdate: onPlayerStateUpdate);
    _zegoDelegate.createEngine().then((value) {
      _zegoDelegate.loginRoom(_roomID);
    });

    if (Platform.isAndroid) {
      getExternalStorageDirectories(type: StorageDirectory.pictures)
          .then((dir) => _appDocumentsPath = dir?.first.path);
    } else {
      getApplicationDocumentsDirectory()
          .then((dir) => _appDocumentsPath = dir.path);
    }
  }

  @override
  void dispose() {
    _watermarkImage = '';

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

  void onPlayerStateUpdate(String streamID, ZegoPlayerState state,
      int errorCode, Map<String, dynamic> extendedData) {
    if (streamID == _streamID) {
      setState(() {
        _playerState = state;
      });
    }
  }

  // widget callback

  void onPreSnapshotBtnPress() {
    if (_publisherState == ZegoPublisherState.Publishing) {
      _zegoDelegate.takePublishStreamSnapshot().then((value) {
        if (_appDocumentsPath != null &&
            value.errorCode == 0 &&
            value.image != null) {
          String path = _appDocumentsPath != null
              ? _appDocumentsPath! +
                  '\\' +
                  'tmp_snapshot_${DateTime.now().microsecondsSinceEpoch}.png'
              : '';
          ZegoUtils.showImage(context, value.image, path: path);
        }
      });
    }
  }

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

  void onPlaySnapshotBtnPress() {
    if (_playerState == ZegoPlayerState.Playing) {
      _zegoDelegate.takePlayStreamSnapshot(_streamID).then((value) {
        if (_appDocumentsPath != null &&
            value.errorCode == 0 &&
            value.image != null) {
          String path = _appDocumentsPath != null
              ? _appDocumentsPath! +
                  '\\' +
                  'tmp_snapshot_${DateTime.now().microsecondsSinceEpoch}.png'
              : '';
          ZegoUtils.showImage(context, value.image, path: path);
        }
      });
    }
  }

  void onPlayBtnPress() {
    if (_playerState != ZegoPlayerState.NoPlay) {
      _zegoDelegate.stopPlaying(_streamID);
    } else {
      _zegoDelegate
          .startPlaying(
        _streamID,
      )
          .then((widget) {
        setState(() {
          _playViewWidget = widget;
        });
      });
    }
  }

  get watermarkPath => _watermarkImage.isNotEmpty
      ? (Platform.isWindows
          ? 'file:///$_watermarkImage'
          : 'file://$_watermarkImage')
      : 'flutter-asset://resources/images/ZegoLogo.png';

  Rect get watermarkRect => _watermarkImage.isNotEmpty
      ? Rect.fromLTWH(0, 0, 200, 200)
      : Rect.fromLTWH(0, 0, 240, 45);

  void onWatermarkSwitchChanged(bool b) {
    setState(() {
      _watermarkSwitch = b;
    });
    if (b) {
      _zegoDelegate.setPublishWatermark(
          ZegoWatermark(watermarkPath, watermarkRect), _watermarkShowInPre);
    } else {
      _zegoDelegate.setPublishWatermark(null, _watermarkShowInPre);
    }
  }

  void onSelectWatermarkImageBtnPress() {
    FilePicker.platform
        .pickFiles(
            lockParentWindow: true,
            dialogTitle: '请选择一张照片',
            type: FileType.image)
        .then((FilePickerResult? result) {
      if (result != null) {
        _watermarkImage = result.files.single.path!;
        ZegoLog().addLog('watermark Image path: $_watermarkImage');
        if (_watermarkSwitch) {
          _zegoDelegate.setPublishWatermark(
              ZegoWatermark(watermarkPath, watermarkRect), _watermarkShowInPre);
        }
      }
    });
  }

  void onWatermarkShowInPreSwitchChanged(bool b) {
    setState(() {
      _watermarkShowInPre = b;
    });
    if (_watermarkSwitch) {
      _zegoDelegate.setPublishWatermark(
          ZegoWatermark(watermarkPath, watermarkRect), b);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('水印与截图'),
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
          viewWidget(),
          beautyWidget(context),
          watermarkWidget()
        ],
      ),
    );
  }

  Widget roomInfoWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("RoomID: $_roomID"),
      Text('RoomState: ${_zegoDelegate.roomStateDesc(_roomState)}'),
      Text('PublishStreamID: $_streamID'),
      Text('PlayStreamID: $_streamID'),
    ]);
  }

  Widget viewWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.5,
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                      flex: 15,
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.grey[300],
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
                            color: Colors.grey[300],
                            child: _playViewWidget,
                          ),
                          playWidgetTopWidget()
                        ],
                        alignment: AlignmentDirectional.topCenter,
                      )),
                ],
              ))
        ],
      ),
    );
  }

  Widget beautyWidget(BuildContext context) {
    return Container(
        color: Colors.grey[300],
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.topLeft,
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
                child: Text(
                  '美颜',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.left,
                )),
            Text('flutter 暂不支持。'),
            // TextButton(onPressed: ()=> launch('https://doc-zh.zego.im/article/11257'), child: Text('帮助文档'))
          ],
        ));
  }

  Widget watermarkWidget() {
    return Container(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text('水印')),
                Switch(
                    value: _watermarkSwitch,
                    onChanged: onWatermarkSwitchChanged)
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('水印文件')),
                CupertinoButton.filled(
                    child: Text(
                      '选择文件',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    onPressed: onSelectWatermarkImageBtnPress,
                    padding: EdgeInsets.all(10.0)),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('在预览下是否可见')),
                Switch(
                    value: _watermarkShowInPre,
                    onChanged: onWatermarkShowInPreSwitchChanged)
              ],
            ),
          ],
        ));
  }

  Widget preWidgetTopWidget() {
    return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
              child: Text('Local Preview View',
                  style: TextStyle(color: Colors.white))),
          Expanded(child: Container()),
          Container(
              padding: EdgeInsets.only(left: 10),
              width: MediaQuery.of(context).size.width * 0.4,
              child: CupertinoButton.filled(
                  child: Text(
                    '截图',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  onPressed: onPreSnapshotBtnPress,
                  padding: EdgeInsets.all(10.0))),
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

  // Buttons and titles on the play widget
  Widget playWidgetTopWidget() {
    return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
              child: Text('Remote Play View',
                  style: TextStyle(color: Colors.white))),
          Expanded(child: Container()),
          Container(
            padding: EdgeInsets.only(left: 10),
            width: MediaQuery.of(context).size.width * 0.4,
            child: CupertinoButton.filled(
                child: Text(
                  '截图',
                  style: TextStyle(fontSize: 14.0),
                ),
                onPressed: onPlaySnapshotBtnPress,
                padding: EdgeInsets.all(10.0)),
          ),
          Padding(padding: EdgeInsets.only(top: 5)),
          Container(
            padding: EdgeInsets.only(left: 10),
            width: MediaQuery.of(context).size.width * 0.4,
            child: CupertinoButton.filled(
                child: Text(
                  _playerState != ZegoPlayerState.NoPlay
                      ? (_playerState == ZegoPlayerState.Playing
                          ? '✅ StopPlaying'
                          : '❌ StopPlaying')
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

  Future<ZegoPublisherTakeSnapshotResult> takePublishStreamSnapshot() {
    return ZegoExpressEngine.instance.takePublishStreamSnapshot();
  }

  Future<ZegoPlayerTakeSnapshotResult> takePlayStreamSnapshot(String streamID) {
    return ZegoExpressEngine.instance.takePlayStreamSnapshot(streamID);
  }

  void setPublishWatermark(ZegoWatermark? watermark, bool isPreviewVisible) {
    ZegoExpressEngine.instance.setPublishWatermark(
        watermark: watermark, isPreviewVisible: isPreviewVisible);
  }
}
