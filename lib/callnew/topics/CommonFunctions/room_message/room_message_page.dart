//
//  room_message_page.dart
//  flutter_dart
//
//  Created by Patrick Fu on 2021/07/11.
//  Copyright © 2021 Zego. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew/utils/zego_log_view.dart';
import 'package:smatch/callnew/utils/zego_user_helper.dart';

class RoomMessageObject {
  String fromUserID = '';
  String message = '';
}

class RoomMessagePage extends StatefulWidget {
  @override
  _RoomMessagePageState createState() => _RoomMessagePageState();
}

class _RoomMessagePageState extends State<RoomMessagePage> {
  final String _roomID = '0007';

  String _messagesBuffer = '';

  bool _isEngineActive = false;
  ZegoRoomState _roomState = ZegoRoomState.Disconnected;

  List<ZegoUser> _allUsers = [];
  List<ZegoUser> _customCommandSelectedUsers = [];

  TextEditingController _broadcastMessageController =
      new TextEditingController();
  TextEditingController _customCommandController = new TextEditingController();
  TextEditingController _customCommandUsersController =
      new TextEditingController();
  TextEditingController _barrageMessageController = new TextEditingController();
  TextEditingController _roomExtraInfoKeyController =
      new TextEditingController();
  TextEditingController _roomExtraInfoValueController =
      new TextEditingController();

  @override
  void initState() {
    super.initState();
    ZegoExpressEngine.getVersion()
        .then((value) => ZegoLog().addLog('🌞 SDK Version: $value'));

    createEngine();

    // loginRoom();

    setZegoEventCallback();
  }

  @override
  void dispose() {
    destroyEngine();

    clearZegoEventCallback();

    super.dispose();
  }

  void createEngine() {
    ZegoEngineProfile profile = ZegoEngineProfile(
        ZegoConfig.instance.appID, ZegoConfig.instance.scenario,
        enablePlatformView: ZegoConfig.instance.enablePlatformView,
        appSign: kIsWeb ? null : ZegoConfig.instance.appSign);
    ZegoExpressEngine.createEngineWithProfile(profile);

    // Notify View that engine state changed
    setState(() => _isEngineActive = true);

    ZegoLog().addLog('🚀 Create ZegoExpressEngine');
  }

  Future<void> loginRoom() async {
    // Instantiate a ZegoUser object
    ZegoUser user = ZegoUser(
        ZegoUserHelper.instance.userID, ZegoUserHelper.instance.userName);
    // Login Room
    ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
    if (kIsWeb) {
      var token = await ZegoConfig.instance
          .getToken(ZegoUserHelper.instance.userID, _roomID);
      config.token = token;
    }
    await ZegoExpressEngine.instance.loginRoom(_roomID, user, config: config);

    ZegoLog().addLog('🚪 Start login room, roomID: $_roomID');
  }

  // MARK: - Exit
  Future<void> logoutRoom() async {
    await ZegoExpressEngine.instance.logoutRoom(_roomID);
    ZegoLog().addLog('🚪 Start login room, roomID: $_roomID');
  }

  void destroyEngine() async {
    // Can destroy the engine when you don't need audio and video calls
    //
    // Destroy engine will automatically logout room and stop publishing/playing stream.
    ZegoExpressEngine.destroyEngine();

    ZegoLog().addLog('🏳️ Destroy ZegoExpressEngine');
  }

  // MARK: - Event

