import 'dart:async';
import 'package:universal_io/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew/utils/zego_log_view.dart';
import 'package:smatch/callnew/utils/zego_user_helper.dart';

enum _VideoRotationPageType { Publish, Play }

class ChooseVideoRotationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose Video Rotation Type')),
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose what you want.',
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: CupertinoButton.filled(
                  child: Text('Publish Stream'),
                  onPressed: () {
                    onPressed(context, _VideoRotationPageType.Publish);
                  })),
          Padding(padding: EdgeInsets.only(top: 20)),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: CupertinoButton.filled(
                  child: Text('Play Stream'),
                  onPressed: () {
                    onPressed(context, _VideoRotationPageType.Play);
                  }))
        ],
      )),
    );
  }

  void onPressed(BuildContext context, _VideoRotationPageType type) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return VideoRotationPage(type);
    }));
  }
}

class VideoRotationPage extends StatefulWidget {
  final _VideoRotationPageType type;
  VideoRotationPage(this.type);

  @override
  State<StatefulWidget> createState() => _VideoRotationPageState();
}

class _VideoRotationPageState extends State<VideoRotationPage>
    with WidgetsBindingObserver {
  String _title = '';
  late TextEditingController _streamIDController;
  late TextEditingController _roomIDController;
  late String _rotationMode;
  late ZegoPublisherState _publisherState;
  late ZegoPlayerState _playerState;
  late ZegoRoomState _roomState;
  Widget? _view;
  late int _viewID;

  late ZegoVideoConfig _videoConfig;

  MethodChannel _channel = const MethodChannel('flutter_auto_orientation');

  Future<void> changeScreenOrientation(DeviceOrientation orientation) {
    String o;
    switch (orientation) {
      case DeviceOrientation.portraitUp:
        o = 'portraitUp';
        break;
      case DeviceOrientation.portraitDown:
        o = 'portraitDown';
        break;
      case DeviceOrientation.landscapeLeft:
        o = 'landscapeLeft';
        break;
      case DeviceOrientation.landscapeRight:
        o = 'landscapeRight';
        break;
    }
    return _channel.invokeMethod('change_screen_orientation', [o]);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance?.addObserver(this);
    // WidgetsFlutterBinding.ensureInitialized();

    _viewID = -1;
    _roomState = ZegoRoomState.Disconnected;
    _streamIDController = TextEditingController();
    _streamIDController.text = "123654";
    _roomIDController = TextEditingController();
    _roomIDController.text = "123654";
    _publisherState = ZegoPublisherState.NoPublish;
    _playerState = ZegoPlayerState.NoPlay;

    _rotationMode = "Fixed Portrait";

    _videoConfig = ZegoVideoConfig.preset(ZegoVideoConfigPreset.Preset360P);

    getEngineConfig();
    setZegoEventCallback();
    createEngine();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // In iOS, there is no done key on the numeric keyboard, and the onEditingComplete of TextField cannot be triggered
      // Set video configuration parameters by listening for keyboard hiding
      if (_rotationMode == "Auto") {
        ZegoLog().addLog(
            'didChangeMetrics orientation: ${MediaQuery.of(context).orientation}');
        if (MediaQuery.of(context).orientation == Orientation.portrait) {
          _videoConfig.encodeWidth = 360;
          _videoConfig.encodeHeight = 640;

          setRotateMode(DeviceOrientation.portraitUp);
        } else if (MediaQuery.of(context).orientation ==
            Orientation.landscape) {
          _videoConfig.encodeWidth = 640;
          _videoConfig.encodeHeight = 360;

          setRotateMode(DeviceOrientation.landscapeLeft);
        }

        ZegoExpressEngine.instance.setVideoConfig(_videoConfig);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    // Can destroy the engine when you don't need audio and video calls
    //
    // Destroy engine will automatically logout room and stop publishing/playing stream.

    ZegoExpressEngine.instance.destroyCanvasView(_viewID);

    clearZegoEventCallback();

    logoutRoom().then((value) => ZegoExpressEngine.destroyEngine());

    ZegoLog().addLog('🏳️ Destroy ZegoExpressEngine');

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    super.dispose();
  }

  // widget callback

  void onStartButtonPressed(BuildContext context) {
    loginRoom().then((value) {
      switch (_rotationMode) {
        case "Fixed Portrait":
          setRotateMode(DeviceOrientation.portraitUp);
          break;
        case "Fixed Landscape":
          setRotateMode(DeviceOrientation.landscapeLeft);
          break;
        case "Auto":
          break;
        default:
      }

      ZegoExpressEngine.instance.setVideoConfig(_videoConfig);

      if (widget.type == _VideoRotationPageType.Publish) {
        if (_publisherState == ZegoPublisherState.Publishing) {
          stopPublishing();
        } else {
          // setRotateMode(_rotationMode);
          startPublishing(context);
        }
      } else {
        if (_playerState != ZegoPlayerState.NoPlay) {
          stopPlaying();
        } else {
          // setRotateMode(_rotationMode);
          startPlaying(context);
        }
      }
    });
  }

  // widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_title Video Rotation'),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
          child: Stack(children: [
        Center(
            child: Container(
          color: Colors.white,
          child: _view,
          padding: EdgeInsets.zero,
          width: MediaQuery.of(context).orientation == Orientation.landscape
              ? MediaQuery.of(context).size.height * 8 / 6
              : MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).orientation == Orientation.landscape
              ? MediaQuery.of(context).size.height
              : MediaQuery.of(context).size.height,
        )),
        paramWidget()
      ])),
    );
  }

  Widget paramWidget() {
    return Padding(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Column(
          children: [
            roomInfoWidget(),
            Expanded(child: Container()),
            roomIDAndUserIDWidget(),
            Padding(padding: EdgeInsets.only(bottom: 10)),
            streamIDWidget(),
            Padding(padding: EdgeInsets.only(bottom: 10)),
            rotateModeWidget(),
            startButton(),
            Padding(padding: EdgeInsets.only(bottom: 10)),
          ],
        ));
  }

  Widget roomInfoWidget() {
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(children: [
          Text("RoomID state"),
          Spacer(),
          Text(roomStateDesc()),
        ]));
  }

  Widget roomIDAndUserIDWidget() {
    return Row(children: [
      Padding(padding: EdgeInsets.only(right: 10), child: Text('RoomID')),
      SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: TextField(
            controller: _roomIDController,
            onEditingComplete: () {},
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10.0),
                isDense: true,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff0e88eb)))),
          )),
      Expanded(child: Container()),
      Padding(padding: EdgeInsets.only(right: 10), child: Text('UserID: ')),
      Flexible(
          child: Text(
        '${ZegoUserHelper.instance.userID}',
        softWrap: true,
      ))
    ]);
  }

  Widget streamIDWidget() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('StreamID'),
      SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: TextField(
            controller: _streamIDController,
            onEditingComplete: () {},
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10.0),
                isDense: true,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff0e88eb)))),
          ))
    ]);
  }

  Widget rotateModeWidget() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('RotateMode'),
      DropdownButton(
          value: _rotationMode,
          items: [
            DropdownMenuItem(
              child: Text("Fixed Portrait", style: TextStyle(fontSize: 12.0)),
              value: "Fixed Portrait",
            ),
            DropdownMenuItem(
              child: Text("Fixed Landscape", style: TextStyle(fontSize: 12.0)),
              value: "Fixed Landscape",
            ),
            DropdownMenuItem(
              child: Text("Auto", style: TextStyle(fontSize: 12.0)),
              value: "Auto",
            )
          ],
          onChanged: (String? mode) {
            if (mode == null) {
              return;
            }

            if (_playerState == ZegoPlayerState.Playing ||
                _publisherState == ZegoPublisherState.Publishing) {
              showToast(context, 'Please stop publishing/palying first');
              return;
            }

            if ((widget.type == _VideoRotationPageType.Publish &&
                    _publisherState != ZegoPublisherState.Publishing) ||
                (widget.type == _VideoRotationPageType.Play &&
                    _playerState != ZegoPlayerState.Playing)) {
              switch (mode) {
                case "Fixed Portrait":
                  SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp]);
                  _videoConfig.encodeWidth = 360;
                  _videoConfig.encodeHeight = 640;
                  ZegoLog().addLog('size: ${MediaQuery.of(context).size}');
                  break;
                case "Fixed Landscape":
                  if (Platform.isIOS) {
                    SystemChrome.setPreferredOrientations(
                        [DeviceOrientation.landscapeRight]);
                    // changeScreenOrientation(DeviceOrientation.landscapeLeft);
                  } else if (Platform.isAndroid) {
                    SystemChrome.setPreferredOrientations(
                        [DeviceOrientation.landscapeLeft]);
                  }

                  _videoConfig.encodeWidth = 640;
                  _videoConfig.encodeHeight = 360;
                  ZegoLog().addLog('size: ${MediaQuery.of(context).size}');
                  break;
                case "Auto":
                  SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp]).then((value) {
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.landscapeRight,
                      DeviceOrientation.portraitDown,
                      DeviceOrientation.portraitUp
                    ]);
                  });
                  break;
                default:
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitDown,
                    DeviceOrientation.portraitUp
                  ]);
              }

              setState(() {
                _rotationMode = mode;
              });
            }
          })
    ]);
  }

  Widget startButton() {
    String str = "";
    if (widget.type == _VideoRotationPageType.Publish) {
      if (_publisherState == ZegoPublisherState.Publishing) {
        str = "✅ StopPublishing";
      } else {
        str = "StartPublishing";
      }
    } else {
      if (_playerState != ZegoPlayerState.NoPlay) {
        str = _playerState == ZegoPlayerState.Playing
            ? '✅ StopPlaying'
            : '❌ StopPlaying';
      } else {
        str = "StartPlaying";
      }
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: CupertinoButton(
          child: Text(str), onPressed: () => onStartButtonPressed(context)),
    );
  }

  void showToast(BuildContext context, String text) {
    bool show = true;
    showDialog(
        context: context,
        useSafeArea: true,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(),
              Container(),
              Card(
                  child:
                      Padding(padding: EdgeInsets.all(10), child: Text(text)))
            ],
          );
        }).then((value) => show = false);
    Timer(Duration(seconds: 1), () {
      if (show) {
        Navigator.of(context).pop();
      }
    });
  }

  // zego

  void getEngineConfig() {
    ZegoExpressEngine.getVersion()
        .then((value) => ZegoLog().addLog('🌞 SDK Version: $value'));
  }

  void createEngine() {
    ZegoEngineProfile profile = ZegoEngineProfile(
        ZegoConfig.instance.appID, ZegoConfig.instance.scenario,
        enablePlatformView: ZegoConfig.instance.enablePlatformView,
        appSign: ZegoConfig.instance.appSign);
    ZegoExpressEngine.createEngineWithProfile(profile);

    ZegoLog().addLog('🚀 Create ZegoExpressEngine');
  }

  String roomStateDesc() {
    switch (_roomState) {
      case ZegoRoomState.Disconnected:
        return "Disconnected 🔴";
      case ZegoRoomState.Connecting:
        return "Connecting 🟡";
      case ZegoRoomState.Connected:
        return "Connected 🟢";
      default:
        return "Unknown";
    }
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

  Future<void> loginRoom() async {
    ZegoUser user = ZegoUser(
        ZegoUserHelper.instance.userID, ZegoUserHelper.instance.userName);

    // Login Room
    await ZegoExpressEngine.instance.loginRoom(_roomIDController.text, user);

    ZegoLog().addLog('🚪 Start login room, roomID: ${_roomIDController.text}');
  }

  Future logoutRoom() async {
    if (_roomIDController.text.isNotEmpty) {
      await ZegoExpressEngine.instance.logoutRoom(_roomIDController.text);

      ZegoLog()
          .addLog('🚪 Start logout room, roomID: ${_roomIDController.text}');
    }
  }

  void startPublishing(BuildContext context) async {
    if (_streamIDController.text.isNotEmpty) {
      if (_viewID == -1) {
        _view = await ZegoExpressEngine.instance.createCanvasView((viewID) {
          _viewID = viewID;
          ZegoExpressEngine.instance.startPreview(
              canvas: ZegoCanvas(_viewID,
                  backgroundColor: 0xffffff, viewMode: ZegoViewMode.AspectFit));
          ZegoExpressEngine.instance
              .startPublishingStream(_streamIDController.text);
          ZegoLog().addLog(
              '📥 Start publish stream, streamID: ${_streamIDController.text}');
        });

        setState(() {});
      } else {
        ZegoExpressEngine.instance.startPreview(
            canvas: ZegoCanvas(_viewID,
                backgroundColor: 0xffffff, viewMode: ZegoViewMode.AspectFit));
        ZegoExpressEngine.instance
            .startPublishingStream(_streamIDController.text);
        ZegoLog().addLog(
            '📥 Start publish stream, streamID: ${_streamIDController.text}');
      }
    }
  }

  void stopPublishing() {
    ZegoExpressEngine.instance.stopPreview();
    ZegoExpressEngine.instance.stopPublishingStream();
  }

  void startPlaying(BuildContext context) async {
    if (_streamIDController.text.isNotEmpty) {
      if (_viewID == -1) {
        _view = await ZegoExpressEngine.instance.createCanvasView((viewID) {
          _viewID = viewID;
          ZegoExpressEngine.instance.startPlayingStream(
              _streamIDController.text,
              canvas: ZegoCanvas(_viewID,
                  backgroundColor: 0xffffff, viewMode: ZegoViewMode.AspectFit));
          ZegoLog().addLog(
              '📥 Start publish stream, streamID: ${_streamIDController.text}');
        });
        setState(() {});
      } else {
        ZegoExpressEngine.instance.startPlayingStream(_streamIDController.text,
            canvas: ZegoCanvas(_viewID,
                backgroundColor: 0xffffff, viewMode: ZegoViewMode.AspectFit));
        ZegoLog().addLog(
            '📥 Start publish stream, streamID: ${_streamIDController.text}');
      }
    }
  }

  void stopPlaying() {
    ZegoExpressEngine.instance.stopPlayingStream(_streamIDController.text);
  }

  void setRotateMode(DeviceOrientation mode) {
    ZegoExpressEngine.instance.setAppOrientation(mode);
  }
}
