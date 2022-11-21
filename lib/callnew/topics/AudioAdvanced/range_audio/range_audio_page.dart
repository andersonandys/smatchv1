import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew/utils/zego_log_view.dart';
import 'package:smatch/callnew/utils/zego_user_helper.dart';

class RangeAudioWidget extends StatefulWidget {
  const RangeAudioWidget({Key? key}) : super(key: key);

  @override
  State<RangeAudioWidget> createState() => _RangeAudioWidgetState();
}

class _RangeAudioWidgetState extends State<RangeAudioWidget> {
  late String _roomID;
  late ZegoRoomState _roomState;
  late TextEditingController _roomIDController;
  late TextEditingController _userIDController;

  late ZegoRangeAudioMode _rangeAudioMode;
  late TextEditingController _teamIDController;

  late bool _enableMic;
  late bool _enableSpeaker;
  late TextEditingController _receiveRangeController;

  late bool _enable3DSoundEffects;

  late bool _muteUser;
  late TextEditingController _muteUserController;

  late Map<String, List<double>> _userPositions;

  late List<double> _selfPosition;
  late List<double> _rotateAngles;
  late List<double> _matrixRotateFront;
  late List<double> _matrixRotateRight;
  late List<double> _matrixRotateUp;

  late ZegoDelegate _zegoDelegate;

  @override
  void initState() {
    super.initState();

    _zegoDelegate = ZegoDelegate();

    _roomState = ZegoRoomState.Disconnected;
    _roomIDController = TextEditingController();
    _roomIDController.text = 'range_audio';
    _roomID = 'range_audio';
    _userIDController = TextEditingController();
    _userIDController.text = ZegoUserHelper.instance.userID;

    _rangeAudioMode = ZegoRangeAudioMode.World;
    _teamIDController = TextEditingController();

    _enableMic = false;
    _enableSpeaker = false;
    _receiveRangeController = TextEditingController();
    _receiveRangeController.text = '100';

    _enable3DSoundEffects = false;

    _userPositions = {};

    _selfPosition = [0.0, 0.0, 0.0];

    _rotateAngles = [0.0, 0.0, 0.0];
    _matrixRotateFront = [0.0, 0.0, 0.0];
    _matrixRotateRight = [0.0, 0.0, 0.0];
    _matrixRotateUp = [0.0, 0.0, 0.0];

    _zegoDelegate.eulerAnglesToRotationMatrix(
        _rotateAngles, _matrixRotateFront, _matrixRotateRight, _matrixRotateUp);

    _muteUser = false;
    _muteUserController = TextEditingController();

    _zegoDelegate.setZegoEventCallback(
        onRoomStateUpdate: onRoomStateUpdate,
        onIMRecvBroadcastMessage: onIMRecvBroadcastMessage,
        onRoomUserUpdate: onRoomUserUpdate);
    _zegoDelegate.createEngine().then((value) {
      _zegoDelegate.createRangeAudio();
    });
  }

