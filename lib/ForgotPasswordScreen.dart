// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, file_names, no_leading_underscores_for_local_identifiers, prefer_interpolation_to_compose_strings, avoid_print, non_constant_identifier_names

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AboutUsScreen.dart';
import 'package:flutter_application_1/FeedbackScreen.dart';
import 'package:flutter_application_1/LoginScreen.dart';
import 'package:flutter_application_1/Onboarding1.dart';
import 'package:flutter_application_1/PreHomeScreen.dart';
import 'package:flutter_application_1/PreviousResultsScreen.dart';
import 'package:flutter_application_1/ProfileScreen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    TextEditingController _email = TextEditingController();

    User? user = FirebaseAuth.instance.currentUser;

    void ForgotPassword(String Email) async {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: Email.trim());
      } catch (Error) {
        print("Error while reseting password:" + Error.toString());
      }
    }

    void logout(BuildContext context) async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Logout"),
            content: Text("Are you sure you want to log out?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Close dialog

                  await FirebaseAuth.instance.signOut();

                  // Show logout success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Logged out successfully"),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Navigate back to login screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text("Logout", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Color(0xFFE5D188), // Light yellow background
          child: Stack(
            children: [
              Column(
                children: [
                  // Top Section with Background Image
                  Container(
                    height: screenHeight * 0.25,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/Sidebar_Top.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(height: 20), // Spacing

                  // Sidebar Buttons
                  buildSidebarButton(
                    customIconPath: "assets/icons/Home_icon.png",
                    text: 'Home'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PreHomeScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/profile_icon.png",
                    text: 'Profile'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/history_icon.png",
                    text: 'History'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PreviousResultsScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/help_icon.png",
                    text: 'Help'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Onboarding1()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/feedback_icon.png",
                    text: 'Feedback'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FeedbackScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/info_icon.png",
                    text: 'About Us'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AboutUsScreen()),
                      );
                    },
                  ),
                  Column(
                    children: [
                      if (user != null)
                        buildSidebarButton(
                          customIconPath: "assets/icons/logout_icon.png",
                          text: 'Logout'.tr(),
                          onTap: () {
                            logout(context);
                          },
                        ),
                    ],
                  ),
                ],
              ),

              // Logo Positioned Below Top Section
              Positioned(
                top: screenHeight * 0.1, // Adjust for desired position
                left: 0,
                right: 140,
                child: Center(
                  child: Image.asset(
                    "assets/images/logo.png",
                    height: 140, // Adjust size as needed
                    width: 140, // Adjust size as needed
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Top Image Covering Full Width
          Positioned(
            top: -1,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/Top.png",
              fit: BoxFit.cover,
              height: screenHeight * 0.25,
              width: screenWidth,
            ),
          ),

          // Bottom Image Covering Full Width
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/Bottom.png",
              fit: BoxFit.cover,
              height: screenHeight * 0.2,
              width: screenWidth,
            ),
          ),
          // Sidebar Icon at Top Right
          Positioned(
            top: 25,
            right: 5,
            child: Builder(
              builder: (context) => GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Image.asset(
                  "assets/icons/menu.png",
                  height: 62,
                  width: 62,
                ),
              ),
            ),
          ),

          Positioned(
            top: 30, // Adjust vertically
            left: 12, // Adjust horizontally
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                "assets/icons/Back_arrow.png",
                height: 35,
                width: 35,
              ),
            ),
          ),

          // Content
          Positioned.fill(
            top: screenHeight * 0.15,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo Image
                  Image.asset(
                    "assets/icons/FP_icon.png",
                    height: screenHeight * 0.18,
                    width: screenWidth * 0.4,
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Forgot Password Text

                  Text(
                    'Forgot Password'.tr(),
                    style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Instruction Text
                  Text(
                    'Enter your registered email below to receive password reset instructions.'
                        .tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: 'Enter Email'.tr(),
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide(
                          color: Color(0xFF7B5228),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide(
                          color: Color(0xFF7B5228),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email cannot be empty';
                      } else if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Submit Button
                  SizedBox(
                    width: screenWidth * 0.55,
                    height: screenHeight * 0.07,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle password reset action
                        ForgotPassword(_email.text.toString());
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF7B5228),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Text(
                        'Send Instructions'.tr(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Back to Login Button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Back to Login'.tr(),
                      style: TextStyle(
                        color: Color(0xFF7B5228),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Sidebar Button
Widget buildSidebarButton({
  IconData? icon,
  String? customIconPath,
  required String text,
  required VoidCallback onTap,
}) {
  return Padding(
    padding:
        EdgeInsets.symmetric(vertical: 6, horizontal: 15), // Button Spacing
    child: GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: Offset(-10, 0), // Move button slightly left
        child: Container(
          height: 64,
          width: 250,
          decoration: BoxDecoration(
            color: Color(0xFF7B5228), // Brown background for button
            borderRadius: BorderRadius.circular(30), // Rounded button shape
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Row(
            children: [
              // Circular icon background
              Transform.translate(
                offset: Offset(-8, 0), // Moves the icon slightly left
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFE5D188), // Light background for icon
                    shape: BoxShape.circle,
                  ),
                  padding:
                      EdgeInsets.all(10), // Adjust for proper icon placement
                  child: customIconPath != null
                      ? Image.asset(
                          customIconPath,
                          height: 26,
                          width: 26,
                        )
                      : Icon(icon, color: Colors.black, size: 24),
                ),
              ),
              SizedBox(width: 10), // Space between icon and text

              // Profile text
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
