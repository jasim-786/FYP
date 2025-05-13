import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:open_file/open_file.dart';

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

    // Format date with localization
    final dateString = _getFormattedDate(context);

    // Get translated treatments and prevention text
    final treatmentText = _getTranslatedTreatmentsForPdf(context);
    final preventionText = _getTranslatedPreventionForPdf(context);

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
                  tr("app_name"),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.brown800,
                  ),
                ),
              ],
            ),
            pw.Text(
              tr("detection_report"),
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
                "${tr("app_name")} - ${tr("app_tagline")}",
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
              pw.Text(
                tr("report_disclaimer"),
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
              ),
            ],
          ),
        ),

        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Text(
              tr("disease_detection_report"),
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
          pw.Text(tr("prediction"),
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text("${tr("disease")}: ${_getTranslatedDiseaseName()}",
              style: pw.TextStyle(fontSize: 16)),
          pw.Text("${tr("detected_on")}: $dateString",
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text(tr("recommended_treatments"),
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(treatmentText, style: pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text(tr("preventions"),
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(preventionText, style: pw.TextStyle(fontSize: 14)),
        ],
      ),
    );

    // Save the PDF to a temporary file
    final pdfFile = await File(
            '${tempDir.path}/${tr("detection_report")}_${DateTime.now().millisecondsSinceEpoch}.pdf')
        .writeAsBytes(await pdf.save());

    final text = '''
${tr("prediction")}: ${_getTranslatedDiseaseName()}
${tr("detected_on")}: $dateString
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
            SnackBar(content: Text(tr("storage_permission_settings"))),
          );
          return;
        }
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr("storage_permission_denied"))),
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

    // Format date with localization
    final dateString = _getFormattedDate(context);

    // Get translated treatments and prevention text
    final treatmentText = _getTranslatedTreatmentsForPdf(context);
    final preventionText = _getTranslatedPreventionForPdf(context);

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
                  tr("app_name"),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.brown800,
                  ),
                ),
              ],
            ),
            pw.Text(
              tr("detection_report"),
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
                "${tr("app_name")} - ${tr("app_tagline")}",
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
              pw.Text(
                tr("report_disclaimer"),
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
              ),
            ],
          ),
        ),

        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Text(
              tr("disease_detection_report"),
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
          pw.Text(tr("prediction"),
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text("${tr("disease")}: ${_getTranslatedDiseaseName()}",
              style: pw.TextStyle(fontSize: 16)),
          pw.Text("${tr("detected_on")}: $dateString",
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text(tr("recommended_treatments"),
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(treatmentText, style: pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text(tr("preventions"),
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
          '${tr("detection_report")}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${targetDir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr("pdf_saved_opening")),
        ),
      );

      // Open the PDF
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("${tr("failed_to_open_pdf")}: ${result.message}")),
        );
      }
    } catch (e, stackTrace) {
      print("PDF save/open error: $e\n$stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${tr("failed_to_save_pdf")}: $e")),
      );
    }
  }

  // Helper method to get translated disease name
  String _getTranslatedDiseaseName() {
    // Convert disease name to translation key format
    final diseaseKey = "disease_${disease.toLowerCase().replaceAll(' ', '_')}";
    return tr(diseaseKey);
  }

  // Helper method to format date with localization
  String _getFormattedDate(BuildContext context) {
    // Format date according to locale
    return "${timestamp.day}/${timestamp.month}/${timestamp.year} ${tr("at")} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
  }

  // Helper method to get translated treatments for PDF
  String _getTranslatedTreatmentsForPdf(BuildContext context) {
    final diseaseKey = disease.replaceAll(' ', '_').toLowerCase();

    return treatments.entries.map((e) {
      final category = e.key;
      final categoryKey = "${category.toLowerCase()}_treatments";
      final translatedCategory = tr(categoryKey).toUpperCase();

      final points = (e.value as List<dynamic>).asMap().entries.map((item) {
        final itemIndex = item.key + 1; // 1-based index
        final translationKey =
            "${diseaseKey}_${category.toLowerCase()}_$itemIndex";
        return tr(translationKey);
      }).join("\n");

      return "$translatedCategory:\n$points";
    }).join("\n\n");
  }

  // Helper method to get translated prevention for PDF
  String _getTranslatedPreventionForPdf(BuildContext context) {
    final diseaseKey = disease.replaceAll(' ', '_').toLowerCase();

    return prevention.asMap().entries.map((entry) {
      final index = entry.key + 1; // 1-based index
      final translationKey = "${diseaseKey}_prevention_$index";
      return tr(translationKey);
    }).join("\n");
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
    final diseaseKey = disease.replaceAll(' ', '_').toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr("detection_details"),
          style: const TextStyle(color: Colors.white),
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
                "${tr("prediction")}: ${_getTranslatedDiseaseName()}",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7B5228),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${tr("detected_on")}: ${_getFormattedDate(context)}",
                style: TextStyle(fontSize: screenWidth * 0.045),
              ),
              const SizedBox(height: 24),
              Text(
                "${tr("recommended_treatments")}:",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown[800],
                ),
              ),
              const SizedBox(height: 10),
              ...treatments.entries.map((entry) {
                final category = entry.key;
                final items = entry.value is List
                    ? entry.value as List<dynamic>
                    : [entry.value];
                final categoryKey = "${category.toLowerCase()}_treatments";

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
                            tr(categoryKey),
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ...items.asMap().entries.map((item) {
                        final itemIndex = item.key + 1; // 1-based index
                        final translationKey =
                            "${diseaseKey}_${category.toLowerCase()}_$itemIndex";

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• "),
                              Expanded(
                                child: Text(
                                  tr(translationKey),
                                  style:
                                      TextStyle(fontSize: screenWidth * 0.043),
                                  // For RTL languages, use textAlign
                                  textAlign: context.locale.languageCode ==
                                              'ur' ||
                                          context.locale.languageCode == 'ar' ||
                                          context.locale.languageCode == 'pa'
                                      ? TextAlign.right
                                      : TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
              Text(
                "${tr("preventions")}:",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown[800],
                ),
              ),
              const SizedBox(height: 10),
              ...prevention.asMap().entries.map((entry) {
                final index = entry.key + 1; // 1-based index
                final translationKey = "${diseaseKey}_prevention_$index";

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• "),
                      Expanded(
                        child: Text(
                          tr(translationKey),
                          style: TextStyle(fontSize: screenWidth * 0.043),
                          // For RTL languages, use textAlign
                          textAlign: context.locale.languageCode == 'ur' ||
                                  context.locale.languageCode == 'ar' ||
                                  context.locale.languageCode == 'pa'
                              ? TextAlign.right
                              : TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