  void setZegoEventCallback() {
    ZegoExpressEngine.onRoomStateUpdate = (String roomID, ZegoRoomState state,
        int errorCode, Map<String, dynamic> extendedData) {
      ZegoLog().addLog(
          '🚩 🚪 Room state update, roomID: $roomID, state: $state, errorCode: $errorCode');
      setState(() => _roomState = state);
    };

    ZegoExpressEngine.onRoomUserUpdate =
        (String roomID, ZegoUpdateType updateType, List<ZegoUser> userList) {
      ZegoLog().addLog(
          '🚩 🕺 Room user update, roomID: $roomID, type: ${updateType.toString()}, count: ${userList.length}');
      if (updateType == ZegoUpdateType.Add) {
        setState(() => _allUsers.addAll(userList));
      } else if (updateType == ZegoUpdateType.Delete) {
        for (ZegoUser removedUser in userList) {
          for (ZegoUser user in _allUsers) {
            if (user.userID == removedUser.userID &&
                user.userName == removedUser.userName) {
              setState(() => _allUsers.remove(user));
            }
          }
        }
      }
    };

    ZegoExpressEngine.onIMRecvBroadcastMessage =
        (String roomID, List<ZegoBroadcastMessageInfo> messageList) {
      for (ZegoBroadcastMessageInfo message in messageList) {
        ZegoLog().addLog(
            '🚩 💬 Received broadcast message, ID: ${message.messageID}, fromUser: ${message.fromUser.userID}, sendTime: ${message.sendTime}, roomID: $roomID');
        appendMessage(
            '💬 ${message.message} [ID:${message.messageID}] [From:${message.fromUser.userName}]');
      }
    };

    ZegoExpressEngine.onIMRecvCustomCommand =
        (String roomID, ZegoUser fromUser, String command) {
      ZegoLog().addLog(
          '🚩 💭 Received custom command, fromUser: ${fromUser.userID}, roomID: $roomID, command: $command');
      appendMessage('💭 $command [From:${fromUser.userName}]');
    };

    ZegoExpressEngine.onIMRecvBarrageMessage =
        (String roomID, List<ZegoBarrageMessageInfo> messageList) {
      for (ZegoBarrageMessageInfo message in messageList) {
        ZegoLog().addLog(
            '🚩 🗯 Received barrage message, ID: ${message.messageID}, fromUser: ${message.fromUser.userID}, sendTime: ${message.sendTime}, roomID: $roomID');
        appendMessage(
            '🗯 ${message.message} [ID:${message.messageID}] [From:${message.fromUser.userName}]');
      }
    };

    ZegoExpressEngine.onRoomExtraInfoUpdate =
        (String roomID, List<ZegoRoomExtraInfo> roomExtraInfoList) {
      ZegoLog().addLog('🚩 📢 Room extra info update');
      for (ZegoRoomExtraInfo info in roomExtraInfoList) {
        ZegoLog().addLog(
            '🚩 📢 --- Key: ${info.key}, Value: ${info.value}, Time: ${info.updateTime}, UserID: ${info.updateUser.userID}');
        appendMessage(
            '📢 RoomExtraInfo: Key: [${info.key}], Value: [${info.value}], From:${info.updateUser.userName}');
      }
    };
  }

  void clearZegoEventCallback() {
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onRoomUserUpdate = null;
    ZegoExpressEngine.onIMRecvBroadcastMessage = null;
    ZegoExpressEngine.onIMRecvCustomCommand = null;
    ZegoExpressEngine.onIMRecvBarrageMessage = null;
  }

  // MARK: - Message

  void sendBroadcastMessage() {
    String message = _broadcastMessageController.text.trim();
    ZegoExpressEngine.instance
        .sendBroadcastMessage(_roomID, message)
        .then((value) {
      ZegoLog().addLog(
          '🚩 💬 Send broadcast message result, errorCode: ${value.errorCode}');
      appendMessage('💬 📤 Send: $message');
    });
  }

  void sendCustomCommand() {
    var tempUsers = <ZegoUser>[];
    var userIDs = [];
    if (_customCommandUsersController.text.isNotEmpty) {
      userIDs = _customCommandUsersController.text.split(',');
      for (var userID in userIDs) {
        print(userID);
        tempUsers.add(ZegoUser.id(userID));
      }
    }

    String command = _customCommandController.text.trim();
    ZegoExpressEngine.instance
        .sendCustomCommand(_roomID, command, tempUsers)
        .then((value) {
      ZegoLog().addLog(
          '🚩 💭 Send custom command to users: $userIDs result, errorCode: ${value.errorCode}');
      appendMessage('💭 📤 Send: $command');
    });
  }

  void sendBarrageMessage() {
    String message = _barrageMessageController.text.trim();
    ZegoExpressEngine.instance
        .sendBarrageMessage(_roomID, message)
        .then((value) {
      ZegoLog()
          .addLog('🚩 🗯 Send barrage message, errorCode: ${value.errorCode}');
      appendMessage('🗯 📤 Send: $message');
    });
  }

  void setRoomExtraInfo() {
    String key = _roomExtraInfoKeyController.text.trim();
    String value = _roomExtraInfoValueController.text.trim();
    ZegoExpressEngine.instance
        .setRoomExtraInfo(_roomID, key, value)
        .then((result) {
      ZegoLog().addLog(
          '🚩 📢 Set room extra info result, errorCode: ${result.errorCode}');
      appendMessage('📢 📤 Set: key: $key, value: $value');
    });
  }

