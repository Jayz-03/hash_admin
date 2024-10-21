import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hash_admin/screens/messages/videoCall.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MessagesScreen extends StatefulWidget {
  final String userId;
  final String appointmentId;
  final String senderId;

  const MessagesScreen({
    super.key,
    required this.userId,
    required this.appointmentId,
    required this.senderId,
  });

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _chatRef = FirebaseDatabase.instance.ref();
  String fullname = '';
  String service = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _listenForVideoCallRequests();
  }

  void _fetchUserData() async {
    final userSnapshot = await _chatRef.child('users/${widget.userId}').get();
    final appointmentSnapshot = await _chatRef
        .child('Appointment/${widget.userId}/${widget.appointmentId}')
        .get();

    if (userSnapshot.exists && appointmentSnapshot.exists) {
      final userData = userSnapshot.value as Map<dynamic, dynamic>;
      final appointmentData =
          appointmentSnapshot.value as Map<dynamic, dynamic>;

      setState(() {
        fullname = '${userData['firstName']} ${userData['lastName']}';
        service = appointmentData['service'] ?? 'No Service';
      });
    }
  }

  void sendMessage(String message) {
    if (message.isEmpty) return;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _chatRef
        .child('Chats/${widget.userId}/${widget.appointmentId}/messages')
        .push()
        .set({
      'senderId': widget.senderId,
      'message': message,
      'timestamp': timestamp,
    });

    _messageController.clear();
  }

  void _listenForVideoCallRequests() {
    _chatRef
        .child(
            'calls/${widget.userId}/${widget.appointmentId}/videoCallApproval')
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null && data['status'] == 'pending') {
        _showVideoCallRequestDialog();
      }
    });
  }

  void _showVideoCallRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PhosphorIcon(
                PhosphorIconsFill.videoCamera,
                size: 100,
                color: Color.fromARGB(255, 228, 142, 136),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'Video Call Request',
                  style: GoogleFonts.robotoCondensed(
                      fontSize: 20,
                      color: Color.fromARGB(255, 228, 142, 136),
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Text(
                  '$fullname has requested a video call.',
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 14,
                    color: Color.fromARGB(255, 228, 142, 136),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  _approveVideoCall();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Approve',
                  style: GoogleFonts.robotoCondensed(
                      fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  _rejectVideoCall();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Reject',
                  style: GoogleFonts.robotoCondensed(
                      fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _approveVideoCall() {
    _chatRef
        .child(
            'calls/${widget.userId}/${widget.appointmentId}/videoCallApproval')
        .update({'status': 'approved'});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Video call approved.'),
      backgroundColor: Colors.green,
    ));
  }

  void _rejectVideoCall() {
    _chatRef
        .child(
            'calls/${widget.userId}/${widget.appointmentId}/videoCallApproval')
        .update({'status': 'rejected'});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Video call rejected.'),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: PhosphorIcon(
            PhosphorIconsFill.arrowArcLeft,
            size: 30,
            color: Color.fromARGB(255, 228, 142, 136),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fullname,
              style: GoogleFonts.robotoCondensed(
                fontSize: 18,
                color: Color.fromARGB(255, 228, 142, 136),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              service,
              style: GoogleFonts.robotoCondensed(
                fontSize: 14,
                color: Color.fromARGB(255, 228, 142, 136),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: PhosphorIcon(
              PhosphorIconsFill.videoCamera,
              size: 30,
              color: Color.fromARGB(255, 228, 142, 136),
            ),
            onPressed: () async {
              // Check video call approval status in Firebase
              DatabaseEvent event = await _chatRef
                  .child(
                      'calls/${widget.userId}/${widget.appointmentId}/videoCallApproval')
                  .once();

              DataSnapshot snapshot = event.snapshot;

              // Safely checking if the snapshot exists and value contains the status
              if (snapshot.exists &&
                  (snapshot.value as Map?)?['status'] == 'approved') {
                // If approved, proceed to call
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoCallScreen(),
                  ),
                );
              } else {
                // Show a message if the request is still pending or rejected
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          PhosphorIcon(
                            PhosphorIconsFill.videoCamera,
                            size: 100,
                            color: Color.fromARGB(255, 228, 142, 136),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: Text(
                              'Video Call Not Approved',
                              style: GoogleFonts.robotoCondensed(
                                fontSize: 20,
                                color: Color.fromARGB(255, 240, 128, 128),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: Text(
                              'The video call request is still pending or rejected.',
                              style: GoogleFonts.robotoCondensed(
                                fontSize: 14,
                                color: Color.fromARGB(255, 240, 128, 128),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'OK',
                            style: GoogleFonts.robotoCondensed(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 240, 128, 128),
                            textStyle: GoogleFonts.robotoCondensed(
                              fontSize: 16,
                              color: Color.fromARGB(255, 240, 128, 128),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _chatRef
                  .child(
                      'Chats/${widget.userId}/${widget.appointmentId}/messages')
                  .orderByChild('timestamp')
                  .onValue,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 228, 142, 136)));
                }
                if (!snapshot.hasData || snapshot.data.snapshot.value == null) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/okokok.png',
                          width: 200,
                          height: 200,
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          'No messages yet, but you can start conversation \nwith $fullname appointing for $service',
                          style: GoogleFonts.robotoCondensed(
                            fontSize: 16,
                            color: Color.fromARGB(255, 240, 128, 128),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                Map messages = snapshot.data.snapshot.value as Map;
                List messageList = messages.values.toList();
                messageList
                    .sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

                return ListView.builder(
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    bool isSender =
                        messageList[index]['senderId'] == widget.senderId;
                    return Align(
                      alignment: isSender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSender
                              ? Color.fromARGB(255, 228, 142, 136)
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          messageList[index]['message'],
                          style: GoogleFonts.robotoCondensed(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    cursorColor: Color.fromARGB(255, 228, 142, 136),
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.robotoCondensed(
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 228, 142, 136),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 228, 142, 136),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 228, 142, 136),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Color.fromARGB(255, 228, 142, 136),
                  ),
                  onPressed: () => sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
