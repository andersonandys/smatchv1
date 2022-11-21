import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

import 'package:zego_express_engine/zego_express_engine.dart';

import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew//utils/zego_log_view.dart';
import 'package:smatch/callnew//utils/zego_utils.dart';

class PlayStreamPage extends StatefulWidget {
  final int screenWidthPx;
  final int screenHeightPx;
  final String roomID;

  PlayStreamPage(this.screenWidthPx, this.screenHeightPx, this.roomID);

  @override
  _PlayStreamPageState createState() => new _PlayStreamPageState();
}

class _PlayStreamPageState extends State<PlayStreamPage> {
  String _title = 'PlayStream';
  bool _isPlaying = false;

  int _playViewID = -1;
  Widget? _playViewWidget;
  late ZegoCanvas _playCanvas;

  int _playWidth = 0;
  int _playHeight = 0;
  double _playVideoFPS = 0.0;
  double _playAudioFPS = 0.0;
  double _playVideoBitrate = 0.0;
  double _playAudioBitrate = 0.0;
  double _totalRecvBytes = 0;
  int _rtt = 0;
  int _peerToPeerDelay = 0;
  int _delay = 0;
  int _avTimestampDiff = 0;
  bool _isHardwareDecode = false;
  String _videoCodecID = '';
  String _networkQuality = '';

  String? _appDocumentsPath;

  bool _isUseSpeaker = true;

  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();

    setPlayerCallback();

