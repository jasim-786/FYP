// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ImageDisplayScreen.dart'; // Import the new screen

class DetectingOptionPage extends StatelessWidget {
  const DetectingOptionPage({super.key});

  // Method to handle image picking
  Future<void> _pickImage(BuildContext context) async {
    // Request permission to access the gallery
    PermissionStatus status = await Permission.photos.request();

    if (status.isGranted) {
      // If permission is granted, open the gallery to pick an image
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Navigate to the new screen and pass the image path
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ImageDisplayScreen(imagePath: pickedFile.path),
          ),
        );
      }
    } else {
      // If permission is denied, show a message
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
            // Centered buttons
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Button for uploading an image
                  ElevatedButton(
                    onPressed: () {
                      _pickImage(context); // Call the method to pick an image
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
