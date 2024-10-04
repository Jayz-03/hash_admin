import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
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
                          'No messages yet, but you can \nstart conversation with $fullname',
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
                              : Colors.grey[300],
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
