import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew//utils/zego_log_view.dart';
import 'package:smatch/callnew//utils/zego_user_helper.dart';

class H265Page extends StatefulWidget {
  const H265Page({Key? key}) : super(key: key);
  @override
  _H265PageState createState() => _H265PageState();
}

enum _MixerState { None, Fail, Success }

class _H265PageState extends State<H265Page> {
  late ZegoRoomState _roomState;
  late String _roomID;
  final String _streamID = "h265";

  late ZegoPublisherState _publisherState;
  late ZegoPlayerState _playerState_0;
  late ZegoPlayerState _playerState_1;
  late ZegoPlayerState _playerState_2;

  late Size _publishSize;
  late Size _playSize_0;
  late Size _playSize_1;
  late Size _playSize_2;

  late ZegoPublishStreamQuality _pulishQuality;
  late ZegoPlayStreamQuality _playQuality_0;
  late ZegoPlayStreamQuality _playQuality_1;
  late ZegoPlayStreamQuality _playQuality_2;

  Widget? _previewViewWidget;
  Widget? _playViewWidget_0;
  Widget? _playViewWidget_1;
  Widget? _playViewWidget_2;

  late TextEditingController _publishStreamIDController;
  late TextEditingController _playStreamIDController_0;
  late TextEditingController _playStreamIDController_1;
  late TextEditingController _playStreamIDController_2;

  late TextEditingController _roomIDController;
  late TextEditingController _userIDController;

  late int _publishVideoFPS;
  late Size _publishResolutionSize;
  late TextEditingController _publishVideoBitrateController;

  late int _mixerVideoFPS;
  late Size _mixerResolutionSize;
  late TextEditingController _mixerH264BitrateController;
  late TextEditingController _mixerH264StreamIDController;
  late TextEditingController _mixerH265BitrateController;
  late TextEditingController _mixerH265StreamIDController;
  late _MixerState _mixerState;

  late Set<String> _remoteStreamList;

  late ZegoDelegate _zegoDelegate;

  @override
  void initState() {
    super.initState();

    _zegoDelegate = ZegoDelegate();

    _publisherState = ZegoPublisherState.NoPublish;
    _playerState_0 = ZegoPlayerState.NoPlay;
    _playerState_1 = ZegoPlayerState.NoPlay;
    _playerState_2 = ZegoPlayerState.NoPlay;
    _roomState = ZegoRoomState.Disconnected;

    _publishSize = Size(360, 640);
    _playSize_0 = Size(360, 640);
    _playSize_1 = Size(360, 640);
    _playSize_2 = Size(360, 640);

    _pulishQuality = ZegoPublishStreamQuality(
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        0,
        .0,
        ZegoStreamQualityLevel.Unknown,
        false,
        ZegoVideoCodecID.Default,
        .0,
        .0,
        .0);
    _playQuality_0 = ZegoPlayStreamQuality(
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        0,
        .0,
        0,
        .0,
        ZegoStreamQualityLevel.Unknown,
        0,
        0,
        false,
        ZegoVideoCodecID.Default,
        .0,
        .0,
        .0);
    _playQuality_1 = ZegoPlayStreamQuality(
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        0,
        .0,
        0,
        .0,
        ZegoStreamQualityLevel.Unknown,
        0,
        0,
        false,
        ZegoVideoCodecID.Default,
        .0,
        .0,
        .0);
    _playQuality_2 = ZegoPlayStreamQuality(
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        .0,
        0,
        .0,
        0,
        .0,
        ZegoStreamQualityLevel.Unknown,
        0,
        0,
        false,
        ZegoVideoCodecID.Default,
        .0,
        .0,
        .0);

    _publishStreamIDController = TextEditingController();
    _publishStreamIDController.text = _streamID;

    _playStreamIDController_0 = TextEditingController();
    _playStreamIDController_0.text = _streamID;

    _playStreamIDController_1 = TextEditingController();
    _playStreamIDController_1.text = '264';
    _playStreamIDController_2 = TextEditingController();
    _playStreamIDController_2.text = '265';

    _roomIDController = TextEditingController();
    _roomIDController.text = 'h265';
    _roomID = 'h265';
    _userIDController = TextEditingController();
    _userIDController.text = ZegoUserHelper.instance.userID;

    _publishVideoFPS = 15;
    _publishResolutionSize = Size(360, 600);
    _publishVideoBitrateController = TextEditingController();
    _publishVideoBitrateController.text = '616';

    _mixerState = _MixerState.None;
    _mixerVideoFPS = 15;
    _mixerResolutionSize = Size(360, 600);
    _mixerH264BitrateController = TextEditingController();
    _mixerH264BitrateController.text = '616';
    _mixerH264StreamIDController = TextEditingController();
    _mixerH264StreamIDController.text = '264';
    _mixerH265BitrateController = TextEditingController();
    _mixerH265BitrateController.text = '616';
    _mixerH265StreamIDController = TextEditingController();
    _mixerH265StreamIDController.text = '265';

    _remoteStreamList = {};

    _zegoDelegate.setZegoEventCallback(
        onRoomStateUpdate: onRoomStateUpdate,
        onPublisherStateUpdate: onPublisherStateUpdate,
        onPlayerStateUpdate: onPlayerStateUpdate,
        onPlayerQualityUpdate: onPlayerQualityUpdate,
        onPublisherQualityUpdate: onPublisherQualityUpdate,
        onPublisherVideoSizeChanged: onPublisherVideoSizeChanged,
        onPlayerVideoSizeChanged: onPlayerVideoSizeChanged,
        onRoomStreamUpdate: onRoomStreamUpdate);
    _zegoDelegate.createEngine();
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
    setState(() => _publisherState = state);
  }

