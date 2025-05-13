// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, file_names, sort_child_properties_last, prefer_final_fields, non_constant_identifier_names, avoid_print, prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/PhoneNumberScreen.dart';
import 'package:flutter_application_1/PreHomeScreen.dart';
import 'package:flutter_application_1/SignUpScreen.dart';
import 'package:flutter_application_1/ForgotPasswordScreen.dart';
import 'package:flutter_application_1/Onboarding1.dart';
import 'package:flutter_application_1/UserDetailScreen.dart';
import 'package:flutter_application_1/AdminScreen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoginSelected = true; // Tracks whether Login is selected

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;
  int _logoTapCount = 0; // Counter for logo taps

  void Login(String Email, String Password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await auth.signInWithEmailAndPassword(email: Email, password: Password);
      // Navigate to HomeScreen after successful login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PreHomeScreen()),
      );
    } on FirebaseAuthException catch (error) {
      // Show error message if login fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? "Login Failed")),
      );
    }
  }

  void logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'.tr()),
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          // Dismiss the keyboard when tapping outside the TextField
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                "assets/images/Background.png",
                fit: BoxFit.cover,
              ),
            ),

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

            // Main Content Positioned
            Positioned.fill(
              top: screenHeight * 0.1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo Image with Secret Functionality
                      Transform.translate(
                        offset: Offset(-80, -10),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _logoTapCount++;
                              if (_logoTapCount >= 5) {
                                _logoTapCount = 0; // Reset counter
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdminScreen(),
                                  ),
                                );
                              }
                            });
                          },
                          child: Image.asset(
                            "assets/images/logo.png",
                            height: screenHeight * 0.17,
                            width: screenWidth * 0.4,
                          ),
                        ),
                      ),
                      // Welcome Text
                      Transform.translate(
                        offset: Offset(0, 0),
                        child: Text(
                          isLoginSelected
                              ? 'welcome_back'.tr()
                              : 'create_an_account'.tr(),
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Login Form & Buttons Stack
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Login Form Container
                          SizedBox(
                            height: screenHeight * 0.275,
                            child: Container(
                              padding: EdgeInsets.all(4),
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
                                    // Login and Signup Toggle
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
                                              },
                                              child: Text('login'.tr()),
                                              style: TextButton.styleFrom(
                                                foregroundColor: isLoginSelected
                                                    ? Colors.white
                                                    : Colors.black,
                                                backgroundColor: isLoginSelected
                                                    ? Color(0xFF7B5228)
                                                    : Colors.transparent,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 4),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SignUpScreen(),
                                                  ),
                                                );
                                              },
                                              child: Text('signup'.tr()),
                                              style: TextButton.styleFrom(
                                                foregroundColor: isLoginSelected
                                                    ? Colors.black
                                                    : Colors.white,
                                                backgroundColor: isLoginSelected
                                                    ? Colors.transparent
                                                    : Color(0xFF7B5228),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 4),
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
                                    SizedBox(height: 5),

                                    // Username Field
                                    Form(
                                      key: _key,
                                      child: TextFormField(
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
                                          if (value == null || value.isEmpty) {
                                            return 'Email cannot be empty'.tr();
                                          } else if (!value.contains('@')) {
                                            return 'Enter a valid email'.tr();
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    // Password Field
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
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(32),
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
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
                            ),
                          ),

                          // Login or Signup Button
                          Positioned(
                            bottom: -22,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: SizedBox(
                                width: screenWidth * 0.5,
                                height: screenHeight * 0.06,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (isLoginSelected) {
                                      // Handle login action
                                      if (_key.currentState!.validate()) {
                                        Login(_email.text.tr(),
                                            _password.text.tr());
                                      }
                                    } else {
                                      // Handle signup action
                                    }
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
                                    isLoginSelected
                                        ? 'Login'.tr()
                                        : 'Signup'.tr(),
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

                      // Forgot Password & Continue Without Login
                      SizedBox(height: 20),

                      if (isLoginSelected)
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot your password?'.tr(),
                            style: TextStyle(
                              color: Color(0xFF7B5228),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      SizedBox(height: 15),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: screenWidth * 0.4,
                                height: screenHeight * 0.06,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PhoneNumberScreen(),
                                      ),
                                    );
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
                                    'Phone Login'.tr(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              SizedBox(
                                width: screenWidth * 0.4,
                                height: screenHeight * 0.06,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      final GoogleSignInAccount? googleUser =
                                          await GoogleSignIn().signIn();

                                      if (googleUser == null) return;

                                      final GoogleSignInAuthentication
                                          googleAuth =
                                          await googleUser.authentication;

                                      final credential =
                                          GoogleAuthProvider.credential(
                                        accessToken: googleAuth.accessToken,
                                        idToken: googleAuth.idToken,
                                      );

                                      UserCredential userCredential =
                                          await FirebaseAuth.instance
                                              .signInWithCredential(credential);

                                      final user = userCredential.user;
                                      if (user != null) {
                                        DocumentSnapshot doc =
                                            await FirebaseFirestore.instance
                                                .collection('users_details')
                                                .doc(user.uid)
                                                .get();

                                        if (!doc.exists) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UserDetailScreen(
                                                isGoogleLogin: true,
                                              ),
                                            ),
                                          );
                                        } else {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Onboarding1()),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Google Sign-In failed: $e')),
                                      );
                                    }
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
                                    'Gmail Login'.tr(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: screenWidth * 0.7,
                            height: screenHeight * 0.09,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Onboarding1(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Color(0xFF7B5228),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              child: Text(
                                'Login as Guest'.tr(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
