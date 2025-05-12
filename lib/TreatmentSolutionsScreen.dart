import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/FeedbackScreen.dart';
import 'package:flutter_application_1/PreHomeScreen.dart';
import 'package:flutter_application_1/PreviousResultsScreen.dart';
import 'package:flutter_application_1/ProfileScreen.dart';
import 'package:flutter_application_1/Onboarding1.dart';
import 'package:flutter_application_1/AboutUsScreen.dart';
import 'package:flutter_application_1/LoginScreen.dart';

class TreatmentSolutionsScreen extends StatefulWidget {
  final String? detectedDisease;

  const TreatmentSolutionsScreen({super.key, this.detectedDisease});

  @override
  State<TreatmentSolutionsScreen> createState() =>
      _TreatmentSolutionsScreenState();
}

class _TreatmentSolutionsScreenState extends State<TreatmentSolutionsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? _diseaseData;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDiseaseData();
    if (widget.detectedDisease != null && widget.detectedDisease!.isNotEmpty) {
      _searchQuery = widget.detectedDisease!;
    }
  }

  Future<void> _loadDiseaseData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/solutions.json');
      final data = json.decode(jsonString);

      setState(() {
        _diseaseData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading disease data: $e'.tr());
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      drawer: Drawer(
        child: Container(
          color: Color(0xFFE5D188),
          child: Stack(
            children: [
              Column(
                children: [
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
                  SizedBox(height: 20),
                  buildSidebarButton(
                    customIconPath: "assets/icons/Home_icon.png",
                    text: 'Home'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PreHomeScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/profile_icon.png",
                    text: 'Profile'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/history_icon.png",
                    text: 'History'.tr(),
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
                    text: 'Help'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Onboarding1()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/feedback_icon.png",
                    text: 'Feedback'.tr(),
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
                    text: 'About Us'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AboutUsScreen()),
                      );
                    },
                  ),
                  if (user != null)
                    buildSidebarButton(
                      customIconPath: "assets/icons/logout_icon.png",
                      text: 'Logout'.tr(),
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                    ),
                ],
              ),
              Positioned(
                top: screenHeight * 0.1,
                left: 0,
                right: 140,
                child: Center(
                  child: Image.asset(
                    "assets/images/logo.png",
                    height: 140,
                    width: 140,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss the keyboard when tapping outside the TextField
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Positioned.fill(
              top: screenHeight * 0.15,
              bottom: screenHeight * 0.16,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Wheatopedia'.tr(),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B5228),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF4F4F6),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Color(0xFF7B5228),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.search,
                                            color: Color(0xFF7B5228)),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: TextField(
                                            controller: TextEditingController(
                                                text: _searchQuery),
                                            decoration:
                                                InputDecoration.collapsed(
                                              hintText: 'Search Disease'.tr(),
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                _searchQuery = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _isLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF7B5228)),
                                    ),
                                  )
                                : _diseaseData == null
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              size: 64,
                                              color: Color(0xFF7B5228)
                                                  .withOpacity(0.8),
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'Error loading disease data'.tr(),
                                              style: TextStyle(
                                                color: Color(0xFF7B5228),
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            ElevatedButton(
                                              onPressed: _loadDiseaseData,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: Text('Retry'.tr()),
                                            ),
                                          ],
                                        ),
                                      )
                                    : _diseaseData!.keys
                                            .where((disease) => disease
                                                .toLowerCase()
                                                .contains(
                                                    _searchQuery.toLowerCase()))
                                            .isEmpty
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.search_off,
                                                  size: 64,
                                                  color: Colors.grey.shade400,
                                                ),
                                                SizedBox(height: 16),
                                                Text(
                                                  'No diseases found'.tr(),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Try a different search term'
                                                      .tr(),
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            itemCount: _diseaseData!.keys
                                                .where((disease) => disease
                                                    .toLowerCase()
                                                    .contains(_searchQuery
                                                        .toLowerCase()))
                                                .length,
                                            itemBuilder: (context, index) {
                                              final disease = _diseaseData!.keys
                                                  .where((disease) => disease
                                                      .toLowerCase()
                                                      .contains(_searchQuery
                                                          .toLowerCase()))
                                                  .elementAt(index);
                                              return _buildEnhancedDiseaseCard(
                                                  disease,
                                                  _diseaseData![disease]);
                                            },
                                          ),
                            SizedBox(height: screenHeight * 0.2),
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
              top: 25,
              right: 5,
              child: Builder(
                builder: (context) => GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState?.openDrawer();
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
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedDiseaseCard(
      String diseaseName, Map<String, dynamic> diseaseInfo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF7B5228),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_hospital,
                  size: 30,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diseaseName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B5228),
                      ),
                    ),
                    if (diseaseInfo['scientificName'.tr()] != null)
                      Text(
                        diseaseInfo['scientificName'.tr()],
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildInfoSection(
            'Symptoms'.tr(),
            diseaseInfo['symptoms'.tr()] ?? "No data available".tr(),
            Icons.medical_services,
            Color(0xFFD32F2F),
          ),
          if (diseaseInfo['environmentalConditions'.tr()] != null)
            Column(
              children: [
                SizedBox(height: 20),
                _buildInfoSection(
                  'Environmental Conditions'.tr(),
                  diseaseInfo['environmentalConditions'.tr()],
                  Icons.wb_sunny,
                  Color(0xFFFFA000),
                ),
              ],
            ),
          if (diseaseInfo['vulnerableStages'.tr()] != null)
            Column(
              children: [
                SizedBox(height: 20),
                _buildInfoSection(
                  'Vulnerable Stages'.tr(),
                  diseaseInfo['vulnerableStages'],
                  Icons.trending_up,
                  Color(0xFF1976D2),
                ),
              ],
            ),
          SizedBox(height: 20),
          _buildExpandableSection(
            title: 'Treatments'.tr(),
            icon: Icons.local_hospital,
            iconColor: Color(0xFFD32F2F),
            initiallyExpanded: true,
            children: [
              if (diseaseInfo['treatments'.tr()] is List)
                ...List<String>.from(diseaseInfo['treatments'.tr()])
                    .map<Widget>((treatment) => _buildTreatmentItem(treatment))
                    .toList()
              else if (diseaseInfo['treatments'.tr()] is Map)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (diseaseInfo['treatments'.tr()]['chemical'.tr()] != null)
                      _buildExpandableSection(
                        title: 'Chemical'.tr(),
                        icon: Icons.science,
                        iconColor: Colors.red.shade400,
                        initiallyExpanded: true,
                        children: List<String>.from(
                                diseaseInfo['treatments'.tr()]['chemical'.tr()])
                            .map<Widget>((treatment) => _buildTreatmentItem(
                                treatment,
                                Colors.red.shade50,
                                Colors.red.shade100))
                            .toList(),
                      ),
                    if (diseaseInfo['treatments'.tr()]['biological'.tr()] !=
                        null)
                      _buildExpandableSection(
                        title: 'Biological'.tr(),
                        icon: Icons.eco,
                        iconColor: Colors.blue.shade400,
                        initiallyExpanded: false,
                        children: List<String>.from(
                                diseaseInfo['treatments'.tr()]
                                    ['biological'.tr()])
                            .map<Widget>((treatment) => _buildTreatmentItem(
                                treatment,
                                Colors.blue.shade50,
                                Colors.blue.shade100))
                            .toList(),
                      ),
                    if (diseaseInfo['treatments'.tr()]['cultural'.tr()] != null)
                      _buildExpandableSection(
                        title: 'Cultural'.tr(),
                        icon: Icons.agriculture,
                        iconColor: Colors.green.shade400,
                        initiallyExpanded: false,
                        children: List<String>.from(
                                diseaseInfo['treatments'.tr()]['cultural'.tr()])
                            .map<Widget>((treatment) => _buildTreatmentItem(
                                treatment,
                                Colors.green.shade50,
                                Colors.green.shade100))
                            .toList(),
                      ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 20),
          _buildExpandableSection(
            title: 'Prevention'.tr(),
            icon: Icons.shield,
            iconColor: Colors.blue.shade700,
            initiallyExpanded: false,
            children: diseaseInfo['prevention'.tr()] is List
                ? List<String>.from(diseaseInfo['prevention'.tr()])
                    .map<Widget>((item) => _buildTreatmentItem(
                        item, Colors.blue.shade50, Colors.blue.shade100))
                    .toList()
                : [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Text(
                        diseaseInfo['prevention'.tr()] ??
                            "No data available".tr(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
          ),
          if (diseaseInfo['traditionalPractices'.tr()] != null)
            Column(
              children: [
                SizedBox(height: 20),
                _buildExpandableSection(
                  title: 'Traditional Practices'.tr(),
                  icon: Icons.history_edu,
                  iconColor: Colors.brown.shade400,
                  initiallyExpanded: false,
                  children: diseaseInfo['traditionalPractices'] is List
                      ? List<String>.from(diseaseInfo['traditionalPractices'])
                          .map<Widget>((item) => _buildTreatmentItem(item,
                              Colors.brown.shade50, Colors.brown.shade100))
                          .toList()
                      : [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.brown.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.brown.shade100),
                            ),
                            child: Text(
                              diseaseInfo['traditionalPractices'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                ),
              ],
            ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    String content,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B5228),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return ExpansionTile(
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          SizedBox(width: 8),
          Expanded(
            // Wrap the text to prevent overflow
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B5228),
              ),
            ),
          ),
        ],
      ),
      initiallyExpanded: initiallyExpanded,
      childrenPadding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildTreatmentItem(String treatment,
      [Color? bgColor, Color? borderColor]) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? Colors.green.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              treatment,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
                height: 1.4,
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