    if (Platform.isAndroid) {
      getExternalStorageDirectories(type: StorageDirectory.pictures)
          .then((dir) => _appDocumentsPath = dir?.first.path);
    } else if (!kIsWeb) {
      getApplicationDocumentsDirectory()
          .then((dir) => _appDocumentsPath = dir.path);
    }
  }

  void setPlayerCallback() {
    // Set the player state callback
    ZegoExpressEngine.onPlayerStateUpdate = (String streamID,
        ZegoPlayerState state,
        int errorCode,
        Map<String, dynamic> extendedData) {
      if (errorCode == 0) {
        setState(() {
          _isPlaying = true;
          _title = 'Playing';
        });
      } else {
        ZegoLog().addLog('Play error: $errorCode');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('拉流失败, errorCode: $errorCode')));
      }
    };

    // Set the player quality callback
    ZegoExpressEngine.onPlayerQualityUpdate =
        (String streamID, ZegoPlayStreamQuality quality) {
      setState(() {
        _playVideoFPS = quality.videoRecvFPS;
        _playAudioFPS = quality.audioRecvFPS;
        _playVideoBitrate = quality.videoKBPS;
        _playAudioBitrate = quality.audioKBPS;
        _totalRecvBytes = quality.totalRecvBytes;
        _rtt = quality.rtt;
        _peerToPeerDelay = quality.peerToPeerDelay;
        _delay = quality.delay;
        _avTimestampDiff = quality.avTimestampDiff;
        _isHardwareDecode = quality.isHardwareDecode;
        _videoCodecID = quality.videoCodecID.toString();

        switch (quality.level) {
          case ZegoStreamQualityLevel.Excellent:
            _networkQuality = '☀️';
            break;
          case ZegoStreamQualityLevel.Good:
            _networkQuality = '⛅️️';
            break;
          case ZegoStreamQualityLevel.Medium:
            _networkQuality = '☁️';
            break;
          case ZegoStreamQualityLevel.Bad:
            _networkQuality = '🌧';
            break;
          case ZegoStreamQualityLevel.Die:
            _networkQuality = '❌';
            break;
          default:
            break;
        }
      });
    };

    // Set the player video size changed callback
    ZegoExpressEngine.onPlayerVideoSizeChanged =
        (String streamID, int width, int height) {
      setState(() {
        _playWidth = width;
        _playHeight = height;
      });
    };

    ZegoExpressEngine.onPlayerRecvVideoFirstFrame = (String streamID) {
      ZegoLog().addLog('🚩 [onPlayerRecvVideoFirstFrame] streamID: $streamID');
    };

    ZegoExpressEngine.onPlayerRenderVideoFirstFrame = (String streamID) {
      ZegoLog()
          .addLog('🚩 [onPlayerRenderVideoFirstFrame] streamID: $streamID');
    };

    ZegoExpressEngine.onPlayerRecvSEI = (String streamID, Uint8List data) {
      ZegoLog().addLog(
          '🚩 [onPlayerRecvSEI] streamID: $streamID, data length: ${data.length}');
    };

    ZegoExpressEngine.onPlayerMediaEvent =
        (String streamID, ZegoPlayerMediaEvent event) {
      ZegoLog()
          .addLog('🚩 [onPlayerMediaEvent] streamID: $streamID, event: $event');
    };
  }

  @override
  void dispose() {
    super.dispose();

    if (_isPlaying) {
      // Stop playing
      ZegoExpressEngine.instance.stopPlayingStream(_controller.text.trim());
    }

    // Unregister player callback
    ZegoExpressEngine.onPlayerStateUpdate = null;
    ZegoExpressEngine.onPlayerQualityUpdate = null;
    ZegoExpressEngine.onPlayerVideoSizeChanged = null;
    ZegoExpressEngine.onPlayerRecvVideoFirstFrame = null;
    ZegoExpressEngine.onPlayerRenderVideoFirstFrame = null;
    ZegoExpressEngine.onPlayerRecvSEI = null;
    ZegoExpressEngine.onPlayerMediaEvent = null;

    if (_playViewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_playViewID);
      _playViewID = -1;
    }

    // Logout room
    ZegoExpressEngine.instance.logoutRoom(widget.roomID);
  }

  void onPlayButtonPressed() async {
    String streamID = _controller.text.trim();

    if (_playViewID == -1) {
      _playViewWidget =
          await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _playViewID = viewID;
        startPlayingStream(_playViewID, streamID);
      });
      setState(() {});
    } else {
      startPlayingStream(_playViewID, streamID);
    }
  }

  void startPlayingStream(int viewID, String streamID) {
    setState(() {
      // Set the play canvas
      _playCanvas = ZegoCanvas.view(viewID);

      // Start playing stream
      ZegoExpressEngine.instance
          .startPlayingStream(streamID, canvas: _playCanvas);
    });
  }

  void onSpeakerStateChanged() {
    setState(() {
      _isUseSpeaker = !_isUseSpeaker;
      ZegoExpressEngine.instance.muteSpeaker(!_isUseSpeaker);
    });
  }

  void onSnapshotButtonClicked() {
    ZegoExpressEngine.instance
        .takePlayStreamSnapshot(_controller.text.trim())
        .then((result) {
      ZegoLog().addLog(
          '[takePublishStreamSnapshot], errorCode: ${result.errorCode}, is null image?: ${result.image != null ? "false" : "true"}');
      String path = _appDocumentsPath != null
          ? _appDocumentsPath! + '/' + 'tmp_snapshot_${DateTime.now()}.png'
          : '';
      ZegoUtils.showImage(context, result.image, path: path);
    });
  }

  Widget prepareToolWidget() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
            ),
            Row(
              children: <Widget>[Text('StreamID: ')],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                      left: 10.0, top: 12.0, bottom: 12.0),
                  hintText: 'Please enter streamID',
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff0e88eb)))),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
            ),
            Text(
              'StreamID must be globally unique and the length should not exceed 255 bytes',
              style: TextStyle(fontSize: 12.0, color: Colors.black45),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
            ),
            Container(
              padding: const EdgeInsets.all(0.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Color(0xee0e88eb),
              ),
              width: 240.0,
              height: 60.0,
              child: CupertinoButton(
                child: Text('Start Playing',
                    style: TextStyle(color: Colors.white)),
                onPressed: onPlayButtonPressed,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget playingToolWidget() {
    return Container(
      padding: EdgeInsets.only(
          left: 10.0,
          right: 10.0,
          bottom: MediaQuery.of(context).padding.bottom + 20.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
          ),
          Row(
            children: <Widget>[
              Text(
                'RoomID: ${widget.roomID}',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                'StreamID: ${_controller.text.trim()}',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                'Rendering with: ${ZegoConfig.instance.enablePlatformView ? 'PlatformView' : 'TextureRenderer'}',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                'Resolution: $_playWidth x $_playHeight',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                'VideoRecvFPS: ${_playVideoFPS.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                'AudioRecvFPS: ${_playAudioFPS.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                'VideoBitrate: ${_playVideoBitrate.toStringAsFixed(2)} kb/s',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                'AudioBitrate: ${_playAudioBitrate.toStringAsFixed(2)} kb/s',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                'TotalRecvBytes: ${(_totalRecvBytes / 1024 / 1024).toStringAsFixed(2)} MB',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                'RTT: $_rtt ms',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                'P2P Delay: $_peerToPeerDelay ms',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                'Delay: $_delay ms',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                'avTimestampDiff: $_avTimestampDiff ms',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          Row(children: <Widget>[
            Text(
              'VideoCodecID: $_videoCodecID',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ]),
          Row(
            children: <Widget>[
              Text(
                'HardwareDecode: ${_isHardwareDecode ? '✅' : '❎'}',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                'NetworkQuality: $_networkQuality',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          Expanded(child: SizedBox()),
          Row(
            children: <Widget>[
              Offstage(
                  offstage: kIsWeb,
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(0.0),
                    pressedOpacity: 1.0,
                    borderRadius: BorderRadius.circular(0.0),
                    child: Icon(
                        _isUseSpeaker ? Icons.volume_up : Icons.volume_off,
                        size: 44.0,
                        color: Colors.white),
                    onPressed: onSpeakerStateChanged,
                  )),
              SizedBox(width: 10.0),
              Offstage(
                offstage: kIsWeb,
                child: CupertinoButton(
                  padding: const EdgeInsets.all(0.0),
                  pressedOpacity: 1.0,
                  borderRadius: BorderRadius.circular(0.0),
                  child: Icon(Icons.camera, size: 44.0, color: Colors.white),
                  onPressed: onSnapshotButtonClicked,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text(_title)),
        body: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              child: _playViewWidget,
            ),
            _isPlaying ? playingToolWidget() : prepareToolWidget(),
          ],
        ));
  }
}