  @override
  void dispose() {
    _zegoDelegate.clearZegoEventCallback();
    _zegoDelegate.dispose();

    _zegoDelegate.destoryRangeAudio();
    if (_roomState != ZegoRoomState.Disconnected) {
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
    setState(() {
      _roomID = roomID;
      _roomState = state;
    });
  }

  void onIMRecvBroadcastMessage(
      String roomID, List<ZegoBroadcastMessageInfo> messageList) {
    for (ZegoBroadcastMessageInfo messageInfo in messageList) {
      List<String> list = messageInfo.message.split(",");
      Float32List position = Float32List.fromList([
        double.parse(list[0]),
        double.parse(list[1]),
        double.parse(list[2])
      ]);
      for (var userID in _userPositions.keys) {
        if (messageInfo.fromUser.userID == userID) {
          _userPositions[userID] = position.toList();
        }
      }
      // Update other audio position
      _zegoDelegate.updateAudioSource(messageInfo.fromUser.userID, position);
    }
    setState(() {});
  }

  void onRoomUserUpdate(
      String roomID, ZegoUpdateType updateType, List<ZegoUser> userList) {
    if (updateType == ZegoUpdateType.Add) {
      for (ZegoUser user in userList) {
        _userPositions[user.userID] = [0.0, 0.0, 0.0];
      }
      var message =
          '${_selfPosition[0]},${_selfPosition[1]},${_selfPosition[2]}';
      /** 发送房间广播信令
                     * ❗️❗️❗️房间信令属于低频信息，此方法只为演示Demo使用，开发者需自己使用服务器维护位置信息
                     *  Send room broadcast message
                     * ❗️❗️❗️Room message is low-frequency information. This method is only for testing. Developers need to maintain position information by themselves
                     */
      Timer(Duration(milliseconds: 500), () async {
        var result = await _zegoDelegate.sendBroadcastMessage(_roomID, message);
        ZegoLog().addLog(
            "Send broadcast message result errorCode: ${result.errorCode}, messageID: ${result.messageID}");
      });
    } else {
      for (ZegoUser user in userList) {
        _userPositions.remove(user.userID);
      }
    }

    ZegoLog().addLog(_userPositions.toString());
    setState(() {});
  }

  // widget callback
  void onLoginRoomBtnPress() {
    if (_roomState != ZegoRoomState.Disconnected) {
      _zegoDelegate.logoutRoom(_roomID);
    } else {
      _zegoDelegate
          .loginRoom(
              _roomIDController.text.trim(), _userIDController.text.trim())
          .then((value) {
        _zegoDelegate.updateSelfPosition(
            Float32List.fromList(_selfPosition),
            Float32List.fromList(_matrixRotateFront),
            Float32List.fromList(_matrixRotateRight),
            Float32List.fromList(_matrixRotateUp));
      });
    }
  }

  void onRangeAudioModeChanged(ZegoRangeAudioMode? mode) {
    if (mode != null) {
      _rangeAudioMode = mode;
      _zegoDelegate.setRangeAudioMode(mode);
      setState(() {});
    }
  }

  void onTeamIDEditComplete() {
    _zegoDelegate.setTeamID(_teamIDController.text.trim());
  }

  void onMicSwitchChanged(bool enable) {
    _enableMic = enable;
    _zegoDelegate.enableMicrophone(enable);
    setState(() {});
  }

  void onSpeakerSwitchChanged(bool enable) {
    _enableSpeaker = enable;
    _zegoDelegate.enableSpeaker(enable);
    setState(() {});
  }

  void onReceiveRangeEditComplete() {
    var range = double.tryParse(_receiveRangeController.text);
    if (range != null) {
      _zegoDelegate.setAudioReceiveRange(range);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('请输入数字')));
    }
  }

  void on3DSoundEffectsSwitchChanged(bool enable) {
    _enable3DSoundEffects = enable;
    _zegoDelegate.enableSpatializer(enable);
    setState(() {});
  }

  void onFrontPositionChanged(double value, [bool isEnd = false]) {
    _selfPosition[0] = value;
    if (isEnd) {
      _zegoDelegate.updateSelfPosition(
          Float32List.fromList(_selfPosition),
          Float32List.fromList(_matrixRotateFront),
          Float32List.fromList(_matrixRotateRight),
          Float32List.fromList(_matrixRotateUp));

      var message =
          '${_selfPosition[0].toInt()},${_selfPosition[1].toInt()},${_selfPosition[2].toInt()}';
      /** 发送房间广播信令
                 * ❗️❗️❗️房间信令属于低频信息，此方法只为演示Demo使用，开发者需自己使用服务器维护位置信息
                 *  Send room broadcast message
                 * ❗️❗️❗️Room message is low-frequency information. This method is only for testing. Developers need to maintain position information by themselves
                 */
      _zegoDelegate.sendBroadcastMessage(_roomID, message).then((result) {
        ZegoLog().addLog(
            'Send BroadcastMessage:${result.errorCode == 0 ? "Success" : "Failed"}');
      });
      ZegoLog().addLog(
          "Update self position:${_selfPosition[0]},${_selfPosition[1]},${_selfPosition[2]}");
    }

    setState(() {});
  }

  void onRightPositionChanged(double value, [bool isEnd = false]) {
    _selfPosition[1] = value;
    if (isEnd) {
      _zegoDelegate.updateSelfPosition(
          Float32List.fromList(_selfPosition),
          Float32List.fromList(_matrixRotateFront),
          Float32List.fromList(_matrixRotateRight),
          Float32List.fromList(_matrixRotateUp));

      var message =
          '${_selfPosition[0].toInt()},${_selfPosition[1].toInt()},${_selfPosition[2].toInt()}';
      /** 发送房间广播信令
                 * ❗️❗️❗️房间信令属于低频信息，此方法只为演示Demo使用，开发者需自己使用服务器维护位置信息
                 *  Send room broadcast message
                 * ❗️❗️❗️Room message is low-frequency information. This method is only for testing. Developers need to maintain position information by themselves
                 */
      _zegoDelegate.sendBroadcastMessage(_roomID, message).then((result) {
        ZegoLog().addLog(
            'Send BroadcastMessage:${result.errorCode == 0 ? "Success" : "Failed"}');
      });
      ZegoLog().addLog(
          "Update self position:${_selfPosition[0]},${_selfPosition[1]},${_selfPosition[2]}");
    }

    setState(() {});
  }

  void onUpPositionChanged(double value, [bool isEnd = false]) {
    _selfPosition[2] = value;
    if (isEnd) {
      _zegoDelegate.updateSelfPosition(
          Float32List.fromList(_selfPosition),
          Float32List.fromList(_matrixRotateFront),
          Float32List.fromList(_matrixRotateRight),
          Float32List.fromList(_matrixRotateUp));

      var message =
          '${_selfPosition[0].toInt()},${_selfPosition[1].toInt()},${_selfPosition[2].toInt()}';
      /** 发送房间广播信令
                 * ❗️❗️❗️房间信令属于低频信息，此方法只为演示Demo使用，开发者需自己使用服务器维护位置信息
                 *  Send room broadcast message
                 * ❗️❗️❗️Room message is low-frequency information. This method is only for testing. Developers need to maintain position information by themselves
                 */
      _zegoDelegate.sendBroadcastMessage(_roomID, message).then((result) {
        ZegoLog().addLog(
            'Send BroadcastMessage:${result.errorCode == 0 ? "Success" : "Failed"}');
      });
      ZegoLog().addLog(
          "Update self position:${_selfPosition[0]},${_selfPosition[1]},${_selfPosition[2]}");
    }

    setState(() {});
  }

  void onFrontRotateChanged(double value, [bool isEnd = false]) {
    _rotateAngles[0] = value;
    if (isEnd) {
      _zegoDelegate.eulerAnglesToRotationMatrix(_rotateAngles,
          _matrixRotateFront, _matrixRotateRight, _matrixRotateUp);
      _zegoDelegate.updateSelfPosition(
          Float32List.fromList(_selfPosition),
          Float32List.fromList(_matrixRotateFront),
          Float32List.fromList(_matrixRotateRight),
          Float32List.fromList(_matrixRotateUp));
      ZegoLog().addLog("Update front rotate:$value");
    }

    setState(() {});
  }

  void onRightRotateChanged(double value, [bool isEnd = false]) {
    _rotateAngles[1] = value;
    if (isEnd) {
      _zegoDelegate.eulerAnglesToRotationMatrix(_rotateAngles,
          _matrixRotateFront, _matrixRotateRight, _matrixRotateUp);
      _zegoDelegate.updateSelfPosition(
          Float32List.fromList(_selfPosition),
          Float32List.fromList(_matrixRotateFront),
          Float32List.fromList(_matrixRotateRight),
          Float32List.fromList(_matrixRotateUp));
      ZegoLog().addLog("Update right rotate:$value");
    }

    setState(() {});
  }

  void onUpRotateChanged(double value, [bool isEnd = false]) {
    _rotateAngles[2] = value;
    if (isEnd) {
      _zegoDelegate.eulerAnglesToRotationMatrix(_rotateAngles,
          _matrixRotateFront, _matrixRotateRight, _matrixRotateUp);
      _zegoDelegate.updateSelfPosition(
          Float32List.fromList(_selfPosition),
          Float32List.fromList(_matrixRotateFront),
          Float32List.fromList(_matrixRotateRight),
          Float32List.fromList(_matrixRotateUp));
      ZegoLog().addLog("Update up rotate:$value");
    }

    setState(() {});
  }

  void onMuteUserSwitchChanged(bool enable) {
    _muteUser = enable;
    for (var element in _muteUserController.text.split(';')) {
      _zegoDelegate.muteUser(element, enable);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('范围语音'),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: mainContent(context),
      )),
    );
  }

  Widget mainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          child: ZegoLogView(),
          height: MediaQuery.of(context).size.height * 0.1,
        ),
        roomInfoWidget(),
        roomAboutWidget(),
        teamAudioWidget(),
        rangeAudioWidget(),
        soundEffects3DWidget(),
        locationInformationWidget(),
        muteUserWidget(),
        userPositionWidget()
      ],
    );
  }

  Widget roomInfoWidget() {
    return Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("RoomID: $_roomID"),
          Text('RoomState: ${_zegoDelegate.roomStateDesc(_roomState)}'),
        ]));
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

  Widget teamAudioWidget() {
    return Column(
      children: [
        Container(
          color: Colors.grey[300],
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topLeft,
          child: Container(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
              child: Text(
                'Team Audio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              )),
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text('Range audio mode')),
                  DropdownButton<ZegoRangeAudioMode>(
                    items: [
                      DropdownMenuItem(
                        child: Text(ZegoRangeAudioMode.World.name),
                        value: ZegoRangeAudioMode.World,
                      ),
                      DropdownMenuItem(
                        child: Text(ZegoRangeAudioMode.Team.name),
                        value: ZegoRangeAudioMode.Team,
                      ),
                      DropdownMenuItem(
                        child: Text(ZegoRangeAudioMode.SecretTeam.name),
                        value: ZegoRangeAudioMode.SecretTeam,
                      )
                    ],
                    onChanged: onRangeAudioModeChanged,
                    value: _rangeAudioMode,
                  )
                ],
              ),
              Row(
                children: [
                  Text('Team ID '),
                  Expanded(
                      child: TextField(
                    controller: _teamIDController,
                    onEditingComplete: onTeamIDEditComplete,
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
              )
            ],
          ),
        )
      ],
    );
  }

  Widget rangeAudioWidget() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          color: Colors.grey[300],
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topLeft,
          child: Container(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
              child: Text(
                'Range Audio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              )),
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text('Enable microphone')),
                  Switch(value: _enableMic, onChanged: onMicSwitchChanged)
                ],
              ),
              Row(
                children: [
                  Expanded(child: Text('Enable speaker')),
                  Switch(
                      value: _enableSpeaker, onChanged: onSpeakerSwitchChanged)
                ],
              ),
              Row(
                children: [
                  Text('Receive range '),
                  Expanded(
                      child: TextField(
                    controller: _receiveRangeController,
                    style: TextStyle(fontSize: 11),
                    onEditingComplete: onReceiveRangeEditComplete,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10.0),
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff0e88eb)))),
                  ))
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget soundEffects3DWidget() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          color: Colors.grey[300],
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topLeft,
          child: Container(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
              child: Text(
                '3D sound effects',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              )),
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Row(
            children: [
              Expanded(child: Text('3D sound effects')),
              Switch(
                  value: _enable3DSoundEffects,
                  onChanged: on3DSoundEffectsSwitchChanged)
            ],
          ),
        )
      ],
    );
  }

  Widget locationInformationWidget() {
    return Column(
      children: [
        Container(
          color: Colors.grey[300],
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topLeft,
          child: Container(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
              child: Text(
                'Location Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              )),
        ),
        Column(
          children: [
            Container(
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.topLeft,
              child: Container(
                  padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                  child: Text(
                    'Position',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  )),
            ),
            Container(
                padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Column(children: [
                  Row(
                    children: [
                      Text('front[-100,100]   '),
                      Expanded(
                          child: Slider(
                              value: _selfPosition[0],
                              max: 100.0,
                              min: -100.0,
                              onChangeEnd: (value) =>
                                  onFrontPositionChanged(value, true),
                              onChanged: onFrontPositionChanged)),
                      Text('   ${_selfPosition[0].toInt()}')
                    ],
                  ),
                  Row(
                    children: [
                      Text('right[-100,100]   '),
                      Expanded(
                          child: Slider(
                              value: _selfPosition[1],
                              max: 100.0,
                              min: -100.0,
                              onChangeEnd: (value) =>
                                  onRightPositionChanged(value, true),
                              onChanged: onRightPositionChanged)),
                      Text('   ${_selfPosition[1].toInt()}')
                    ],
                  ),
                  Row(
                    children: [
                      Text('up[-100,100]   '),
                      Expanded(
                          child: Slider(
                              value: _selfPosition[2],
                              max: 100.0,
                              min: -100.0,
                              onChangeEnd: (value) =>
                                  onUpPositionChanged(value, true),
                              onChanged: onUpPositionChanged)),
                      Text('   ${_selfPosition[2].toInt()}')
                    ],
                  ),
                ]))
          ],
        ),
        Column(
          children: [
            Container(
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.topLeft,
              child: Container(
                  padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                  child: Text(
                    'Direction',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  )),
            ),
            Container(
                padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Column(children: [
                  Row(
                    children: [
                      Text('front rotate[-180,180]   '),
                      Expanded(
                          child: Slider(
                              value: _rotateAngles[0],
                              max: 180.0,
                              min: -180.0,
                              onChangeEnd: (value) =>
                                  onFrontRotateChanged(value, true),
                              onChanged: onFrontRotateChanged)),
                      Text('   ${_rotateAngles[0].toInt()}')
                    ],
                  ),
                  Row(
                    children: [
                      Text('right rotate[-180,180]   '),
                      Expanded(
                          child: Slider(
                              value: _rotateAngles[1],
                              max: 180.0,
                              min: -180.0,
                              onChangeEnd: (value) =>
                                  onRightRotateChanged(value, true),
                              onChanged: onRightRotateChanged)),
                      Text('   ${_rotateAngles[1].toInt()}')
                    ],
                  ),
                  Row(
                    children: [
                      Text('up rotate[-180,180]   '),
                      Expanded(
                          child: Slider(
                              value: _rotateAngles[2],
                              max: 180.0,
                              min: -180.0,
                              onChangeEnd: (value) =>
                                  onUpRotateChanged(value, true),
                              onChanged: onUpRotateChanged)),
                      Text('   ${_rotateAngles[2].toInt()}')
                    ],
                  ),
                ]))
          ],
        ),
      ],
    );
  }

  Widget muteUserWidget() {
    return Column(
      children: [
        Container(
          color: Colors.grey[300],
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topLeft,
          child: Container(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
              child: Text(
                'Mute User',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              )),
        ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Row(
            children: [
              Switch(value: _muteUser, onChanged: onMuteUserSwitchChanged),
              Expanded(
                  child: TextField(
                controller: _muteUserController,
                style: TextStyle(fontSize: 11),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10.0),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff0e88eb)))),
              )),
            ],
          ),
        )
      ],
    );
  }

  Widget userPositionWidget() {
    return Column(
      children: [
        Container(
          color: Colors.grey[300],
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topLeft,
          child: Container(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
              child: Text(
                'User Position',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              )),
        ),
        Padding(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Column(
              children: _userPositions.keys.map<Widget>((userID) {
                return Text(
                    'UserID: $userID ,   Position: ${_userPositions[userID]?[0]},${_userPositions[userID]?[1]},${_userPositions[userID]?[2]}',
                    maxLines: 2);
              }).toList(),
            ))
      ],
    );
  }
}

