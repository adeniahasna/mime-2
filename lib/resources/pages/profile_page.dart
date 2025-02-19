import 'package:flutter/material.dart';
import 'package:flutter_app/config/assets_image.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/app/controllers/auth_controller.dart';

class ProfilePage extends NyStatefulWidget {
  static RouteView path = ("/profile", (_) => ProfilePage());

  ProfilePage({super.key}) : super(child: () => _ProfilePageState());
}

class _ProfilePageState extends NyPage<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = AuthController();

  String? _name;
  String? _email;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user.uid).get();
      setState(() {
        _name = userDoc["name"];
        _email = userDoc["email"];
      });
    }
  }

  Future<void> _logout() async {
    await _authController.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/sign-in', (route) => false);
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 25),
                child: Text(
                  "Profile",
                  style: GoogleFonts.anekDevanagari(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Positioned(
              top: 13,
              left: 0,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Image.asset(
                  AssetImages.backButton,
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _name == null || _email == null
            ? Center(child: CircularProgressIndicator())
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      CircleAvatar(
                        backgroundColor: Color(0xFF4413D2),
                        radius: 70,
                        child: Icon(Icons.person, size: 90),
                      ),
                      SizedBox(height: 30),
                      Text(
                        _name!,
                        style: GoogleFonts.anekDevanagari(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _email!,
                        style: GoogleFonts.anekDevanagari(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Logout',
                          style: GoogleFonts.anekDevanagari(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
