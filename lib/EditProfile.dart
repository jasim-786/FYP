// ignore_for_file: file_names, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isPasswordEditable = false;

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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
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
            top: screenHeight * 0.04,
            right: screenWidth * 0.05,
            child: GestureDetector(
              onTap: () {
                print("Menu Clicked");
              },
              child: Image.asset(
                "assets/icons/menu.png",
                height: 60,
                width: 40,
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
          Positioned.fill(
            top: screenHeight * 0.18,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: const Offset(-20, -40),
                        child: Image.asset(
                          "assets/icons/edit_icon.png",
                          height: screenHeight * 0.14,
                          width: screenHeight * 0.14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Transform.translate(
                        offset: const Offset(-20, -10),
                        child: Text(
                          'Edit\nProfile',
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
                        padding: const EdgeInsets.all(10),
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
                            const SizedBox(height: 10),
                            _buildTextField(
                              Icons.person,
                              'Fullname',
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
                              'Email Address',
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
                              'Phone Number',
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
                              '**************',
                              _passwordController,
                              isPassword: true,
                              isEditable: _isPasswordEditable,
                              onEdit: () {
                                setState(() {
                                  _isPasswordEditable = !_isPasswordEditable;
                                });
                              },
                            ),
                            const SizedBox(height: 40),
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
                  const SizedBox(height: 20),
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
