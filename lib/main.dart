// ignore_for_file: prefer_const_constructors

// main.dart
import 'package:flutter/material.dart';
import 'SplashScreen.dart'; // Import the splash screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Set the splash screen as the home
    );
  }
}
