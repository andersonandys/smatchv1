import 'dart:async';
import 'dart:convert';
import 'package:universal_io/io.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//topics/OtherFunctions/copyrighted_music/copyrighted_music_delegate.dart';
import 'package:smatch/callnew//utils/zego_log_view.dart';
import 'package:smatch/callnew//utils/zego_slider_bar.dart';

class CopyrightedMusicPage extends StatefulWidget {
  const CopyrightedMusicPage({Key? key}) : super(key: key);

  @override
  State<CopyrightedMusicPage> createState() => _CopyrightedMusicPageState();
}

class _CopyrightedMusicPageState extends State<CopyrightedMusicPage> {
  late CopyrightedMusicDelegate _copyrightedMusicDelegate;

  late Map<String, Object> _templateJson;
  late String _commondString;
  late TextEditingController _templateController;
  late String _resultString;
  late LongPressGestureRecognizer _longPressRecognizer;

  late TextEditingController _roomIDController;
  late TextEditingController _streamIDController;

  late TextEditingController _musicTokenController;
  late TextEditingController _krcLyricTokenController;

  late TextEditingController _sourceIDMediaPlayerController;
  late TextEditingController _startPositionMediaPlayerController;

  late int _mediaPlayerIndex;
  late int _audioTrackCount;
  late int _audioTrackIndex;

  late bool _enableAux;
  late bool _enableRepeat;

  late StreamController<double> _playProgressStreamController;

  late TextEditingController _publishVolumeController;
  late TextEditingController _playerVolumeController;

  late TextEditingController _songIDController;
  late ZegoCopyrightedMusicType _musicType;

  late int _score;
  late int _cache;
  late double _downloadProgress;
  late int _pitch;

  // widget style
  late TextStyle _buttonTextStyle;
  late TextStyle _defaultTextStyle;
  late InputDecoration _inputDecoration;

  // about zego express sdk
  late ZegoRoomState _roomState;
  late ZegoPublisherState _publisherState;
  late ZegoCopyrightedMusicBillingMode _billingMode;

  @override
  void initState() {
    super.initState();

    _copyrightedMusicDelegate = CopyrightedMusicDelegate();

    // 手机端强制设置为横屏
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);

    _templateJson = {};
    _commondString = "";
    _templateController = TextEditingController();
    loadJson();

    _resultString = "";
    _longPressRecognizer = LongPressGestureRecognizer();

    _roomIDController = TextEditingController();
    _roomIDController.text = 'CopytightedMusicRoom';

    _streamIDController = TextEditingController();
    _streamIDController.text = 'CopytightedMusicStrem';

    _musicTokenController = TextEditingController();
    _krcLyricTokenController = TextEditingController();

    _sourceIDMediaPlayerController = TextEditingController();
    _startPositionMediaPlayerController = TextEditingController();

    _mediaPlayerIndex = 0;
    _audioTrackCount = 0;
    _audioTrackIndex = 0;

    _enableAux = false;
    _enableRepeat = false;

    _playProgressStreamController = StreamController();

    _publishVolumeController = TextEditingController();
    _playerVolumeController = TextEditingController();

    _songIDController = TextEditingController();
    _musicType = ZegoCopyrightedMusicType.ZegoCopyrightedMusicSong;

    _score = 0;
    _cache = 0;
    _downloadProgress = 0.0;
    _pitch = 0;

