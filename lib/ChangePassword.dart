// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

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
            child: const Text('OK'),
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
      _showDialog("Missing Fields", "Please fill out all fields.",
          isError: true);
      return;
    }

    if (newPass != confirmPass) {
      _showDialog("Mismatch", "New passwords do not match.", isError: true);
      return;
    }

    if (!_isPasswordStrong(newPass)) {
      _showDialog("Weak Password",
          "Password must be at least 8 characters long, include an uppercase letter and a number.",
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

      _showDialog("Success", "Your password has been changed.");
      Navigator.pop(context); // back to profile
    } catch (e) {
      _showDialog("Error", e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Top background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/Top.png",
              fit: BoxFit.cover,
              height: h * 0.25,
              width: w,
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
              height: h * 0.2,
              width: w,
            ),
          ),
          Positioned(
            top: 35, // Adjust vertically
            left: 12, // Adjust horizontally
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                "assets/icons/Back_arrow.png",
                height: 40,
                width: 40,
              ),
            ),
          ),

          // Main content inside SafeArea
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    top: h * 0.18, left: w * 0.05, right: w * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Change Password",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Enter your current and new password",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      icon: Icons.lock_outline,
                      hintText: "Old Password",
                      controller: _oldPassController,
                      obscureText: _obscureOld,
                      toggle: () => setState(() => _obscureOld = !_obscureOld),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      icon: Icons.lock,
                      hintText: "New Password",
                      controller: _newPassController,
                      obscureText: _obscureNew,
                      toggle: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      icon: Icons.lock,
                      hintText: "Confirm Password",
                      controller: _confirmPassController,
                      obscureText: _obscureConfirm,
                      toggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: w * 0.6,
                      height: h * 0.06,
                      child: ElevatedButton(
                        onPressed: _changePassword,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF7B5228),
                        ),
                        child: const Text(
                          "Change",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
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
}
