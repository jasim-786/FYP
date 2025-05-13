import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AboutUsScreen.dart';
import 'package:flutter_application_1/FeedbackScreen.dart';
import 'package:flutter_application_1/LoginScreen.dart';
import 'package:flutter_application_1/Onboarding1.dart';
import 'package:flutter_application_1/PreHomeScreen.dart';
import 'package:flutter_application_1/PreviousResultsScreen.dart';
import 'package:flutter_application_1/ProfileScreen.dart';

class WheatResourceEstimatorScreen extends StatefulWidget {
  @override
  _WheatResourceEstimatorScreenState createState() =>
      _WheatResourceEstimatorScreenState();
}

class _WheatResourceEstimatorScreenState
    extends State<WheatResourceEstimatorScreen> {
  final TextEditingController _landController = TextEditingController();
  String _selectedUnit = 'Acre'.tr();
  String _detectedDisease = '';

  double? seedKg, dapBags, ureaBags, waterLiters, medicineLiters;
  double? totalSeedCost,
      totalDapCost,
      totalUreaCost,
      totalWaterCost,
      totalMedicineCost;

  final Map<String, double> unitToAcre = {
    'Acre'.tr(): 1.0,
    'Kanal'.tr(): 0.125,
    'Marla'.tr(): 0.00625,
  };

  final double seedPricePerKg = 150;
  final double dapPricePerBag = 3500;
  final double ureaPricePerBag = 2500;
  final double waterPricePerLitre = 0.10;
  final double brownRustPricePerLitre = 1500;
  final double yellowRustPricePerLitre = 1600;

  final Color primaryColor = Color(0xFF7B5228);
  final Color accentColor = Color(0xFFE5D188);

  void _calculateResources() {
    final double? inputAmount = double.tryParse(_landController.text);
    if (inputAmount != null && inputAmount > 0) {
      double acres = inputAmount * unitToAcre[_selectedUnit]!;
      setState(() {
        seedKg = acres * 50;
        dapBags = acres * 1.25;
        ureaBags = acres * 1.5;
        waterLiters = acres * 6000;

        totalSeedCost = seedKg! * seedPricePerKg;
        totalDapCost = dapBags! * dapPricePerBag;
        totalUreaCost = ureaBags! * ureaPricePerBag;
        totalWaterCost = waterLiters! * waterPricePerLitre;

        if (_detectedDisease == 'Brown Rust'.tr()) {
          medicineLiters = acres * 1.5;
          totalMedicineCost = medicineLiters! * brownRustPricePerLitre;
        } else if (_detectedDisease == 'Yellow Rust'.tr()) {
          medicineLiters = acres * 2.0;
          totalMedicineCost = medicineLiters! * yellowRustPricePerLitre;
        } else {
          medicineLiters = null;
          totalMedicineCost = null;
        }
      });
    }
  }

  User? user = FirebaseAuth.instance.currentUser;
  void logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout".tr()),
          content: Text("Are you sure you want to log out?".tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text("Cancel".tr()),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog

                await FirebaseAuth.instance.signOut();

                // Show logout success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Logged out successfully".tr()),
                    duration: Duration(seconds: 2),
                  ),
                );

                // Navigate back to login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text("Logout".tr(), style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(Icons.analytics, color: primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildDiseaseSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Detected Disease (if any)'.tr()),
        ...['Brown Rust'.tr(), 'Yellow Rust'.tr(), 'No Disease'.tr()]
            .map((disease) {
          return RadioListTile<String>(
            title: Text(disease),
            value: disease == 'No Disease'.tr() ? '' : disease,
            groupValue: _detectedDisease,
            activeColor: primaryColor,
            onChanged: (value) {
              setState(() {
                _detectedDisease = value!;
              });
            },
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  Column(
                    children: [
                      if (user != null)
                        buildSidebarButton(
                          customIconPath: "assets/icons/logout_icon.png",
                          text: 'Logout'.tr(),
                          onTap: () {
                            logout();
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
      backgroundColor: Colors.white,
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
          Positioned(
            top: 25,
            right: 5,
            child: Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Image.asset(
                  "assets/icons/menu.png",
                  height: 62,
                  width: 62,
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: screenHeight * 0.18,
            bottom: screenHeight * 0.18,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 0, left: 0),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Text(
                          'Wheat Resource\nEstimator'.tr(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B5228),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _landController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Land Area'.tr(),
                            filled: true,
                            fillColor: accentColor.withOpacity(0.4),
                            prefixIcon:
                                Icon(Icons.terrain, color: primaryColor),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedUnit,
                          underline: SizedBox(),
                          items: ['Acre'.tr(), 'Kanal'.tr(), 'Marla'.tr()]
                              .map((unit) => DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedUnit = value!),
                          dropdownColor: Colors.white,
                          style: TextStyle(color: primaryColor),
                          iconEnabledColor: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDiseaseSelection(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _calculateResources,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 6,
                      shadowColor: Colors.black45,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Text(
                        'Calculate Resources'.tr(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (seedKg != null) ...[
                    _buildSectionTitle('Estimation Results'.tr()),
                    _buildResultRow('Wheat Seed Required'.tr(),
                        '${seedKg!.toStringAsFixed(1)} kg', Icons.grass),
                    _buildResultRow(
                        'DAP Fertilizer'.tr(),
                        '${dapBags!.toStringAsFixed(2)} bags',
                        Icons.local_florist),
                    _buildResultRow('Urea Fertilizer'.tr(),
                        '${ureaBags!.toStringAsFixed(2)} bags', Icons.eco),
                    _buildResultRow(
                        'Water per Irrigation'.tr(),
                        '${waterLiters!.toStringAsFixed(0)} liters',
                        Icons.water_drop),
                    if (medicineLiters != null)
                      _buildResultRow(
                          'Medicine Required'.tr(),
                          '${medicineLiters!.toStringAsFixed(1)} liters',
                          Icons.medication),
                    Divider(height: 32, color: primaryColor, thickness: 1),
                    _buildSectionTitle('Cost Estimations'.tr()),
                    _buildResultRow(
                        'Total Seed Cost'.tr(),
                        'PKR ${totalSeedCost!.toStringAsFixed(0)}',
                        Icons.monetization_on),
                    _buildResultRow(
                        'Total DAP Cost'.tr(),
                        'PKR ${totalDapCost!.toStringAsFixed(0)}',
                        Icons.monetization_on),
                    _buildResultRow(
                        'Total Urea Cost'.tr(),
                        'PKR ${totalUreaCost!.toStringAsFixed(0)}',
                        Icons.monetization_on),
                    _buildResultRow(
                        'Total Water Cost'.tr(),
                        'PKR ${totalWaterCost!.toStringAsFixed(0)}',
                        Icons.monetization_on),
                    if (totalMedicineCost != null)
                      _buildResultRow(
                          'Total Medicine Cost'.tr(),
                          'PKR ${totalMedicineCost!.toStringAsFixed(0)}',
                          Icons.monetization_on),
                  ],
                  const SizedBox(height: 40),
                ],
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
        ],
      ),
    );
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
}
