// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, file_names, prefer_final_fields, sort_child_properties_last, non_constant_identifier_names, avoid_print, prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/LoginScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isLoginSelected = false; // Tracks whether Login is selected
  GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Key for scaffold

  TextEditingController _email = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _name = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  Future<User?> SignUp(String email, String password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (error) {
      print("Error while creating user for database: ${error.message}");
      return null;
    }
  }

  void saveUserDetails(String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('users_details')
          .doc(uid)
          .set({
        'userId': uid, // ✅ ADD THIS LINE
        'Full_name': _name.text.trim(),
        'Email': _email.text.trim(),
        'Phone Number': _phone.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User details saved successfully!")),
      );

      _name.clear();
      _email.clear();
      _phone.clear();
      _password.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving details: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      body: GestureDetector(
        onTap: () {
          // Dismiss the keyboard when tapping outside the TextField
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // Top decoration
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
            // Bottom decoration
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
            // Main content
            Positioned.fill(
              top: screenHeight * 0.145,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header with icon and text
                    Stack(
                      clipBehavior:
                          Clip.none, // Allow overflow to avoid clipping
                      children: [
                        Positioned(
                          top: -30, // Moves the icon up
                          right: 100, // Moves the icon right
                          child: Image.asset(
                            "assets/icons/Create icon.png",
                            height: screenHeight * 0.12,
                            width: screenHeight * 0.12,
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(-5, 0),
                          child: Text(
                            'Create\nAccount'.tr(),
                            style: TextStyle(
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),

                    // Signup form and button

                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          height: screenHeight * 0.53,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Color(0xFF7B5228),
                                width: 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 150,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE5D188),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                isLoginSelected = true;
                                              });
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginScreen(),
                                                ),
                                              );
                                            },
                                            child: Text('Login'.tr()),
                                            style: TextButton.styleFrom(
                                              foregroundColor: isLoginSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                              backgroundColor: isLoginSelected
                                                  ? Color(0xFF7B5228)
                                                  : Colors.transparent,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 4),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                isLoginSelected = false;
                                              });
                                            },
                                            child: Text('Signup'.tr()),
                                            style: TextButton.styleFrom(
                                              foregroundColor: isLoginSelected
                                                  ? Colors.black
                                                  : Colors.white,
                                              backgroundColor: isLoginSelected
                                                  ? Colors.transparent
                                                  : Color(0xFF7B5228),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 4),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Form(
                                    key: _key,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: _name,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(
                                                    r'[a-zA-Z\s]')), // Allows only letters and spaces
                                          ],
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.person),
                                            hintText: 'Enter Full Name'.tr(),
                                            filled: true,
                                            fillColor: Colors.transparent,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Color(0xFF7B5228),
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Color(0xFF7B5228),
                                                width: 2,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Full name cannot be empty';
                                            } else if (!RegExp(r'^[a-zA-Z\s]+$')
                                                .hasMatch(value.trim())) {
                                              return 'Only alphabets are allowed';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 10),
                                        TextFormField(
                                          controller: _email,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.email),
                                            hintText: 'Enter Email'.tr(),
                                            filled: true,
                                            fillColor: Colors.transparent,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Color(0xFF7B5228),
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Color(0xFF7B5228),
                                                width: 2,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Email cannot be empty';
                                            } else if (!value.contains('@')) {
                                              return 'Enter a valid email';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 10),
                                        TextFormField(
                                          controller: _phone,
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.phone),
                                            hintText: 'Phone Number'.tr(),
                                            filled: true,
                                            fillColor: Colors.transparent,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Color(0xFF7B5228),
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Color(0xFF7B5228),
                                                width: 2,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Phone number cannot be empty';
                                            } else if (value.length != 11) {
                                              return 'Enter a valid 11-digit phone number';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 10),
                                        TextFormField(
                                          controller: _password,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.lock),
                                            hintText: 'Password'.tr(),
                                            filled: true,
                                            fillColor: Colors.transparent,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Color(0xFF7B5228),
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Color(0xFF7B5228),
                                                width: 2,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Password cannot be empty';
                                            } else if (value.length < 6) {
                                              return 'Password must be at least 6 characters';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.lock),
                                      hintText: 'Confirm Password'.tr(),
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Signup button
                        Positioned(
                          bottom: -25,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SizedBox(
                              width: screenWidth * 0.5,
                              height: screenHeight * 0.06,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_key.currentState!.validate()) {
                                    User? user = await SignUp(
                                        _email.text, _password.text);

                                    if (user != null) {
                                      saveUserDetails(user.uid);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginScreen()),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Sign up failed. Please try again.'
                                                    .tr())),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0xFF7B5228),
                                ),
                                child: Text(
                                  'Signup'.tr(),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Login link moved outside of Stack
                    SizedBox(height: 35),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Have an account? Login'.tr(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
