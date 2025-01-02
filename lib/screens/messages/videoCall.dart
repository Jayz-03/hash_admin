import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';

const appId = "777f371c217f472b800518ca32f5f305";
const token =
    "007eJxTYCj6nd7/nl0j7fA/g3bVqZJ9tq+/P4zg2/Ghs2L3h1y2CE4FBnNz8zRjc8NkI0PzNBNzoyQLAwNTQ4vkRGOjNNM0YwPTXRsT0hsCGRkq3ecwMzJAIIjPw1CSmpOam5qSmZyZl8rAAAB+AiK8";
const channel = "telemedicine";

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _isMuted = false;
  bool _isVideoOff = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = await createAgoraRtcEngine();
    await _engine.initialize(
      const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('Local user ${connection.localUid} joined');
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("Remote user $remoteUid left the channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.joinChannel(
      token: token,
      channelId: channel,
      options: const ChannelMediaOptions(
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        audienceLatencyLevel:
            AudienceLatencyLevelType.audienceLatencyLevelUltraLowLatency,
      ),
      uid: 0,
    );
  }

  Future<void> _leaveChannel() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  Future<void> _toggleMute() async {
    setState(() {
      _isMuted = !_isMuted;
    });
    await _engine.muteLocalAudioStream(_isMuted);
  }

  Future<void> _toggleVideo() async {
    setState(() {
      _isVideoOff = !_isVideoOff;
    });
    await _engine.muteLocalVideoStream(_isVideoOff);
  }

  Future<void> _switchCamera() async {
    await _engine.switchCamera();
  }

  @override
  void dispose() {
    _leaveChannel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: Color.fromARGB(255, 228, 142, 136)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Telemedicine',
          style: GoogleFonts.robotoCondensed(
            fontSize: 16,
            color: Color.fromARGB(255, 228, 142, 136),
          ),
        ),
      ),
      body: Stack(
        children: [
          Center(child: _remoteVideo()),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 120,
                height: 170,
                child: Center(
                  child: _localUserJoined
                      ? AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: _engine,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        )
                      : const CircularProgressIndicator(color: Color.fromARGB(255, 228, 142, 136)),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.switch_camera, color: Color.fromARGB(255, 228, 142, 136)),
                    onPressed: _switchCamera,
                  ),
                  IconButton(
                    icon: Icon(
                        _isVideoOff ? Icons.videocam_off : Icons.videocam,
                        color: Color.fromARGB(255, 228, 142, 136)),
                    onPressed: _toggleVideo,
                  ),
                  IconButton(
                    icon: Icon(
                        _isMuted ? Icons.mic_off : Icons.mic,
                        color: Color.fromARGB(255, 228, 142, 136)),
                    onPressed: _toggleMute,
                  ),
                  IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.red),
                    onPressed: () async {
                      await _leaveChannel();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: channel),
        ),
      );
    } else {
      return Text(
        'Waiting for the patient to join...',
        style: GoogleFonts.robotoCondensed(
          fontSize: 16,
          color: Color.fromARGB(255, 228, 142, 136),
        ),
        textAlign: TextAlign.center,
      );
    }
  }
}
