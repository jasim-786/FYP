import 'dart:convert';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:open_file_plus/open_file_plus.dart';

class DetectionDetailScreen extends StatelessWidget {
  final String disease;
  final String base64Image;
  final DateTime timestamp;
  final Map<String, dynamic> treatments;
  final List<dynamic> prevention;

  const DetectionDetailScreen({
    Key? key,
    required this.disease,
    required this.base64Image,
    required this.timestamp,
    required this.treatments,
    required this.prevention,
  }) : super(key: key);
  Future<void> _shareDetection(BuildContext context) async {
    final tempDir = await getTemporaryDirectory();

    // Generate the PDF
    final pdf = pw.Document();
    final image = base64Decode(base64Image);
    final dateString =
        "${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
    final treatmentText = treatments.entries.map((e) {
      final points =
          (e.value as List<dynamic>).map((item) => "• $item").join("\n");
      return "${e.key.toUpperCase()}:\n$points";
    }).join("\n\n");
    final preventionText = prevention.map((p) => "• $p").join("\n");

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text("Disease Detection Report",
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Image(pw.MemoryImage(image), height: 200, fit: pw.BoxFit.cover),
          pw.SizedBox(height: 20),
          pw.Text("Prediction: $disease",
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text("Detected on: $dateString",
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 20),
          pw.Text("Recommended Treatments",
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text(treatmentText),
          pw.SizedBox(height: 20),
          pw.Text("Preventions",
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text(preventionText),
        ],
      ),
    );

    // Save the PDF to a temporary file
    final pdfFile = await File(
            '${tempDir.path}/Detection_Report_${DateTime.now().millisecondsSinceEpoch}.pdf')
        .writeAsBytes(await pdf.save());

    final text = '''
Prediction: $disease
Detected on: ${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}
''';

    // Share only the PDF
    await Share.shareXFiles(
      [XFile(pdfFile.path)],
      text: text,
    );
  }

  Future<void> _generateAndDownloadPDF(BuildContext context) async {
    // Request storage permission only for Android 9 and below (API < 29)
    if (Platform.isAndroid) {
      // Check Android version using DeviceInfoPlugin
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;

      if (sdkVersion < 29) {
        // Android 9 (API 28) or below
        var status = await Permission.storage.request();
        if (status.isPermanentlyDenied) {
          openAppSettings();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("❌ Please grant storage permission in settings")),
          );
          return;
        }
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Storage permission denied")),
          );
          return;
        }
      }
    }

    final pdf = pw.Document();
    final image = base64Decode(base64Image);
    final dateString =
        "${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";

    final treatmentText = treatments.entries.map((e) {
      final points =
          (e.value as List<dynamic>).map((item) => "• $item").join("\n");
      return "${e.key.toUpperCase()}:\n$points";
    }).join("\n\n");

    final preventionText = prevention.map((p) => "• $p").join("\n");

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text("Disease Detection Report",
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Image(pw.MemoryImage(image), height: 200, fit: pw.BoxFit.cover),
          pw.SizedBox(height: 20),
          pw.Text("Prediction: $disease",
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text("Detected on: $dateString",
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 20),
          pw.Text("Recommended Treatments",
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text(treatmentText),
          pw.SizedBox(height: 20),
          pw.Text("Preventions",
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text(preventionText),
        ],
      ),
    );

    try {
      // Save to app-specific Documents directory
      final targetDir = await getApplicationDocumentsDirectory();
      final fileName =
          'Detection_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${targetDir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("✅ PDF saved to app's Documents folder. Opening now..."),
        ),
      );

      // Open the PDF
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to open PDF: ${result.message}")),
        );
      }
    } catch (e, stackTrace) {
      print("PDF save/open error: $e\n$stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to save or open PDF: $e")),
      );
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'chemical':
        return Icons.science;
      case 'biological':
        return Icons.biotech;
      case 'cultural':
        return Icons.agriculture;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detection Details"),
        backgroundColor: const Color(0xFF7B5228),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareDetection(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _generateAndDownloadPDF(context),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE5D188),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  base64Decode(base64Image),
                  height: screenHeight * 0.3,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Prediction: $disease",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7B5228),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Detected on: ${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}",
                style: TextStyle(fontSize: screenWidth * 0.045),
              ),
              const SizedBox(height: 24),
              Text(
                "Recommended Treatments:",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown[800],
                ),
              ),
              const SizedBox(height: 10),
              ...treatments.entries.map((entry) {
                final category = entry.key;
                final items = entry.value as List<dynamic>;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_getIconForCategory(category),
                              color: Colors.teal[700]),
                          const SizedBox(width: 6),
                          Text(
                            category[0].toUpperCase() + category.substring(1),
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ...items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("• "),
                                Expanded(
                                  child: Text(
                                    item.toString(),
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.043),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
              Text(
                "Preventions:",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown[800],
                ),
              ),
              const SizedBox(height: 10),
              ...prevention.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• "),
                        Expanded(
                          child: Text(
                            item.toString(),
                            style: TextStyle(fontSize: screenWidth * 0.043),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
