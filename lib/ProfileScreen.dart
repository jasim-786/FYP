// ignore_for_file: use_key_in_widget_constructors, file_names, prefer_const_constructors

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Top Image Covering Full Width
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

          // Bottom Image Covering Full Width
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

          // Profile Content
          Positioned.fill(
            top: screenHeight * 0.22,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        AssetImage("assets/images/profile_placeholder.png"),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "John Doe", // Replace with dynamic user name
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "johndoe@example.com", // Replace with dynamic email
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 24),

                  // Profile Options
                  buildProfileOption(
                      icon: Icons.edit, text: "Edit Profile", onTap: () {}),
                  buildProfileOption(
                      icon: Icons.lock, text: "Change Password", onTap: () {}),
                  buildProfileOption(
                      icon: Icons.language,
                      text: "Change Language",
                      onTap: () {
                        _showLanguageDialog(context);
                      }),
                  buildProfileOption(
                      icon: Icons.logout, text: "Logout", onTap: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileOption(
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF7B5228)),
        title: Text(text, style: TextStyle(fontSize: 18)),
        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Language"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("English"),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement language change to English
                },
              ),
              ListTile(
                title: Text("Urdu"),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement language change to Urdu
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
