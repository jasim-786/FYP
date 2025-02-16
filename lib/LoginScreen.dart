// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, file_names, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_application_1/SignUpScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoginSelected = true; // Tracks whether Login is selected

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
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
            top: 0,
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
            top: 25, // Adjust for desired position
            right: 5, // Adjust for desired position
            child: GestureDetector(
              onTap: () {
                // Handle sidebar icon tap action
              },
              child: Image.asset(
                "assets/icons/menu.png", // Path to your custom image
                height: 62, // Adjust size as needed
                width: 62, // Adjust size as needed
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
                    "assets/images/logo.png",
                    height: screenHeight * 0.18,
                    width: screenWidth * 0.4,
                  ),
                  SizedBox(height: screenHeight * 0.00),

                  // Welcome Text
                  Text(
                    isLoginSelected ? 'Welcome Back!' : 'Create an Account',
                    style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),

                  // Login Form & Buttons Stack
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Login Form Container
                      SizedBox(
                        height: screenHeight * 0.26,
                        child: Container(
                          padding: EdgeInsets.all(10),
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
                                      borderRadius: BorderRadius.circular(20),
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
                                        child: Text('Login'),
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
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SignUpScreen()));
                                        },
                                        child: Text('Signup'),
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
                              SizedBox(height: 5),

                              // Username Field
                              TextField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person),
                                  hintText: 'Username',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                ),
                              ),
                              SizedBox(height: 16),

                              // Password Field
                              TextField(
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock),
                                  hintText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Login or Signup Button
                      Positioned(
                        bottom: -25,
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
                                isLoginSelected ? 'Login' : 'Signup',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Forgot Password & Continue Without Logging
                      Positioned(
                        bottom: -150, // Adjusted for proper spacing
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            // Forgot Password Text
                            if (isLoginSelected)
                              TextButton(
                                onPressed: () {
                                  // Handle forgot password action
                                },
                                child: Text(
                                  'Forgot your password?',
                                  style: TextStyle(
                                    color: Color(0xFF7B5228),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                            SizedBox(height: 15), // Extra spacing

                            // Continue Without Logging Button
                            SizedBox(
                              width: screenWidth * 0.7,
                              height: screenHeight * 0.07,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle continue without logging action
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
                                  'Continue Without Login',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
