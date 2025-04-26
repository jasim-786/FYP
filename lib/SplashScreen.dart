// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_application_1/PreHomeScreen.dart';
import 'LoginScreen.dart'; // Import your login page
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate after a delay and check if user is logged in
    Future.delayed(Duration(seconds: 10), () async {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User is logged in, go to PreHomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PreHomeScreen()),
        );
      } else {
        // No user logged in, go to LoginScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/logo1.gif',
              fit: BoxFit.cover,
            ),
          ),
          // Optionally add a loading indicator or splash content here
        ],
      ),
    );
  }
}
