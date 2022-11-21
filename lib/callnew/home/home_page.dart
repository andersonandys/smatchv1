//
//  home_page.dart
//  zego-express-example-topics-flutter
//
//  Created by Patrick Fu on 2020/11/12.
//  Copyright © 2020 Zego. All rights reserved.
//

import 'package:flutter/foundation.dart';
import 'package:smatch/callnew/home/global_setting_page.dart';
import 'package:smatch/callnew/topics/AudioAdvanced/audio_3a/audio_3a_page.dart';
import 'package:smatch/callnew/topics/AudioAdvanced/audio_effect_player/audio_effect_player_page.dart';
import 'package:smatch/callnew/topics/AudioAdvanced/ear_return_and_channel_settings/ear_return_and_channel_settings_page.dart';
import 'package:smatch/callnew/topics/AudioAdvanced/original_audio_data_acquisition/original_audio_data_acquisition_page.dart';
import 'package:smatch/callnew/topics/AudioAdvanced/range_audio/range_audio_page.dart';
import 'package:smatch/callnew/topics/AudioAdvanced/soundlevel_spectrum/soundlevel_spectrum_page.dart';
import 'package:smatch/callnew/topics/AudioAdvanced/voice_change/voice_change_page.dart';
import 'package:smatch/callnew/topics/BestPractices/video_talk/video_talk_page.dart';
import 'package:smatch/callnew/topics/CommonFunctions/common_video_config/common_video_config_page.dart';
import 'package:smatch/callnew/topics/CommonFunctions/devices_config/devices_config_page.dart';
import 'package:smatch/callnew/topics/CommonFunctions/room_message/room_message_page.dart';
import 'package:smatch/callnew/topics/CommonFunctions/video_rotation/video_rotation.dart';
import 'package:smatch/callnew/topics/OtherFunctions/beauty_watermark_snapshot/beauty_watermark_snapshot_page.dart';
import 'package:smatch/callnew/topics/OtherFunctions/camera/camera_page.dart';
import 'package:smatch/callnew/topics/OtherFunctions/flow_control/flow_control_page.dart';
import 'package:smatch/callnew/topics/OtherFunctions/media_player/media_player_resource_selection_page.dart';
import 'package:smatch/callnew/topics/OtherFunctions/multiple_rooms/multiple_rooms_page.dart';
import 'package:smatch/callnew/topics/OtherFunctions/network_and_performance/network_and_performance_page.dart';
import 'package:smatch/callnew/topics/OtherFunctions/recording/recording_page.dart';
import 'package:smatch/callnew/topics/OtherFunctions/security/security_page.dart';
import 'package:smatch/callnew/topics/OtherFunctions/sei/sei_page.dart';
import 'package:smatch/callnew/topics/OtherFunctions/stream_mixing/mixer_main.dart';
import 'package:smatch/callnew/topics/QuickStart/play_stream/play_stream_login_page.dart';
import 'package:smatch/callnew/topics/QuickStart/publish_stream/publish_stream_login_page.dart';
import 'package:smatch/callnew/topics/QuickStart/quick_start/quick_start_page.dart';
import 'package:smatch/callnew/topics/StreamAdvanced/h265/h265_page.dart';
import 'package:smatch/callnew/topics/StreamAdvanced/publishing_multiple_streams/publishing_multiple_streams_page.dart';
import 'package:smatch/callnew/topics/StreamAdvanced/stream_by_cdn/stream_by_cdn.dart';
import 'package:smatch/callnew/topics/StreamAdvanced/stream_monitoring/stream_monitoring.dart';
import 'package:smatch/callnew/topics/VideoAdvanced/encoding_and_decoding/encoding_and_decoding_page.dart';
import 'package:smatch/callnew/utils/zego_config.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    // Limit the vertical orientation of the screen
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    if (Platform.isAndroid || Platform.isIOS) {
      Permission.camera.request().then((value) async {
        await Permission.microphone.request();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('ZegoExpressExample'),
          actions: [
            IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return GlobalSettingPage();
                  }));
                })
          ],
        ),
        body: SafeArea(
            child: ListView(
          children: ListTile.divideTiles(context: context, tiles: [
            ListTile(
              title: Text('快速开始'),
              tileColor: Colors.grey[300],
            ),
            TopicWidget('Quick Start', QuickStartPage(), context),
            TopicWidget('Publish Stream', PublishStreamLoginPage(), context),
            TopicWidget('Play Stream', PlayStreamLoginPage(), context),
            ListTile(
              title: Text('最佳实践'),
              tileColor: Colors.grey[300],
            ),
            TopicWidget('VideoTalk', VideoTalkPage(), context),
            ListTile(
              title: Text('常用功能'),
              tileColor: Colors.grey[300],
            ),
            TopicWidget(
                'Common Video Config', CommonVideoConfigPage(), context),
            TopicWidget('Video Rotation', ChooseVideoRotationPage(), context,
                isHide: kIsWeb || Platform.isWindows || Platform.isMacOS),
            TopicWidget('RoomMessage', RoomMessagePage(), context),
            TopicWidget(
              'Devices config',
              DevicesConfigPage(),
              context,
              isHide: Platform.isAndroid || Platform.isIOS, // !kIsWeb,
            ),
            Offstage(
              child: ListTile(
                title: Text('推流、拉流进阶'),
                tileColor: Colors.grey[300],
              ),
              offstage: kIsWeb,
            ),
            TopicWidget('Stream Monitorning', StreamMonitoringPage(), context,
                isHide: kIsWeb),
            TopicWidget('Stream by CDN', AddStreamToCDNPage(), context,
                isHide: kIsWeb),
            TopicWidget('H265', H265Page(), context, isHide: kIsWeb),
            TopicWidget('Publishing Multiple Streams',
                PublishingMultipleStreamsPage(), context),
            Offstage(
              child: ListTile(
                title: Text('视频进阶功能'),
                tileColor: Colors.grey[300],
              ),
              offstage: kIsWeb,
            ),
            TopicWidget('Video Encoding and Decoding',
                EncodingAndDecodingPage(), context,
                isHide: kIsWeb),
            Offstage(
              child: ListTile(
                title: Text('音频进阶功能'),
                tileColor: Colors.grey[300],
              ),
              offstage: kIsWeb,
            ),
            TopicWidget('Voice Change', VoiceChangePage(), context,
                isHide: kIsWeb),
            TopicWidget(
                'Soundlevel And Spectrum', SoundlevelSpectrumPage(), context,
                isHide: kIsWeb),
            TopicWidget('Audio Effect Player', AudioEffectPlayerPage(), context,
                isHide: kIsWeb),
            TopicWidget('Ear Return And Channel Settings',
                EarReturnAndChannelSettingsPage(), context,
                isHide: kIsWeb),
            TopicWidget('Audio 3A', Audio3aPage(), context),
            TopicWidget('Original Audio Data Acquisition',
                OriginalAudioDataAcquisitionPage(), context,
                isHide: kIsWeb),
            TopicWidget('Range Audio', RangeAudioWidget(), context,
                isHide: kIsWeb),
            ListTile(
              title: Text('其他功能'),
              tileColor: Colors.grey[300],
            ),
            TopicWidget('Beauty Watermark Snapshot',
                BeautyWatermarkSnapshotPage(), context,
                isHide: kIsWeb),
            TopicWidget('Stream Mixer', MixerMainPage(), context,
                isHide: kIsWeb),
            TopicWidget(
                'Media Player', MediaPlayerResourceSelectionPage(), context),
            TopicWidget('Login Multiple Room', MutilpeRoomsPage(), context,
                isHide: kIsWeb),
            TopicWidget('Flow Control', FlowControlPage(), context,
                isHide: kIsWeb),
            TopicWidget('SEI', SEIPage(), context),
            TopicWidget('Camera', CameraPage(), context,
                isHide: kIsWeb || Platform.isWindows || Platform.isMacOS),
            TopicWidget('Security', SecurityPage(), context, isHide: kIsWeb),
            TopicWidget(
                'Network And Performance', NetworkAndPerformancePage(), context,
                isHide: kIsWeb),
            TopicWidget('Record', RecordingPage(), context, isHide: kIsWeb),
          ]).toList(),
        )));
