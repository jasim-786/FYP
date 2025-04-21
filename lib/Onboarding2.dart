// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, file_names

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Onboarding1.dart';
import 'package:flutter_application_1/Onboarding3.dart';
import 'package:flutter_application_1/PreHomeScreen.dart';

class Onboarding2 extends StatelessWidget {
  const Onboarding2({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFE5D188), // Background color
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 0) {
              // User swiped Right -> Go to previous page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Onboarding1()),
              );
            } else if (details.primaryVelocity! < 0) {
              // User swiped Left -> Go to next page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Onboarding3()),
              );
            }
          }
        },
        child: Stack(
          children: [
            Positioned(
              top: 30, // Adjust vertically
              left: 12, // Adjust horizontally
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Onboarding1()),
                  );
                },
                child: Image.asset(
                  "assets/icons/Back_arrow.png",
                  height: 35,
                  width: 35,
                ),
              ),
            ),
            // Centered Top Image
            Positioned(
              top: screenHeight * 0.05, // Adjust as needed
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Image.asset(
                      "assets/images/OB2.png", // Placeholder for your top image
                      fit: BoxFit.contain,
                      width: screenWidth * 0.65, // Adjust size as needed
                    ),
                  ),
                  Text(
                    'Upload or Take a Photo'.tr(), // Placeholder text
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8), // Space between texts
                  Text(
                    'Spot Wheat Rust Disease in Your Crops with Ease'
                        .tr(), // Additional text
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20), // Space before indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white, // Active dot color
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(0xFF7B5228), // Inactive dot color
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white, // Inactive dot color
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white, // Inactive dot color
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25), // Space before buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PreHomeScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7B5228),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        child: Text(
                          'Skip'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Onboarding3(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7B5228),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        child: Text(
                          'Next'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Bottom Image Covering Full Screen Width
            Positioned(
              bottom: -25,
              left: 0,
              right: 0,
              child: Image.asset(
                "assets/images/onboarding_bottom.png", // Placeholder for your bottom image
                fit: BoxFit.cover,
                height: screenHeight * 0.28, // Adjust height as needed
                width: screenWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
