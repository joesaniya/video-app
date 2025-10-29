// import 'dart:async';
// import 'dart:developer';

// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:video_call_app/presentation/screens/home_screen.dart';

// import 'package:video_call_app/presentation/utils/appcolors.dart';

// const appId = "35f67e0fd1714eb1b8d2dac2081e2c7a";
// const token =
//     "007eJxTYFBvX/0sZYrgXpNDny6ciJ/KrvVUg1lV5vzZg5PWKcfGu1koMBibppmZpxqkpRiaG5qkJhkmWaQYpSQmGxlYGKYaJZsn+p1lyGwIZGRwc5ZjYWSAQBCflaEktbjEkIEBADIHHhc=";

// class CallScreen extends StatefulWidget {
//   final VoidCallback? onCallEnded;
//   final String username;
//   final String meetingId;

//   const CallScreen({
//     super.key,
//     required this.onCallEnded,
//     required this.username,
//     required this.meetingId,
//   });

//   @override
//   State<CallScreen> createState() => _CallScreenState();
// }

// class _CallScreenState extends State<CallScreen> {
//   int? _remoteUid;
//   bool _localUserJoined = false;
//   late RtcEngine _engine;
//   bool _isMuted = false;
//   bool _isCameraOff = false;
//   bool _isScreenSharing = false;
//   Timer? _callTimer;
//   int _callDuration = 0;
//   bool _isDisposed = false;

//   @override
//   void initState() {
//     super.initState();
//     initAgora();
//   }

//   Future<void> initAgora() async {
//     await [Permission.microphone, Permission.camera].request();

//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(
//       const RtcEngineContext(
//         appId: appId,
//         channelProfile: ChannelProfileType.channelProfileCommunication,
//       ),
//     );

//     _engine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           log("local user ${connection.localUid} joined");
//           if (!_isDisposed) {
//             setState(() {
//               _localUserJoined = true;
//             });
//             _startCallTimer();
//           }
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           log("remote user $remoteUid joined");
//           if (!_isDisposed) {
//             setState(() {
//               _remoteUid = remoteUid;
//             });
//           }
//         },
//         onUserOffline:
//             (
//               RtcConnection connection,
//               int remoteUid,
//               UserOfflineReasonType reason,
//             ) {
//               log("remote user $remoteUid left channel");
//               if (!_isDisposed) {
//                 setState(() {
//                   _remoteUid = null;
//                 });
//                 _showRemoteUserLeftDialog();
//               }
//             },
//         onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
//           log(
//             '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token',
//           );
//         },
//         onLocalVideoStateChanged:
//             (
//               VideoSourceType source,
//               LocalVideoStreamState state,
//               LocalVideoStreamReason error,
//             ) {
//               log('Local video state: $state, source: $source');
//               if (source == VideoSourceType.videoSourceScreen) {
//                 if (state ==
//                     LocalVideoStreamState.localVideoStreamStateStopped) {
//                   if (!_isDisposed) {
//                     setState(() {
//                       _isScreenSharing = false;
//                     });
//                   }
//                 }
//               }
//             },
//       ),
//     );

//     await _engine.enableVideo();
//     await _engine.startPreview();

//     await _engine.joinChannel(
//       token: token,
//       channelId: widget.meetingId,
//       uid: 0,
//       options: const ChannelMediaOptions(
//         clientRoleType: ClientRoleType.clientRoleBroadcaster,
//         channelProfile: ChannelProfileType.channelProfileCommunication,
//         publishCameraTrack: true,
//         publishMicrophoneTrack: true,
//       ),
//     );
//   }

//   void _startCallTimer() {
//     _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (!_isDisposed) {
//         setState(() {
//           _callDuration++;
//         });
//       }
//     });
//   }

//   String _formatDuration(int seconds) {
//     int hours = seconds ~/ 3600;
//     int minutes = (seconds % 3600) ~/ 60;
//     int secs = seconds % 60;

//     if (hours > 0) {
//       return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
//     }
//     return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
//   }

//   void _showRemoteUserLeftDialog() {
//     if (_isDisposed || !mounted) return;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text('Call Ended'),
//         content: const Text('Guest has left the call'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(dialogContext).pop(); // Use dialogContext
//               _endCall();
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   // 2. Replace dispose method:
//   @override
//   void dispose() {
//     _isDisposed = true;
//     _callTimer?.cancel();
//     _disposeAgoraSync();
//     super.dispose();
//   }

//   // 3. Add this new method:
//   void _disposeAgoraSync() {
//     Future.microtask(() async {
//       try {
//         if (_isScreenSharing) {
//           await _engine.stopScreenCapture();
//         }
//         await _engine.leaveChannel();
//         await _engine.release();
//       } catch (e) {
//         log('Error disposing Agora: $e');
//       }
//     });
//   }

//   // 4. Replace _disposeAgora method (or remove it if you have it):
//   // Remove the old _disposeAgora method completely

//   // 5. Replace _endCall method:
//   Future<void> _endCall() async {
//     log('Ending call...');

//     if (_isDisposed) return;

//     // Mark as disposed immediately to prevent multiple calls
//     _isDisposed = true;

//     try {
//       // Cancel timer first
//       _callTimer?.cancel();

//       // Stop screen sharing if active
//       if (_isScreenSharing) {
//         await _engine.stopScreenCapture();
//       }

//       // Stop preview and leave channel
//       await _engine.stopPreview();
//       await _engine.leaveChannel();

//       // Release the engine
//       await _engine.release();

//       log('Agora cleanup completed');
//     } catch (e) {
//       log('Error during Agora cleanup: $e');
//     }

//     // Call the callback
//     widget.onCallEnded?.call();

//     // Navigate safely after cleanup
//     if (mounted) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (_) => const HomeScreen()),
//           );
//         }
//       });
//     }
//   }

//   // 6. Replace endCall method:
//   Future<void> endCall() async {
//     if (_isDisposed) return;

//     // Mark as disposed first
//     _isDisposed = true;

//     try {
//       // Cancel timer first
//       _callTimer?.cancel();

//       // Stop screen sharing if active
//       if (_isScreenSharing) {
//         await _engine.stopScreenCapture();
//       }

//       // Stop preview and leave channel
//       await _engine.stopPreview();
//       await _engine.leaveChannel();

//       // Release the engine
//       await _engine.release();

