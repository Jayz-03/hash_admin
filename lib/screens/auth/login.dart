import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hash_admin/common/tab-bar-navigation.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      if (emailController.text == 'hash.hiv0@gmail.com') {
        try {
          // Perform login
          UserCredential userCredential =
              await _auth.signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );

          User? user = userCredential.user;

          // Update the user's active status to true
          await FirebaseDatabase.instance.ref('users/${user?.uid}').update({
            'active': true,
            'lastSeen': DateTime.now().millisecondsSinceEpoch,
          });

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => TabNavigation()));
        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}')),
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        // Show an error message if the email doesn't match
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Center(child: Text('Invalid email or password')),
              backgroundColor: Colors.red),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  'assets/images/main-logo.png',
                  height: 150,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        cursorColor: Color.fromARGB(255, 240, 128, 128),
                        controller: emailController,
                        style: GoogleFonts.robotoCondensed(),
                        decoration: InputDecoration(
                          prefixIcon: PhosphorIcon(PhosphorIconsFill.envelope,
                              size: 24),
                          hintText: 'Email address',
                          hintStyle: GoogleFonts.robotoCondensed(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 240, 128, 128),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 240, 128, 128),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 240, 128, 128),
                              width: 2.0,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          if (!regex.hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        cursorColor: Color.fromARGB(255, 240, 128, 128),
                        controller: passwordController,
                        style: GoogleFonts.robotoCondensed(),
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          prefixIcon:
                              PhosphorIcon(PhosphorIconsFill.lock, size: 24),
                          hintText: 'Password',
                          hintStyle: GoogleFonts.robotoCondensed(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 240, 128, 128),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 240, 128, 128),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 240, 128, 128),
                              width: 2.0,
                            ),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Color.fromARGB(255, 240, 128, 128),
                                ),
                              )
                            : Text(
                                'Log in',
                                style: GoogleFonts.robotoCondensed(
                                    fontSize: 16, color: Colors.white),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 240, 128, 128),
                          minimumSize: Size(double.infinity, 50),
                          textStyle: GoogleFonts.robotoCondensed(
                              fontSize: 16,
                              color: Color.fromARGB(255, 240, 128, 128)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
