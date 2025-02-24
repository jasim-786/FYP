// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, file_names

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
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

          // Main Content Positioned
          Positioned.fill(
            top: screenHeight * 0.22,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Empty Container Styled Like Login Screen
                  Container(
                    height: screenHeight * 0.35,
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
                    child: Center(
                      child: Text(
                        'This space is empty. Add content here as needed.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.05),

                  // Upload Image Button with Correctly Positioned Icon
                  SizedBox(
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.06,
                    child: Stack(
                      clipBehavior: Clip.none, // Ensures the icon isn't cropped
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Handle button press
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF7B5228),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Upload Image',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Icon Positioned Outside the Button
                        Positioned(
                          top: -35,
                          right: -35,
                          child: Image.asset(
                            'assets/icons/upload_icon.png', // Path to your image
                            width: 70, // Adjust width for your icon
                            height: 70, // Adjust height for your icon
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // "or" Text
                  Text(
                    "or",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Second Button
                  SizedBox(
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.06,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Handle second button press
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF7B5228),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Take Photo',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Icon Positioned Outside the Second Button
                        Positioned(
                          top: -35,
                          right: -35,
                          child: Image.asset(
                            'assets/icons/take_photo_icon.png', // Path to your second button icon
                            width: 70,
                            height: 70,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
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
