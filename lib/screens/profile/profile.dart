import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hash_admin/screens/auth/login.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  DatabaseReference databaseRef = FirebaseDatabase.instance.ref('admins');
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (currentUser != null) {
      try {
        final snapshot = await databaseRef.child(currentUser!.uid).get();
        if (snapshot.exists) {
          setState(() {
            userData = Map<String, dynamic>.from(snapshot.value as Map);
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 240, 128, 128)))
          : ListView(
              padding: const EdgeInsets.all(10),
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(
                        userData?['profileImageUrl'] ??
                            "https://i.pinimg.com/originals/73/17/a5/7317a548844e0d0cccd211002e0abc45.jpg",
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${userData?['firstName'] ?? 'John'} ${userData?['lastName'] ?? 'Doe'}",
                      style: GoogleFonts.robotoCondensed(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userData?['email'] ?? "No email available",
                      style: GoogleFonts.robotoCondensed(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: List.generate(5, (index) {
                    return Expanded(
                      child: Container(
                        height: 7,
                        margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromARGB(255, 228, 142, 136),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 35),
                ...List.generate(
                  customListTiles.length,
                  (index) {
                    final tile = customListTiles[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Card(
                        color: const Color.fromARGB(255, 248, 173, 157),
                        elevation: 4,
                        shadowColor: Colors.black12,
                        child: ListTile(
                          leading: Icon(
                            tile.icon,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          title: Text(
                            tile.title,
                            style: GoogleFonts.robotoCondensed(
                              fontSize: 16,
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          trailing: PhosphorIcon(
                            PhosphorIconsFill.arrowArcRight,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          onTap: () {
                            if (tile.title == "Sign Out") {
                              _signOut(context);
                            }
                          },
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
    );
  }
}

class ProfileCompletionCard {
  final String title;
  final String buttonText;
  final IconData icon;
  ProfileCompletionCard({
    required this.title,
    required this.buttonText,
    required this.icon,
  });
}

class CustomListTile {
  final IconData icon;
  final String title;
  CustomListTile({
    required this.icon,
    required this.title,
  });
}

List<CustomListTile> customListTiles = [
  CustomListTile(
    icon: PhosphorIconsFill.lock,
    title: "Password & Security",
  ),
  CustomListTile(
    title: "Personal Information",
    icon: PhosphorIconsFill.user,
  ),
  CustomListTile(
    title: "Sign Out",
    icon: PhosphorIconsFill.signOut,
  ),
];