//       log('Agora cleanup completed');
//     } catch (e) {
//       log('Error ending call: $e');
//     }

//     // Call the callback
//     widget.onCallEnded?.call();

//     // Navigate safely
//     if (mounted) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (_) => const HomeScreen()),
//           );
//         }
//       });
//     }
//   }

//   void _toggleMute() {
//     setState(() {
//       _isMuted = !_isMuted;
//     });
//     _engine.muteLocalAudioStream(_isMuted);
//   }

//   void _toggleCamera() {
//     setState(() {
//       _isCameraOff = !_isCameraOff;
//     });
//     _engine.muteLocalVideoStream(_isCameraOff);
//   }

//   void _switchCamera() {
//     _engine.switchCamera();
//   }

//   Future<void> _toggleScreenShare() async {
//     if (_isScreenSharing) {
//       // Stop screen sharing
//       try {
//         await _engine.stopScreenCapture();
//         await _engine.updateChannelMediaOptions(
//           const ChannelMediaOptions(
//             publishCameraTrack: true,
//             publishScreenTrack: false,
//           ),
//         );
//         setState(() {
//           _isScreenSharing = false;
//         });
//       } catch (e) {
//         log('Error stopping screen share: $e');
//       }
//     } else {
//       // Start screen sharing
//       try {
//         await _engine.startScreenCapture(
//           const ScreenCaptureParameters2(
//             captureAudio: true,
//             captureVideo: true,
//           ),
//         );
//         await _engine.updateChannelMediaOptions(
//           const ChannelMediaOptions(
//             publishCameraTrack: false,
//             publishScreenTrack: true,
//             publishScreenCaptureAudio: true,
//             publishScreenCaptureVideo: true,
//           ),
//         );
//         setState(() {
//           _isScreenSharing = true;
//         });
//       } catch (e) {
//         log('Error starting screen share: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to start screen sharing: $e')),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     log('Name: ${widget.username}, Meeting ID: ${widget.meetingId}');
//     final colors = AppColors();
//     return WillPopScope(
//       onWillPop: () async {
//         // Prevent back button, force user to use End Call button
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: colors.bgColor,
//         body: Stack(
//           children: [
//             // Remote video (full screen)
//             Positioned.fill(child: _remoteVideo()),

//             // Top section with name and call duration
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: EdgeInsets.only(
//                   top: MediaQuery.of(context).padding.top + 16,
//                   left: 20,
//                   right: 20,
//                   bottom: 20,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.black.withOpacity(0.7),
//                       Colors.black.withOpacity(0.3),
//                       Colors.transparent,
//                     ],
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.username,
//                           style: GoogleFonts.poppins(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),

//                         const SizedBox(height: 2),
//                         Text(
//                           _formatDuration(_callDuration),
//                           style: GoogleFonts.poppins(
//                             color: Colors.white.withOpacity(0.7),
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),

