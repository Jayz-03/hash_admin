import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _auth = FirebaseAuth.instance;
  late final DatabaseReference _appointmentsRef;
  late StreamSubscription<DatabaseEvent> _appointmentsSubscription;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _appointmentsRef =
        FirebaseDatabase.instance.ref('Appointment/${_auth.currentUser?.uid}');
    _appointmentsSubscription = _appointmentsRef.onValue.listen((event) {
      _calculateUnreadCount();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _appointmentsSubscription.cancel();
    super.dispose();
  }

  Future<void> _calculateUnreadCount() async {
    final appointmentsSnapshot = await _appointmentsRef.get();
    final data = appointmentsSnapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      final unreadCount = data.values.where((appointment) {
        final appointmentData = appointment as Map<dynamic, dynamic>;
        return appointmentData['userActive'] == 'Yes';
      }).length;

      setState(() {
        _unreadCount = unreadCount;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final appointmentsSnapshot = await _appointmentsRef.get();
    final data = appointmentsSnapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      for (var entry in data.entries) {
        final appointmentRef = _appointmentsRef.child(entry.key);
        await appointmentRef.update({'userActive': 'No'});
      }

      setState(() {
        _unreadCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 18,
                    color: const Color.fromARGB(255, 240, 128, 128),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _markAllAsRead,
                      child: Text(
                        'Mark All as Read',
                        style: GoogleFonts.robotoCondensed(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 240, 128, 128),
                        ),
                      ),
                    ),
                    Text(
                      'Unread: $_unreadCount',
                      style: GoogleFonts.robotoCondensed(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 240, 128, 128),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _appointmentsRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 240, 128, 128),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final data =
                    snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

                if (data == null) {
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
                          'No notifications available!',
                          style: GoogleFonts.robotoCondensed(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 240, 128, 128),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final appointments = data.entries.map((entry) {
                  final appointment = entry.value as Map<dynamic, dynamic>;
                  return {
                    'key': entry.key,
                    'service': appointment['service'] as String,
                    'date': appointment['date'] as String,
                    'time': appointment['time'] as String,
                    'timestamp': appointment['timestamp'] as int,
                    'userActive': appointment['userActive'] as String,
                  };
                }).toList();

                appointments
                    .sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

                return ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final date =
                        DateFormat('yyyy-MM-dd').parse(appointment['date']);
                    final formattedDate =
                        DateFormat('EEEE, MMMM d, yyyy').format(date);
                    final time = appointment['time'];
                    final createdAt = DateTime.fromMillisecondsSinceEpoch(
                        appointment['timestamp']);
                    final timeAgo = timeago.format(createdAt);

                    return Container(
                      color: appointment['userActive'] == 'Yes'
                          ? Colors.white
                          : Colors.grey[300],
                      child: Stack(
                        children: [
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              ListTile(
                                  leading: PhosphorIcon(
                                    PhosphorIconsFill.bell,
                                    size: 60,
                                    color: const Color.fromARGB(
                                        255, 240, 128, 128),
                                  ),
                                  title: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'You have an appointment for ',
                                          style: GoogleFonts.robotoCondensed(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${appointment['service']}',
                                          style: GoogleFonts.robotoCondensed(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' on ',
                                          style: GoogleFonts.robotoCondensed(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '$formattedDate',
                                          style: GoogleFonts.robotoCondensed(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' from ',
                                          style: GoogleFonts.robotoCondensed(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '$time',
                                          style: GoogleFonts.robotoCondensed(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () {}),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 10, bottom: 4),
                                  child: Text('$timeAgo',
                                      style: GoogleFonts.robotoCondensed(
                                        color: Colors.black,
                                      )),
                                ),
                              ),
                            ],
                          ),
                          if (appointment['userActive'] == 'No')
                            Positioned.fill(
                              child: Container(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