// =======
//       appBar: AppBar(
//         title: Text('ZegoExpressExample'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.settings),
//             onPressed: () {
//               Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
//                 return GlobalSettingPage();
//               }));
//             }
//           )
//         ],
//       ),
//       body: SafeArea(
//         child: ListView(
//           children: ListTile.divideTiles(
//             context: context,
//             tiles: [
//               ListTile(title: Text('快速开始'), tileColor: Colors.grey[300],),
//               TopicWidget('Quick Start', QuickStartPage(), context),
//               TopicWidget('Publish Stream', PublishStreamLoginPage(), context),
//               TopicWidget('Play Stream', PlayStreamLoginPage(), context),

//               ListTile(title: Text('最佳实践'), tileColor: Colors.grey[300],),
//               TopicWidget('VideoTalk', VideoTalkPage(), context),

//               ListTile(title: Text('常用功能'), tileColor: Colors.grey[300],),
//               ...appWidget[0],
//               ...webWidget[0],
//               TopicWidget('RoomMessage', RoomMessagePage(), context),

//               ...appWidget[1],
//               ...appWidget[2],

//               ListTile(title: Text('其他功能'), tileColor: Colors.grey[300],),
//               TopicWidget('Media Player', MediaPlayerResourceSelectionPage(), context),
//               ...appWidget[3],
//             ]
//           ).toList(),
//         )
//       )
//     );
// >>>>>>> flutter_web_demo_2
  }
}

class TopicWidget extends StatelessWidget {
  const TopicWidget(this.title, this.targetPage, this.context,
      {Key? key, this.isHide = false})
      : super(key: key);

  final String title;
  final Widget targetPage;
  final BuildContext context;
  final bool isHide;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      child: _TopicWidget(title, targetPage, context),
      offstage: isHide,
    );
  }
}

class _TopicWidget extends ListTile {
  _TopicWidget(String title, Widget targetPage, BuildContext context)
      : super(
          title: Text(title),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            if (ZegoConfig.instance.appID > 0 &&
                ZegoConfig.instance.appSign.isNotEmpty) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return targetPage;
              }));
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Tips'),
                      content: Text(
                          'Please set up AppID and other necessary configuration first'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();

                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return GlobalSettingPage();
                            }));
                          },
                        )
                      ],
                    );
                  });
            }
          },
        );
}
