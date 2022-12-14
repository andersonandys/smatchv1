import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:smatch/callclub/utils/toast.dart';

Future<String> fetchToken(BuildContext context, token) async {
  // if (!dotenv.isInitialized) {
  //   // Load Environment variables
  //   await dotenv.load(fileName: ".env");
  // }
  final String? _AUTH_URL = "";
  String? _AUTH_TOKEN = token;

  if ((_AUTH_TOKEN?.isEmpty ?? true) && (_AUTH_URL?.isEmpty ?? true)) {
    showSnackBarMessage(
        message: "Please set the environment variables", context: context);
    throw Exception("Either AUTH_TOKEN or AUTH_URL is not set in .env file");
    return "";
  }

  if ((_AUTH_TOKEN?.isNotEmpty ?? false) && (_AUTH_URL?.isNotEmpty ?? false)) {
    showSnackBarMessage(
        message: "Please set only one environment variable", context: context);
    throw Exception("Either AUTH_TOKEN or AUTH_URL can be set in .env file");
    return "";
  }

  if (_AUTH_URL?.isNotEmpty ?? false) {
    final Uri getTokenUrl = Uri.parse('$_AUTH_URL/get-token');
    final http.Response tokenResponse = await http.get(getTokenUrl);
    _AUTH_TOKEN = json.decode(tokenResponse.body)['token'];
  }

  return _AUTH_TOKEN ?? "";
}

Future<String> createMeeting(String _token) async {
  final String? _VIDEOSDK_API_ENDPOINT = "https://api.videosdk.live/v2";

  final Uri getMeetingIdUrl = Uri.parse('$_VIDEOSDK_API_ENDPOINT/rooms');
  final http.Response meetingIdResponse =
      await http.post(getMeetingIdUrl, headers: {
    "Authorization": _token,
  });

  var _meetingID = json.decode(meetingIdResponse.body)['roomId'];
  return _meetingID;
}

Future<bool> validateMeeting(String token, String meetingId) async {
  final String? _VIDEOSDK_API_ENDPOINT = "https://api.videosdk.live/v2";

  final Uri validateMeetingUrl =
      Uri.parse('$_VIDEOSDK_API_ENDPOINT/rooms/validate/$meetingId');
  final http.Response validateMeetingResponse =
      await http.get(validateMeetingUrl, headers: {
    "Authorization": token,
  });

  return validateMeetingResponse.statusCode == 200;
}

Future<dynamic> fetchSession(String token, String meetingId) async {
  final String? _VIDEOSDK_API_ENDPOINT = "https://api.videosdk.live/v2";

  final Uri getMeetingIdUrl =
      Uri.parse('$_VIDEOSDK_API_ENDPOINT/sessions?roomId=${meetingId}');
  final http.Response meetingIdResponse =
      await http.get(getMeetingIdUrl, headers: {
    "Authorization": token,
  });
  List<dynamic> sessions = jsonDecode(meetingIdResponse.body)['data'];
  return sessions.first;
}