typedef RoomStateUpdateCallback = void Function(
    String, ZegoRoomState, int, Map<String, dynamic>);
typedef IMRecvBroadcastMessageCallback = void Function(
    String, List<ZegoBroadcastMessageInfo>);
typedef RoomUserUpdateCallback = void Function(
    String, ZegoUpdateType, List<ZegoUser>);

class ZegoDelegate {
  RoomStateUpdateCallback? _onRoomStateUpdate;
  IMRecvBroadcastMessageCallback? _onIMRecvBroadcastMessage;
  RoomUserUpdateCallback? _onRoomUserUpdate;

  ZegoRangeAudio? _rangeAudio;

  dispose() {}

  void _initCallback() {
    ZegoExpressEngine.onRoomStateUpdate = (String roomID, ZegoRoomState state,
        int errorCode, Map<String, dynamic> extendedData) {
      ZegoLog().addLog(
          '🚩 🚪 Room state update, state: $state, errorCode: $errorCode, roomID: $roomID');
      _onRoomStateUpdate?.call(roomID, state, errorCode, extendedData);
    };

    ZegoExpressEngine.onIMRecvBroadcastMessage = (roomID, messageList) {
      ZegoLog().addLog(
          '🚩 🚪 im recv broadcast message, roomID: $roomID, messageList length: ${messageList.length}');
      _onIMRecvBroadcastMessage?.call(roomID, messageList);
    };

    ZegoExpressEngine.onRoomUserUpdate = (roomID, updateType, userList) {
      ZegoLog().addLog(
          '🚩 🚪 room user update, roomID: $roomID, updateType: $updateType');
      _onRoomUserUpdate?.call(roomID, updateType, userList);
    };

    ZegoExpressEngine.onRangeAudioMicrophoneStateUpdate =
        (rangeAudio, state, errorCode) {
      ZegoLog().addLog(
          '🚩 🚪 onRangeAudioMicrophoneStateUpdate, state: $state, errorCode: $errorCode');
    };
  }

