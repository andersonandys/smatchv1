import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew//utils/zego_log_view.dart';
import 'package:smatch/callnew//utils/zego_user_helper.dart';

class NetworkAndPerformancePage extends StatefulWidget {
  const NetworkAndPerformancePage({Key? key}) : super(key: key);

  @override
  State<NetworkAndPerformancePage> createState() =>
      _NetworkAndPerformancePageState();
}

class _NetworkAndPerformancePageState extends State<NetworkAndPerformancePage> {
  final _roomID = 'network_and_performance';

  late ZegoRoomState _roomState;
  int? _upConnectCost;
  int? _downConnectCost;
  int? _upRtt;
  int? _downRtt;
  double? _upPacketLostRate;
  double? _downPacketLostRate;
  ZegoStreamQualityLevel? _upQualityLevel;
  ZegoStreamQualityLevel? _downQualityLevel;
  late TextEditingController _upController;
  late TextEditingController _downController;

  double? _appCpu;
  double? _systemCpu;
  double? _appMemory;
  double? _appMemoryPercentage;
  double? _systemMemoryPercentage;

  late bool isStart;

  late ZegoDelegate _zegoDelegate;

  @override
  void initState() {
    super.initState();

    _zegoDelegate = ZegoDelegate();

    _roomState = ZegoRoomState.Disconnected;
    _upController = TextEditingController();
    _upController.text = '1000';
    _downController = TextEditingController();
    _downController.text = '1000';

    isStart = false;

    _zegoDelegate.setZegoEventCallback(
        onRoomStateUpdate: onRoomStateUpdate,
        onNetworkSpeedTestError: onNetworkSpeedTestError,
        onNetworkSpeedTestQualityUpdate: onNetworkSpeedTestQualityUpdate,
        onPerformanceStatusUpdate: onPerformanceStatusUpdate);
    _zegoDelegate.createEngine().then((value) {
      _zegoDelegate.loginRoom(_roomID);
      _zegoDelegate.startPerformanceMonitor();
    });
  }

