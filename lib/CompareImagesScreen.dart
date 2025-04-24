import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class CompareImagesScreen extends StatefulWidget {
  const CompareImagesScreen({super.key});

  @override
  State<CompareImagesScreen> createState() => _CompareImagesScreenState();
}

class _CompareImagesScreenState extends State<CompareImagesScreen> {
  File? _firstImage;
  File? _secondImage;
  String result1 = '';
  String result2 = '';
  late Interpreter _interpreter;
  List<String> _labels = [];

  @override
  void initState() {
    super.initState();
    _loadModel();
    _loadLabels(); // Load labels.txt
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
        setState(() {
          if (isFirst) {
            _firstImage = File(pickedFile.path); // Set the first image
          } else {
            _secondImage = File(pickedFile.path); // Set the second image
          }
        });
      } else {
        print('No image selected');
      }
    } else {
      // Handle permission denied case
      _showPermissionDeniedDialog(context);
    }
  }

  Future<String> _detectDisease(File image) async {
    try {
      var imageData = img.decodeImage(image.readAsBytesSync())!;
      imageData = img.copyResize(imageData, width: 224, height: 224);

      var input = List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = imageData.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      );

      var inputBuffer = [input]; // Convert to 4D list

      var output = List.filled(4, 0.0).reshape([1, 4]);

      _interpreter.run(inputBuffer, output);

      int predictedClass = output[0].indexOf(
          output[0].reduce((a, b) => (a as double) > (b as double) ? a : b));

      return _getDiseaseLabel(predictedClass);
    } catch (e) {
      print("❌ Detection error: $e");
      return "❌ Detection failed!";
    }
  }

  String _getDiseaseLabel(int index) {
    return (index < _labels.length) ? _labels[index] : "Unknown";
  }

  void _compareImages() async {
    if (_firstImage != null && _secondImage != null) {
      final prediction1 = await _detectDisease(_firstImage!);
      final prediction2 = await _detectDisease(_secondImage!);

      setState(() {
        result1 = "Prediction (1st): $prediction1";
        result2 = "Prediction (2nd): $prediction2";
      });
    } else {
      setState(() {
        result1 = result2 = "⚠️ Please select both images!";
      });
    }
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  Widget _buildImageContainer(File? image, String label, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF7B5228), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(1, 1)),
        ],
      ),
      child: image != null
          ? FutureBuilder<Size?>(
              future: _getImageDimensions(image),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  final size = snapshot.data!;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      image,
                      width: double.infinity,
                      height: size.height > screenHeight * 0.4
                          ? screenHeight * 0.4
                          : size.height,
                      fit: BoxFit.cover,
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            )
          : Center(
              child: Text(
                'No $label Image Selected',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
    );
  }

  Future<Size?> _getImageDimensions(File image) async {
    final bytes = await image.readAsBytes();
    final img = await decodeImageFromList(bytes);
    return Size(img.width.toDouble(), img.height.toDouble());
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
          Positioned.fill(
            top: screenHeight * 0.195,
            bottom: screenHeight * 0.15,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 5),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildImageContainer(
                              _firstImage, "First", screenHeight),
                          _buildImageButtons(true),
                          if (result1.isNotEmpty)
                            Text(result1, style: TextStyle(fontSize: 16)),
                          SizedBox(height: 10),
                          _buildImageContainer(
                              _secondImage, "Second", screenHeight),
                          _buildImageButtons(false),
                          if (result2.isNotEmpty)
                            Text(result2, style: TextStyle(fontSize: 16)),
                          SizedBox(height: 20),
                          if (_firstImage != null && _secondImage != null)
                            ElevatedButton(
                              onPressed: _compareImages,
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
                ],
              ),
            ),
          ),
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
        ],
      ),
    );
  }
}