  void onPlayerStateUpdate(String streamID, ZegoPlayerState state,
      int errorCode, Map<String, dynamic> extendedData) {
    if (streamID == _playStreamIDController_0.text.trim()) {
      _playerState_0 = state;
    }
    if (streamID == _playStreamIDController_1.text.trim()) {
      _playerState_1 = state;
    }
    if (streamID == _playStreamIDController_2.text.trim()) {
      _playerState_2 = state;
    }
    setState(() {});
  }

  void onPublisherQualityUpdate(
      String streamID, ZegoPublishStreamQuality quality) {
    setState(() {
      _pulishQuality = quality;
    });
  }

  void onPlayerQualityUpdate(String streamID, ZegoPlayStreamQuality quality) {
    if (streamID == _playStreamIDController_0.text.trim()) {
      _playQuality_0 = quality;
    }
    if (streamID == _playStreamIDController_1.text.trim()) {
      _playQuality_1 = quality;
    }
    if (streamID == _playStreamIDController_2.text.trim()) {
      _playQuality_2 = quality;
    }
    setState(() {});
  }

  void onPublisherVideoSizeChanged(
      int width, int height, ZegoPublishChannel channel) {
    setState(() {
      _publishSize = Size(width.toDouble(), height.toDouble());
    });
  }

  void onPlayerVideoSizeChanged(String streamID, int width, int height) {
    if (streamID == _playStreamIDController_0.text.trim()) {
      _playSize_0 = Size(width.toDouble(), height.toDouble());
    }
    if (streamID == _playStreamIDController_1.text.trim()) {
      _playSize_1 = Size(width.toDouble(), height.toDouble());
    }
    if (streamID == _playStreamIDController_2.text.trim()) {
      _playSize_2 = Size(width.toDouble(), height.toDouble());
    }
    setState(() {});
  }

  void onRoomStreamUpdate(String roomID, ZegoUpdateType updateType,
      List<ZegoStream> streamList, Map<String, dynamic> extendedData) {
    if (updateType == ZegoUpdateType.Add) {
      for (var stream in streamList) {
        _remoteStreamList.add(stream.streamID);
      }
    } else {
      for (var stream in streamList) {
        _remoteStreamList.remove(stream.streamID);
      }
    }

    if (_mixerState == _MixerState.Success) {
      stopMixStream(update: false)
          .then((value) => startMixStream(update: false));
    }
  }

  // widget callback

  void onLoginRoomBtnPress() {
    if (_roomState != ZegoRoomState.Disconnected) {
      _zegoDelegate.logoutRoom(_roomID);
    } else {
      _zegoDelegate.loginRoom(
          _roomIDController.text.trim(), _userIDController.text.trim());
    }
  }

