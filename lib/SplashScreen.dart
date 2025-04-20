// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'LoginScreen.dart'; // Import your login page

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
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
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