  @override
  void dispose() {
    _zegoDelegate.clearZegoEventCallback();
    _zegoDelegate.stopPerformanceMonitor();
    _zegoDelegate
        .logoutRoom(_roomID)
        .then((value) => _zegoDelegate.destroyEngine());

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

  void onNetworkSpeedTestError(int errorCode, ZegoNetworkSpeedTestType type) {}

  void onNetworkSpeedTestQualityUpdate(
      ZegoNetworkSpeedTestQuality quality, ZegoNetworkSpeedTestType type) {
    if (type == ZegoNetworkSpeedTestType.Uplink) {
      _upConnectCost = quality.connectCost;
      _upRtt = quality.rtt;
      _upPacketLostRate = quality.packetLostRate;
      _upQualityLevel = quality.quality;
    } else {
      _downConnectCost = quality.connectCost;
      _downRtt = quality.rtt;
      _downPacketLostRate = quality.packetLostRate;
      _downQualityLevel = quality.quality;
    }
    setState(() {});
  }

  void onPerformanceStatusUpdate(ZegoPerformanceStatus status) {
    _appCpu = status.cpuUsageApp;
    _appMemory = status.memoryUsedApp;
    _appMemoryPercentage = status.memoryUsageApp;
    _systemCpu = status.cpuUsageSystem;
    _systemMemoryPercentage = status.memoryUsageSystem;
    setState(() {});
  }

  // widget callback
  void onTestBtnPress() {
    var expectedUplinkBitrate = int.tryParse(_upController.text.trim());
    var expectedDownlinkBitrate = int.tryParse(_downController.text.trim());
    if (expectedUplinkBitrate == null || expectedDownlinkBitrate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('请输入整数数字')));
      return;
    }
    isStart = !isStart;
    setState(() {});
    if (isStart) {
      _zegoDelegate.startNetworkSpeedTest(ZegoNetworkSpeedTestConfig(
          true, expectedUplinkBitrate, true, expectedDownlinkBitrate));
    } else {
      _zegoDelegate.stopNetworkSpeedTest();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('网络与性能'),
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
          networkSpeedTestWidget(),
          performanceWidget()
        ],
      ),
    );
  }

  Widget roomInfoWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("RoomID: $_roomID"),
      Text('RoomState: ${_zegoDelegate.roomStateDesc(_roomState)}')
    ]);
  }

  Widget networkSpeedTestWidget() {
    var infoWidgetMaker = (bool isUp) {
      var connectCost = isUp ? _upConnectCost : _downConnectCost;
      var rtt = isUp ? _upRtt : _downRtt;
      var packetLostRate = isUp
          ? _upPacketLostRate?.toStringAsFixed(3)
          : _downPacketLostRate?.toStringAsFixed(3);
      var qualityLevel = isUp ? _upQualityLevel : _downQualityLevel;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              alignment: Alignment.centerLeft, child: Text(isUp ? '上行' : '下行')),
          Text('ConnectCost: ${connectCost == null ? '' : '${connectCost}ms'}'),
          Text('RTT: ${rtt == null ? '' : '${rtt}ms'}'),
          Text(
              'PacketLostRate: ${packetLostRate == null ? '' : '${(double.parse(packetLostRate) * 100).toStringAsFixed(1)}%'}'),
          Text(
              'QualityLevel: ${qualityLevel == null ? '' : '${qualityLevel.name}'}'),
          Divider(),
          Text('期望${isUp ? '上行' : '下行'}码率'),
          Padding(
              padding: EdgeInsets.only(right: 10),
              child: TextField(
                controller: isUp ? _upController : _downController,
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
      );
    };
    return Column(
      children: [
        Container(
          color: Colors.grey[300],
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topLeft,
          child: Padding(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
              child: Text(
                '网速测试',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              )),
        ),
        Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Flexible(flex: 1, child: infoWidgetMaker(false)),
                Flexible(flex: 1, child: infoWidgetMaker(true))
              ],
            )),
        CupertinoButton.filled(
            child: Text(
              isStart ? '停止网速测试' : '开始网速测试',
              style: TextStyle(fontSize: 14.0),
            ),
            onPressed: onTestBtnPress,
            padding: EdgeInsets.all(10.0)),
      ],
    );
  }

  Widget performanceWidget() {
    var infoWidgetMaker = (bool isApp) {
      var cpu =
          isApp ? _appCpu?.toStringAsFixed(3) : _systemCpu?.toStringAsFixed(3);
      var memoryPercentage = isApp
          ? _appMemoryPercentage?.toStringAsFixed(3)
          : _systemMemoryPercentage?.toStringAsFixed(3);
      var appMemoryPercentage = _appMemory?.toStringAsFixed(3);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              alignment: Alignment.centerLeft,
              child: Text(isApp ? 'App' : 'System')),
          Text(
              'CPU: ${cpu == null ? '' : '${(double.parse(cpu) * 100).toStringAsFixed(1)}%'}'),
          Text(
              'Memory(%): ${memoryPercentage == null ? '' : '${(double.parse(memoryPercentage) * 100).toStringAsFixed(1)}%'}'),
          Offstage(
              offstage: !isApp,
              child: Text(
                  'Memory: ${appMemoryPercentage == null ? '' : '${appMemoryPercentage}MB'}'))
        ],
      );
    };
    return Column(
      children: [
        Container(
          color: Colors.grey[300],
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topLeft,
          child: Padding(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
              child: Text(
                '性能监控',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              )),
        ),
        Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Flexible(flex: 1, child: infoWidgetMaker(true)),
                Flexible(flex: 1, child: infoWidgetMaker(false))
              ],
            ))
      ],
    );
  }
}

typedef RoomStateUpdateCallback = void Function(
    String, ZegoRoomState, int, Map<String, dynamic>);
typedef NetworkSpeedTestErrorCallback = Function(int, ZegoNetworkSpeedTestType);
typedef NetworkSpeedTestQualityUpdateCallback = void Function(
    ZegoNetworkSpeedTestQuality quality, ZegoNetworkSpeedTestType type);
