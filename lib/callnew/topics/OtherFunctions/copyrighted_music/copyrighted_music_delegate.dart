import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:smatch/callnew//utils/zego_config.dart';
import 'package:smatch/callnew//utils/zego_log_view.dart';
import 'package:smatch/callnew//utils/zego_user_helper.dart';

typedef RoomStateUpdateCallback = void Function(
    String, ZegoRoomState, int, Map<String, dynamic>);
typedef PublisherStateUpdateCallback = void Function(
    String, ZegoPublisherState, int, Map<String, dynamic>);
typedef PlayerStateUpdateCallback = void Function(
    String, ZegoPlayerState, int, Map<String, dynamic>);
typedef MediaPlayerPlayingProgressCallback = void Function(int, double);
// copyrighted music
typedef DownloadProgressUpdateCallback = Function(
    ZegoCopyrightedMusic, String, double);
typedef CurrentPitchValueUpdateCallback = Function(
    ZegoCopyrightedMusic, String, int, int);

class CopyrightedMusicDelegate {
  RoomStateUpdateCallback? _onRoomStateUpdate;
  PublisherStateUpdateCallback? _onPublisherStateUpdate;
  PlayerStateUpdateCallback? _onPlayerStateUpdate;
  MediaPlayerPlayingProgressCallback? _onMediaPlayerPlayingProgress;
  DownloadProgressUpdateCallback? _onDownloadProgressUpdate;
  CurrentPitchValueUpdateCallback? _onCurrentPitchValueUpdate;

  ZegoCopyrightedMusic? _copyrightedMusic;

  List<ZegoMediaPlayer?> _mediaPlayers = [];
  List<int> _totalDurationMediaplayer = [];

  CopyrightedMusicDelegate();

  dispose() {}

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

    ZegoExpressEngine.onMediaPlayerPlayingProgress =
        (ZegoMediaPlayer player, int progress) async {
      int index = _mediaPlayers.indexOf(player);
      // ZegoLog().addLog(
      //     '🚩 📥 Media player onMediaPlayerPlayingProgress index: ${_mediaPlayers.indexOf(player)},  preogress: $progress');
      if (_totalDurationMediaplayer[index] <= 0 ||
          progress > _totalDurationMediaplayer[index]) {
        return;
      }
      _onMediaPlayerPlayingProgress?.call(
          index, progress / _totalDurationMediaplayer[index]);
    };

