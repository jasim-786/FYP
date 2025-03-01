// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, file_names, unused_element, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application_1/AboutUsScreen.dart';
import 'package:flutter_application_1/DetectionScreen.dart';
import 'package:flutter_application_1/Onboarding1.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Method to handle image picking
  Future<void> _pickImage(BuildContext context) async {
    PermissionStatus status = await Permission.photos.request();
    print("Permission status: $status"); // Debug permission

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      print("Picked file: ${pickedFile?.path ?? 'null'}"); // Debug picker

      if (pickedFile != null && context.mounted) {
        print(
            "Navigating to DetectionScreen with path: ${pickedFile.path}"); // Debug navigation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetectionScreen(imagePath: pickedFile.path),
          ),
        );
      }
    } else {
      _showPermissionDeniedDialog(context);
    }
  }

  // Show a dialog if permission is denied
  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Permission Denied"),
        content: Text("Please grant permission to access your gallery."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  // Function to request permission and take a photo using the camera
  /*Future<void> _takePhoto() async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      // Request permission first
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      // Open app settings if permanently denied
      openAppSettings();
    }

    if (status.isGranted) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permission to access camera denied!")),
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

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
                    text: "Home",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/profile_icon.png",
                    text: "Profile",
                    onTap: () {
                      // Handle Profile Navigation
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/help_icon.png",
                    text: "Help",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Onboarding1()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/feedback_icon.png",
                    text: "Feedback",
                    onTap: () {
                      // Handle Profile Navigation
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/info_icon.png",
                    text: "About Us",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AboutUsScreen()),
                      );
                    },
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
                          "No image selected",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )),

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
                            print("Upload button clicked!"); // Debugging
                            _pickImage(context);
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
