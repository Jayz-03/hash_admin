import 'package:flutter/material.dart';
import 'package:agora_uikit/agora_uikit.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  @override
  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: "777f371c217f472b800518ca32f5f305",
      channelName: "telemedicine",
      tempToken:
          "007eJxTYFCXOGrIbd9VIWa4/mrD6bgJ9aYxBWxyB5xX2BqsiD3y9asCg7m5eZqxuWGykaF5mom5UZKFgYGpoUVyorFRmmmasYGp4lvR9IZARoZPTnUMjFAI4vMwlKTmpOampmQmZ+alMjAAAHTMIA0=",
    ),
    enabledPermission: [
      Permission.camera,
      Permission.microphone,
    ],
  );

  @override 
  void initState() {
    super.initState();
    initAgora();
  }

  void initAgora() async {
    try {
      await client.initialize();
    } catch (e) {
      print("Agora initialization failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(client: client),
              AgoraVideoButtons(client: client),
            ],
          ),
        ),
      ),
    );
  }
}
