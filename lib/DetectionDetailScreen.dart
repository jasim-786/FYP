import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
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
    final Uint8List logoImage = await rootBundle
        .load('assets/images/logo.png')
        .then((data) => data.buffer.asUint8List());
    final pdf = pw.Document();
    final image = base64Decode(base64Image);
    final dateString =
        "${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
    final treatmentText = treatments.entries.map((e) {
      final points =
          (e.value as List<dynamic>).map((item) => "$item").join("\n");
      return "${e.key.toUpperCase()}:\n$points";
    }).join("\n\n");
    final preventionText = prevention.map((p) => "$p").join("\n");

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(32),

        // Header added
        header: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Row(
              children: [
                pw.Image(pw.MemoryImage(logoImage), width: 80, height: 80),
                pw.SizedBox(width: 8),
                pw.Text(
                  "Wheat Rust Guard",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.brown800,
                  ),
                ),
              ],
            ),
            pw.Text(
              "Detection Report",
              style: pw.TextStyle(
                fontSize: 14,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),

        // Footer
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Column(
            children: [
              pw.Divider(),
              pw.Text(
                "Wheat Rust Guard  Empowering Farmers with AI",
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
              pw.Text(
                "This report is generated for informational purposes only.",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
              ),
            ],
          ),
        ),

        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Text(
              "Disease Detection Report",
              style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Center(
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.ClipRRect(
                horizontalRadius: 8,
                verticalRadius: 8,
                child: pw.Image(
                  pw.MemoryImage(image),
                  height: 200,
                  fit: pw.BoxFit.cover,
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text("Prediction",
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text("Disease: $disease", style: pw.TextStyle(fontSize: 16)),
          pw.Text("Detected on: $dateString",
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text("Recommended Treatments",
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(treatmentText, style: pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text("Preventions",
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(preventionText, style: pw.TextStyle(fontSize: 14)),
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
    final Uint8List logoImage = await rootBundle
        .load('assets/images/logo.png')
        .then((data) => data.buffer.asUint8List());
    final pdf = pw.Document();
    final image = base64Decode(base64Image);
    final dateString =
        "${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";

    final treatmentText = treatments.entries.map((e) {
      final points =
          (e.value as List<dynamic>).map((item) => "$item").join("\n");
      return "${e.key.toUpperCase()}:\n$points";
    }).join("\n\n");

    final preventionText = prevention.map((p) => "$p").join("\n");

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(32),

        // Header added
        header: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Row(
              children: [
                pw.Image(pw.MemoryImage(logoImage), width: 80, height: 80),
                pw.SizedBox(width: 8),
                pw.Text(
                  "Wheat Rust Guard",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.brown800,
                  ),
                ),
              ],
            ),
            pw.Text(
              "Detection Report",
              style: pw.TextStyle(
                fontSize: 14,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),

        // Footer
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Column(
            children: [
              pw.Divider(),
              pw.Text(
                "Wheat Rust Guard  Empowering Farmers with AI",
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
              pw.Text(
                "This report is generated for informational purposes only.",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
              ),
            ],
          ),
        ),

        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Text(
              "Disease Detection Report",
              style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Center(
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.ClipRRect(
                horizontalRadius: 8,
                verticalRadius: 8,
                child: pw.Image(
                  pw.MemoryImage(image),
                  height: 200,
                  fit: pw.BoxFit.cover,
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text("Prediction",
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text("Disease: $disease", style: pw.TextStyle(fontSize: 16)),
          pw.Text("Detected on: $dateString",
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text("Recommended Treatments",
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(treatmentText, style: pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text("Preventions",
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(preventionText, style: pw.TextStyle(fontSize: 14)),
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

  Widget _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'chemical':
        return Image.asset('assets/icons/biotech.png', width: 34, height: 34);
      case 'biological':
        return Image.asset('assets/icons/science.png', width: 34, height: 34);
      case 'cultural':
        return Image.asset('assets/icons/agriculture.png',
            width: 34, height: 34);
      default:
        return Image.asset('assets/icons/info_icon.png', width: 34, height: 34);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detection Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF7B5228),
        foregroundColor: Colors.white, // Ensures text and icons are white
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareDetection(context),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => _generateAndDownloadPDF(context),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SizedBox(
            height: 35,
            width: 35,
            child: Image.asset('assets/icons/Back_arrow.png'),
          ),
        ),
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
                          _getIconForCategory(category),
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