  void onPublishStreamBtnPress() {
    if (_publisherState == ZegoPublisherState.NoPublish &&
        _publishStreamIDController.text.isNotEmpty) {
      var bitrate = int.tryParse(_publishVideoBitrateController.text);
      if (bitrate == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('请输入整数数字')));
        return;
      }
      var config = ZegoVideoConfig.preset(ZegoVideoConfigPreset.Preset360P);
      config.fps = _publishVideoFPS;
      config.encodeWidth = _publishResolutionSize.width.toInt();
      config.encodeHeight = _publishResolutionSize.height.toInt();
      config.captureWidth = _publishResolutionSize.width.toInt();
      config.captureHeight = _publishResolutionSize.height.toInt();
      config.bitrate = bitrate;
      config.codecID = ZegoVideoCodecID.H265;
      _zegoDelegate.setVideoConfig(config);

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

  void onPlayStreamBtnPress(int index) {
    String streamID = _playStreamIDController_0.text;
    ZegoPlayerState playState = _playerState_0;
    if (index == 1) {
      streamID = _playStreamIDController_1.text;
      playState = _playerState_1;
    } else if (index == 2) {
      streamID = _playStreamIDController_2.text;
      playState = _playerState_2;
    }
    if (playState == ZegoPlayerState.NoPlay && streamID.isNotEmpty) {
      _zegoDelegate
          .startPlaying(streamID, index,
              mode: index != 0
                  ? ZegoStreamResourceMode.OnlyCDN
                  : ZegoStreamResourceMode.Default)
          .then((widget) {
        if (index == 0) {
          _playViewWidget_0 = widget;
        } else if (index == 1) {
          _playViewWidget_1 = widget;
        } else if (index == 2) {
          _playViewWidget_2 = widget;
        }
        setState(() {});
      });
    } else {
      _zegoDelegate.stopPlaying(streamID);
    }
  }

