import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_call_app/presentation/utils/call_data.dart';

class CallProvider extends ChangeNotifier {
  // State variables
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isScreenSharing = false;
  Timer? _callTimer;
  int _callDuration = 0;
  bool _isDisposed = false;
  bool _isInitialized = false;

  // Getters
  int? get remoteUid => _remoteUid;
  bool get localUserJoined => _localUserJoined;
  RtcEngine get engine => _engine;
  bool get isMuted => _isMuted;
  bool get isCameraOff => _isCameraOff;
  bool get isScreenSharing => _isScreenSharing;
  int get callDuration => _callDuration;
  bool get isInitialized => _isInitialized;

  // Initialize Agora
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _requestPermissions();
      await _initializeEngine();
      await _setupEventHandlers();
      await _joinChannel();
      _isInitialized = true;
    } catch (e) {
      log('Error initializing Agora: $e');
      rethrow;
    }
  }

  Future<void> _requestPermissions() async {
    await [Permission.microphone, Permission.camera].request();
  }

  Future<void> _initializeEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  Future<void> _setupEventHandlers() async {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          log("local user ${connection.localUid} joined");
          if (!_isDisposed) {
            _localUserJoined = true;
            notifyListeners();
            _startCallTimer();
          }
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          log("remote user $remoteUid joined");
          if (!_isDisposed) {
            _remoteUid = remoteUid;
            notifyListeners();
          }
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              log("remote user $remoteUid left channel");
              if (!_isDisposed) {
                _remoteUid = null;
                notifyListeners();
              }
            },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          log(
            '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token',
          );
        },
        onLocalVideoStateChanged:
            (
              VideoSourceType source,
              LocalVideoStreamState state,
              LocalVideoStreamReason error,
            ) {
              log('Local video state: $state, source: $source');
              if (source == VideoSourceType.videoSourceScreen) {
                if (state ==
                    LocalVideoStreamState.localVideoStreamStateStopped) {
                  if (!_isDisposed) {
                    _isScreenSharing = false;
                    notifyListeners();
                  }
                }
              }
            },
      ),
    );
  }

  Future<void> _joinChannel() async {
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: token,
      channelId: 'test1',
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
      ),
    );
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isDisposed) {
        _callDuration++;
        notifyListeners();
      }
    });
  }

  String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Control methods
  void toggleMute() {
    _isMuted = !_isMuted;
    _engine.muteLocalAudioStream(_isMuted);
    notifyListeners();
  }

  void toggleCamera() {
    _isCameraOff = !_isCameraOff;
    _engine.muteLocalVideoStream(_isCameraOff);
    notifyListeners();
  }

  void switchCamera() {
    _engine.switchCamera();
  }

  Future<void> toggleScreenShare() async {
    if (_isScreenSharing) {
      await _stopScreenShare();
    } else {
      await _startScreenShare();
    }
  }

  Future<void> _startScreenShare() async {
    try {
      await _engine.startScreenCapture(
        const ScreenCaptureParameters2(captureAudio: true, captureVideo: true),
      );
      await _engine.updateChannelMediaOptions(
        const ChannelMediaOptions(
          publishCameraTrack: false,
          publishScreenTrack: true,
          publishScreenCaptureAudio: true,
          publishScreenCaptureVideo: true,
        ),
      );
      _isScreenSharing = true;
      notifyListeners();
    } catch (e) {
      log('Error starting screen share: $e');
      rethrow;
    }
  }

  Future<void> _stopScreenShare() async {
    try {
      await _engine.stopScreenCapture();
      await _engine.updateChannelMediaOptions(
        const ChannelMediaOptions(
          publishCameraTrack: true,
          publishScreenTrack: false,
        ),
      );
      _isScreenSharing = false;
      notifyListeners();
    } catch (e) {
      log('Error stopping screen share: $e');
      rethrow;
    }
  }

  Future<void> endCall() async {
    if (_isDisposed) return;

    _isDisposed = true;

    try {
      _callTimer?.cancel();

      if (_isScreenSharing) {
        await _engine.stopScreenCapture();
      }

      await _engine.stopPreview();
      await _engine.leaveChannel();
      await _engine.release();

      log('Agora cleanup completed');
    } catch (e) {
      log('Error ending call: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _callTimer?.cancel();
    _disposeAgoraSync();
    super.dispose();
  }

  void _disposeAgoraSync() {
    Future.microtask(() async {
      try {
        if (_isScreenSharing) {
          await _engine.stopScreenCapture();
        }
        await _engine.leaveChannel();
        await _engine.release();
      } catch (e) {
        log('Error disposing Agora: $e');
      }
    });
  }
}
