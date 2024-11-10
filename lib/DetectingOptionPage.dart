// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class DetectingOptionPage extends StatelessWidget {
  const DetectingOptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard if open
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // Full-screen background image
            Positioned.fill(
              child: Image.asset(
                "assets/Background_DetectionOption.png",
                fit: BoxFit.cover, // Ensures the image covers the entire screen
              ),
            ),
            // Back button
            Positioned(
              top: 40, // Positioning the button at the top left
              left: 10,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context); // Go back to the previous page
                },
              ),
            ),
            // Centered buttons
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Button for uploading an image
                  ElevatedButton(
                    onPressed: () {
                      // Handle image upload action
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Upload Image",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  SizedBox(height: 20), // Space between buttons
                  // Button for real-time detection
                  ElevatedButton(
                    onPressed: () {
                      // Handle real-time detection action
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Real-Time Detection",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