  Future<void> startMixStream({bool update = true}) async {
    ZegoLog().addLog("Start mixer task");

    ZegoMixerTask task = ZegoMixerTask('${_roomID}_MixStream');

    task.videoConfig = ZegoMixerVideoConfig(_mixerResolutionSize.width.toInt(),
        _mixerResolutionSize.height.toInt(), _mixerVideoFPS, 3000);

    int streamCount = _remoteStreamList.length +
        (_publisherState == ZegoPublisherState.Publishing ? 1 : 0);
    if (streamCount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('混流失败, 至少存在一条流才能混流.')));
      return;
    }

    List<ZegoMixerInput> inputList = [];

    Rect firstRect = Rect.fromLTWH(
        0, 0, task.videoConfig.width / 2, task.videoConfig.height / 2);
    Rect secondRect = Rect.fromLTWH(task.videoConfig.width / 2, 0,
        task.videoConfig.width.toDouble(), task.videoConfig.height / 2);
    Rect thirdRect = Rect.fromLTWH(0, task.videoConfig.height / 2,
        task.videoConfig.width / 2, task.videoConfig.height.toDouble());
    Rect fourthRect = Rect.fromLTWH(
        task.videoConfig.width / 2,
        task.videoConfig.height / 2,
        task.videoConfig.width.toDouble(),
        task.videoConfig.height.toDouble());
    List rectArrayList = <Rect>[firstRect, secondRect, thirdRect, fourthRect];

    if (_publisherState == ZegoPublisherState.Publishing) {
      ZegoMixerInput firstInput = ZegoMixerInput.defaultConfig();
      firstInput.streamID = _publishStreamIDController.text.trim();
      firstInput.contentType = ZegoMixerInputContentType.Video;
      firstInput.layout = rectArrayList[0];
      inputList.add(firstInput);
      for (int idx = 0; idx < 3 && idx < _remoteStreamList.length; ++idx) {
        ZegoMixerInput input = ZegoMixerInput.defaultConfig();

        input.streamID = _remoteStreamList.elementAt(idx);
        input.contentType = ZegoMixerInputContentType.Video;
        input.layout = rectArrayList[idx + 1];
        inputList.add(input);
      }
    } else {
      for (int idx = 0; idx < 4 && idx < _remoteStreamList.length; ++idx) {
        ZegoMixerInput input = ZegoMixerInput.defaultConfig();
        input.streamID = _remoteStreamList.elementAt(idx);
        input.contentType = ZegoMixerInputContentType.Video;
        input.layout = rectArrayList[idx];
        inputList.add(input);
      }
    }
    task.inputList = inputList;

    List<ZegoMixerOutput> outputList = [];

    var h264Bitrate = int.tryParse(_mixerH264BitrateController.text);
    var h265Bitrate = int.tryParse(_mixerH265BitrateController.text);
    if (h264Bitrate == null || h265Bitrate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('码率需要为整数数字')));
      return;
    }
    ZegoMixerOutput outputH264 =
        new ZegoMixerOutput(_mixerH264StreamIDController.text.trim());
    ZegoMixerOutputVideoConfig outputH264VideoConfig =
        new ZegoMixerOutputVideoConfig(ZegoVideoCodecID.Default, h264Bitrate);
    outputH264.videoConfig = outputH264VideoConfig;
    outputList.add(outputH264);
    ZegoMixerOutput outputH265 =
        new ZegoMixerOutput(_mixerH265StreamIDController.text.trim());
    ZegoMixerOutputVideoConfig outputH265VideoConfig =
        new ZegoMixerOutputVideoConfig(ZegoVideoCodecID.H265, h265Bitrate);
    outputH265.videoConfig = outputH265VideoConfig;
    outputList.add(outputH265);
    task.outputList = outputList;

    var result = await _zegoDelegate.startMixStream(task);
    if (update) {
      if (result.errorCode == 0) {
        _mixerState = _MixerState.Success;
      } else {
        ZegoLog().addLog('startMixStream errorCode: ${result.errorCode}');
        _mixerState = _MixerState.Fail;
      }
      setState(() {});
    }
  }

  Future<void> stopMixStream({bool update = true}) async {
    ZegoMixerTask task = ZegoMixerTask('${_roomID}_MixStream');
    task.videoConfig = ZegoMixerVideoConfig(_mixerResolutionSize.width.toInt(),
        _mixerResolutionSize.height.toInt(), _mixerVideoFPS, 3000);

    int streamCount = _remoteStreamList.length +
        (_publisherState == ZegoPublisherState.Publishing ? 1 : 0);
    if (streamCount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('混流失败, 至少存在一条流才能混流.')));
      return;
    }

    List<ZegoMixerInput> inputList = [];

    Rect firstRect = Rect.fromLTWH(
        0, 0, task.videoConfig.width / 2, task.videoConfig.height / 2);
    Rect secondRect = Rect.fromLTWH(task.videoConfig.width / 2, 0,
        task.videoConfig.width.toDouble(), task.videoConfig.height / 2);
    Rect thirdRect = Rect.fromLTWH(0, task.videoConfig.height / 2,
        task.videoConfig.width / 2, task.videoConfig.height.toDouble());
    Rect fourthRect = Rect.fromLTWH(
        task.videoConfig.width / 2,
        task.videoConfig.height / 2,
        task.videoConfig.width.toDouble(),
        task.videoConfig.height.toDouble());
    List rectArrayList = <Rect>[firstRect, secondRect, thirdRect, fourthRect];

    if (_publisherState == ZegoPublisherState.Publishing) {
      ZegoMixerInput firstInput = ZegoMixerInput.defaultConfig();
      firstInput.streamID = _publishStreamIDController.text.trim();
      firstInput.contentType = ZegoMixerInputContentType.Video;
      firstInput.layout = rectArrayList[0];
      inputList.add(firstInput);
      for (int idx = 0; idx < 3 && idx < _remoteStreamList.length; ++idx) {
        ZegoMixerInput input = ZegoMixerInput.defaultConfig();

        input.streamID = _remoteStreamList.elementAt(idx);
        input.contentType = ZegoMixerInputContentType.Video;
        input.layout = rectArrayList[idx + 1];
        inputList.add(input);
      }
    } else {
      for (int idx = 0; idx < 4 && idx < _remoteStreamList.length; ++idx) {
        ZegoMixerInput input = ZegoMixerInput.defaultConfig();
        input.streamID = _remoteStreamList.elementAt(idx);
        input.contentType = ZegoMixerInputContentType.Video;
        input.layout = rectArrayList[idx];
        inputList.add(input);
      }
    }
    task.inputList = inputList;

    List<ZegoMixerOutput> outputList = [];

    var h264Bitrate = int.tryParse(_mixerH264BitrateController.text);
    var h265Bitrate = int.tryParse(_mixerH265BitrateController.text);
    if (h264Bitrate == null || h265Bitrate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('码率需要为整数数字')));
      return;
    }
    ZegoMixerOutput outputH264 =
        new ZegoMixerOutput(_mixerH264StreamIDController.text.trim());
    ZegoMixerOutputVideoConfig outputH264VideoConfig =
        new ZegoMixerOutputVideoConfig(ZegoVideoCodecID.Default, h264Bitrate);
    outputH264.videoConfig = outputH264VideoConfig;
    outputList.add(outputH264);
    ZegoMixerOutput outputH265 =
        new ZegoMixerOutput(_mixerH265StreamIDController.text.trim());
    ZegoMixerOutputVideoConfig outputH265VideoConfig =
        new ZegoMixerOutputVideoConfig(ZegoVideoCodecID.H265, h265Bitrate);
    outputH265.videoConfig = outputH265VideoConfig;
    outputList.add(outputH265);
    task.outputList = outputList;
    await _zegoDelegate.stopMixerTask(task);

    if (update) {
      setState(() {
        _mixerState = _MixerState.None;
      });
    }
  }

  void onMixerBtnPress() {
    if (_mixerState != _MixerState.None) {
      stopMixStream();
    } else {
      startMixStream();
    }
  }

  void onPublishResolutionChanged(Size? size) {
    if (size != null) {
      _publishResolutionSize = size;
      _publishVideoBitrateController.text = _zegoDelegate
          .getBitrateWithFPS(
              _publishVideoFPS, _publishResolutionSize, ZegoVideoCodecID.H265)
          .toString();
      setState(() {});
    }
  }

  void onPublishFPSChanged(int? fps) {
    if (fps != null) {
      _publishVideoFPS = fps;
      _publishVideoBitrateController.text = _zegoDelegate
          .getBitrateWithFPS(
              _publishVideoFPS, _publishResolutionSize, ZegoVideoCodecID.H265)
          .toString();
      setState(() {});
    }
  }

  void onMixerFPSChanged(int? fps) {
    if (fps != null) {
      _mixerVideoFPS = fps;
      _mixerH264BitrateController.text = _zegoDelegate
          .getBitrateWithFPS(
              _mixerVideoFPS, _mixerResolutionSize, ZegoVideoCodecID.Default)
          .toString();
      _mixerH265BitrateController.text = _zegoDelegate
          .getBitrateWithFPS(
              _mixerVideoFPS, _mixerResolutionSize, ZegoVideoCodecID.H265)
          .toString();
      setState(() {});
    }
  }

  void onMixerResolutionChanged(Size? size) {
    if (size != null) {
      _mixerResolutionSize = size;
      _mixerH264BitrateController.text = _zegoDelegate
          .getBitrateWithFPS(
              _mixerVideoFPS, _mixerResolutionSize, ZegoVideoCodecID.Default)
          .toString();
      _mixerH265BitrateController.text = _zegoDelegate
          .getBitrateWithFPS(
              _mixerVideoFPS, _mixerResolutionSize, ZegoVideoCodecID.H265)
          .toString();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("H265"),
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
            roomAboutWidget(),
            streamViewsWidget(),
            playStreamViewsWidget(),
            Divider(),
            publishWidget(),
            Divider(),
            mixerWidget()
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

  Widget roomAboutWidget() {
    return Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Row(
            children: [
              Text('RoomID '),
              Expanded(
                  child: TextField(
                controller: _roomIDController,
                style: TextStyle(fontSize: 11),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10.0),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff0e88eb)))),
              ))
            ],
          ),
          Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Text('UserID '),
                  Expanded(
                      child: TextField(
                    controller: _userIDController,
                    style: TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10.0),
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff0e88eb)))),
                  ))
                ],
              )),
          Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: CupertinoButton.filled(
                  child: Text(
                    _roomState != ZegoRoomState.Disconnected
                        ? (_roomState == ZegoRoomState.Connected
                            ? '✅ Logout Room'
                            : '❌ Logout Room')
                        : 'Login Room',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  onPressed: onLoginRoomBtnPress,
                  padding: EdgeInsets.all(10.0)))
        ]));
  }

