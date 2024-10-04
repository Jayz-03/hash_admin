import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hash_admin/screens/appointment/appointment.dart';
import 'package:hash_admin/screens/auth/login.dart';
import 'package:hash_admin/screens/home/home.dart';
import 'package:hash_admin/screens/messages/chatBoxMessages.dart';
import 'package:hash_admin/screens/notification/notification.dart';
import 'package:hash_admin/screens/profile/profile.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TabNavigation extends StatelessWidget {
  const TabNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/hash-logo.png',
                  width: 40,
                ),
                const SizedBox(width: 10),
                Image.asset(
                  'assets/images/logo-text.png',
                  width: 70,
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              HomeScreen(),
              AuthWrapper(authenticatedPage: AdminAppointmentScreen()),
              AuthWrapper(authenticatedPage: ChatBoxScreen()),
              AuthWrapper(authenticatedPage: NotificationScreen()),
              AuthWrapper(authenticatedPage: ProfileScreen()),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color.fromARGB(255, 255, 218, 185),
                  width: 2.0,
                ),
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: const Color.fromARGB(255, 255, 255, 255),
                primaryColor: Colors.white,
                textTheme: Theme.of(context).textTheme.copyWith(
                      bodySmall: GoogleFonts.comfortaa(color: Colors.black),
                    ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(bottom: 0),
                child: TabBar(
                  unselectedLabelColor: Color.fromARGB(255, 255, 218, 185),
                  labelColor: Color.fromARGB(255, 240, 128, 128),
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                        width: 2.0, color: Color.fromARGB(255, 240, 128, 128)),
                    insets: EdgeInsets.symmetric(horizontal: 40),
                  ),
                  tabs: [
                    Tab(
                        icon: PhosphorIcon(PhosphorIconsFill.houseLine,
                            size: 28)),
                    Tab(
                        icon: PhosphorIcon(PhosphorIconsFill.calendarBlank,
                            size: 28)),
                    Tab(
                        icon: PhosphorIcon(PhosphorIconsFill.chatCentered,
                            size: 28)),
                    Tab(icon: PhosphorIcon(PhosphorIconsFill.bell, size: 28)),
                    Tab(icon: PhosphorIcon(PhosphorIconsFill.user, size: 28)),
                  ],
                ),
              ),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final Widget authenticatedPage;

  const AuthWrapper({super.key, required this.authenticatedPage});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null && !_dialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSignInDialog();
      });
    }
  }

  void _showSignInDialog() {
    setState(() {
      _dialogShown = true;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/okokok.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Sign In Required!',
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 20,
                    color: Color.fromARGB(255, 240, 128, 128),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Text(
                  'You need to sign in to view this section.',
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
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
              'Please sign in to view this section.',
              style: GoogleFonts.robotoCondensed(
                fontSize: 16,
                color: Color.fromARGB(255, 240, 128, 128),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text(
                'Sign In',
                style: GoogleFonts.robotoCondensed(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 240, 128, 128),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return widget.authenticatedPage;
    }
  }
}
