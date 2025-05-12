// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, file_names, use_key_in_widget_constructors, unnecessary_null_comparison, library_private_types_in_public_api, use_super_parameters, depend_on_referenced_packages, prefer_final_fields, avoid_print, unused_element, use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/AboutUsScreen.dart';
import 'package:flutter_application_1/FeedbackScreen.dart';
import 'package:flutter_application_1/HomeScreen.dart';
import 'package:flutter_application_1/LoginScreen.dart';
import 'package:flutter_application_1/Onboarding1.dart';
import 'package:flutter_application_1/PreviousResultsScreen.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class DetectionScreen extends StatefulWidget {
  final String imagePath;

  const DetectionScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _DetectionScreenState createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  late String imagePath;
  Interpreter? _interpreter;
  String result = "Detection Result: Not Analyzed".tr();
  List<String> _labels = [];
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _syncOfflineDetections(); // On app load
    Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        _syncOfflineDetections();
      }
    });
    imagePath = widget.imagePath; // Initialize state with the initial image
    print("📍 Navigated to DetectionScreen with: $imagePath");
    _loadModel();
    _loadLabels(); // Load labels.txt
  }

  Future<void> _showTreatmentBottomSheet(String diseaseKey) async {
    try {
      String treatmentText = "";

      if (diseaseKey == "Unknown") {
        // Show custom message for unknown cases
        treatmentText =
            "❗ This image does not appear to be a wheat leaf. Please upload a clear image of a wheat leaf for accurate results.";
      } else {
        // Load JSON and treatment data
        final jsonString = await rootBundle.loadString('assets/solutions.json');
        final Map<String, dynamic> allData = json.decode(jsonString);

        if (!allData.containsKey(diseaseKey)) {
          throw Exception("Disease not found in treatment data.");
        }

        final diseaseData = allData[diseaseKey];
        final treatments = diseaseData['treatments'] ?? {};
        final prevention = diseaseData['prevention'] ?? [];

        String formatList(String title, List<dynamic> items) {
          return items.isNotEmpty ? "$title\n• ${items.join('\n• ')}\n\n" : '';
        }

        if (treatments.isNotEmpty) {
          if (treatments['chemical'] != null) {
            treatmentText +=
                formatList("🧪 Chemical Treatments", treatments['chemical']);
          }
          if (treatments['biological'] != null) {
            treatmentText += formatList(
                "🌱 Biological Treatments", treatments['biological']);
          }
          if (treatments['cultural'] != null) {
            treatmentText +=
                formatList("🚜 Cultural Practices", treatments['cultural']);
          }
        }

        if (prevention.isNotEmpty) {
          treatmentText += formatList("🛡️ Prevention Tips", prevention);
        }
      }

      // Show Bottom Sheet
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFE5D188),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diseaseKey == "Unknown"
                              ? "Unknown Detection"
                              : "Treatment for ${diseaseKey.replaceAll('_', ' ')}",
                          style: TextStyle(
                            color: Color(0xFF7B5228),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          treatmentText.trim(),
                          style: TextStyle(
                            color: Colors.black87,
                            height: 1.5,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 24),
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: Colors.white),
                            label: Text("Close",
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF7B5228),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print("Error loading treatment info: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading treatment information")),
      );
    }
  }

  Future<void> _loadModel() async {
    try {
      _interpreter =
          await Interpreter.fromAsset('assets/Model/hybrid_model.tflite');
      print("✅ TFLite model loaded successfully.");
    } catch (e) {
      print("❌ Error loading TFLite model: $e");
    }
  }

  Future<void> _loadLabels() async {
    final String labelsData = await DefaultAssetBundle.of(context)
        .loadString('assets/Model/label.txt');
    setState(() {
      _labels = labelsData.split('\n').map((e) => e.trim()).toList();
    });
  }

  Future<void> _detectDisease() async {
    if (!File(imagePath).existsSync()) {
      setState(() {
        result = "⚠️ Image file not found!";
      });
      return;
    }

    try {
      // Load and resize the image
      File imageFile = File(imagePath);
      var image = img.decodeImage(imageFile.readAsBytesSync())!;
      image = img.copyResize(image, width: 224, height: 224);

      // Convert image to normalized 4D list
      var input = List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = image.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      );

      var inputBuffer = [input]; // Convert to 4D list (1, 224, 224, 4)

      // Prepare output buffer
      var output = List.filled(4, 0.0).reshape([1, 4]);

      // Run the model
      _interpreter?.run(inputBuffer, output);

      // Get the prediction
      int predictedClass = output[0].indexOf(
          output[0].reduce((a, b) => (a as double) > (b as double) ? a : b));

      String disease = _getDiseaseLabel(predictedClass);

      setState(() {
        result = "Prediction: $disease";
      });
      await _storeDetectionResult(disease);
      if (user != null) {
        await _showTreatmentBottomSheet(disease.replaceAll(' ', '_'));
      } else {
        // Optionally show a login prompt
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please log in to view treatments.')),
        );
      }
    } catch (e) {
      print("❌ Error during detection: $e");
      setState(() {
        result = "❌ Detection failed!";
      });
    }
  }

  String _getDiseaseLabel(int index) {
    if (index < _labels.length) {
      return _labels[index];
    }
    return "Unknown";
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  // Method to pick a new image from the gallery
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Image Source"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> isOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _storeDetectionResult(String diseaseName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("⚠️ User not logged in. Skipping Firestore upload.");
      return;
    }

    try {
      File imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        print("⚠️ Image file not found. Skipping upload.");
        return;
      }

      // Resize & convert image to base64
      var image = img.decodeImage(imageFile.readAsBytesSync())!;
      image = img.copyResize(image, width: 224, height: 224);
      final compressedImage = img.encodeJpg(image, quality: 85);
      final base64Image = base64Encode(compressedImage);

      // Get disease data
      Map<String, dynamic> treatments = {};
      List<dynamic> prevention = [];
      if (diseaseName != "Unknown") {
        final jsonString = await rootBundle.loadString('assets/solutions.json');
        final Map<String, dynamic> allData = json.decode(jsonString);
        final diseaseData = allData[diseaseName];
        treatments = diseaseData?['treatments'] ?? {};
        prevention = diseaseData?['prevention'] ?? [];
      } else {
        treatments = {"note": "This image does not appear to be a wheat leaf."};
        prevention = ["This image does not appear to be a wheat leaf."];
      }

      // Build detection data
      final detectionData = {
        'userId': user.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'prediction': diseaseName,
        'image_base64': base64Image,
        'treatments': treatments,
        'prevention': prevention,
      };

      // Check online status
      if (!await isOnline()) {
        Hive.box('offline_detections').add(detectionData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Offline: Detection saved locally.")),
        );
        return;
      }

      // Upload online with loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Uploading..."),
            ],
          ),
        ),
      );

      final batch = FirebaseFirestore.instance.batch();
      final docRef =
          FirebaseFirestore.instance.collection('disease_detections').doc();
      batch.set(docRef, {
        ...detectionData,
        'timestamp': Timestamp.now(), // Firestore needs proper format
      });
      await batch.commit();

      Navigator.pop(context); // Close dialog
      print("✅ Detection result uploaded to Firestore.");
    } catch (e) {
      Navigator.pop(context);
      print("❌ Error uploading to Firestore: $e");
      if (e.toString().contains('Document too large')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Image or data too large. Please try a smaller image.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading data")),
        );
      }
    }
  }

  Future<void> _syncOfflineDetections() async {
    if (!await isOnline()) return;
    final box = Hive.box('offline_detections');
    final items = box.values.toList();

    for (var item in items) {
      try {
        await FirebaseFirestore.instance.collection('disease_detections').add({
          ...Map<String, dynamic>.from(item),
          'timestamp': Timestamp.fromMillisecondsSinceEpoch(item['timestamp']),
        });
      } catch (e) {
        print("❌ Sync failed for one item: $e");
        return;
      }
    }

    await box.clear();
    print("✅ All offline detections synced.");
  }

  void logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
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
    File imageFile = File(imagePath);
    bool fileExists = imageFile.existsSync(); // Check if file exists

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
                    text: "Home".tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/profile_icon.png",
                    text: "Profile".tr(),
                    onTap: () {
                      // Handle Profile Navigation
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/history_icon.png",
                    text: "History".tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PreviousResultsScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/help_icon.png",
                    text: "Help".tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Onboarding1()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/feedback_icon.png",
                    text: "Feedback".tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FeedbackScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/info_icon.png",
                    text: "About Us".tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AboutUsScreen()),
                      );
                    },
                  ),
                  Column(
                    children: [
                      if (user != null)
                        buildSidebarButton(
                          customIconPath: "assets/icons/logout_icon.png",
                          text: "Logout".tr(),
                          onTap: () {
                            logout(context);
                          },
                        ),
                    ],
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

          Positioned(
            top: 30, // Adjust vertically
            left: 12, // Adjust horizontally
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                "assets/icons/Back_arrow.png",
                height: 35,
                width: 35,
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
                          onPressed: _showImageSourceDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF7B5228),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Change Image'.tr(),
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
                          top: -40,
                          left: -55,
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

                  // Display Prediction Result
                  Text(
                    result,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    textAlign: TextAlign.center,
                  ),

                  // Detect Disease Button
                  SizedBox(
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.06,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ElevatedButton(
                          onPressed: _detectDisease,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF7B5228),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Detect Disease'.tr(),
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
                          top: -40,
                          left: -55,
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

/// Custom Sidebar Button
Widget buildSidebarButton({
  IconData? icon,
  String? customIconPath,
  required String text,
  required VoidCallback onTap,
}) {
  return Padding(
    padding:
        EdgeInsets.symmetric(vertical: 8, horizontal: 20), // Button Spacing
    child: GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: Offset(-10, 0), // Move button slightly left
        child: Container(
          width: 250,
          decoration: BoxDecoration(
            color: Color(0xFF7B5228), // Brown background for button
            borderRadius: BorderRadius.circular(30), // Rounded button shape
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Row(
            children: [
              // Circular icon background
              Transform.translate(
                offset: Offset(-8, 0), // Moves the icon slightly left
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFE5D188), // Light background for icon
                    shape: BoxShape.circle,
                  ),
                  padding:
                      EdgeInsets.all(10), // Adjust for proper icon placement
                  child: customIconPath != null
                      ? Image.asset(
                          customIconPath,
                          height: 26,
                          width: 26,
                        )
                      : Icon(icon, color: Colors.black, size: 24),
                ),
              ),
              SizedBox(width: 10), // Space between icon and text

              // Profile text
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
