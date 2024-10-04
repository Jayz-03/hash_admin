import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hash_admin/screens/messages/messages.dart';

class ChatBoxScreen extends StatefulWidget {
  @override
  _ChatBoxScreenState createState() => _ChatBoxScreenState();
}

class _ChatBoxScreenState extends State<ChatBoxScreen> {
  final DatabaseReference _appointmentsRef =
      FirebaseDatabase.instance.ref().child('Appointment');
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('users');
  late StreamSubscription _appointmentsSubscription;
  List<Map<String, dynamic>> _approvedAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApprovedAppointments();
  }

  void _fetchApprovedAppointments() {
    _appointmentsSubscription = _appointmentsRef.onValue.listen((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        print('No approved appointments found.');
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      List<Map<String, dynamic>> approved = [];

      for (var userId in data.keys) {
        final userAppointments = data[userId] as Map<dynamic, dynamic>;

        for (var appointmentId in userAppointments.keys) {
          final appointmentData =
              Map<String, dynamic>.from(userAppointments[appointmentId]);
          if (appointmentData['status'] == 'Approved') {
            final userSnapshot = await _usersRef.child(userId).get();
            if (userSnapshot.exists) {
              final userData = userSnapshot.value as Map<dynamic, dynamic>;
              appointmentData['firstName'] = userData['firstName'];
              appointmentData['lastName'] = userData['lastName'];
            }

            appointmentData['userId'] = userId;
            appointmentData['appointmentId'] = appointmentId;
            approved.add(appointmentData);
          }
        }
      }

      if (mounted) {
        setState(() {
          _approvedAppointments = approved;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _appointmentsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 228, 142, 136),
              ),
            )
          : ListView.builder(
              itemCount: _approvedAppointments.length,
              itemBuilder: (context, index) {
                final appointment = _approvedAppointments[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  elevation: 4,
                  color: Colors.white,
                  child: ListTile(
                    leading:
                        Image.asset("assets/images/hash-logo.png", height: 30),
                    title: Text(
                      '${appointment['firstName']} ${appointment['lastName']}',
                      style: GoogleFonts.robotoCondensed(
                        fontSize: 18,
                        color: Color.fromARGB(255, 228, 142, 136),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${appointment['service']} - ${appointment['date']}',
                      style: GoogleFonts.robotoCondensed(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MessagesScreen(
                            userId: appointment['userId'],
                            appointmentId: appointment['appointmentId'],
                            senderId: 'q5INLrhJXOZXwo6hrInJHlWGmWU2',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
