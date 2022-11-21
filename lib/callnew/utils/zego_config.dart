import 'package:flutter/foundation.dart';
import 'package:zego_express_engine/zego_express_engine.dart' show ZegoScenario;
import 'package:universal_io/io.dart';
import 'dart:convert';

class ZegoConfig {
  static final ZegoConfig instance = ZegoConfig._internal();
  ZegoConfig._internal();

  // ----- Persistence params -----
  // Developers can get appID from admin console.
  // https://console.zego.im/dashboard
  // for example:
  //     int appID = 123456789;
  int appID = 0;

  ZegoScenario scenario = ZegoScenario.General;

  bool enablePlatformView = kIsWeb ? true : false;

  // Developers can get appSign from admin console.
  // https://console.zego.im/dashboard
  // Note: If you need to use a more secure authentication method: token authentication, please refer to [How to upgrade from AppSign authentication to Token authentication](https://doc-zh.zego.im/faq/token_upgrade?product=ExpressVideo&platform=all)
  // for example:
  //     String appSign = "04AAAAAxxxxxxxxxxxxxx";
  String appSign = "";
  String token = "";

  // only the web need
  getToken(userID, roomId) async {
    if (token.isNotEmpty) return Future.value(token);
    var params = {
      "appId": this.appID,
      "idName": userID,
      "version": '03',
      "roomId": roomId,
      "privilege": {"1": 1, "2": 1},
      "expire_time": 7 * 24 * 60 * 60
    };
    print('------loadData_sys_post--------');

    var httpClient = new HttpClient();

    // queryParameters get请求的查询参数(适用于get请求？？？是吗？？？)
    // Uri uri = Uri(
    //     scheme: "https", host: "xxx.xxx.xxx.xxx", path: homeRegularListUrl);
    // HttpClientRequest request = await httpClient.postUrl(uri);

    var url = "https://sig-liveroom-admin.zego.cloud/thirdToken/get";
    var request = await httpClient.postUrl(Uri.parse(url));

    // 设置请求头
    // Content-Type大小写都ok
    request.headers.set('content-type', 'application/json');

    request.add(utf8.encode(json.encode(params)));

    var response = await request.close();
    var result = null;
    String responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == HttpStatus.ok) {
      print('请求成功');
      result = jsonDecode(responseBody)["data"]["token"];
      print(result);
    }
    return result;
  }
}