    ZegoExpressEngine.onDownloadProgressUpdate =
        (ZegoCopyrightedMusic copyrightedMusic, String resourceID,
            double progressRate) {
      ZegoLog().addLog(
          '🚩 📥 Copyrighted Music onDownloadProgressUpdate resourceID: $resourceID, progressRate: $progressRate');
      _onDownloadProgressUpdate?.call(
          copyrightedMusic, resourceID, progressRate);
    };
    ZegoExpressEngine.onCurrentPitchValueUpdate =
        (ZegoCopyrightedMusic copyrightedMusic, String resourceID,
            int currentDuration, int pitchValue) {
      ZegoLog().addLog(
          '🚩 📥 Copyrighted Music onCurrentPitchValueUpdate resourceID: $resourceID, currentDuration: $currentDuration, pitchValue: $pitchValue');
      _onCurrentPitchValueUpdate?.call(
          copyrightedMusic, resourceID, currentDuration, pitchValue);
    };
  }

  void setZegoEventCallback(
      {RoomStateUpdateCallback? onRoomStateUpdate,
      PublisherStateUpdateCallback? onPublisherStateUpdate,
      PlayerStateUpdateCallback? onPlayerStateUpdate,
      MediaPlayerPlayingProgressCallback? onMediaPlayerPlayingProgress,
      DownloadProgressUpdateCallback? onDownloadProgressUpdate,
      CurrentPitchValueUpdateCallback? onCurrentPitchValueUpdate}) {
    if (onRoomStateUpdate != null) {
      _onRoomStateUpdate = onRoomStateUpdate;
    }
    if (onPublisherStateUpdate != null) {
      _onPublisherStateUpdate = onPublisherStateUpdate;
    }
    if (onPlayerStateUpdate != null) {
      _onPlayerStateUpdate = onPlayerStateUpdate;
    }
    if (onMediaPlayerPlayingProgress != null) {
      _onMediaPlayerPlayingProgress = onMediaPlayerPlayingProgress;
    }
    if (onDownloadProgressUpdate != null) {
      _onDownloadProgressUpdate = onDownloadProgressUpdate;
    }
    if (onCurrentPitchValueUpdate != null) {
      _onCurrentPitchValueUpdate = onCurrentPitchValueUpdate;
    }
  }

  void clearZegoEventCallback() {
    _onRoomStateUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = null;

    _onPublisherStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;

    _onPlayerStateUpdate = null;
    ZegoExpressEngine.onPlayerStateUpdate = null;

    _onMediaPlayerPlayingProgress = null;
    ZegoExpressEngine.onMediaPlayerPlayingProgress = null;

    _onDownloadProgressUpdate = null;
    ZegoExpressEngine.onDownloadProgressUpdate = null;

    _onCurrentPitchValueUpdate = null;
    ZegoExpressEngine.onCurrentPitchValueUpdate = null;
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
    ZegoLog().addLog('🏳️ destroyEngine');
    ZegoExpressEngine.destroyEngine();
  }

  Future<void> createCopyrightedMusic() async {
    _copyrightedMusic =
        await ZegoExpressEngine.instance.createCopyrightedMusic();
    ZegoLog().addLog('🚀 Create ZegoCopyrightedMusic');
  }

  void destoryCopyrightedMusic() {
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('🏳️ destoryCopyrightedMusic');
      ZegoExpressEngine.instance.destroyCopyrightedMusic(_copyrightedMusic!);
    }
  }

  void initCopyrightedMusic() {
    if (_copyrightedMusic != null) {
      ZegoLog().addLog(
          '📥 initCopyrightedMusic config.user.userID: ${ZegoUserHelper.instance.userID}');
      _copyrightedMusic!
          .initCopyrightedMusic(ZegoCopyrightedMusicConfig(ZegoUser(
              ZegoUserHelper.instance.userID,
              ZegoUserHelper.instance.userName.isEmpty
                  ? ZegoUserHelper.instance.userID
                  : ZegoUserHelper.instance.userName)))
          .then((value) {
        ZegoLog().addLog('initCopyrightedMusic errorCode: ${value.errorCode}');
      });
    }
  }

  Future<String> sendExtendedRequest(String commond, String params) async {
    String resource = "";
    if (_copyrightedMusic != null) {
      ZegoLog()
          .addLog('📥 sendExtendedRequest commond: $commond, params: $params');
      var result =
          await _copyrightedMusic!.sendExtendedRequest(commond, params);
      resource = result.result;
      ZegoLog().addLog(
          'sendExtendedRequest errorCode: ${result.errorCode} commond: ${result.command} result: ${result.result}');
    }
    return resource;
  }

  Future<String> getMusicByToken(String shareToken) async {
    String resource = "";
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 getMusicByToken shareToken: $shareToken');
      var result = await _copyrightedMusic!.getMusicByToken(shareToken);
      resource = result.resource;
      ZegoLog().addLog(
          'getMusicByToken errorCode: ${result.errorCode} result: ${result.resource}');
    }
    return resource;
  }

  Future<String> getKrcLyricByToken(String krcToken) async {
    String lyrics = "";
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 getKrcLyricByToken krcToken: $krcToken');
      var result = await _copyrightedMusic!.getKrcLyricByToken(krcToken);
      ZegoLog().addLog(
          'getKrcLyricByToken errorCode: ${result.errorCode} lyrics: ${result.lyrics}');
      lyrics = result.lyrics;
    }
    return lyrics;
  }

  Future<String> requestSong(
      String songID, ZegoCopyrightedMusicBillingMode mode) async {
    String resource = "";
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 requestSong songID: $songID  mode: $mode');
      var config = ZegoCopyrightedMusicRequestConfig(songID, mode);
      var result = await _copyrightedMusic!.requestSong(config);
      ZegoLog().addLog(
          'requestSong errorCode: ${result.errorCode} lyrics: ${result.resource}');
      resource = result.resource;
    }
    return resource;
  }

  Future<String> getLrcLyric(String songID) async {
    String lyrics = "";
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 getLrcLyric songID: $songID');
      var result = await _copyrightedMusic!.getLrcLyric(songID);
      ZegoLog().addLog(
          'getLrcLyric errorCode: ${result.errorCode} lyrics: ${result.lyrics}');
      lyrics = result.lyrics;
    }
    return lyrics;
  }

  void queryCache(String songID, ZegoCopyrightedMusicType type) async {
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 queryCache songID: $songID, type: $type');
      var result = await _copyrightedMusic!.queryCache(songID, type);
      ZegoLog().addLog('queryCache : $result');
    }
  }

  Future<String> requestAccompaniment(
      String songID, ZegoCopyrightedMusicBillingMode mode) async {
    String resource = "";
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 requestAccompaniment songID: $songID, mode: $mode');
      var config = ZegoCopyrightedMusicRequestConfig(songID, mode);
      var result = await _copyrightedMusic!.requestAccompaniment(config);
      resource = result.resource;
      ZegoLog().addLog(
          'requestAccompaniment errorCode: ${result.errorCode}, resource: ${result.resource}');
    }
    return resource;
  }

  Future<String> requestAccompanimentClip(
      String songID, ZegoCopyrightedMusicBillingMode mode) async {
    String resource = "";
    if (_copyrightedMusic != null) {
      ZegoLog()
          .addLog('📥 requestAccompanimentClip songID: $songID, mode: $mode');
      var config = ZegoCopyrightedMusicRequestConfig(songID, mode);
      var result = await _copyrightedMusic!.requestAccompanimentClip(config);
      resource = result.resource;
      ZegoLog().addLog(
          'requestAccompanimentClip errorCode: ${result.errorCode}, resource: ${result.resource}');
    }
    return resource;
  }

  Future<int> getTotalScore(String resourceID) async {
    if (resourceID.isEmpty) {
      ZegoLog().addLog('🐛 getTotalScore resourceID isEmpty');
      return -1;
    }
    int score = -1;
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 getTotalScore resourceID: $resourceID');
      score = await _copyrightedMusic!.getTotalScore(resourceID);
      ZegoLog().addLog('getTotalScore score: $score');
    }
    return score;
  }

  Future<int> getPreviousScore(String resourceID) async {
    if (resourceID.isEmpty) {
      ZegoLog().addLog('🐛 getPreviousScore resourceID isEmpty');
      return -1;
    }
    int score = -1;
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 getPreviousScore resourceID: $resourceID');
      score = await _copyrightedMusic!.getPreviousScore(resourceID);
      ZegoLog().addLog('getPreviousScore score: $score');
    }
    return score;
  }

  Future<int> getAverageScore(String resourceID) async {
    if (resourceID.isEmpty) {
      ZegoLog().addLog('🐛 getAverageScore resourceID isEmpty');
      return -1;
    }
    int score = -1;
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 getAverageScore resourceID: $resourceID');
      score = await _copyrightedMusic!.getAverageScore(resourceID);
      ZegoLog().addLog('getAverageScore score: $score');
    }
    return score;
  }

  Future<int> startScore(String resourceID,
      {int pitchValueInterval = 1000}) async {
    if (resourceID.isEmpty) {
      ZegoLog().addLog('🐛 startScore resourceID isEmpty');
      return -1;
    }
    int score = -1;
    if (_copyrightedMusic != null) {
      ZegoLog().addLog(
          '📥 startScore resourceID: $resourceID pitchValueInterval: $pitchValueInterval');
      score =
          await _copyrightedMusic!.startScore(resourceID, pitchValueInterval);
      ZegoLog().addLog('startScore score: $score');
    }
    return score;
  }

  Future<int> stopScore(String resourceID) async {
    if (resourceID.isEmpty) {
      ZegoLog().addLog('🐛 stopScore resourceID isEmpty');
      return -1;
    }
    int score = -1;
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 stopScore resourceID: $resourceID');
      score = await _copyrightedMusic!.stopScore(resourceID);
      ZegoLog().addLog('stopScore score: $score');
    }
    return score;
  }

  Future<int> pauseScore(String resourceID) async {
    if (resourceID.isEmpty) {
      ZegoLog().addLog('🐛 pauseScore resourceID isEmpty');
      return -1;
    }
    int score = -1;
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 pauseScore resourceID: $resourceID');
      score = await _copyrightedMusic!.pauseScore(resourceID);
      ZegoLog().addLog('pauseScore score: $score');
    }
    return score;
  }

  Future<int> resumeScore(String resourceID) async {
    if (resourceID.isEmpty) {
      ZegoLog().addLog('🐛 resumeScore resourceID isEmpty');
      return -1;
    }
    int score = -1;
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 resumeScore resourceID: $resourceID');
      score = await _copyrightedMusic!.resumeScore(resourceID);
      ZegoLog().addLog('resumeScore score: $score');
    }
    return score;
  }

  Future<int> resetScore(String resourceID) async {
    if (resourceID.isEmpty) {
      ZegoLog().addLog('🐛 resetScore resourceID isEmpty');
      return -1;
    }
    int score = -1;
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 resetScore resourceID: $resourceID');
      score = await _copyrightedMusic!.resetScore(resourceID);
      ZegoLog().addLog('resetScore score: $score');
    }
    return score;
  }

  Future<int> getCacheSize() async {
    int cache = 0;
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 getCacheSize');
      cache = await _copyrightedMusic!.getCacheSize();
      ZegoLog().addLog('getCacheSize cache: $cache');
    }
    return cache;
  }

  Future<int> getDuration(String resourceID) async {
    if (resourceID.isEmpty) {
      ZegoLog().addLog('🐛 getDuration resourceID isEmpty');
      return -1;
    }
    int duration = 0;
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 getDuration resourceID: $resourceID');
      duration = await _copyrightedMusic!.getDuration(resourceID);
      ZegoLog().addLog('getDuration duration: $duration');
    }
    return duration;
  }

  void clearCache() {
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 clearCache');
      _copyrightedMusic!.clearCache();
    }
  }

  Future<int> download(String resourceID) async {
    if (resourceID.isEmpty) {
      ZegoLog().addLog('🐛 download resourceID isEmpty');
      return -1;
    }
    int cache = 0;
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 download resourceID: $resourceID');
      var result = await _copyrightedMusic!.download(resourceID);
      ZegoLog().addLog('download errorCode: ${result.errorCode}');
    }
    return cache;
  }

  Future<int> getCurrentPitch(String resourceID) async {
    if (resourceID.isEmpty) {
      ZegoLog().addLog('🐛 getCurrentPitch resourceID isEmpty');
      return -1;
    }
    int pitch = 0;
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 getCurrentPitch resourceID: $resourceID');
      pitch = await _copyrightedMusic!.getCurrentPitch(resourceID);
      ZegoLog().addLog('getCurrentPitch pitch: $pitch');
    }
    return pitch;
  }

  Future<int> getStandardPitch(String resourceID) async {
    if (resourceID.isEmpty) {
      ZegoLog().addLog('🐛 getStandardPitch resourceID isEmpty');
      return -1;
    }
    int pitch = 0;
    if (_copyrightedMusic != null) {
      ZegoLog().addLog('📥 getStandardPitch resourceID: $resourceID');
      var result = await _copyrightedMusic!.getStandardPitch(resourceID);
      ZegoLog().addLog(
          'getStandardPitch eroorCode: ${result.errorCode} pitch: ${result.pitch}');
    }
    return pitch;
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

      ZegoLog().addLog(
          '🚪 Start login room, roomID: $roomID, userID: ${ZegoUserHelper.instance.userID}');
    }
  }

  Future<void> logoutRoom(String roomID) async {
    if (roomID.isNotEmpty) {
      await ZegoExpressEngine.instance.logoutRoom(roomID);

      ZegoLog().addLog('🚪 Start logout room, roomID: $roomID');
    }
  }

  void startPublishing(String streamID, {String? roomID}) async {
    if (roomID != null) {
      await ZegoExpressEngine.instance.startPublishingStream(streamID,
          config: ZegoPublisherConfig(roomID: roomID));
    } else {
      ZegoExpressEngine.instance.startPublishingStream(streamID);
    }
    ZegoLog().addLog('📥 Start publish stream, streamID: $streamID');
  }

  void stopPublishing() {
    ZegoExpressEngine.instance.stopPublishingStream();
    ZegoLog().addLog('📥 Stop publish stream');
  }

  void createMediaPlayer() async {
    ZegoLog().addLog('🚀 createMediaPlayer');
    _mediaPlayers.clear();
    _totalDurationMediaplayer.clear();
    for (var i = 0; i < 4; i++) {
      _mediaPlayers.add(await ZegoExpressEngine.instance.createMediaPlayer());
      _totalDurationMediaplayer.add(0);
    }
  }

  void destroyMediaPlayer() {
    ZegoLog().addLog('🏳️ destroyMediaPlayer');
    for (var _mediaPlayer in _mediaPlayers) {
      if (_mediaPlayer != null) {
        ZegoExpressEngine.instance.destroyMediaPlayer(_mediaPlayer);
      }
    }
    _mediaPlayers.clear();
    _totalDurationMediaplayer.clear();
  }

  // 0 <= progress <=1
  void seekToMediaPlayer(double progress, int mediaPlayIndex) async {
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      int millisecond =
          (_totalDurationMediaplayer[mediaPlayIndex] * progress).toInt();
      ZegoLog().addLog(
          '📥 seekToMediaPlayer progress: $millisecond, mediaPlayIndex: $mediaPlayIndex');
      var result = await mediaPlayer.seekTo(millisecond);
      ZegoLog().addLog('seekToMediaPlayer errorCode: ${result.errorCode}');
    }
  }

  Future<void> loadResourceMediaPlayer(
      String resourceID, int startPosition, int mediaPlayIndex) async {
    ZegoLog().addLog(
        '📥 loadResourceMediaPlayer resourceID: $resourceID, startPosition: $startPosition, mediaPlayIndex: $mediaPlayIndex');
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      var result = await mediaPlayer.loadCopyrightedMusicResourceWithPosition(
          resourceID, startPosition);
      ZegoLog()
          .addLog('loadResourceMediaPlayer errorCode: ${result.errorCode}');
      _totalDurationMediaplayer[mediaPlayIndex] =
          await mediaPlayer.getTotalDuration();
    }
  }

  void startMediaPlayer(int mediaPlayIndex) {
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      ZegoLog().addLog('📥 startMediaPlayer mediaPlayIndex: $mediaPlayIndex');
      mediaPlayer.start();
    }
  }

  void pauseMediaPlayer(int mediaPlayIndex) {
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      ZegoLog().addLog('📥 pauseMediaPlayer mediaPlayIndex: $mediaPlayIndex');
      mediaPlayer.pause();
    }
  }

  void resumeMediaPlayer(int mediaPlayIndex) {
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      ZegoLog().addLog('📥 resumeMediaPlayer mediaPlayIndex: $mediaPlayIndex');
      mediaPlayer.resume();
    }
  }

  void stopMediaPlayer(int mediaPlayIndex) {
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      ZegoLog().addLog('📥 stopMediaPlayer mediaPlayIndex: $mediaPlayIndex');
      mediaPlayer.stop();
    }
  }

  void setVolumeMediaPlayer(double volume, int mediaPlayIndex) {
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      ZegoLog().addLog(
          '📥 stopMediaPlayer volume: ${200 * volume} mediaPlayIndex: $mediaPlayIndex');
      mediaPlayer.setVolume((200 * volume).toInt());
    }
  }

  void repeatMediaPlayer(bool enable, int mediaPlayIndex) {
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      ZegoLog().addLog(
          '📥 repeatMediaPlayer enable: $enable mediaPlayIndex: $mediaPlayIndex');
      mediaPlayer.enableRepeat(enable);
    }
  }

  void enableAuxMediaPlayer(bool enable, int mediaPlayIndex) {
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      ZegoLog().addLog(
          '📥 enableAux enable: $enable mediaPlayIndex: $mediaPlayIndex');
      mediaPlayer.enableAux(enable);
    }
  }

  void muteLocalMediaPlayer(bool mute, int mediaPlayIndex) {
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      ZegoLog().addLog(
          '📥 muteLocalMediaPlayer mute: $mute mediaPlayIndex: $mediaPlayIndex');
      mediaPlayer.muteLocal(mute);
    }
  }

  void setAudioTrackIndexMediaPlayer(int index, int mediaPlayIndex) {
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      ZegoLog().addLog(
          '📥 setAudioTrackIndexMediaPlayer index: $index mediaPlayIndex: $mediaPlayIndex');
      mediaPlayer.setAudioTrackIndex(index);
    }
  }

  void setVoiceChangerParamMediaPlayer(double value, int mediaPlayIndex) {
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      ZegoLog().addLog(
          '📥 setVoiceChangerParamMediaPlayer audioChannel: ${ZegoMediaPlayerAudioChannel.All} pitch: $value mediaPlayIndex: $mediaPlayIndex');
      mediaPlayer.setVoiceChangerParam(
          ZegoMediaPlayerAudioChannel.All, ZegoVoiceChangerParam(value));
    }
  }

  void setPlaySpeedMediaPlayer(double speed, int mediaPlayIndex) {
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      ZegoLog().addLog(
          '📥 setPlaySpeedMediaPlayer speed: $speed mediaPlayIndex: $mediaPlayIndex');
      mediaPlayer.setPlaySpeed(speed);
    }
  }

  Future<int> getAudioTrackCount(int mediaPlayIndex) async {
    int count = 0;
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      ZegoLog().addLog(
          '📥 getAudioTrackCountMediaPlayer mediaPlayIndex: $mediaPlayIndex');
      count = await mediaPlayer.getAudioTrackCount();
      ZegoLog().addLog('getAudioTrackCountMediaPlayer count: $count');
    }
    return count;
  }

  void getPublishVolume(int mediaPlayIndex) {
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      mediaPlayer
          .getPublishVolume()
          .then((value) => ZegoLog().addLog('📥 PublishVolume: $value'));
    }
  }

  void setPublishVolume(int mediaPlayIndex, int volume) {
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      ZegoLog().addLog('📥 setPublishVolume: $volume');
      mediaPlayer.setPublishVolume(volume);
    }
  }

  void getPlaybackVolume(int mediaPlayIndex) {
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      mediaPlayer
          .getPlayVolume()
          .then((value) => ZegoLog().addLog('📥 PlayVolume: $value'));
    }
  }

  void setPlaybackVolume(int mediaPlayIndex, int volume) {
    var mediaPlayer = _mediaPlayers[mediaPlayIndex];
    if (mediaPlayer != null) {
      ZegoLog().addLog('📥 setPlaybackVolume: $volume');
      mediaPlayer.setPlayVolume(volume);
    }
  }

  String jsonStringFormat(String jsonString) {
    String formatString = "";
    int tabCount = 0;
    String space = " ";
    for (var i = 0; i < jsonString.length; i++) {
      int lastIndex = i + 1;
      var tmpStr = jsonString.substring(i, lastIndex);
      if (tmpStr == "{" || tmpStr == "[") {
        formatString += tmpStr;
        tabCount += 2;
        formatString += "\n" + space * tabCount;
      } else if (tmpStr == ",") {
        formatString += tmpStr;
        formatString += "\n" + space * tabCount;
      } else if (tmpStr == "}" || tmpStr == "]") {
        tabCount -= 2;
        formatString += "\n" + space * tabCount;
        formatString += tmpStr;
      } else {
        formatString += tmpStr;
      }
    }
    ZegoLog().addLog(formatString);
    return formatString;
  }
}
