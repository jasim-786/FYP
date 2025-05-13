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
import 'package:shared_preferences/shared_preferences.dart';

class DetectionScreen extends StatefulWidget {
  final String imagePath;

  const DetectionScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _DetectionScreenState createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  late String imagePath;
  Interpreter? _interpreter;
  String result = "";
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

    // Set initial result text with translation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        result = tr("detection_result_not_analyzed");
      });
    });
  }

  // Helper method to get translated treatment items
  List<String> _getTranslatedTreatmentItems(
      String diseaseKey, String treatmentType) {
    // Create translation keys based on disease and treatment type
    final baseKey =
        "${diseaseKey.toLowerCase()}_${treatmentType.toLowerCase()}";

    // For chemical treatments, we need to translate each item individually
    List<String> translatedItems = [];

    // Try to get translations for items 1-5 (adjust based on your data)
    for (int i = 1; i <= 5; i++) {
      final itemKey = "${baseKey}_$i";
      // Check if translation exists
      String translatedItem = "";
      try {
        translatedItem = tr(itemKey);
        // Only add non-empty translations
        if (translatedItem != itemKey && translatedItem.isNotEmpty) {
          translatedItems.add(translatedItem);
        }
      } catch (e) {
        // Translation key doesn't exist, skip
      }
    }

    return translatedItems;
  }

  Future<void> _showTreatmentBottomSheet(String diseaseKey) async {
    try {
      String treatmentText = "";
      String displayDiseaseName = diseaseKey.replaceAll('_', ' ');
      String diseaseKeyLower = diseaseKey.toLowerCase();

      if (diseaseKey == "Unknown") {
        // Show custom message for unknown cases
        treatmentText = tr("unknown_disease_message");
      } else {
        // Load JSON to get the structure, but we'll use translations for content
        final jsonString = await rootBundle.loadString('assets/solutions.json');
        final Map<String, dynamic> allData = json.decode(jsonString);

        if (!allData.containsKey(diseaseKey)) {
          throw Exception("Disease not found in treatment data.");
        }

        final diseaseData = allData[diseaseKey];

        // Add scientific name (scientific names don't need translation)
        if (diseaseData.containsKey('scientificName')) {
          treatmentText +=
              "${tr('scientific_name')}: ${diseaseData['scientificName']}\n\n";
        }

        // Add symptoms using translation key
        treatmentText +=
            "${tr('symptoms')}: ${tr('${diseaseKeyLower}_symptoms')}\n\n";

        // Add environmental conditions using translation key
        treatmentText +=
            "${tr('environmental_conditions')}: ${tr('${diseaseKeyLower}_conditions')}\n\n";

        // Add vulnerable stages using translation key
        treatmentText +=
            "${tr('vulnerable_stages')}: ${tr('${diseaseKeyLower}_stages')}\n\n";

        // Get translated treatment items
        List<String> chemicalTreatments =
            _getTranslatedTreatmentItems(diseaseKey, "chemical");
        List<String> biologicalTreatments =
            _getTranslatedTreatmentItems(diseaseKey, "biological");
        List<String> culturalPractices =
            _getTranslatedTreatmentItems(diseaseKey, "cultural");
        List<String> preventionTips =
            _getTranslatedTreatmentItems(diseaseKey, "prevention");

        // Helper function to format lists with translations
        String formatList(String title, List<String> items) {
          if (items.isEmpty) return '';
          return "$title\n• ${items.join('\n• ')}\n\n";
        }

        // Add treatments with translated items
        if (chemicalTreatments.isNotEmpty) {
          treatmentText +=
              formatList(tr('chemical_treatments'), chemicalTreatments);
        }

        if (biologicalTreatments.isNotEmpty) {
          treatmentText +=
              formatList(tr('biological_treatments'), biologicalTreatments);
        }

        if (culturalPractices.isNotEmpty) {
          treatmentText +=
              formatList(tr('cultural_practices'), culturalPractices);
        }

        if (preventionTips.isNotEmpty) {
          treatmentText += formatList(tr('prevention_tips'), preventionTips);
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
          // Create a properly localized title using translation keys
          String titleText;
          if (diseaseKey == "Unknown") {
            titleText = tr("unknown_detection");
          } else {
            // Use a translation key with parameter for disease name
            final diseaseTrKey = "disease_${diseaseKey.toLowerCase()}";
            final localizedDiseaseName = tr(diseaseTrKey);

            // For RTL languages, use the appropriate format
            if (context.locale.languageCode == 'ur' ||
                context.locale.languageCode == 'pa') {
              titleText = "$localizedDiseaseName ${tr('ka_ilaj')}";
            } else {
              // For English and other LTR languages
              titleText = "$localizedDiseaseName ${tr('treatment_for')}";
            }
          }

          // Determine if we should use RTL layout
          bool isRtl = context.locale.languageCode == 'ur' ||
              context.locale.languageCode == 'pa';

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
                          titleText,
                          style: TextStyle(
                            color: Color(0xFF7B5228),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        // Use a custom approach for RTL text
                        Container(
                          width: double.infinity,
                          child: Text(
                            treatmentText.trim(),
                            style: TextStyle(
                              color: Colors.black87,
                              height: 1.5,
                              fontSize: 16,
                            ),
                            // Use textAlign instead of textDirection
                            textAlign: isRtl ? TextAlign.right : TextAlign.left,
                          ),
                        ),
                        SizedBox(height: 24),
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: Colors.white),
                            label: Text(tr('close'),
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
        SnackBar(content: Text(tr('error_loading_treatment'))),
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
        result = tr('image_file_not_found');
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
        // Use a translation key for the disease name
        final diseaseKey =
            "disease_${disease.toLowerCase().replaceAll(' ', '_')}";
        result = "${tr('prediction')}: ${tr(diseaseKey)}";
      });
      await _storeDetectionResult(disease);
      if (user != null) {
        await _showTreatmentBottomSheet(disease.replaceAll(' ', '_'));
      } else {
        // Optionally show a login prompt
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('login_to_view_treatments'))),
        );
      }
    } catch (e) {
      print("❌ Error during detection: $e");
      setState(() {
        result = tr('detection_failed');
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
        // Reset result when new image is picked
        result = tr("detection_result_not_analyzed");
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tr('select_image_source')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text(tr('camera')),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text(tr('gallery')),
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
      print(tr("⚠️ User not logged in. Skipping Firestore upload."));
      return;
    }

    try {
      File imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        print(tr("⚠️ Image file not found. Skipping upload."));
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
        final diseaseData = allData[diseaseName.replaceAll(' ', '_')];
        treatments = diseaseData?['treatments'] ?? {};
        prevention = diseaseData?['prevention'] ?? [];
      } else {
        treatments = {"note": tr('unknown_wheat_leaf')};
        prevention = [tr('unknown_wheat_leaf')];
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
          SnackBar(content: Text(tr('offline_detection_saved'))),
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
              Text(tr('uploading')),
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
      print("✅ Detection result uploaded to Firestore.".tr());
    } catch (e) {
      Navigator.pop(context);
      print("❌ Error uploading to Firestore: $e");
      if (e.toString().contains('Document too large')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('image_too_large'))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('error_uploading_data'))),
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
          title: Text(tr('logout')),
          content: Text(tr('confirm_logout')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text(tr('cancel')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog

                await FirebaseAuth.instance.signOut();

                // Show logout success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr('logout_success')),
                    duration: Duration(seconds: 2),
                  ),
                );

                // Navigate back to login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text(tr('logout'), style: TextStyle(color: Colors.red)),
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
                    context: context,
                    customIconPath: "assets/icons/Home_icon.png",
                    text: tr('home'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    context: context,
                    customIconPath: "assets/icons/profile_icon.png",
                    text: tr('profile'),
                    onTap: () {
                      // Handle Profile Navigation
                    },
                  ),
                  buildSidebarButton(
                    context: context,
                    customIconPath: "assets/icons/history_icon.png",
                    text: tr('history'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PreviousResultsScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    context: context,
                    customIconPath: "assets/icons/help_icon.png",
                    text: tr('help'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Onboarding1()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    context: context,
                    customIconPath: "assets/icons/feedback_icon.png",
                    text: tr('feedback'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FeedbackScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    context: context,
                    customIconPath: "assets/icons/info_icon.png",
                    text: tr('about_us'),
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
                          context: context,
                          customIconPath: "assets/icons/logout_icon.png",
                          text: tr('logout'),
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

          // Language Selector
          Positioned(
            top: 30,
            right: 80,
            child: LanguageSelector(),
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
                              tr('image_not_found'),
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
                              tr('change_image'),
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
                              tr('detect_disease'),
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
/// Custom Sidebar Button
Widget buildSidebarButton({
  required BuildContext context,
  IconData? icon,
  String? customIconPath,
  required String text,
  required VoidCallback onTap,
}) {
  return Padding(
    padding:
        EdgeInsets.symmetric(vertical: 6, horizontal: 15), // Button Spacing
    child: GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: Offset(-10, 0), // Move button slightly left
        child: Container(
          height: 64,
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

/// Language Selector Widget
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  Future<void> _saveLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: Icon(Icons.language, color: Colors.white, size: 30),
      onSelected: (Locale locale) {
        context.setLocale(locale);
        _saveLanguagePreference(locale.languageCode);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<Locale>(
          value: Locale('en'),
          child: Row(
            children: [
              Text('🇬🇧 '),
              SizedBox(width: 8),
              Text(tr('english')),
            ],
          ),
        ),
        PopupMenuItem<Locale>(
          value: Locale('ur'),
          child: Row(
            children: [
              Text('🇵🇰 '),
              SizedBox(width: 8),
              Text(tr('urdu')),
            ],
          ),
        ),
        PopupMenuItem<Locale>(
          value: Locale('pa'),
          child: Row(
            children: [
              Text('🇵🇰 '),
              SizedBox(width: 8),
              Text(tr('punjabi')),
            ],
          ),
        ),
      ],
    );
  }
}