typedef PerformanceStatusUpdateCallback = Function(ZegoPerformanceStatus);

class ZegoDelegate {
  RoomStateUpdateCallback? _onRoomStateUpdate;
  NetworkSpeedTestErrorCallback? _onNetworkSpeedTestError;
  NetworkSpeedTestQualityUpdateCallback? _onNetworkSpeedTestQualityUpdate;
  PerformanceStatusUpdateCallback? _onPerformanceStatusUpdate;

  void _initCallback() {
    ZegoExpressEngine.onRoomStateUpdate = (String roomID, ZegoRoomState state,
        int errorCode, Map<String, dynamic> extendedData) {
      ZegoLog().addLog(
          '🚩 🚪 Room state update, state: $state, errorCode: $errorCode, roomID: $roomID');
      _onRoomStateUpdate?.call(roomID, state, errorCode, extendedData);
    };

    ZegoExpressEngine.onNetworkSpeedTestError =
        (int errorCode, ZegoNetworkSpeedTestType type) {
      ZegoLog().addLog(
          '🚩 📤 onNetworkSpeedTestError errorCode: $errorCode, type: $type');
      _onNetworkSpeedTestError?.call(errorCode, type);
    };

    ZegoExpressEngine.onNetworkSpeedTestQualityUpdate =
        (ZegoNetworkSpeedTestQuality quality, ZegoNetworkSpeedTestType type) {
      // ZegoLog().addLog(
      //     '🚩 📥 onNetworkSpeedTestQualityUpdate quality.quality: ${quality.quality}, type: $type');
      _onNetworkSpeedTestQualityUpdate?.call(quality, type);
    };

    ZegoExpressEngine.onPerformanceStatusUpdate =
        (ZegoPerformanceStatus status) {
      // ZegoLog().addLog(
      //     '🚩 📤 onPerformanceStatusUpdate status: ');
      _onPerformanceStatusUpdate?.call(status);
    };
  }

  void setZegoEventCallback({
    RoomStateUpdateCallback? onRoomStateUpdate,
    NetworkSpeedTestErrorCallback? onNetworkSpeedTestError,
    NetworkSpeedTestQualityUpdateCallback? onNetworkSpeedTestQualityUpdate,
    PerformanceStatusUpdateCallback? onPerformanceStatusUpdate,
  }) {
    if (onRoomStateUpdate != null) {
      _onRoomStateUpdate = onRoomStateUpdate;
    }
    if (onNetworkSpeedTestError != null) {
      _onNetworkSpeedTestError = onNetworkSpeedTestError;
    }
    if (onNetworkSpeedTestQualityUpdate != null) {
      _onNetworkSpeedTestQualityUpdate = onNetworkSpeedTestQualityUpdate;
    }
    if (onPerformanceStatusUpdate != null) {
      _onPerformanceStatusUpdate = onPerformanceStatusUpdate;
    }
  }

  void clearZegoEventCallback() {
    _onRoomStateUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = null;

    _onNetworkSpeedTestError = null;
    ZegoExpressEngine.onNetworkSpeedTestError = null;

    _onNetworkSpeedTestQualityUpdate = null;
    ZegoExpressEngine.onNetworkSpeedTestQualityUpdate = null;

    _onPerformanceStatusUpdate = null;
    ZegoExpressEngine.onPerformanceStatusUpdate = null;
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

  void startNetworkSpeedTest(ZegoNetworkSpeedTestConfig config) {
    ZegoExpressEngine.instance.startNetworkSpeedTest(config);
  }

  void stopNetworkSpeedTest() {
    ZegoExpressEngine.instance.stopNetworkSpeedTest();
  }

  void startPerformanceMonitor() {
    ZegoExpressEngine.instance.startPerformanceMonitor();
  }

  void stopPerformanceMonitor() {
    ZegoExpressEngine.instance.stopPerformanceMonitor();
  }
}