  void setZegoEventCallback(
      {RoomStateUpdateCallback? onRoomStateUpdate,
      IMRecvBroadcastMessageCallback? onIMRecvBroadcastMessage,
      RoomUserUpdateCallback? onRoomUserUpdate}) {
    if (onRoomStateUpdate != null) {
      _onRoomStateUpdate = onRoomStateUpdate;
    }

    if (onIMRecvBroadcastMessage != null) {
      _onIMRecvBroadcastMessage = onIMRecvBroadcastMessage;
    }

    if (onRoomUserUpdate != null) {
      _onRoomUserUpdate = onRoomUserUpdate;
    }
  }

  void clearZegoEventCallback() {
    _onRoomStateUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = null;

    _onIMRecvBroadcastMessage = null;
    ZegoExpressEngine.onIMRecvBroadcastMessage = null;

    _onRoomUserUpdate = null;
    ZegoExpressEngine.onRoomUserUpdate = null;
  }

  Future<void> createEngine({bool? enablePlatformView}) async {
    _initCallback();

    await ZegoExpressEngine.destroyEngine();

    ZegoExpressEngine.setEngineConfig(ZegoEngineConfig(advancedConfig: {
      'max_channels': '3',
      'room_user_update_optimize': '1'
    }));

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

      var config = ZegoRoomConfig.defaultConfig();
      config.isUserStatusNotify = true;
      // Login Room
      await ZegoExpressEngine.instance.loginRoom(roomID, user, config: config);

      ZegoLog().addLog('🚪 Start login room, roomID: $roomID');
    }
  }

  Future<void> logoutRoom(String roomID) async {
    if (roomID.isNotEmpty) {
      await ZegoExpressEngine.instance.logoutRoom(roomID);

      ZegoLog().addLog('🚪 Start logout room, roomID: $roomID');
    }
  }

  Future<ZegoIMSendBroadcastMessageResult> sendBroadcastMessage(
      String roomID, String message) {
    return ZegoExpressEngine.instance.sendBroadcastMessage(roomID, message);
  }

  void createRangeAudio() async {
    if (_rangeAudio == null) {
      _rangeAudio = await ZegoExpressEngine.instance.createRangeAudio();
      _rangeAudio?.setAudioReceiveRange(100);
      _rangeAudio?.setRangeAudioMode(ZegoRangeAudioMode.World);
      ZegoLog().addLog('createRangeAudio');
    }
  }

  void destoryRangeAudio() {
    if (_rangeAudio != null) {
      ZegoExpressEngine.instance.destroyRangeAudio(_rangeAudio!);
      ZegoLog().addLog('destroyRangeAudio');
    }
  }

  void enableMicrophone(bool enable) {
    _rangeAudio?.enableMicrophone(enable);
    ZegoLog().addLog('enableMicrophone enable: $enable');
  }

  void enableSpeaker(bool enable) {
    _rangeAudio?.enableSpeaker(enable);
    ZegoLog().addLog('enableSpeaker enable: $enable');
  }

  void enableSpatializer(bool enable) {
    _rangeAudio?.enableSpatializer(enable);
    ZegoLog().addLog('enableSpatializer enable: $enable');
  }

  void setRangeAudioMode(ZegoRangeAudioMode mode) {
    _rangeAudio?.setRangeAudioMode(mode);
    ZegoLog().addLog('setRangeAudioMode mode: $mode');
  }

  void setAudioReceiveRange(double range) {
    _rangeAudio?.setAudioReceiveRange(range);
    ZegoLog().addLog('setAudioReceiveRange range: $range');
  }

  void setTeamID(String teamID) {
    _rangeAudio?.setTeamID(teamID);
    ZegoLog().addLog('setTeamID teamID: $teamID');
  }

  void muteUser(String userID, bool mute) {
    _rangeAudio?.muteUser(userID, mute);
    ZegoLog().addLog('muteUser userID: $userID mute: $mute');
  }

  void setPositionUpdateFrequency(int frequency) {
    _rangeAudio?.setPositionUpdateFrequency(frequency);
    ZegoLog().addLog('setPositionUpdateFrequency frequency: $frequency');
  }

  void updateAudioSource(String userID, Float32List position) {
    _rangeAudio?.updateAudioSource(userID, position);
    ZegoLog().addLog('updateAudioSource userID: $userID , position: $position');
  }

  void updateSelfPosition(Float32List position, Float32List axisForward,
      Float32List axisRight, Float32List axisUp) {
    _rangeAudio?.updateSelfPosition(position, axisForward, axisRight, axisUp);
    ZegoLog().addLog(
        'updateSelfPosition position: $position , axisForward: $axisForward, axisRight: $axisRight , axisUp: $axisUp');
  }

  void eulerAnglesToRotationMatrix(
      List<double> theta,
      List<double> matrix_front,
      List<double> matrix_right,
      List<double> matrix_up) {
    var theta0 = theta[0] * pi / 180;
    var theta1 = theta[1] * pi / 180;
    var theta2 = theta[2] * pi / 180;

    List matrix_rotate_front = [
      [1.0, 0.0, 0.0],
      [0.0, cos(theta0), -sin(theta0)],
      [0.0, sin(theta0), cos(theta0)],
    ];
    List matrix_rotate_right = [
      [cos(theta1), 0.0, sin(theta1)],
      [0.0, 1.0, 0.0],
      [-sin(theta1), 0.0, cos(theta1)],
    ];
    List matrix_rotate_up = [
      [cos(theta2), -sin(theta2), .0],
      [sin(theta2), cos(theta2), .0],
      [.0, .0, .1],
    ];

    List matrix_rotate = [
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0],
    ];
    List matrix_rotate_temp = [
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0],
    ];

    matrixMultiply(
        matrix_rotate_front, matrix_rotate_right, matrix_rotate_temp);
    matrixMultiply(matrix_rotate_temp, matrix_rotate_up, matrix_rotate);

    matrix_front[0] = matrix_rotate[0][0];
    matrix_front[1] = matrix_rotate[1][0];
    matrix_front[2] = matrix_rotate[2][0];

    matrix_right[0] = matrix_rotate[0][1];
    matrix_right[1] = matrix_rotate[1][1];
    matrix_right[2] = matrix_rotate[2][1];

    matrix_up[0] = matrix_rotate[0][2];
    matrix_up[1] = matrix_rotate[1][2];
    matrix_up[2] = matrix_rotate[2][2];
  }

  void matrixMultiply(List a, List b, List dst) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        dst[i][j] = 0.0;
        for (int k = 0; k < 3; k++) {
          dst[i][j] += a[i][k] * b[k][j];
        }
      }
    }
  }
}
