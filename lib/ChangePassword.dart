// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, file_names, prefer_final_fields

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/AboutUsScreen.dart';
import 'package:flutter_application_1/LoginScreen.dart';
import 'package:flutter_application_1/Onboarding1.dart';
import 'package:flutter_application_1/PreHomeScreen.dart';
import 'package:flutter_application_1/PreviousResultsScreen.dart';
import 'package:flutter_application_1/ProfileScreen.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Key for scaffold

  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? user = FirebaseAuth.instance.currentUser;
  void logout() async {
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
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _showDialog(String title, String content, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title,
            style: TextStyle(color: isError ? Colors.red : Colors.green)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'.tr()),
          )
        ],
      ),
    );
  }

  bool _isPasswordStrong(String password) {
    final strongRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
    return strongRegex.hasMatch(password);
  }

  Future<void> _changePassword() async {
    final oldPass = _oldPassController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showDialog('Missing Fields'.tr(), 'Please fill out all fields.'.tr(),
          isError: true);
      return;
    }

    if (newPass != confirmPass) {
      _showDialog("Mismatch", "New passwords do not match.", isError: true);
      return;
    }

    if (!_isPasswordStrong(newPass)) {
      _showDialog(
          'Weak Password'.tr(),
          'Password must be at least 8 characters long, include an uppercase letter and a number.'
              .tr(),
          isError: true);
      return;
    }

    try {
      final user = _auth.currentUser;
      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: oldPass,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPass);

      _showDialog('Success'.tr(), 'Your password has been changed.'.tr());
      Navigator.pop(context); // back to profile
    } catch (e) {
      _showDialog("Error", e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
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
                      // Handle Profile Navigation
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
      body: Stack(
        children: [
          // Top background
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

          // Bottom background
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

          // Main content inside SafeArea
          Positioned.fill(
            top: screenHeight * 0.20,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Change Password'.tr(),
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter your current and new password'.tr(),
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    icon: Icons.lock_outline,
                    hintText: 'Old Password'.tr(),
                    controller: _oldPassController,
                    obscureText: _obscureOld,
                    toggle: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    icon: Icons.lock,
                    hintText: 'New Password'.tr(),
                    controller: _newPassController,
                    obscureText: _obscureNew,
                    toggle: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    icon: Icons.lock,
                    hintText: 'Confirm Password'.tr(),
                    controller: _confirmPassController,
                    obscureText: _obscureConfirm,
                    toggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: screenWidth * 0.6,
                    height: screenHeight * 0.06,
                    child: ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF7B5228),
                      ),
                      child: Text(
                        'Change'.tr(),
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
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

  Widget _buildTextField({
    required IconData icon,
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF7B5228), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF7B5228),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                hintText: hintText,
                hintStyle: const TextStyle(fontSize: 16),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: toggle,
              child: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF7B5228),
              ),
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
