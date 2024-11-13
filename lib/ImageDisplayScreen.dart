// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageDisplayScreen extends StatefulWidget {
  final String imagePath;
  const ImageDisplayScreen({super.key, required this.imagePath});

  @override
  _ImageDisplayScreenState createState() => _ImageDisplayScreenState();
}

class _ImageDisplayScreenState extends State<ImageDisplayScreen> {
  late String imagePath;

  @override
  void initState() {
    super.initState();
    imagePath = widget.imagePath; // Initialize with the passed image path
  }

  // Method to pick a new image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePath =
            pickedFile.path; // Update the image path when a new image is picked
      });
    }
  }

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
                "assets/Image_Display_Background.png", // Your background image here
                fit: BoxFit.cover,
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
            // Positioned text above the image in the middle
            Positioned(
              top: 200, // Position the text slightly below the back button
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Uploaded Image",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    backgroundColor: Colors
                        .black54, // Optional background to make the text readable
                  ),
                ),
              ),
            ),
            // Centered content with image and buttons
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display the image
                  Image.file(File(imagePath)),
                  SizedBox(height: 20),
                  // Button to change the image with the same style as "Upload Image"
                  ElevatedButton(
                    onPressed: _pickImage, // Open gallery to pick a new image
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Change Image",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Button to scan for disease
                  ElevatedButton(
                    onPressed: () {
                      // Handle disease scanning action
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Scan for Disease",
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