//                     // Local video preview (small)
//                     Container(
//                       width: 90,
//                       height: 120,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.3),
//                           width: 2,
//                         ),
//                       ),
//                       clipBehavior: Clip.antiAlias,
//                       child: _localPreview(),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Screen sharing indicator
//             if (_isScreenSharing)
//               Positioned(
//                 top: MediaQuery.of(context).padding.top + 140,
//                 left: 20,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(
//                         Icons.screen_share,
//                         color: Colors.white,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         'Sharing Screen',
//                         style: GoogleFonts.poppins(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//             // Bottom control buttons
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: EdgeInsets.only(
//                   bottom: MediaQuery.of(context).padding.bottom + 40,
//                   top: 40,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                     colors: [
//                       Colors.black.withOpacity(0.8),
//                       Colors.black.withOpacity(0.4),
//                       Colors.transparent,
//                     ],
//                   ),
//                 ),
//                 child: Wrap(
//                   alignment: WrapAlignment.spaceEvenly,
//                   spacing: 8,
//                   runSpacing: 12,
//                   children: [
//                     _buildControlButton(
//                       icon: _isMuted ? Icons.mic_off : Icons.mic,
//                       label: 'Mute',
//                       onTap: _toggleMute,
//                       isActive: _isMuted,
//                     ),
//                     _buildControlButton(
//                       icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
//                       label: 'Camera',
//                       onTap: _toggleCamera,
//                       isActive: _isCameraOff,
//                     ),
//                     _buildControlButton(
//                       icon: Icons.flip_camera_ios,
//                       label: 'Flip',
//                       onTap: _switchCamera,
//                     ),
//                     _buildControlButton(
//                       icon: _isScreenSharing
//                           ? Icons.stop_screen_share
//                           : Icons.screen_share,
//                       label: 'Share',
//                       onTap: _toggleScreenShare,
//                       isActive: _isScreenSharing,
//                       backgroundColor: _isScreenSharing ? Colors.green : null,
//                     ),
//                     _buildControlButton(
//                       icon: Icons.call_end,
//                       label: 'End',
//                       onTap: _endCall,
//                       backgroundColor: const Color(0xFFFF4757),
//                       isEndButton: true,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildControlButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     Color? backgroundColor,
//     bool isActive = false,
//     bool isEndButton = false,
//   }) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: onTap,
//             customBorder: const CircleBorder(),
//             child: Container(
//               width: 56,
//               height: 56,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color:
//                     backgroundColor ??
//                     (isActive
//                         ? Colors.white.withOpacity(0.4)
//                         : Colors.white.withOpacity(0.2)),
//                 border: isEndButton
//                     ? null
//                     : Border.all(
//                         color: Colors.white.withOpacity(0.3),
//                         width: 1,
//                       ),
//               ),
//               child: Icon(icon, color: Colors.white, size: 28),
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _localPreview() {
//     if (_isScreenSharing) {
//       // Show screen share preview
//       return AgoraVideoView(
//         controller: VideoViewController(
//           rtcEngine: _engine,
//           canvas: const VideoCanvas(
//             uid: 0,
//             sourceType: VideoSourceType.videoSourceScreen,
//           ),
//         ),
//       );
//     } else if (_localUserJoined) {
//       // Show camera preview
//       return AgoraVideoView(
//         controller: VideoViewController(
//           rtcEngine: _engine,
//           canvas: const VideoCanvas(uid: 0),
//         ),
//       );
//     } else {
//       return Container(
//         color: Colors.grey[800],
//         child: const Center(
//           child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//         ),
//       );
//     }
//   }

//   Widget _remoteVideo() {
//     if (_remoteUid != null) {
//       return AgoraVideoView(
//         controller: VideoViewController.remote(
//           rtcEngine: _engine,
//           canvas: VideoCanvas(uid: _remoteUid),
//           connection: RtcConnection(channelId: widget.meetingId),
//         ),
//       );
//     } else {
//       return Container(
//         color: Colors.black,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.person_outline,
//                 size: 80,
//                 color: Colors.white.withOpacity(0.3),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Waiting for guest to join...',
//                 style: GoogleFonts.poppins(
//                   color: Colors.white.withOpacity(0.7),
//                   fontSize: 16,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),
//             ],
//           ),
//         ),
//       );
//     }
//   }
// }
// /*
//  void _showRemoteUserLeftDialog() {
//     if (_isDisposed) return;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text('Call Ended'),
//         content: const Text('Guest has left the call'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close dialog
//               _endCall();
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
// Future<void> _endCall() async {
//     log('Ending call...');

//     if (_isDisposed) return;

//     // Mark as disposed immediately to prevent multiple calls
//     _isDisposed = true;

//     try {
//       // Cancel timer first
//       _callTimer?.cancel();

//       // Stop screen sharing if active
//       if (_isScreenSharing) {
//         await _engine.stopScreenCapture();
//       }

//       // Stop preview and leave channel
//       await _engine.stopPreview();
//       await _engine.leaveChannel();

//       // Release the engine
//       await _engine.release();

//       log('Agora cleanup completed');
//     } catch (e) {
//       log('Error during Agora cleanup: $e');
//     }

//     // Call the callback to switch tabs (don't use Navigator.pop)
//     if (mounted) {
//       widget.onCallEnded?.call();
//     }
//   }

//   Future<void> endCall() async {
//     if (_isDisposed) return;

//     try {
//       // Cancel timer first
//       _callTimer?.cancel();

//       // Stop screen sharing if active
//       if (_isScreenSharing) {
//         await _engine.stopScreenCapture();
//       }

//       // Stop preview and leave channel
//       await _engine.stopPreview();
//       await _engine.leaveChannel();

//       // Release the engine
//       await _engine.release();

//       // Mark as disposed
//       _isDisposed = true;

//       // Call the callback and pop
//       if (mounted) {
//         widget.onCallEnded?.call();
//         Navigator.of(context).pop();
//       }
//     } catch (e) {
//       log('Error ending call: $e');
//       _isDisposed = true;
//       if (mounted) {
//         widget.onCallEnded?.call();
//         Navigator.of(context).pop();
//       }
//     }
//   }@override
//   void dispose() {
//     _isDisposed = true;
//     _callTimer?.cancel();
//     _disposeAgora();
//     super.dispose();
//   }

//   Future<void> _disposeAgora() async {
//     try {
//       if (_isScreenSharing) {
//         await _engine.stopScreenCapture();
//       }
//       await _engine.leaveChannel();
//       await _engine.release();
//     } catch (e) {
//       log('Error disposing Agora: $e');
//     }
//   }*
// */// import 'dart:async';

// // import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// // import 'package:flutter/material.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:provider/provider.dart';
// // import 'package:video_call_app/Business-Logic/home-provider.dart';
// // import 'package:video_call_app/Business-Logic/profiile-provider.dart';
// // import 'package:video_call_app/presentation/utils/appcolors.dart';

// // const appId = "35f67e0fd1714eb1b8d2dac2081e2c7a";
// // const token =
// //     "007eJxTYFBvX/0sZYrgXpNDny6ciJ/KrvVUg1lV5vzZg5PWKcfGu1koMBibppmZpxqkpRiaG5qkJhkmWaQYpSQmGxlYGKYaJZsn+p1lyGwIZGRwc5ZjYWSAQBCflaEktbjEkIEBADIHHhc=";
// // const channel = "test1";

// // class AppTest extends StatefulWidget {
// //   final VoidCallback? onCallEnded;

// //   const AppTest({Key? key, this.onCallEnded}) : super(key: key);

// //   @override
// //   State<AppTest> createState() => _AppTestState();
// // }

// // class _AppTestState extends State<AppTest> {
// //   int? _remoteUid;
// //   bool _localUserJoined = false;
// //   late RtcEngine _engine;
// //   bool _isMuted = false;
// //   bool _isCameraOff = false;
// //   Timer? _callTimer;
// //   int _callDuration = 0;

// //   @override
// //   void initState() {
// //     super.initState();
// //     initAgora();
// //   }

// //   Future<void> initAgora() async {
// //     await [Permission.microphone, Permission.camera].request();

// //     _engine = createAgoraRtcEngine();
// //     await _engine.initialize(
// //       const RtcEngineContext(
// //         appId: appId,
// //         channelProfile: ChannelProfileType.channelProfileCommunication,
// //       ),
// //     );

// //     _engine.registerEventHandler(
// //       RtcEngineEventHandler(
// //         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
// //           debugPrint("local user ${connection.localUid} joined");
// //           setState(() {
// //             _localUserJoined = true;
// //           });
// //           _startCallTimer();
// //         },
// //         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
// //           debugPrint("remote user $remoteUid joined");
// //           setState(() {
// //             _remoteUid = remoteUid;
// //           });
// //         },
// //         onUserOffline:
// //             (
// //               RtcConnection connection,
// //               int remoteUid,
// //               UserOfflineReasonType reason,
// //             ) {
// //               debugPrint("remote user $remoteUid left channel");
// //               setState(() {
// //                 _remoteUid = null;
// //               });
// //               // Optionally end call when remote user leaves
// //               _showRemoteUserLeftDialog();
// //             },
// //         onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
// //           debugPrint(
// //             '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token',
// //           );
// //         },
// //       ),
// //     );

// //     await _engine.enableVideo();
// //     await _engine.startPreview();

// //     await _engine.joinChannel(
// //       token: token,
// //       channelId: channel,
// //       uid: 0,
// //       options: const ChannelMediaOptions(
// //         clientRoleType: ClientRoleType.clientRoleBroadcaster,
// //         channelProfile: ChannelProfileType.channelProfileCommunication,
// //       ),
// //     );
// //   }

// //   void _startCallTimer() {
// //     _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
// //       setState(() {
// //         _callDuration++;
// //       });
// //     });
// //   }

// //   String _formatDuration(int seconds) {
// //     int hours = seconds ~/ 3600;
// //     int minutes = (seconds % 3600) ~/ 60;
// //     int secs = seconds % 60;

// //     if (hours > 0) {
// //       return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
// //     }
// //     return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
// //   }

// //   void _showRemoteUserLeftDialog() {
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (context) => AlertDialog(
// //         title: const Text('Call Ended'),
// //         content: Text('guest has left the call'),
// //         actions: [
// //           TextButton(
// //             onPressed: () {
// //               Navigator.of(context).pop();
// //               _endCall();
// //             },
// //             child: const Text('OK'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _callTimer?.cancel();
// //     _dispose();
// //     super.dispose();
// //   }

// //   Future<void> _dispose() async {
// //     await _engine.leaveChannel();
// //     await _engine.release();
// //   }

// //   void _toggleMute() {
// //     setState(() {
// //       _isMuted = !_isMuted;
// //     });
// //     _engine.muteLocalAudioStream(_isMuted);
// //   }

// //   void _toggleCamera() {
// //     setState(() {
// //       _isCameraOff = !_isCameraOff;
// //     });
// //     _engine.muteLocalVideoStream(_isCameraOff);
// //   }

// //   void _switchCamera() {
// //     _engine.switchCamera();
// //   }

// //   Future<void> _endCall() async {
// //     try {
// //       _callTimer?.cancel();
// //       await _engine.stopPreview();
// //       await _engine.leaveChannel();
// //       await _engine.release();
// //       widget.onCallEnded?.call();
// //     } catch (e) {
// //       debugPrint('Error ending call: $e');
// //       widget.onCallEnded?.call();
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final profileProvider = Provider.of<ProfileProvider>(context);
// //     final colors = AppColors();
// //     return Scaffold(
// //       backgroundColor: colors.bgColor,
// //       body: profileProvider.isLoading
// //           ? Center(child: CircularProgressIndicator(color: colors.whiteColor))
// //           : Stack(
// //               children: [
// //                 // Remote video (full screen)
// //                 Positioned.fill(child: _remoteVideo()),

// //                 // Top section with name and call duration
// //                 Positioned(
// //                   top: 0,
// //                   left: 0,
// //                   right: 0,
// //                   child: Container(
// //                     padding: EdgeInsets.only(
// //                       top: MediaQuery.of(context).padding.top + 16,
// //                       left: 20,
// //                       right: 20,
// //                       bottom: 20,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       gradient: LinearGradient(
// //                         begin: Alignment.topCenter,
// //                         end: Alignment.bottomCenter,
// //                         colors: [
// //                           Colors.black.withOpacity(0.7),
// //                           Colors.black.withOpacity(0.3),
// //                           Colors.transparent,
// //                         ],
// //                       ),
// //                     ),
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         // Name and time
// //                         Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               profileProvider.currentUser?.name ?? 'User Name',
// //                               style: const TextStyle(
// //                                 color: Colors.white,
// //                                 fontSize: 22,
// //                                 fontWeight: FontWeight.w600,
// //                               ),
// //                             ),
// //                             const SizedBox(height: 4),
// //                             Text(
// //                               _formatDuration(_callDuration),
// //                               style: TextStyle(
// //                                 color: Colors.white.withOpacity(0.7),
// //                                 fontSize: 14,
// //                               ),
// //                             ),
// //                           ],
// //                         ),

// //                         // Local video preview (small)
// //                         Container(
// //                           width: 90,
// //                           height: 120,
// //                           decoration: BoxDecoration(
// //                             borderRadius: BorderRadius.circular(12),
// //                             border: Border.all(
// //                               color: Colors.white.withOpacity(0.3),
// //                               width: 2,
// //                             ),
// //                           ),
// //                           clipBehavior: Clip.antiAlias,
// //                           child: _localUserJoined
// //                               ? AgoraVideoView(
// //                                   controller: VideoViewController(
// //                                     rtcEngine: _engine,
// //                                     canvas: const VideoCanvas(uid: 0),
// //                                   ),
// //                                 )
// //                               : Container(
// //                                   color: Colors.grey[800],
// //                                   child: const Center(
// //                                     child: CircularProgressIndicator(
// //                                       color: Colors.white,
// //                                       strokeWidth: 2,
// //                                     ),
// //                                   ),
// //                                 ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),

// //                 // Bottom control buttons
// //                 Positioned(
// //                   bottom: 0,
// //                   left: 0,
// //                   right: 0,
// //                   child: Container(
// //                     padding: EdgeInsets.only(
// //                       bottom: MediaQuery.of(context).padding.bottom + 40,
// //                       top: 40,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       gradient: LinearGradient(
// //                         begin: Alignment.bottomCenter,
// //                         end: Alignment.topCenter,
// //                         colors: [
// //                           Colors.black.withOpacity(0.8),
// //                           Colors.black.withOpacity(0.4),
// //                           Colors.transparent,
// //                         ],
// //                       ),
// //                     ),
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                       children: [
// //                         _buildControlButton(
// //                           icon: _isMuted ? Icons.mic_off : Icons.mic,
// //                           label: 'Mute',
// //                           onTap: _toggleMute,
// //                           isActive: _isMuted,
// //                         ),
// //                         _buildControlButton(
// //                           icon: _isCameraOff
// //                               ? Icons.videocam_off
// //                               : Icons.videocam,
// //                           label: 'Camera',
// //                           onTap: _toggleCamera,
// //                           isActive: _isCameraOff,
// //                         ),
// //                         _buildControlButton(
// //                           icon: Icons.flip_camera_ios,
// //                           label: 'Flip',
// //                           onTap: _switchCamera,
// //                         ),
// //                         _buildControlButton(
// //                           icon: Icons.call_end,
// //                           label: 'End',
// //                           onTap: _endCall,
// //                           backgroundColor: const Color(0xFFFF4757),
// //                           isEndButton: true,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //     );
// //   }

// //   Widget _buildControlButton({
// //     required IconData icon,
// //     required String label,
// //     required VoidCallback onTap,
// //     Color? backgroundColor,
// //     bool isActive = false,
// //     bool isEndButton = false,
// //   }) {
// //     return Column(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         Material(
// //           color: Colors.transparent,
// //           child: InkWell(
// //             onTap: onTap,
// //             customBorder: const CircleBorder(),
// //             child: Container(
// //               width: 56,
// //               height: 56,
// //               decoration: BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 color:
// //                     backgroundColor ??
// //                     (isActive
// //                         ? Colors.white.withOpacity(0.4)
// //                         : Colors.white.withOpacity(0.2)),
// //                 border: isEndButton
// //                     ? null
// //                     : Border.all(
// //                         color: Colors.white.withOpacity(0.3),
// //                         width: 1,
// //                       ),
// //               ),
// //               child: Icon(icon, color: Colors.white, size: 28),
// //             ),
// //           ),
// //         ),
// //         const SizedBox(height: 8),
// //         Text(
// //           label,
// //           style: const TextStyle(
// //             color: Colors.white,
// //             fontSize: 12,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _remoteVideo() {
// //     if (_remoteUid != null) {
// //       return AgoraVideoView(
// //         controller: VideoViewController.remote(
// //           rtcEngine: _engine,
// //           canvas: VideoCanvas(uid: _remoteUid),
// //           connection: const RtcConnection(channelId: channel),
// //         ),
// //       );
// //     } else {
// //       return Container(
// //         color: Colors.black,
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(
// //                 Icons.person_outline,
// //                 size: 80,
// //                 color: Colors.white.withOpacity(0.3),
// //               ),
// //               const SizedBox(height: 16),
// //               Text(
// //                 'Waiting for guest to join...',
// //                 style: TextStyle(
// //                   color: Colors.white.withOpacity(0.7),
// //                   fontSize: 16,
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }
// //   }
// // }/*import 'dart:async';

// // import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// // import 'package:flutter/material.dart';
// // import 'package:permission_handler/permission_handler.dart';

// // const appId = "35f67e0fd1714eb1b8d2dac2081e2c7a";
// // const token =
// //     "007eJxTYFBvX/0sZYrgXpNDny6ciJ/KrvVUg1lV5vzZg5PWKcfGu1koMBibppmZpxqkpRiaG5qkJhkmWaQYpSQmGxlYGKYaJZsn+p1lyGwIZGRwc5ZjYWSAQBCflaEktbjEkIEBADIHHhc=";
// // const channel = "test1";

// // class AppTest extends StatefulWidget {
// //   final VoidCallback? onCallEnded;

// //   const AppTest({Key? key, this.onCallEnded}) : super(key: key);

// //   @override
// //   State<AppTest> createState() => _AppTestState();
// // }

// // class _AppTestState extends State<AppTest> {
// //   int? _remoteUid;
// //   bool _localUserJoined = false;
// //   late RtcEngine _engine;
// //   bool _isMuted = false;
// //   bool _isCameraOff = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     initAgora();
// //   }

// //   Future<void> initAgora() async {
// //     await [Permission.microphone, Permission.camera].request();

// //     _engine = createAgoraRtcEngine();
// //     await _engine.initialize(
// //       const RtcEngineContext(
// //         appId: appId,
// //         channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
// //       ),
// //     );

// //     _engine.registerEventHandler(
// //       RtcEngineEventHandler(
// //         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
// //           debugPrint("local user ${connection.localUid} joined");
// //           setState(() {
// //             _localUserJoined = true;
// //           });
// //         },
// //         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
// //           debugPrint("remote user $remoteUid joined");
// //           setState(() {
// //             _remoteUid = remoteUid;
// //           });
// //         },
// //         onUserOffline:
// //             (
// //               RtcConnection connection,
// //               int remoteUid,
// //               UserOfflineReasonType reason,
// //             ) {
// //               debugPrint("remote user $remoteUid left channel");
// //               setState(() {
// //                 _remoteUid = null;
// //               });
// //             },
// //         onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
// //           debugPrint(
// //             '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token',
// //           );
// //         },
// //       ),
// //     );

// //     await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
// //     await _engine.enableVideo();
// //     await _engine.startPreview();

// //     await _engine.joinChannel(
// //       token: token,
// //       channelId: channel,
// //       uid: 0,
// //       options: const ChannelMediaOptions(),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     super.dispose();
// //     _dispose();
// //   }

// //   Future<void> _dispose() async {
// //     await _engine.leaveChannel();
// //     await _engine.release();
// //   }

// //   void _toggleMute() {
// //     setState(() {
// //       _isMuted = !_isMuted;
// //     });
// //     _engine.muteLocalAudioStream(_isMuted);
// //   }

// //   void _toggleCamera() {
// //     setState(() {
// //       _isCameraOff = !_isCameraOff;
// //     });
// //     _engine.muteLocalVideoStream(_isCameraOff);
// //   }

// //   void _switchCamera() {
// //     _engine.switchCamera();
// //   }

// //   void endCall() {
// //     // Navigator.of(context).pop();
// //     widget.onCallEnded?.call();
// //   }

// //   Future<void> _endCall() async {
// //     try {
// //       // Stop preview
// //       await _engine.stopPreview();

// //       // Leave the channel (this notifies remote users)
// //       await _engine.leaveChannel();

// //       // Release engine resources
// //       await _engine.release();

// //       widget.onCallEnded?.call();
// //     } catch (e) {
// //       debugPrint('Error ending call: $e');
// //       // Still navigate even if there's an error
// //       widget.onCallEnded?.call();
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       body: Stack(
// //         children: [
// //           Positioned.fill(child: _remoteVideo()),

// //           // Top section with name and local video
// //           Positioned(
// //             top: 0,
// //             left: 0,
// //             right: 0,
// //             child: Container(
// //               padding: EdgeInsets.only(
// //                 top: MediaQuery.of(context).padding.top + 16,
// //                 left: 20,
// //                 right: 20,
// //                 bottom: 20,
// //               ),
// //               decoration: BoxDecoration(
// //                 gradient: LinearGradient(
// //                   begin: Alignment.topCenter,
// //                   end: Alignment.bottomCenter,
// //                   colors: [
// //                     Colors.black.withOpacity(0.7),
// //                     Colors.black.withOpacity(0.3),
// //                     Colors.transparent,
// //                   ],
// //                 ),
// //               ),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   // Name and time
// //                   Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         'Catherine Lynch',
// //                         style: TextStyle(
// //                           color: Colors.white,
// //                           fontSize: 22,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                       SizedBox(height: 4),
// //                       Text(
// //                         '05:23',
// //                         style: TextStyle(
// //                           color: Colors.white.withOpacity(0.7),
// //                           fontSize: 14,
// //                         ),
// //                       ),
// //                     ],
// //                   ),

// //                   // Local video preview
// //                   Container(
// //                     width: 90,
// //                     height: 120,
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(12),
// //                       border: Border.all(
// //                         color: Colors.white.withOpacity(0.3),
// //                         width: 2,
// //                       ),
// //                     ),
// //                     clipBehavior: Clip.antiAlias,
// //                     child: _localUserJoined
// //                         ? AgoraVideoView(
// //                             controller: VideoViewController(
// //                               rtcEngine: _engine,
// //                               canvas: const VideoCanvas(uid: 0),
// //                             ),
// //                           )
// //                         : Container(
// //                             color: Colors.grey[800],
// //                             child: Center(
// //                               child: CircularProgressIndicator(
// //                                 color: Colors.white,
// //                                 strokeWidth: 2,
// //                               ),
// //                             ),
// //                           ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           // Bottom control buttons
// //           Positioned(
// //             bottom: 0,
// //             left: 0,
// //             right: 0,
// //             child: Container(
// //               padding: EdgeInsets.only(
// //                 bottom: MediaQuery.of(context).padding.bottom + 40,
// //                 top: 40,
// //               ),
// //               decoration: BoxDecoration(
// //                 gradient: LinearGradient(
// //                   begin: Alignment.bottomCenter,
// //                   end: Alignment.topCenter,
// //                   colors: [
// //                     Colors.black.withOpacity(0.8),
// //                     Colors.black.withOpacity(0.4),
// //                     Colors.transparent,
// //                   ],
// //                 ),
// //               ),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                 children: [
// //                   _buildControlButton(
// //                     icon: _isMuted ? Icons.mic_off : Icons.mic,
// //                     label: 'Mute',
// //                     onTap: _toggleMute,
// //                     isActive: _isMuted,
// //                   ),
// //                   _buildControlButton(
// //                     icon: Icons.flip_camera_ios,
// //                     label: 'Flip',
// //                     onTap: _switchCamera,
// //                   ),
// //                   _buildControlButton(
// //                     icon: Icons.call_end,
// //                     label: 'End',
// //                     onTap: _endCall,
// //                     backgroundColor: Color(0xFFFF4757),
// //                     isEndButton: true,
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildControlButton({
// //     required IconData icon,
// //     required String label,
// //     required VoidCallback onTap,
// //     Color? backgroundColor,
// //     bool isActive = false,
// //     bool isEndButton = false,
// //   }) {
// //     return Column(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         Material(
// //           color: Colors.transparent,
// //           child: InkWell(
// //             onTap: onTap,
// //             customBorder: CircleBorder(),
// //             child: Container(
// //               width: 56,
// //               height: 56,
// //               decoration: BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 color: backgroundColor ?? Colors.white.withOpacity(0.2),
// //                 border: isEndButton
// //                     ? null
// //                     : Border.all(
// //                         color: Colors.white.withOpacity(0.3),
// //                         width: 1,
// //                       ),
// //               ),
// //               child: Icon(icon, color: Colors.white, size: 28),
// //             ),
// //           ),
// //         ),
// //         SizedBox(height: 8),
// //         Text(
// //           label,
// //           style: TextStyle(
// //             color: Colors.white,
// //             fontSize: 12,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _remoteVideo() {
// //     if (_remoteUid != null) {
// //       return AgoraVideoView(
// //         controller: VideoViewController.remote(
// //           rtcEngine: _engine,
// //           canvas: VideoCanvas(uid: _remoteUid),
// //           connection: const RtcConnection(channelId: channel),
// //         ),
// //       );
// //     } else {
// //       return Container(
// //         color: Colors.black,
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(
// //                 Icons.person_outline,
// //                 size: 80,
// //                 color: Colors.white.withOpacity(0.3),
// //               ),
// //               SizedBox(height: 16),
// //               Text(
// //                 'Waiting for others to join...',
// //                 style: TextStyle(
// //                   color: Colors.white.withOpacity(0.7),
// //                   fontSize: 16,
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }
// //   }
// // }grpcall-->*/
// // /*import 'dart:async';

// // import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// // import 'package:flutter/material.dart';
// // import 'package:permission_handler/permission_handler.dart';

// // const appId = "35f67e0fd1714eb1b8d2dac2081e2c7a";
// // const token =
// //     "007eJxTYFBvX/0sZYrgXpNDny6ciJ/KrvVUg1lV5vzZg5PWKcfGu1koMBibppmZpxqkpRiaG5qkJhkmWaQYpSQmGxlYGKYaJZsn+p1lyGwIZGRwc5ZjYWSAQBCflaEktbjEkIEBADIHHhc=";
// // const channel = "test1";

// // class AppTest extends StatefulWidget {
// //   const AppTest({Key? key}) : super(key: key);

// //   @override
// //   State<AppTest> createState() => _AppTestState();
// // }

// // class _AppTestState extends State<AppTest> {
// //   int? _remoteUid;
// //   bool _localUserJoined = false;
// //   late RtcEngine _engine;

// //   @override
// //   void initState() {
// //     super.initState();
// //     initAgora();
// //   }

// //   Future<void> initAgora() async {
// //     // retrieve permissions
// //     await [Permission.microphone, Permission.camera].request();

// //     //create the engine
// //     _engine = createAgoraRtcEngine();
// //     await _engine.initialize(
// //       const RtcEngineContext(
// //         appId: appId,
// //         channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
// //       ),
// //     );

// //     _engine.registerEventHandler(
// //       RtcEngineEventHandler(
// //         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
// //           debugPrint("local user ${connection.localUid} joined");
// //           setState(() {
// //             _localUserJoined = true;
// //           });
// //         },
// //         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
// //           debugPrint("remote user $remoteUid joined");
// //           setState(() {
// //             _remoteUid = remoteUid;
// //           });
// //         },
// //         onUserOffline:
// //             (
// //               RtcConnection connection,
// //               int remoteUid,
// //               UserOfflineReasonType reason,
// //             ) {
// //               debugPrint("remote user $remoteUid left channel");
// //               setState(() {
// //                 _remoteUid = null;
// //               });
// //             },
// //         onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
// //           debugPrint(
// //             '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token',
// //           );
// //         },
// //       ),
// //     );

// //     await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
// //     await _engine.enableVideo();
// //     await _engine.startPreview();

// //     await _engine.joinChannel(
// //       token: token,
// //       channelId: channel,
// //       uid: 0,
// //       options: const ChannelMediaOptions(),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     super.dispose();

// //     _dispose();
// //   }

// //   Future<void> _dispose() async {
// //     await _engine.leaveChannel();
// //     await _engine.release();
// //   }

// //   // Create UI with local view and remote view
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Agora Video Call')),
// //       body: Stack(
// //         children: [
// //           Center(child: _remoteVideo()),
// //           Align(
// //             alignment: Alignment.topLeft,
// //             child: SizedBox(
// //               width: 100,
// //               height: 150,
// //               child: Center(
// //                 child: _localUserJoined
// //                     ? AgoraVideoView(
// //                         controller: VideoViewController(
// //                           rtcEngine: _engine,
// //                           canvas: const VideoCanvas(uid: 0),
// //                         ),
// //                       )
// //                     : const CircularProgressIndicator(),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // Display remote user's video
// //   Widget _remoteVideo() {
// //     if (_remoteUid != null) {
// //       return AgoraVideoView(
// //         controller: VideoViewController.remote(
// //           rtcEngine: _engine,
// //           canvas: VideoCanvas(uid: _remoteUid),
// //           connection: const RtcConnection(channelId: channel),
// //         ),
// //       );
// //     } else {
// //       return const Text(
// //         'Please wait for remote user to join',
// //         textAlign: TextAlign.center,
// //       );
// //     }
// //   }
// // }*/






















// // //wrong
// // // // import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:permission_handler/permission_handler.dart';

// // // // class ChannelInputPage extends StatefulWidget {
// // // //   const ChannelInputPage({super.key});

// // // //   @override
// // // //   State<ChannelInputPage> createState() => _ChannelInputPageState();
// // // // }

// // // // class _ChannelInputPageState extends State<ChannelInputPage> {
// // // //   final TextEditingController _controller = TextEditingController();

// // // //   void _joinChannel() {
// // // //     final channelName = _controller.text.trim();
// // // //     if (channelName.isEmpty) {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         const SnackBar(content: Text('Please enter a channel name')),
// // // //       );
// // // //       return;
// // // //     }
// // // //     Navigator.push(
// // // //       context,
// // // //       MaterialPageRoute(
// // // //         builder: (_) => VideoCallPage(channelName: channelName),
// // // //       ),
// // // //     );
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(title: const Text("Join Video Call")),
// // // //       body: Padding(
// // // //         padding: const EdgeInsets.all(20),
// // // //         child: Column(
// // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // //           children: [
// // // //             TextField(
// // // //               controller: _controller,
// // // //               decoration: InputDecoration(
// // // //                 labelText: "Enter Channel Name",
// // // //                 border: OutlineInputBorder(
// // // //                   borderRadius: BorderRadius.circular(12),
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 20),
// // // //             ElevatedButton.icon(
// // // //               onPressed: _joinChannel,
// // // //               icon: const Icon(Icons.video_call),
// // // //               label: const Text("Join Channel"),
// // // //               style: ElevatedButton.styleFrom(
// // // //                 minimumSize: const Size(double.infinity, 50),
// // // //                 shape: RoundedRectangleBorder(
// // // //                   borderRadius: BorderRadius.circular(12),
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // /// Page 2 — Video Call Screen
// // // // class VideoCallPage extends StatefulWidget {
// // // //   final String channelName;
// // // //   const VideoCallPage({super.key, required this.channelName});

// // // //   @override
// // // //   State<VideoCallPage> createState() => _VideoCallPageState();
// // // // }

// // // // class _VideoCallPageState extends State<VideoCallPage> {
// // // //   late RtcEngine agoraEngine;
// // // //   bool localUserJoined = false;
// // // //   int? remoteUid;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     initAgora();
// // // //   }

// // // //   Future<void> initAgora() async {
// // // //     await [Permission.camera, Permission.microphone].request();

// // // //     agoraEngine = createAgoraRtcEngine();
// // // //     await agoraEngine.initialize(
// // // //       const RtcEngineContext(appId: '35f67e0fd1714eb1b8d2dac2081e2c7a'),
// // // //     );

// // // //     agoraEngine.registerEventHandler(
// // // //       RtcEngineEventHandler(
// // // //         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
// // // //           setState(() => localUserJoined = true);
// // // //         },
// // // //         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
// // // //           setState(() => this.remoteUid = remoteUid);
// // // //         },
// // // //         onUserOffline:
// // // //             (
// // // //               RtcConnection connection,
// // // //               int remoteUid,
// // // //               UserOfflineReasonType reason,
// // // //             ) {
// // // //               setState(() => this.remoteUid = null);
// // // //             },
// // // //       ),
// // // //     );

// // // //     await agoraEngine.enableVideo();

// // // //     await agoraEngine.joinChannel(
// // // //       token:
// // // //           '007eJxTYDhULvU++lVj/AIGTilZ/5q3qzeqvFq2vS9Z291ujXKH3AUFBmPTNDPzVIO0FENzQ5PUJMMkixSjlMRkIwMLw1SjZPNEpeUMmQ2BjAwiD1RYGRkgEMRnZyhJLS7JzEtnYAAAT4Ue/Q==',
// // // //       channelId: widget.channelName,
// // // //       uid: 0,
// // // //       options: const ChannelMediaOptions(),
// // // //     );
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     agoraEngine.leaveChannel();
// // // //     agoraEngine.release();
// // // //     super.dispose();
// // // //   }

// // // //   Widget _renderLocalPreview() {
// // // //     if (localUserJoined) {
// // // //       return AgoraVideoView(
// // // //         controller: VideoViewController(
// // // //           rtcEngine: agoraEngine,
// // // //           canvas: const VideoCanvas(uid: 0),
// // // //         ),
// // // //       );
// // // //     } else {
// // // //       return const Center(child: CircularProgressIndicator());
// // // //     }
// // // //   }

// // // //   Widget _renderRemoteVideo() {
// // // //     if (remoteUid != null) {
// // // //       return AgoraVideoView(
// // // //         controller: VideoViewController.remote(
// // // //           rtcEngine: agoraEngine,
// // // //           canvas: VideoCanvas(uid: remoteUid),
// // // //           connection: RtcConnection(channelId: widget.channelName),
// // // //         ),
// // // //       );
// // // //     } else {
// // // //       return const Center(child: Text("Waiting for remote user..."));
// // // //     }
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: Text("Channel: ${widget.channelName}"),
// // // //         actions: [
// // // //           IconButton(
// // // //             icon: const Icon(Icons.call_end),
// // // //             onPressed: () => Navigator.pop(context),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       body: Stack(
// // // //         children: [
// // // //           Center(child: _renderRemoteVideo()),
// // // //           Align(
// // // //             alignment: Alignment.topLeft,
// // // //             child: SizedBox(
// // // //               width: 120,
// // // //               height: 160,
// // // //               child: ClipRRect(
// // // //                 borderRadius: BorderRadius.circular(12),
// // // //                 child: _renderLocalPreview(),
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // import 'dart:async';
// // // import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:permission_handler/permission_handler.dart';

// // // // Agora credentials
// // // const appId = "35f67e0fd1714eb1b8d2dac2081e2c7a";
// // // const token =
// // //     "007eJxTYFBvX/0sZYrgXpNDny6ciJ/KrvVUg1lV5vzZg5PWKcfGu1koMBibppmZpxqkpRiaG5qkJhkmWaQYpSQmGxlYGKYaJZsn+p1lyGwIZGRwc5ZjYWSAQBCflaEktbjEkIEBADIHHhc=";

// // // // ============================
// // // // MAIN ENTRY POINT
// // // // ============================

// // // // ============================
// // // // CHANNEL INPUT PAGE
// // // // ============================
// // // class ChannelInputPage extends StatefulWidget {
// // //   const ChannelInputPage({super.key});

// // //   @override
// // //   State<ChannelInputPage> createState() => _ChannelInputPageState();
// // // }

// // // class _ChannelInputPageState extends State<ChannelInputPage> {
// // //   final TextEditingController _controller = TextEditingController();

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: const Text("Join a Channel")),
// // //       body: Padding(
// // //         padding: const EdgeInsets.all(20.0),
// // //         child: Column(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: [
// // //             const Text("Enter Channel Name", style: TextStyle(fontSize: 18)),
// // //             const SizedBox(height: 10),
// // //             TextField(
// // //               controller: _controller,
// // //               decoration: InputDecoration(
// // //                 hintText: "e.g. test123",
// // //                 border: OutlineInputBorder(
// // //                   borderRadius: BorderRadius.circular(8),
// // //                 ),
// // //               ),
// // //             ),
// // //             const SizedBox(height: 20),
// // //             ElevatedButton(
// // //               onPressed: () async {
// // //                 final channelName = _controller.text.trim();
// // //                 if (channelName.isEmpty) {
// // //                   ScaffoldMessenger.of(context).showSnackBar(
// // //                     const SnackBar(
// // //                       content: Text("Please enter a valid channel name"),
// // //                     ),
// // //                   );
// // //                   return;
// // //                 }
// // //                 Navigator.push(
// // //                   context,
// // //                   MaterialPageRoute(
// // //                     builder: (_) => AppTest(channelName: channelName),
// // //                   ),
// // //                 );
// // //               },
// // //               child: const Text("Join Channel"),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // // ============================
// // // class AppTest extends StatefulWidget {
// // //   final String channelName;

// // //   const AppTest({Key? key, required this.channelName}) : super(key: key);

// // //   @override
// // //   State<AppTest> createState() => _AppTestState();
// // // }

// // // class _AppTestState extends State<AppTest> {
// // //   int? _remoteUid;
// // //   bool _localUserJoined = false;
// // //   late RtcEngine _engine;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     initAgora();
// // //   }

// // //   Future<void> initAgora() async {
// // //     await [Permission.camera, Permission.microphone].request();

// // //     _engine = createAgoraRtcEngine();
// // //     await _engine.initialize(RtcEngineContext(appId: appId));

// // //     _engine.registerEventHandler(
// // //       RtcEngineEventHandler(
// // //         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
// // //           debugPrint("✅ Local user joined channel successfully");
// // //           setState(() => _localUserJoined = true);
// // //         },
// // //         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
// // //           debugPrint("👤 Remote user joined: $remoteUid");
// // //           setState(() => _remoteUid = remoteUid);
// // //         },
// // //         onUserOffline:
// // //             (
// // //               RtcConnection connection,
// // //               int remoteUid,
// // //               UserOfflineReasonType reason,
// // //             ) {
// // //               debugPrint("🚫 Remote user left: $remoteUid");
// // //               setState(() => _remoteUid = null);
// // //             },
// // //       ),
// // //     );

// // //     await _engine.enableVideo();
// // //     await _engine.startPreview();

// // //     await _engine.joinChannel(
// // //       token: token,
// // //       channelId: widget.channelName,
// // //       uid: 0,
// // //       options: const ChannelMediaOptions(),
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _engine.leaveChannel();
// // //     _engine.release();
// // //     super.dispose();
// // //   }

// // //   Widget _localVideo() {
// // //     if (_localUserJoined) {
// // //       return AgoraVideoView(
// // //         controller: VideoViewController(
// // //           rtcEngine: _engine,
// // //           canvas: const VideoCanvas(uid: 0),
// // //         ),
// // //       );
// // //     } else {
// // //       return const Center(child: Text("Joining channel..."));
// // //     }
// // //   }

// // //   Widget _remoteVideo() {
// // //     if (_remoteUid != null) {
// // //       return AgoraVideoView(
// // //         controller: VideoViewController.remote(
// // //           rtcEngine: _engine,
// // //           canvas: VideoCanvas(uid: _remoteUid),
// // //           connection: RtcConnection(channelId: widget.channelName),
// // //         ),
// // //       );
// // //     } else {
// // //       return const Center(child: Text("Waiting for remote user..."));
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text("Channel: ${widget.channelName}")),
// // //       body: Stack(
// // //         children: [
// // //           _remoteVideo(),
// // //           Align(
// // //             alignment: Alignment.topLeft,
// // //             child: SizedBox(
// // //               width: 120,
// // //               height: 160,
// // //               child: ClipRRect(
// // //                 borderRadius: BorderRadius.circular(12),
// // //                 child: _localVideo(),
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //       floatingActionButton: FloatingActionButton(
// // //         backgroundColor: Colors.red,
// // //         child: const Icon(Icons.call_end),
// // //         onPressed: () => Navigator.pop(context),
// // //       ),
// // //     );
// // //   }
// // // }