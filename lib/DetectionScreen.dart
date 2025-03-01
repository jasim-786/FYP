// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, file_names, use_key_in_widget_constructors, unnecessary_null_comparison, library_private_types_in_public_api, use_super_parameters

import 'package:flutter/material.dart';
import 'dart:io';

class DetectionScreen extends StatefulWidget {
  final String imagePath;

  const DetectionScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _DetectionScreenState createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  late String imagePath;

  @override
  void initState() {
    super.initState();
    print("📍 Navigated to DetectionScreen with: ${widget.imagePath}");

    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {}); // Force UI rebuild
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    File imageFile = File(widget.imagePath);
    bool fileExists = imageFile.existsSync(); // Check if file exists

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

          // Main Content Positioned
          Positioned.fill(
            top: screenHeight * 0.22,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Display Selected Image
                  Container(
                    height: screenHeight * 0.40,
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
                    child: fileExists
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(imageFile, fit: BoxFit.cover),
                          )
                        : Center(
                            child: Text(
                              "⚠️ Image not found!",
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                          ),
                  ),

                  SizedBox(height: screenHeight * 0.06),

                  // Upload Image Button
                  SizedBox(
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.06,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF7B5228),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Change Image',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Icon Positioned on Top Left of the Button
                        Positioned(
                          top: -38,
                          left: -40,
                          child: Image.asset(
                            'assets/icons/replace_icon.png',
                            width: 70,
                            height: 70,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Detect Disease Button
                  SizedBox(
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.06,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Add disease detection logic here
                            print("Detecting disease...");
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
                              'Detect Disease',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Icon Positioned on Top Left of the Second Button
                        Positioned(
                          top: -36,
                          left: -45,
                          child: Image.asset(
                            'assets/icons/Detection_icon.png',
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
