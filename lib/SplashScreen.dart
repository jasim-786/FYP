// SplashScreen.dart
// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, use_super_parameters, library_private_types_in_public_api

// SplashScreen.dart
import 'package:flutter/material.dart';
import 'Loginpage.dart'; // Import your login page

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to the login page after a delay
    Future.delayed(Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Loginpage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // Take the full width of the screen
        height: double.infinity, // Take the full height of the screen
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/logo1.gif'), // Your GIF file
            fit: BoxFit.cover, // Cover the entire screen
          ),
        ),
      ),
    );
  }
}
