import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

class TreatmentDetailsScreen extends StatefulWidget {
  final String? adminEmail; // Passed from AdminScreen to check admin status
  const TreatmentDetailsScreen({super.key, this.adminEmail});

  @override
  _TreatmentDetailsScreenState createState() => _TreatmentDetailsScreenState();
}

class _TreatmentDetailsScreenState extends State<TreatmentDetailsScreen> {
  bool get _isAdmin => widget.adminEmail == 'jasimsagheer786@gmail.com';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Verify Firebase initialization
    if (Firebase.apps.isEmpty) {
      setState(() {
        _errorMessage = 'Firebase not initialized';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            'Treatment & Suggestions',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.green.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Center(
          child: Text(
            _errorMessage!,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.red.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Treatment & Suggestions',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('diseases').snapshots(),
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }

          // Handle error state
          if (snapshot.hasError) {
            debugPrint('Firestore error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading data: ${snapshot.error}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.red.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}), // Retry
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          // Handle no data state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            debugPrint('No data in diseases collection');
            return Center(
              child: Text(
                'No disease data available. Please check Firestore setup.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Data available
          final diseases = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: diseases.length,
            itemBuilder: (context, index) {
              final doc = diseases[index];
              final name = doc.id
                  .replaceAll('_', ' ')
                  .replaceAll('Rust', 'Rust Disease');
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                elevation: 6,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade100.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    leading: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.shade100,
                      ),
                      child: Icon(
                        Icons.local_florist,
                        color: Colors.green.shade700,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.green.shade800,
                      ),
                    ),
                    collapsedBackgroundColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    childrenPadding: const EdgeInsets.all(16),
                    children: [
                      _buildIconSection(context, name),
                      _buildSection(context, "Scientific Name",
                          data["scientificName"] ?? 'N/A'),
                      _buildSection(
                          context, "Symptoms", data["symptoms"] ?? 'N/A'),
                      _buildSection(context, "Environmental Conditions",
                          data["environmentalConditions"] ?? 'N/A'),
                      _buildSection(context, "Vulnerable Stages",
                          data["vulnerableStages"] ?? 'N/A'),
                      _buildEditableListSection(
                        context,
                        "Chemical Treatments",
                        (data["treatments"]?["chemical"] as List<dynamic>?)
                                ?.cast<String>() ??
                            [],
                        doc.id,
                        "treatments.chemical",
                      ),
                      _buildEditableListSection(
                        context,
                        "Biological Treatments",
                        (data["treatments"]?["biological"] as List<dynamic>?)
                                ?.cast<String>() ??
                            [],
                        doc.id,
                        "treatments.biological",
                      ),
                      _buildEditableListSection(
                        context,
                        "Cultural Treatments",
                        (data["treatments"]?["cultural"] as List<dynamic>?)
                                ?.cast<String>() ??
                            [],
                        doc.id,
                        "treatments.cultural",
                      ),
                      _buildEditableListSection(
                        context,
                        "Prevention",
                        (data["prevention"] as List<dynamic>?)
                                ?.cast<String>() ??
                            [],
                        doc.id,
                        "prevention",
                      ),
                      _buildSection(context, "Economic Threshold",
                          data["economicThreshold"] ?? 'N/A'),
                      _buildEditableListSection(
                        context,
                        "Traditional Practices",
                        (data["traditionalPractices"] as List<dynamic>?)
                                ?.cast<String>() ??
                            [],
                        doc.id,
                        "traditionalPractices",
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildIconSection(BuildContext context, String diseaseName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade300.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Icon(
              diseaseName.contains('Brown')
                  ? Icons.grass
                  : Icons.energy_savings_leaf,
              size: 52,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            diseaseName,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.green.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableListSection(
    BuildContext context,
    String title,
    List<String> items,
    String docId,
    String fieldPath,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.green.shade700,
                ),
              ),
              if (_isAdmin)
                IconButton(
                  icon:
                      Icon(Icons.edit, color: Colors.green.shade700, size: 20),
                  onPressed: () =>
                      _showEditDialog(context, title, items, docId, fieldPath),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text(
              'No items available',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ...items.asMap().entries.map<Widget>(
                (entry) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "• ",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            height: 1.5,
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
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    List<String> items,
    String docId,
    String fieldPath,
  ) {
    final List<TextEditingController> controllers =
        items.map((item) => TextEditingController(text: item)).toList();
    final TextEditingController newItemController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Text(
          'Edit $title',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.green.shade800,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...controllers.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: entry.value,
                              style: GoogleFonts.poppins(fontSize: 14),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon:
                                Icon(Icons.delete, color: Colors.red.shade700),
                            onPressed: () {
                              controllers.removeAt(entry.key);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 8),
              TextField(
                controller: newItemController,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Add new item',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedItems = controllers
                  .map((c) => c.text.trim())
                  .where((text) => text.isNotEmpty)
                  .toList();
              if (newItemController.text.trim().isNotEmpty) {
                updatedItems.add(newItemController.text.trim());
              }

              try {
                await FirebaseFirestore.instance
                    .collection('diseases')
                    .doc(docId)
                    .update({fieldPath: updatedItems});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$title updated successfully'),
                    backgroundColor: Colors.green.shade700,
                  ),
                );
              } catch (e) {
                debugPrint('Error updating $title: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating $title: $e'),
                    backgroundColor: Colors.red.shade700,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
