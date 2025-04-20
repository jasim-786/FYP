// ignore_for_file: avoid_print, file_names, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ChangePassword.dart';
import 'package:flutter_application_1/EditProfile.dart';
import 'package:flutter_application_1/HomeScreen.dart';
import 'package:flutter_application_1/Onboarding1.dart';
import 'package:flutter_application_1/PreviousResultsScreen.dart';

class PreHomeScreen extends StatelessWidget {
  const PreHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          /// Top Design (Moved outside SafeArea)
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

          /// Menu Button (Moved outside SafeArea)
          Positioned(
            top: screenHeight * 0.03,
            right: screenWidth * 0.05,
            child: GestureDetector(
              onTap: () {
                print("Menu Clicked");
              },
              child: Image.asset(
                "assets/icons/menu.png",
                height: screenHeight * 0.07,
                width: screenWidth * 0.12,
              ),
            ),
          ),

          /// SafeArea contents (everything else inside)
          SafeArea(
            child: Stack(
              children: [
                /// Feature Selection
                Positioned(
                  top: screenHeight * 0.35,
                  left: screenWidth * 0.08,
                  right: screenWidth * 0.08,
                  child: Wrap(
                    spacing: screenWidth * 0.04, // horizontal spacing
                    runSpacing: screenHeight * 0.03, // vertical spacing
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFeatureButton(
                        "Upload Image",
                        "assets/icons/home_upload.png",
                        screenHeight,
                        screenWidth,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        ),
                      ),
                      _buildFeatureButton(
                          "History",
                          "assets/icons/home_history.png",
                          screenHeight,
                          screenWidth,
                          () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PreviousResultsScreen()),
                              )),
                      _buildFeatureButton(
                          "Feedback",
                          "assets/icons/home_feedback.png",
                          screenHeight,
                          screenWidth,
                          () => print("Estimate Resources For Land")),
                      _buildFeatureButton(
                          "Help",
                          "assets/icons/home_help.png",
                          screenHeight,
                          screenWidth,
                          () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Onboarding1()),
                              )),
                      _buildFeatureButton(
                          "Edit Profile",
                          "assets/icons/home_ep.png",
                          screenHeight,
                          screenWidth,
                          () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditProfile()),
                              )),
                      _buildFeatureButton(
                          "Change Password",
                          "assets/icons/home_cp.png",
                          screenHeight,
                          screenWidth,
                          () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChangePassword()),
                              )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      /// FAB and Bottom Navigation Bar (unchanged)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 72,
        width: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF7B5228),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: RawMaterialButton(
          shape: CircleBorder(),
          onPressed: () {
            print("Scan tapped");
          },
          child: Icon(
            Icons.document_scanner,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Color(0xFF7B5228),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _bottomIcon(Icons.home, "Home", () => print("Home tapped")),
              _bottomIcon(
                  Icons.favorite, "Favorites", () => print("Favorites tapped")),
              const SizedBox(width: 40),
              _bottomIcon(
                  Icons.shopping_cart, "Cart", () => print("Cart tapped")),
              _bottomIcon(
                  Icons.person, "Profile", () => print("Profile tapped")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(
    String title,
    String imagePath,
    double screenHeight,
    double screenWidth,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: screenWidth * 0.253,
        child: Column(
          children: [
            Container(
              padding:
                  EdgeInsets.all(8), // Tiny padding to act as a slim border
              decoration: BoxDecoration(
                color: Color(0xFFE5D188),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF7B5228),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(screenWidth * 0.025),
                child: Image.asset(
                  imagePath,
                  height: screenHeight * 0.09,
                  width: screenWidth * 0.18,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.008),
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
