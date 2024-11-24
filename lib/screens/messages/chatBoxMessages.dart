import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
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
          setState(() {
            _isLoading = false;
            _approvedAppointments = [];
          });
        }
        return;
      }

      List<Map<String, dynamic>> approved = [];

      for (var userId in data.keys) {
        final userAppointments = data[userId] as Map<dynamic, dynamic>? ?? {};

        for (var appointmentId in userAppointments.keys) {
          final appointmentData =
              Map<String, dynamic>.from(userAppointments[appointmentId] ?? {});
          
          if (appointmentData['status'] == 'Approved') {
            final userSnapshot = await _usersRef.child(userId).get();
            if (userSnapshot.exists) {
              final userData =
                  Map<String, dynamic>.from(userSnapshot.value as Map<dynamic, dynamic>? ?? {});
              appointmentData['firstName'] = userData['firstName'] ?? 'Unknown';
              appointmentData['lastName'] = userData['lastName'] ?? 'User';
            }

            appointmentData['userId'] = userId;
            appointmentData['appointmentId'] = appointmentId;
            appointmentData['timestamp'] = appointmentData['timestamp'] ?? 0; 
            approved.add(appointmentData);
          }
        }
      }

      approved.sort((a, b) {
        final aTimestamp = a['timestamp'] ?? 0;
        final bTimestamp = b['timestamp'] ?? 0;
        return bTimestamp.compareTo(aTimestamp);
      });

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
    final String senderId = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown'; // Fallback to 'Unknown'

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 228, 142, 136),
              ),
            )
          : _approvedAppointments.isEmpty
              ? Center(
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
                        'Currently, there is no approved appointments yet.',
                        style: GoogleFonts.robotoCondensed(
                          fontSize: 16,
                          color: Color.fromARGB(255, 240, 128, 128),
                        ),
                      ),
                    ],
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
                        leading: Image.asset("assets/images/hash-logo.png",
                            height: 30),
                        title: Text(
                          '${appointment['firstName']} ${appointment['lastName']}',
                          style: GoogleFonts.robotoCondensed(
                            fontSize: 18,
                            color: Color.fromARGB(255, 228, 142, 136),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${appointment['service'] ?? 'No service'} - ${appointment['date'] ?? 'No date'} - ${appointment['time'] ?? 'No time'}',
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
                                userId: appointment['userId'] ?? 'Unknown',
                                appointmentId: appointment['appointmentId'] ?? 'Unknown',
                                senderId: senderId,
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