  void appendMessage(String message) {
    setState(() {
      _messagesBuffer =
          '$_messagesBuffer[${DateTime.now().toLocal().toString()}] $message\n\n\n';
    });
  }

  // MARK: - Widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('RoomMessage')),
      body: SafeArea(
          child: GestureDetector(
        child: mainContent(),
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      )),
    );
  }

  Widget mainContent() {
    return SingleChildScrollView(
        child: Column(children: [
      SizedBox(
        child: ZegoLogView(),
        height: MediaQuery.of(context).size.height * 0.1,
      ),
      Divider(),
      Container(
          child: roomInfoWidget(),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3)),
      Divider(),
      sendBroadcastMessageWidget(),
      Divider(),
      sendCustomCommandWidget(),
      Divider(),
      sendBarrageMessageWidget(),
      Divider(),
      setRoomExtraInfoWidget(),
      Divider(),
      ElevatedButton(onPressed: loginRoom, child: Text('login room')),
      Divider(),
      ElevatedButton(onPressed: logoutRoom, child: Text('logout room')),
      Divider(),
      Text(_messagesBuffer, textAlign: TextAlign.left),
    ]));
  }

  Widget sendBroadcastMessageWidget() {
    return sendMessageWidget('💬 Broadcast Message', 'Send to all users',
        _broadcastMessageController, sendBroadcastMessage, Spacer());
  }

  Widget sendCustomCommandWidget() {
    // TODO: Support selecting users, add a button here
    return sendMessageWidget('💭 Custom Command', 'Send to specified users',
        _customCommandController, sendCustomCommand, Spacer(), true);
  }

  Widget sendBarrageMessageWidget() {
    return sendMessageWidget('🗯 Barrage Message', 'Send to all users',
        _barrageMessageController, sendBarrageMessage, Spacer());
  }

  Widget sendMessageWidget(
      String labelText,
      String hintText,
      TextEditingController textController,
      VoidCallback sendFunction,
      Widget extraWidget,
      [bool needUserTextEdit = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                labelText,
                style: TextStyle(fontSize: 15),
              ),
              extraWidget,
            ],
          ),
          SizedBox(height: 5),
          Offstage(
              offstage: !needUserTextEdit,
              child: Row(
                children: [
                  Text('toUsers: '),
                  Expanded(
                      child: TextField(
                    controller: _customCommandUsersController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10.0),
                        isDense: true,
                        hintStyle:
                            TextStyle(color: Colors.black26, fontSize: 14.0),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff0e88eb)))),
                  ))
                ],
              )),
          SizedBox(height: 5),
          Row(children: [
            Expanded(
                child: TextField(
              controller: textController,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10.0),
                  isDense: true,
                  // labelText: labelText,
                  // labelStyle: TextStyle(color: Colors.black54, fontSize: 14.0),
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.black26, fontSize: 14.0),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff0e88eb)))),
            )),
            SizedBox(width: 10),
            ElevatedButton(onPressed: sendFunction, child: Text('Send!')),
          ]),
        ],
      ),
    );
  }

  Widget setRoomExtraInfoWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '📢 Room Extra Info',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 5,
                    child: TextField(
                      controller: _roomExtraInfoKeyController,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10.0),
                          isDense: true,
                          labelText: 'Key',
                          labelStyle:
                              TextStyle(color: Colors.black54, fontSize: 14.0),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Color(0xff0e88eb)))),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _roomExtraInfoValueController,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10.0),
                          isDense: true,
                          labelText: 'Value',
                          labelStyle:
                              TextStyle(color: Colors.black54, fontSize: 14.0),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Color(0xff0e88eb)))),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(onPressed: setRoomExtraInfo, child: Text('Set!')),
          ]),
        ],
      ),
    );
  }

  Widget roomInfoWidget() {
    return Row(children: [
      Text(
        "RoomID: $_roomID | UserID: ${ZegoUserHelper.instance.userID}",
        style: TextStyle(fontSize: 8),
      ),
      Spacer(),
      Text(
        "room state:  ${roomStateDesc()}",
        style: TextStyle(fontSize: 10),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }

  String roomStateDesc() {
    switch (_roomState) {
      case ZegoRoomState.Disconnected:
        return "Disconnected 🔴";
        break;
      case ZegoRoomState.Connecting:
        return "Connecting 🟡";
        break;
      case ZegoRoomState.Connected:
        return "Connected 🟢";
        break;
      default:
        return "Unknown";
    }
  }
}