// Buttons and titles on the preview widget
  Widget preWidgetTopWidget() {
    return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Text('预览', style: TextStyle(color: Colors.white))),
          Text('VideoCodec: ${_pulishQuality.videoCodecID.name}',
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Text(
              'Resolution: ${_publishSize.width.toInt()} x ${_publishSize.height.toInt()}',
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Text(
              'Bitrate: ${(_pulishQuality.videoSendBytes / 1000).toStringAsFixed(2)}kbps',
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Text('FPS: ${_pulishQuality.videoSendFPS.toStringAsFixed(2)}f/s',
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Expanded(child: Container()),
        ]));
  }

// Buttons and titles on the play widget
  Widget playWidgetTopWidget(int i) {
    var playQuality = _playQuality_0;

    var playSize = _playSize_0;
    var playState = _playerState_0;
    if (i == 1) {
      playSize = _playSize_1;
      playQuality = _playQuality_1;
      playState = _playerState_1;
    } else if (i == 2) {
      playSize = _playSize_2;
      playQuality = _playQuality_2;
      playState = _playerState_2;
    }
    return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Text('拉流', style: TextStyle(color: Colors.white))),
          Text('VideoCodec: ${playQuality.videoCodecID.name}',
              key: ValueKey('VideoCodec$i'),
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Text(
              'Resolution: ${playSize.width.toInt()} x ${playSize.height.toInt()}',
              key: ValueKey('Resolution$i'),
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Text(
              'Bitrate: ${(playQuality.videoRecvBytes / 1000).toStringAsFixed(2)}kbps',
              key: ValueKey('Bitrate$i'),
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Text('FPS: ${playQuality.videoRecvFPS.toStringAsFixed(2)}f/s',
              key: ValueKey('FPS$i'),
              style: TextStyle(color: Colors.red[100], fontSize: 11.5)),
          Expanded(child: Container()),
          Padding(
              padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  Text('Stream ID: '),
                  Expanded(
                      child: TextField(
                    key: ValueKey('playStreamID$i'),
                    controller: i != 0
                        ? (i == 1
                            ? _playStreamIDController_1
                            : _playStreamIDController_2)
                        : _playStreamIDController_0,
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
                key: ValueKey('startPlay$i'),
                child: Text(
                  playState != ZegoPlayerState.NoPlay
                      ? (playState == ZegoPlayerState.Playing
                          ? '✅ StopPlaying'
                          : '❌ StopPlaying')
                      : 'StartPlaying',
                  style: TextStyle(fontSize: 14.0),
                ),
                onPressed: () => onPlayStreamBtnPress(i),
                padding: EdgeInsets.all(10.0)),
          )
        ]));
  }

  Widget streamViewsWidget() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.3,
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
                      child: _playViewWidget_0,
                    ),
                    playWidgetTopWidget(0)
                  ],
                  alignment: AlignmentDirectional.topCenter,
                ))
          ],
        ));
  }

  Widget playStreamViewsWidget() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.3,
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
                flex: 15,
                child: Stack(
                  children: [
                    Container(
                      color: Colors.grey,
                      child: _playViewWidget_1,
                    ),
                    playWidgetTopWidget(1)
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
                      child: _playViewWidget_2,
                    ),
                    playWidgetTopWidget(2)
                  ],
                  alignment: AlignmentDirectional.topCenter,
                ))
          ],
        ));
  }

  Widget publishWidget() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                  flex: 15,
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Text('StreamID: '),
                              Expanded(
                                  child: TextField(
                                controller: _publishStreamIDController,
                                style: TextStyle(fontSize: 11),
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(10.0),
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFF90CAF9))),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xff0e88eb)))),
                              )),
                            ],
                          )),
                      Row(
                        children: [
                          Expanded(child: Text('Resolution: ')),
                          DropdownButton<Size>(
                            items: [
                              DropdownMenuItem(
                                child: Text('360x600'),
                                value: Size(360, 600),
                              ),
                              DropdownMenuItem(
                                child: Text('720x1280'),
                                value: Size(720, 1280),
                              ),
                              DropdownMenuItem(
                                child: Text('1080x1920'),
                                value: Size(1080, 1920),
                              ),
                            ],
                            onChanged: onPublishResolutionChanged,
                            value: _publishResolutionSize,
                          ),
                        ],
                      ),
                    ],
                  )),
              Flexible(
                flex: 1,
                child: Container(),
              ),
              Flexible(
                  flex: 15,
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(child: Text('视频帧率')),
                              DropdownButton<int>(
                                items: [
                                  DropdownMenuItem(
                                    child: Text('15'),
                                    value: 15,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('30'),
                                    value: 30,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('60'),
                                    value: 60,
                                  ),
                                ],
                                onChanged: onPublishFPSChanged,
                                value: _publishVideoFPS,
                              )
                            ],
                          )),
                      Row(
                        children: [
                          Text('视频码率: '),
                          Expanded(
                              child: TextField(
                            controller: _publishVideoBitrateController,
                            style: TextStyle(fontSize: 11),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10.0),
                                isDense: true,
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFF90CAF9))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xff0e88eb)))),
                          )),
                        ],
                      ),
                    ],
                  )),
            ],
          ),
          Padding(padding: EdgeInsets.only(bottom: 10), child: Container()),
          Center(
            child: CupertinoButton.filled(
                child: Text(
                  _publisherState != ZegoPublisherState.NoPublish
                      ? (_publisherState == ZegoPublisherState.Publishing
                          ? '✅ StopPublish'
                          : '❌ StopPublish')
                      : 'StartPublish',
                  style: TextStyle(fontSize: 14.0),
                ),
                onPressed: () => onPublishStreamBtnPress(),
                padding: EdgeInsets.all(10.0)),
          )
        ],
      ),
    );
  }

  Widget mixerWidget() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                  flex: 15,
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(child: Text('视频帧率')),
                              DropdownButton<int>(
                                items: [
                                  DropdownMenuItem(
                                    child: Text('15'),
                                    value: 15,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('30'),
                                    value: 30,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('60'),
                                    value: 60,
                                  ),
                                ],
                                onChanged: onMixerFPSChanged,
                                value: _mixerVideoFPS,
                              )
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Text('H264 Bitrate: '),
                              Expanded(
                                  child: TextField(
                                controller: _mixerH264BitrateController,
                                style: TextStyle(fontSize: 11),
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(10.0),
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFF90CAF9))),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xff0e88eb)))),
                              )),
                            ],
                          )),
                      Row(
                        children: [
                          Text('H264 StreamID: '),
                          Expanded(
                              child: TextField(
                            controller: _mixerH264StreamIDController,
                            style: TextStyle(fontSize: 11),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10.0),
                                isDense: true,
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFF90CAF9))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xff0e88eb)))),
                          )),
                        ],
                      ),
                    ],
                  )),
              Flexible(
                flex: 1,
                child: Container(),
              ),
              Flexible(
                  flex: 15,
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(child: Text('Resolution: ')),
                              DropdownButton<Size>(
                                items: [
                                  DropdownMenuItem(
                                    child: Text('360x600'),
                                    value: Size(360, 600),
                                  ),
                                  DropdownMenuItem(
                                    child: Text('720x1280'),
                                    value: Size(720, 1280),
                                  ),
                                  DropdownMenuItem(
                                    child: Text('1080x1920'),
                                    value: Size(1080, 1920),
                                  ),
                                ],
                                onChanged: onMixerResolutionChanged,
                                value: _mixerResolutionSize,
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Text('H265 Bitrate: '),
                              Expanded(
                                  child: TextField(
                                controller: _mixerH265BitrateController,
                                style: TextStyle(fontSize: 11),
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(10.0),
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFF90CAF9))),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xff0e88eb)))),
                              )),
                            ],
                          )),
                      Row(
                        children: [
                          Text('H265 StreamID: '),
                          Expanded(
                              child: TextField(
                            controller: _mixerH265StreamIDController,
                            style: TextStyle(fontSize: 11),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10.0),
                                isDense: true,
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFF90CAF9))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xff0e88eb)))),
                          )),
                        ],
                      ),
                    ],
                  )),
            ],
          ),
          Padding(padding: EdgeInsets.only(bottom: 10), child: Container()),
          Center(
            child: CupertinoButton.filled(
                child: Text(
                  _mixerState != _MixerState.None
                      ? (_mixerState == _MixerState.Success
                          ? '✅ StopMixer'
                          : '❌ StopMixer')
                      : 'StartMixer',
                  style: TextStyle(fontSize: 14.0),
                ),
                onPressed: () => onMixerBtnPress(),
                padding: EdgeInsets.all(10.0)),
          )
        ],
      ),
    );
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