    // widget style
    if (Platform.isAndroid || Platform.isIOS) {
      _buttonTextStyle = TextStyle(color: Colors.white, fontSize: 12);
      _defaultTextStyle = TextStyle(fontSize: 12, color: Colors.black);
    } else {
      _buttonTextStyle = TextStyle(color: Colors.white);
      _defaultTextStyle = TextStyle(color: Colors.black);
    }
    _inputDecoration = InputDecoration(
        border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 2),
    ));

    // about zego express sdk init
    _roomState = ZegoRoomState.Disconnected;
    _billingMode = ZegoCopyrightedMusicBillingMode.Count;
    _publisherState = ZegoPublisherState.NoPublish;

    _copyrightedMusicDelegate.setZegoEventCallback(
        onRoomStateUpdate: onRoomStateUpdate,
        onPublisherStateUpdate: onPublisherStateUpdate,
        onMediaPlayerPlayingProgress: onMediaPlayerPlayingProgress,
        onDownloadProgressUpdate: onDownloadProgressUpdate);
    _copyrightedMusicDelegate.createEngine().then((value) {
      _copyrightedMusicDelegate.createCopyrightedMusic();
      _copyrightedMusicDelegate.createMediaPlayer();
    });
  }

  @override
  void dispose() {
    super.dispose();

    _copyrightedMusicDelegate.destoryCopyrightedMusic();
    _copyrightedMusicDelegate.destroyMediaPlayer();
    _copyrightedMusicDelegate.destroyEngine();

    _longPressRecognizer.dispose();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void loadJson() async {
    ZegoLog().addLog('start load json');
    ZegoLog().addLog('start load json');
    var jsonStr =
        await rootBundle.loadString('resources/json/CopyrightedMusic.json');
    var map = jsonDecode(jsonStr);
    for (var key in map.keys) {
      _templateJson[key.toString()] = map[key];
    }
    ZegoLog().addLog('load json finish. $_templateJson');
    ZegoLog().addLog('load json finish');
    setState(() {});
  }

  // zego call back
  void onRoomStateUpdate(String roomID, ZegoRoomState state, int errorCode,
      Map<String, dynamic> extendedData) {
    setState(() {
      _roomState = state;
    });
  }

  void onPublisherStateUpdate(String streamID, ZegoPublisherState state,
      int errorCode, Map<String, dynamic> extendedData) {
    setState(() {
      _publisherState = state;
    });
  }

  void onMediaPlayerPlayingProgress(int index, double pregress) {
    if (index == _mediaPlayerIndex) {
      _playProgressStreamController.sink.add(pregress);
    }
  }

  void onDownloadProgressUpdate(ZegoCopyrightedMusic copyrightedMusic,
      String resourceID, double progressRate) {
    setState(() {
      _downloadProgress = progressRate;
    });
  }

  void onCurrentPitchValueUpdate(ZegoCopyrightedMusic copyrightedMusic,
      String resourceID, int currentDuration, int pitchValue) {
    // setState(() {
    //   _pitch = pitchValue;
    // });
  }

  // widget
  void onSendExtendedRequestButtonTap() {
    _copyrightedMusicDelegate
        .sendExtendedRequest(_commondString, _templateController.text.trim())
        .then((value) {
      setState(() {
        _resultString = "SendExtendedRequest: \n $value";
      });
    });
  }

  void onRoomButtonTap() {
    if (_roomState == ZegoRoomState.Connecting) {
      return;
    }
    if (_roomState == ZegoRoomState.Disconnected) {
      _copyrightedMusicDelegate.loginRoom(_roomIDController.text.trim());
    } else {
      _copyrightedMusicDelegate.logoutRoom(_roomIDController.text.trim());
    }
  }

  void onStreamButtonTap() {
    if (_publisherState == ZegoPublisherState.PublishRequesting) {
      return;
    }
    if (_publisherState == ZegoPublisherState.NoPublish) {
      _copyrightedMusicDelegate
          .startPublishing(_streamIDController.text.trim());
    } else {
      _copyrightedMusicDelegate.stopPublishing();
    }
  }

  void onInitCopyrightedMusicButtonTap() {
    _copyrightedMusicDelegate.initCopyrightedMusic();
  }

  void onGetMusicByTokenButtonTap() {
    _copyrightedMusicDelegate
        .getMusicByToken(_musicTokenController.text.trim())
        .then((value) {
      setState(() {
        _resultString = "GetMusicByToken: \n $value";
      });
    });
  }

  void onGetKrcLyricByTokenButtonTap() {
    _copyrightedMusicDelegate
        .getKrcLyricByToken(_krcLyricTokenController.text.trim())
        .then((value) {
      setState(() {
        _resultString = "GetKrcLyricByToken: \n $value";
      });
    });
  }

  void onLoadResourceButtonTap() {
    int position = 0;
    if (_startPositionMediaPlayerController.text.isNotEmpty) {
      position = int.parse(_startPositionMediaPlayerController.text.trim());
    }
    _copyrightedMusicDelegate
        .loadResourceMediaPlayer(_sourceIDMediaPlayerController.text.trim(),
            position, _mediaPlayerIndex)
        .then((value) async {
      _audioTrackCount =
          await _copyrightedMusicDelegate.getAudioTrackCount(_mediaPlayerIndex);
      setState(() {});
    });
  }

  void onMediaPlayerProgressChanged(double progress) {
    _copyrightedMusicDelegate.seekToMediaPlayer(progress, _mediaPlayerIndex);
  }

  void onRequestSongButtonTap() {
    _copyrightedMusicDelegate
        .requestSong(_songIDController.text.trim(), _billingMode)
        .then((value) {
      setState(() {
        _resultString = "RequestSong: \n $value";
      });
    });
  }

  void onGetLrcLyricButtonTap() {
    _copyrightedMusicDelegate
        .getLrcLyric(_songIDController.text.trim())
        .then((value) {
      setState(() {
        _resultString = "GetLrcLyric: \n $value";
      });
    });
  }

  void onQueryCacheButtonTap() {
    _copyrightedMusicDelegate.queryCache(
        _songIDController.text.trim(), _musicType);
  }

  void onRequestAccompanimentButtonTap() {
    _copyrightedMusicDelegate
        .requestAccompaniment(_songIDController.text.trim(), _billingMode)
        .then((value) {
      setState(() {
        _resultString = "RequestAccompaniment: \n $value";
      });
    });
  }

  void onRequestAccompanimentClipButtonTap() {
    _copyrightedMusicDelegate
        .requestAccompanimentClip(_songIDController.text.trim(), _billingMode)
        .then((value) {
      setState(() {
        _resultString = "RequestAccompanimentClip: \n $value";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('版权音乐'),
      ),
      body: SafeArea(child: bodyWidget(context)),
    );
  }

  Widget bodyWidget(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: DefaultTextStyle(
                style: _defaultTextStyle,
                child: Container(
                  width: MediaQuery.of(context).size.width * 2,
                  height: MediaQuery.of(context).size.height,
                  child: Row(
                    children: [
                      Flexible(flex: 2, child: firstColumnWidget(context)),
                      Flexible(flex: 3, child: secondColumnWidget(context)),
                      Flexible(flex: 3, child: thirdColumnWidget(context)),
                    ],
                  ),
                ),
              )));
    }
    return Row(
      children: [
        Flexible(flex: 1, child: firstColumnWidget(context)),
        Flexible(flex: 1, child: secondColumnWidget(context)),
        Flexible(flex: 1, child: thirdColumnWidget(context)),
      ],
    );
  }

  // first column
  Widget firstColumnWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 5, right: 5),
      child: SingleChildScrollView(
        child: Column(
          children: [
            templateJsonWidget(context),
            Padding(padding: EdgeInsets.all(5)),
            templateWidget(context),
            Padding(padding: EdgeInsets.all(5)),
            resultWidget(context),
            Padding(padding: EdgeInsets.all(5)),
            initCopyrightedMusicAndSendExtendedRequestWidget(context)
          ],
        ),
      ),
    );
  }

  Widget templateJsonWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
        color: Colors.grey,
        width: 2,
      )),
      height: MediaQuery.of(context).size.height / 4,
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              var value = _templateJson.values.toList()[index];
              ZegoLog().addLog(jsonEncode(value));
              _commondString = _templateJson.keys.toList()[index];
              _templateController.text =
                  _copyrightedMusicDelegate.jsonStringFormat(jsonEncode(value));
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 3 - 10,
              child: Text('${_templateJson.keys.toList()[index]}'),
            ),
          );
        },
        itemCount: _templateJson.length,
      ),
    );
  }

  Widget templateWidget(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 4,
      child: Column(
        children: [
          Expanded(
              child: TextField(
                  style: _defaultTextStyle,
                  decoration: _inputDecoration,
                  controller: _templateController,
                  maxLines: null,
                  expands: true))
        ],
      ),
    );
  }

  Widget resultWidget(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Result:',
            style: TextStyle(color: Colors.black26, fontSize: 24),
          ),
          Expanded(
              child: Container(
                  width: Platform.isAndroid || Platform.isIOS
                      ? MediaQuery.of(context).size.width * 3 / 2 - 10
                      : MediaQuery.of(context).size.width / 3 - 10,
                  decoration: BoxDecoration(
                      border: Border.all(
                    color: Colors.grey,
                    width: 2,
                  )),
                  child: SelectableText(
                    _resultString,
                    style: TextStyle(color: Colors.black),
                  ))),
        ],
      ),
    );
  }

  Widget initCopyrightedMusicAndSendExtendedRequestWidget(
      BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: onInitCopyrightedMusicButtonTap,
          child: Text(
            'InitCopyrightedMusic',
            style: _buttonTextStyle,
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue)),
        ),
        TextButton(
          onPressed: onSendExtendedRequestButtonTap,
          child: Text(
            'SendExtendedRequest',
            style: _buttonTextStyle,
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue)),
        )
      ],
    );
  }

  // second column
  Widget secondColumnWidget(BuildContext context) {
    return Container(
        child: SingleChildScrollView(
            child: Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          roomWidget(context),
          Padding(padding: EdgeInsets.all(5)),
          streamWidget(context),
          Padding(padding: EdgeInsets.all(5)),
          getMusicByTokenWidget(),
          Padding(padding: EdgeInsets.all(5)),
          getKrcLyricByTokenWidget(),
          Padding(padding: EdgeInsets.all(5)),
          mediaPlayerInitWidget(context),
          Padding(padding: EdgeInsets.all(5)),
          audioTrackIndexWidget(),
          Padding(padding: EdgeInsets.all(5)),
          auxAndRepeatWidget(),
          Padding(padding: EdgeInsets.all(5)),
          mediaPlayerWidget(context),
          Padding(padding: EdgeInsets.all(5)),
          volumeWidget()
        ],
      ),
    )));
  }

  Widget roomWidget(BuildContext context) {
    return Row(
      children: [
        Text('RoomID: '),
        Expanded(
            child: TextField(
          style: _defaultTextStyle,
          decoration: _inputDecoration,
          controller: _roomIDController,
        )),
        Padding(padding: EdgeInsets.all(2)),
        TextButton(
          onPressed: onRoomButtonTap,
          child: Text(
            _roomState == ZegoRoomState.Connected
                ? 'Logout Room'
                : 'Login Room',
            style: _buttonTextStyle,
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue)),
        )
      ],
    );
  }

  Widget streamWidget(BuildContext context) {
    return Row(
      children: [
        Text('StreamID: '),
        Expanded(
            child: TextField(
          style: _defaultTextStyle,
          decoration: _inputDecoration,
          controller: _streamIDController,
        )),
        Padding(padding: EdgeInsets.all(2)),
        TextButton(
          onPressed: onStreamButtonTap,
          child: Text(
            _publisherState == ZegoPublisherState.Publishing
                ? 'Stop Publishing'
                : 'Start Publishing',
            style: _buttonTextStyle,
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue)),
        )
      ],
    );
  }

  Widget getMusicByTokenWidget() {
    return Row(
      children: [
        Expanded(
            child: TextField(
          style: _defaultTextStyle,
          decoration: InputDecoration(
              hintText: 'Input Token',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2),
              )),
          controller: _musicTokenController,
        )),
        Padding(padding: EdgeInsets.all(2)),
        TextButton(
          onPressed: onGetMusicByTokenButtonTap,
          child: Text(
            'GetMusicByToken',
            style: _buttonTextStyle,
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue)),
        )
      ],
    );
  }

  Widget getKrcLyricByTokenWidget() {
    return Row(
      children: [
        Expanded(
            child: TextField(
          style: _defaultTextStyle,
          decoration: InputDecoration(
              hintText: 'Input Token',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2),
              )),
          controller: _krcLyricTokenController,
        )),
        Padding(padding: EdgeInsets.all(2)),
        TextButton(
          onPressed: onGetKrcLyricByTokenButtonTap,
          child: Text(
            'GetKrcLyricByToken',
            style: _buttonTextStyle,
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue)),
        )
      ],
    );
  }

  Widget mediaPlayerInitWidget(BuildContext context) {
    final itemBuilder = (BuildContext context) {
      const List sourceIDs = [
        "z_65973657_1",
        "z_101846593_1",
        "z_101846593_2",
        "z_300785364_1",
        "z_300785364_2",
        "z_287915293_1",
        "z_287915293_2",
        "z_125282604_1",
        "z_125282604_2",
        "z_345222868_1",
        "z_345222868_2",
        "z_125282604_1_hq",
        "z_125282604_1_sq",
      ];
      return sourceIDs.map((sourceID) {
        return PopupMenuItem(
          value: '$sourceID',
          child: Text('$sourceID'),
        );
      }).toList();
    };
    return Row(
      children: [
        Expanded(
            child: Stack(
          children: [
            TextField(
              style: _defaultTextStyle,
              decoration: InputDecoration(
                  hintText: 'Source ID',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2),
                  )),
              controller: _sourceIDMediaPlayerController,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Container()),
                PopupMenuButton<String>(
                  itemBuilder: itemBuilder,
                  icon: Icon(
                    Icons.arrow_drop_down,
                  ),
                  onSelected: (value) {
                    setState(() {
                      _sourceIDMediaPlayerController.text = value;
                    });
                  },
                )
              ],
            )
          ],
        )),
        Padding(padding: EdgeInsets.all(2)),
        Expanded(
            child: TextField(
          style: _defaultTextStyle,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter(RegExp(r'[0-9]'), allow: true)
          ],
          decoration: InputDecoration(
              hintText: 'Position',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2),
              )),
          controller: _startPositionMediaPlayerController,
        )),
        Padding(padding: EdgeInsets.all(2)),
        DropdownButton<int>(
            items: [
              DropdownMenuItem<int>(
                child: Text("Player 0"),
                value: 0,
              ),
              DropdownMenuItem<int>(
                child: Text("Player 1"),
                value: 1,
              ),
              DropdownMenuItem<int>(
                child: Text("Player 2"),
                value: 2,
              ),
              DropdownMenuItem<int>(
                child: Text("Player 3"),
                value: 3,
              )
            ],
            value: _mediaPlayerIndex,
            onChanged: (index) {
              if (index != null) {
                setState(() {
                  _mediaPlayerIndex = index;
                });
              }
            }),
        Padding(padding: EdgeInsets.all(2)),
        TextButton(
          onPressed: onLoadResourceButtonTap,
          child: Text(
            'Load',
            style: _buttonTextStyle,
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue)),
        )
      ],
    );
  }

  Widget audioTrackIndexWidget() {
    var itemMaker = () {
      List<DropdownMenuItem<int>> list = [];
      for (var i = 0; i < _audioTrackCount; i++) {
        list.add(DropdownMenuItem<int>(
          child: Text('Track $i'),
          value: i,
        ));
      }
      return list;
    };
    return Row(
      children: [
        Expanded(child: Text('Audio Track Index: ')),
        Padding(padding: EdgeInsets.all(5)),
        DropdownButton<int>(
          items: itemMaker(),
          onChanged: (index) {
            if (index != null) {
              _copyrightedMusicDelegate.setAudioTrackIndexMediaPlayer(
                  index, _mediaPlayerIndex);
              setState(() {
                _audioTrackIndex = index;
              });
            }
          },
          value: _audioTrackIndex,
        )
      ],
    );
  }

  Widget auxAndRepeatWidget() {
    return Row(
      children: [
        Checkbox(
            value: _enableAux,
            onChanged: (enable) {
              if (enable != null) {
                _copyrightedMusicDelegate.enableAuxMediaPlayer(
                    enable, _mediaPlayerIndex);
                setState(() {
                  _enableAux = enable;
                });
              }
            }),
        Text('Enable Aux'),
        Expanded(child: Container()),
        Checkbox(
            value: _enableRepeat,
            onChanged: (enable) {
              if (enable != null) {
                _copyrightedMusicDelegate.repeatMediaPlayer(
                    enable, _mediaPlayerIndex);
                setState(() {
                  _enableRepeat = enable;
                });
              }
            }),
        Text('Repeat'),
      ],
    );
  }

  Widget mediaPlayerWidget(BuildContext context) {
    return
        //  Container(
        //     height: MediaQuery.of(context).size.height / 5,
        //     child:
        Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZegoSliderBar(
            progressStream: _playProgressStreamController.stream,
            onProgressChanged: onMediaPlayerProgressChanged),
        // Slider(value: _playProgress, onChanged: (double value) {}, onChangeEnd: onPlayerProgressChanged, onChangeStart: (value) => isSlider = true,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                _copyrightedMusicDelegate.startMediaPlayer(_mediaPlayerIndex);
              },
              child: Text("START", style: _buttonTextStyle),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                _copyrightedMusicDelegate.pauseMediaPlayer(_mediaPlayerIndex);
              },
              child: Text("PAUSE", style: _buttonTextStyle),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                _copyrightedMusicDelegate.resumeMediaPlayer(_mediaPlayerIndex);
              },
              child: Text("RESUME", style: _buttonTextStyle),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                _copyrightedMusicDelegate.stopMediaPlayer(_mediaPlayerIndex);
              },
              child: Text("STOP", style: _buttonTextStyle),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
            ),
          ],
        )
      ],
      // )
    );
  }

  Widget volumeWidget() {
    return Column(
      children: [
        Row(
          children: [
            Text('PublishVolume'),
            Expanded(
                child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter(RegExp(r'[0-9]'), allow: true)
              ],
              style: _defaultTextStyle,
              decoration: _inputDecoration,
              controller: _publishVolumeController,
            )),
            Padding(padding: EdgeInsets.all(2)),
            TextButton(
              onPressed: () {
                _copyrightedMusicDelegate.getPublishVolume(_mediaPlayerIndex);
              },
              child: Text("Get Volume", style: _buttonTextStyle),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
            ),
            Padding(padding: EdgeInsets.all(2)),
            TextButton(
              onPressed: () {
                if (_publishVolumeController.text.isNotEmpty) {
                  _copyrightedMusicDelegate.setPublishVolume(_mediaPlayerIndex,
                      int.parse(_publishVolumeController.text));
                }
              },
              child: Text("Set Volume", style: _buttonTextStyle),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
            )
          ],
        ),
        Padding(padding: EdgeInsets.all(5)),
        Row(
          children: [
            Text('PlaybackVolume'),
            Expanded(
                child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter(RegExp(r'[0-9]'), allow: true)
              ],
              style: _defaultTextStyle,
              decoration: _inputDecoration,
              controller: _playerVolumeController,
            )),
            Padding(padding: EdgeInsets.all(2)),
            TextButton(
              onPressed: () {
                _copyrightedMusicDelegate.getPlaybackVolume(_mediaPlayerIndex);
              },
              child: Text("Get Volume", style: _buttonTextStyle),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
            ),
            Padding(padding: EdgeInsets.all(2)),
            TextButton(
              onPressed: () {
                if (_playerVolumeController.text.isNotEmpty) {
                  _copyrightedMusicDelegate.setPlaybackVolume(_mediaPlayerIndex,
                      int.parse(_playerVolumeController.text));
                }
              },
              child: Text("Set Volume", style: _buttonTextStyle),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
            )
          ],
        )
      ],
    );
  }

  // third column
  Widget thirdColumnWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        right: 10,
      ),
      child: Column(
        children: [
          LogWidget(context),
          Expanded(child: thirdColumnContentWidget(context))
        ],
      ),
    );
  }

  Widget thirdColumnContentWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          songIDAboutWidget(context),
          Padding(padding: EdgeInsets.all(5)),
          resourceIDAboutWidget(context)
        ],
      ),
    );
  }

  Widget songIDAboutWidget(BuildContext context) {
    final itemBuilder = (BuildContext context) {
      const List songIDs = [
        "65973657",
        "101846593",
        "300785364",
        "287915293",
        "125282604",
        "345222868",
        "68431743",
        "245222868",
        "36365"
      ];
      return songIDs.map((songID) {
        return PopupMenuItem(
          value: '$songID',
          child: Text('$songID'),
        );
      }).toList();
    };
    return Card(
        child: Column(
      children: [
        Row(
          children: [
            Text('BillingMode: '),
            DropdownButton<ZegoCopyrightedMusicBillingMode>(
              items: [
                DropdownMenuItem<ZegoCopyrightedMusicBillingMode>(
                  child: Text('Count'),
                  value: ZegoCopyrightedMusicBillingMode.Count,
                ),
                DropdownMenuItem<ZegoCopyrightedMusicBillingMode>(
                  child: Text('Room'),
                  value: ZegoCopyrightedMusicBillingMode.Room,
                ),
                DropdownMenuItem<ZegoCopyrightedMusicBillingMode>(
                  child: Text('User'),
                  value: ZegoCopyrightedMusicBillingMode.User,
                ),
              ],
              value: _billingMode,
              onChanged: (ZegoCopyrightedMusicBillingMode? mode) {
                if (mode != null) {
                  setState(() {
                    _billingMode = mode;
                  });
                }
              },
            ),
            Padding(padding: EdgeInsets.all(10)),
            Text('Song ID: '),
            Expanded(
                child: Stack(
              children: [
                TextField(
                  style: _defaultTextStyle,
                  decoration: InputDecoration(
                      hintText: 'Song ID',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      )),
                  controller: _songIDController,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: Container()),
                    PopupMenuButton<String>(
                      itemBuilder: itemBuilder,
                      icon: Icon(
                        Icons.arrow_drop_down,
                      ),
                      onSelected: (value) {
                        setState(() {
                          _songIDController.text = value;
                        });
                      },
                    )
                  ],
                )
              ],
            )),
          ],
        ),
        Padding(padding: EdgeInsets.all(5)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: onRequestSongButtonTap,
              child: Text("RequestSong", style: _buttonTextStyle),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
            ),
            TextButton(
              onPressed: onGetLrcLyricButtonTap,
              child: Text("GetLrcLyric", style: _buttonTextStyle),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
            ),
            DropdownButton<ZegoCopyrightedMusicType>(
              items: [
                DropdownMenuItem<ZegoCopyrightedMusicType>(
                  value: ZegoCopyrightedMusicType.ZegoCopyrightedMusicSong,
                  child: Text('Song'),
                ),
                DropdownMenuItem<ZegoCopyrightedMusicType>(
                  value: ZegoCopyrightedMusicType.ZegoCopyrightedMusicSongHQ,
                  child: Text('SongHQ'),
                ),
                DropdownMenuItem<ZegoCopyrightedMusicType>(
                  value: ZegoCopyrightedMusicType.ZegoCopyrightedMusicSongSQ,
                  child: Text('SongSQ'),
                ),
                DropdownMenuItem<ZegoCopyrightedMusicType>(
                  value: ZegoCopyrightedMusicType
                      .ZegoCopyrightedMusicAccompaniment,
                  child: Text('Accompaniment'),
                ),
                DropdownMenuItem<ZegoCopyrightedMusicType>(
                  value: ZegoCopyrightedMusicType
                      .ZegoCopyrightedMusicAccompanimentClip,
                  child: Text('AccompanimentClip'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _musicType = value;
                  });
                }
              },
              value: _musicType,
            ),
            TextButton(
              onPressed: onQueryCacheButtonTap,
              child: Text("Query Cache", style: _buttonTextStyle),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
            ),
          ],
        ),
        Padding(padding: EdgeInsets.all(5)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: onRequestAccompanimentButtonTap,
              child: Text("RequestAccompaniment", style: _buttonTextStyle),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
            ),
            TextButton(
              onPressed: onRequestAccompanimentClipButtonTap,
              child: Text("RequestAccompanimentClip", style: _buttonTextStyle),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
            ),
          ],
        )
      ],
    ));
  }

  Widget resourceIDAboutWidget(BuildContext context) {
    return Column(
      children: [
        // getAverageScore、getPreviousScore、getTotalScore、pauseScore、resetScore、resumeScore、startScore、stopScore
        scoreWidget(),
        Padding(padding: EdgeInsets.all(5)),
        // clearCache、getCacheSize、getDuration
        cacheWidget(),
        Padding(padding: EdgeInsets.all(5)),
        // download
        downloadWidget(),
        Padding(padding: EdgeInsets.all(5)),
        // getCurrentPitch、getStandardPitch
        pitchWidget()
      ],
    );
  }

  Widget scoreWidget() {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Score: $_score'),
          TextButton(
            onPressed: () {
              _copyrightedMusicDelegate
                  .getTotalScore(_sourceIDMediaPlayerController.text.trim())
                  .then((value) {
                setState(() {
                  _score = value;
                });
              });
            },
            child: Text("GetTotalScore", style: _buttonTextStyle),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              _copyrightedMusicDelegate
                  .getPreviousScore(_sourceIDMediaPlayerController.text.trim())
                  .then((value) {
                setState(() {
                  _score = value;
                });
              });
            },
            child: Text("GetPreviousScore", style: _buttonTextStyle),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              _copyrightedMusicDelegate
                  .getAverageScore(_sourceIDMediaPlayerController.text.trim())
                  .then((value) {
                setState(() {
                  _score = value;
                });
              });
            },
            child: Text("GetAverageScore", style: _buttonTextStyle),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue)),
          )
        ],
      ),
      Padding(padding: EdgeInsets.all(5)),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              _copyrightedMusicDelegate
                  .startScore(_sourceIDMediaPlayerController.text.trim())
                  .then((value) {
                setState(() {
                  _score = value;
                });
              });
            },
            child: Text("StartScore", style: _buttonTextStyle),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              _copyrightedMusicDelegate
                  .stopScore(_sourceIDMediaPlayerController.text.trim())
                  .then((value) {
                setState(() {
                  _score = value;
                });
              });
            },
            child: Text("StopScore", style: _buttonTextStyle),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              _copyrightedMusicDelegate
                  .pauseScore(_sourceIDMediaPlayerController.text.trim())
                  .then((value) {
                setState(() {
                  _score = value;
                });
              });
            },
            child: Text("PauseScore", style: _buttonTextStyle),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              _copyrightedMusicDelegate
                  .resumeScore(_sourceIDMediaPlayerController.text.trim())
                  .then((value) {
                setState(() {
                  _score = value;
                });
              });
            },
            child: Text("ResumeScore", style: _buttonTextStyle),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              _copyrightedMusicDelegate
                  .resetScore(_sourceIDMediaPlayerController.text.trim())
                  .then((value) {
                setState(() {
                  _score = value;
                });
              });
            },
            child: Text("ResetScore", style: _buttonTextStyle),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue)),
          )
        ],
      )
    ]);
  }

  Widget cacheWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Cache: $_cache'),
        TextButton(
          onPressed: () {
            _copyrightedMusicDelegate.getCacheSize().then((value) {
              setState(() {
                _cache = value;
              });
            });
          },
          child: Text("GetCacheSize", style: _buttonTextStyle),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue)),
        ),
        TextButton(
          onPressed: () {
            _copyrightedMusicDelegate.clearCache();
            setState(() {
              _score = 0;
            });
          },
          child: Text("ClearCache", style: _buttonTextStyle),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue)),
        ),
        TextButton(
          onPressed: () {
            _copyrightedMusicDelegate
                .getDuration(_sourceIDMediaPlayerController.text.trim());
          },
          child: Text("GetDuration", style: _buttonTextStyle),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue)),
        ),
      ],
    );
  }

  Widget downloadWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: LinearProgressIndicator(
          minHeight: 12,
          backgroundColor: Colors.grey,
          color: Colors.blue[200],
          value: _downloadProgress,
        )),
        Padding(padding: EdgeInsets.all(5)),
        TextButton(
          onPressed: () {
            setState(() {
              _downloadProgress = 0;
            });
            _copyrightedMusicDelegate
                .download(_sourceIDMediaPlayerController.text.trim());
          },
          child: Text("Download", style: _buttonTextStyle),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue)),
        ),
      ],
    );
  }

  Widget pitchWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('pitch: $_pitch'),
        TextButton(
          onPressed: () {
            _copyrightedMusicDelegate
                .getCurrentPitch(_sourceIDMediaPlayerController.text.trim())
                .then((value) {
              setState(() {
                _pitch = value;
              });
            });
          },
          child: Text("GetCurrentPitch", style: _buttonTextStyle),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue)),
        ),
        TextButton(
          onPressed: () {
            _copyrightedMusicDelegate
                .getStandardPitch(_sourceIDMediaPlayerController.text.trim())
                .then((value) {
              setState(() {
                _pitch = value;
              });
            });
          },
          child: Text("GetStandardPitch", style: _buttonTextStyle),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue)),
        ),
      ],
    );
  }

  Widget LogWidget(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      child: ZegoLogView(),
    );
  }
}
