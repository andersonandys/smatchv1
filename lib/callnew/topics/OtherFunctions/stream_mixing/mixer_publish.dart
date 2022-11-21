import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew//utils/zego_log_view.dart';
import 'package:smatch/callnew//utils/zego_user_helper.dart';

class MixerPublishPage extends StatefulWidget {
  const MixerPublishPage({Key? key}) : super(key: key);

  @override
  _MixerPublishPageState createState() => _MixerPublishPageState();
}

class _MixerPublishPageState extends State<MixerPublishPage> {
  Widget? _view;
  late TextEditingController _controller;
  late bool _useCamera;
  late bool _useMic;
  final _roomID = 'mixer';

  late ZegoDelegate _zegoDelegate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _zegoDelegate = ZegoDelegate();

    _controller = TextEditingController();
    _controller.text = 'mixer';
    _useCamera = true;
    _useMic = true;

    _zegoDelegate.createEngine().then((value) {
      _zegoDelegate.loginRoom(_roomID);

      _zegoDelegate.enableCamare(_useCamera);
      _zegoDelegate.enableMic(_useMic);
    });
  }

  @override
  void dispose() {
    _zegoDelegate.dispose();
    _zegoDelegate
        .logoutRoom(_roomID)
        .then((value) => _zegoDelegate.destroyEngine());

    super.dispose();
  }

  void onStartBtnPress() async {
    if (_controller.text.isNotEmpty) {
      _view = await _zegoDelegate.startPublishing(
        _controller.text,
      );
      setState(() {});
    }
  }

  void onStopBtnPress() {
    _zegoDelegate.stopPublishing();
  }

  void onCamareBtnPress() {
    setState(() {
      _useCamera = !_useCamera;
    });
    _zegoDelegate.enableCamare(_useCamera);
  }

  void onMicBtnPress() {
    setState(() {
      _useMic = !_useMic;
    });
    _zegoDelegate.enableMic(_useMic);
  }

  Widget view() {
    return Stack(
      children: [
        Container(
          color: Colors.grey,
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.width * 0.8,
          child: _view,
        ),
        Positioned(
            right: 55,
            bottom: 5,
            width: 40,
            height: 40,
            child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _useCamera ? Colors.white : Colors.black38),
                child: IconButton(
                    color: _useCamera ? Colors.black : Colors.white,
                    onPressed: onCamareBtnPress,
                    icon: Icon(Icons.camera_alt)))),
        Positioned(
            right: 5,
            bottom: 5,
            width: 40,
            height: 40,
            child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _useMic ? Colors.white : Colors.black38),
                child: IconButton(
                    color: _useMic ? Colors.black : Colors.white,
                    onPressed: onMicBtnPress,
                    icon: Icon(Icons.mic))))
      ],
    );
  }

  Widget mainWidget() {
    return Column(children: [
      SizedBox(
        child: ZegoLogView(),
        height: MediaQuery.of(context).size.height * 0.1,
      ),
      Center(
          child: Container(
        padding: EdgeInsets.only(top: 20),
        width: MediaQuery.of(context).size.width * 0.7,
        child: Column(
          children: [
            Text('RoomID:    mixer'),
            Padding(padding: EdgeInsets.only(top: 10)),
            Center(child: view()),
            Padding(padding: EdgeInsets.only(top: 10)),
            TextField(
              controller: _controller,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10.0),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff0e88eb)))),
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: CupertinoButton.filled(
                  child: Text(
                    '发起推流',
                  ),
                  onPressed: onStartBtnPress,
                  padding: EdgeInsets.only(top: 10, bottom: 10)),
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: CupertinoButton.filled(
                  child: Text(
                    '停止推流',
                  ),
                  onPressed: onStopBtnPress,
                  padding: EdgeInsets.only(top: 10, bottom: 10)),
            )
          ],
        ),
      ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("混流"),
        ),
        body: SafeArea(child: SingleChildScrollView(child: mainWidget())));
  }
}

class ZegoDelegate {
  late int _preViewID;

  Widget? preWidget;
  ZegoDelegate() : _preViewID = -1;

  dispose() {
    if (_preViewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_preViewID);
      _preViewID = -1;
    }
  }

  void enableCamare(bool enable) {
    ZegoExpressEngine.instance.enableCamera(enable);
  }

  void enableMic(bool enable) {
    ZegoExpressEngine.instance.muteMicrophone(!enable);
  }

  Future<void> createEngine({bool? enablePlatformView}) async {
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
}
