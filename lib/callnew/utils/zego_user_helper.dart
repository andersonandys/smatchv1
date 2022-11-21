import 'dart:math';

class ZegoUserHelper {
  ZegoUserHelper._();
  static final ZegoUserHelper instance = ZegoUserHelper._();

  String _userID = "";

  String _userName = "";

  String get userID {
    if (_userID.isEmpty) {
      _userID = 'ZegoExpressFlutter_${Random().nextInt(1000)}';
    }
    return _userID;
  }

  String get userName {
    if (_userName.isEmpty) {
      _userName = userID;
    }
    return _userName;
  }

  set userID(String userID_) => _userID = userID_;

  set userName(String userName_) => _userName = userName_;
}
