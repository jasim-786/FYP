import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CompareImagesScreen extends StatefulWidget {
  const CompareImagesScreen({super.key});

  @override
  State<CompareImagesScreen> createState() => _CompareImagesScreenState();
}

class _CompareImagesScreenState extends State<CompareImagesScreen> {
  File? _firstImage;
  File? _secondImage;

  Future<void> _pickImage(bool isFirst, ImageSource source) async {
    PermissionStatus status;

    if (source == ImageSource.camera) {
      // Request camera permission
      status = await Permission.camera.request();
    } else {
      // Request gallery permission
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        print("Picked file: ${pickedFile.path}");
        // Handle image file path here
      } else {
        print('No image selected');
      }
    } else {
      // Handle permission denied case
      _showPermissionDeniedDialog(context);
    }
  }

  Widget _buildImageContainer(File? image, String label) {
    return Container(
      height: 180,
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF7B5228), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(1, 1)),
        ],
      ),
      child: image != null
          ? Image.file(image, fit: BoxFit.cover)
          : Center(
              child: Text(
                'No $label Image Selected',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
    );
  }

  Widget _buildImageButtons(bool isFirst) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // First Image Button
        ElevatedButton.icon(
          onPressed: () => _pickImage(isFirst, ImageSource.gallery),
          icon: Icon(Icons.image),
          label: Text('Upload ${isFirst ? "1st" : "2nd"} Photo'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            backgroundColor: Color(0xFF7B5228),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
        SizedBox(width: 4), // Space between buttons

        // Second Image Button
        ElevatedButton.icon(
          onPressed: () => _pickImage(isFirst, ImageSource.camera),
          icon: Icon(Icons.camera_alt),
          label: Text('Take ${isFirst ? "1st" : "2nd"} Photo'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            backgroundColor: Color(0xFF7B5228),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
      ],
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Permission Denied"),
        content: Text("Please grant permission to access the camera."),
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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
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
          Positioned(
            top: 30,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.asset(
                "assets/icons/Back_arrow.png",
                height: 35,
                width: 35,
              ),
            ),
          ),
          Positioned.fill(
            top: screenHeight * 0.20,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildImageContainer(_firstImage, "First"),
                    _buildImageButtons(true),
                    SizedBox(height: 10),
                    _buildImageContainer(_secondImage, "Second"),
                    _buildImageButtons(false),
                    SizedBox(height: 30),
                    if (_firstImage != null && _secondImage != null)
                      ElevatedButton(
                        onPressed: () {
                          // Add comparison logic if needed
                        },
                        child: Text("Compare"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7B5228),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