typedef RoomStreamUpdateCallback = void Function(
    String roomID,
    ZegoUpdateType updateType,
    List<ZegoStream> streamList,
    Map<String, dynamic> extendedData);

class ZegoDelegate {
  RoomStateUpdateCallback? _onRoomStateUpdate;
  PublisherStateUpdateCallback? _onPublisherStateUpdate;
  PlayerStateUpdateCallback? _onPlayerStateUpdate;
  PublisherQualityUpdateCallback? _onPublisherQualityUpdate;
  PlayerQualityUpdateCallback? _onPlayerQualityUpdate;
  PublisherVideoSizeChangedCallback? _onPublisherVideoSizeChanged;
  PlayerVideoSizeChangedCallback? _onPlayerVideoSizeChanged;
  RoomStreamUpdateCallback? _onRoomStreamUpdate;

  late int _preViewID;
  late int _playViewID_0;
  late int _playViewID_1;
  late int _playViewID_2;
  Widget? preWidget;
  Widget? playWidget;
  ZegoDelegate()
      : _preViewID = -1,
        _playViewID_0 = -1,
        _playViewID_1 = -1,
        _playViewID_2 = -1;

  dispose() {
    if (_preViewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_preViewID);
      _preViewID = -1;
    }
    if (_playViewID_0 != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_playViewID_0);
      _playViewID_0 = -1;
    }
    if (_playViewID_1 != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_playViewID_1);
      _playViewID_1 = -1;
    }
    if (_playViewID_2 != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_playViewID_2);
      _playViewID_2 = -1;
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
      _onPublisherQualityUpdate?.call(streamID, quality);
    };

    ZegoExpressEngine.onPlayerQualityUpdate =
        (String streamID, ZegoPlayStreamQuality quality) {
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

    ZegoExpressEngine.onRoomStreamUpdate =
        (roomID, updateType, streamList, extendedData) {
      ZegoLog().addLog(
          '🚩 📥 onRoomStreamUpdate: roomID: $roomID updateType: $updateType');
      _onRoomStreamUpdate?.call(roomID, updateType, streamList, extendedData);
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
    RoomStreamUpdateCallback? onRoomStreamUpdate,
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
    if (onRoomStreamUpdate != null) {
      _onRoomStreamUpdate = onRoomStreamUpdate;
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

    _onRoomStreamUpdate = null;
    ZegoExpressEngine.onRoomStreamUpdate = null;
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

  Future<void> loginRoom(String roomID, String userID) async {
    if (roomID.isNotEmpty) {
      // Instantiate a ZegoUser object
      ZegoUser user = ZegoUser.id(userID);

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

  Future<Widget?> startPlaying(String streamID, int index,
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

    if (streamID.isNotEmpty) {
      var playViewID = _playViewID_0;
      if (index == 1) {
        playViewID = _playViewID_1;
      } else if (index == 2) {
        playViewID = _playViewID_2;
      }
      if (playViewID == -1 && needShow) {
        playWidget =
            await ZegoExpressEngine.instance.createCanvasView((viewID) {
          if (index == 0) {
            _playViewID_0 = viewID;
          } else if (index == 1) {
            _playViewID_1 = viewID;
          } else if (index == 2) {
            _playViewID_2 = viewID;
          }

          playFunc(viewID);
        });
      } else {
        playFunc(playViewID);
      }
    }
    return playWidget;
  }

  void stopPlaying(String streamID) {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
  }

  void setVideoConfig(ZegoVideoConfig config) {
    ZegoExpressEngine.instance.setVideoConfig(config);
  }

  int getBitrateWithFPS(int fps, Size size, ZegoVideoCodecID videoCodecID) {
    return (0.0901 *
            getCoefficientOfVideoCodec(videoCodecID) *
            getCoefficientOfFPS(fps) *
            pow(size.width * size.height, 0.7371))
        .toInt();
  }

  double getCoefficientOfFPS(int fps) {
    double coefficient = 1.0;
    switch (fps) {
      case 15:
        coefficient = 1.0;
        break;
      case 30:
        coefficient = 1.5;
        break;
      case 60:
        coefficient = 1.8;
        break;
    }
    return coefficient;
  }

  double getCoefficientOfVideoCodec(ZegoVideoCodecID videoCodecID) {
    double coefficient = 1.0;
    switch (videoCodecID) {
      case ZegoVideoCodecID.Default:
        coefficient = 1.0;
        break;
      case ZegoVideoCodecID.H265:
        coefficient = 0.8;
        break;
      default:
    }
    return coefficient;
  }

  Future<ZegoMixerStartResult> startMixStream(ZegoMixerTask task) {
    return ZegoExpressEngine.instance.startMixerTask(task);
  }

  Future<ZegoMixerStopResult> stopMixerTask(ZegoMixerTask task) {
    return ZegoExpressEngine.instance.stopMixerTask(task);
  }
}
