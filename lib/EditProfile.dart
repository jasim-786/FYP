// ignore_for_file: file_names, avoid_print, use_build_context_synchronously, prefer_final_fields

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/AboutUsScreen.dart';
import 'package:flutter_application_1/ChangePassword.dart';
import 'package:flutter_application_1/HomeScreen.dart';
import 'package:flutter_application_1/LoginScreen.dart';
import 'package:flutter_application_1/Onboarding1.dart';
import 'package:flutter_application_1/PreviousResultsScreen.dart';
import 'package:flutter_application_1/ProfileScreen.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController =
      TextEditingController(); // You might not need this in production

  // Add this to _EditProfileState
  bool _isNameEditable = false;
  bool _isEmailEditable = false;
  bool _isPhoneEditable = false;

  GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Key for scaffold

  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users_details')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _fullnameController.text = data['Full_name'] ?? '';
            _emailController.text = data['Email'] ?? '';
            _phoneController.text = data['Phone Number'] ?? '';
            _passwordController.text = '**************';
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                    text: "Home",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/profile_icon.png",
                    text: "Profile",
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
                    text: "History",
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
                    text: "Help",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Onboarding1()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/feedback_icon.png",
                    text: "Feedback",
                    onTap: () {
                      // Handle Profile Navigation
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/info_icon.png",
                    text: "About Us",
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
                          text: "Logout",
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
          Positioned.fill(
            top: screenHeight * 0.16,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: const Offset(-30, -40),
                        child: Image.asset(
                          "assets/icons/edit_icon.png",
                          height: screenHeight * 0.14,
                          width: screenHeight * 0.14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Transform.translate(
                        offset: const Offset(-40, -10),
                        child: Text(
                          'Edit\nProfile'.tr(),
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF7B5228),
                            width: 2.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 8),
                            _buildTextField(
                              Icons.person,
                              'Fullname'.tr(),
                              _fullnameController,
                              isEditable: _isNameEditable,
                              onEdit: () {
                                setState(() {
                                  _isNameEditable = !_isNameEditable;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              Icons.email,
                              'Email Address'.tr(),
                              _emailController,
                              isEditable: _isEmailEditable,
                              onEdit: () {
                                setState(() {
                                  _isEmailEditable = !_isEmailEditable;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              Icons.phone,
                              'Phone Number'.tr(),
                              _phoneController,
                              isEditable: _isPhoneEditable,
                              onEdit: () {
                                setState(() {
                                  _isPhoneEditable = !_isPhoneEditable;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              Icons.lock,
                              '**************'.tr(),
                              _passwordController,
                              isPassword: true,
                              isEditable:
                                  false, // password shouldn't be editable here
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ChangePassword()),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: -80,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SizedBox(
                            width: screenWidth * 0.5,
                            height: screenHeight * 0.06,
                            child: ElevatedButton(
                              onPressed: () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  await FirebaseFirestore.instance
                                      .collection('user_details')
                                      .doc(user.uid)
                                      .update({
                                    'Full_name': _fullnameController.text,
                                    'Email': _emailController.text,
                                    'Phone Number': _phoneController.text,
                                    // Password change not allowed here for security
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Profile updated successfully')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF7B5228),
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hintText,
    TextEditingController controller, {
    bool isPassword = false,
    bool isEditable = false,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFF7B5228),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              readOnly: !isEditable,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: hintText == 'Phone Number'
                  ? TextInputType.phone
                  : TextInputType.text,
              decoration: InputDecoration(
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF7B5228),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                hintText: hintText,
                hintStyle: const TextStyle(fontSize: 16),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.edit,
                color: Color(0xFF7B5228),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
