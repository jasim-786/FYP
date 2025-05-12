// ignore_for_file: avoid_print, file_names, prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_null_comparison

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AboutUsScreen.dart';
import 'package:flutter_application_1/ChangePassword.dart';
import 'package:flutter_application_1/CompareImagesScreen.dart';
import 'package:flutter_application_1/CropDiaryScreen.dart';
import 'package:flutter_application_1/EditProfile.dart';
import 'package:flutter_application_1/FeedbackScreen.dart';
import 'package:flutter_application_1/HomeScreen.dart';
import 'package:flutter_application_1/LoginScreen.dart';
import 'package:flutter_application_1/Onboarding1.dart';
import 'package:flutter_application_1/PreviousResultsScreen.dart';
import 'package:flutter_application_1/ProfileScreen.dart';
import 'package:flutter_application_1/TimeWidget.dart';
import 'package:flutter_application_1/TreatmentSolutionsScreen.dart';
import 'package:flutter_application_1/WeatherWidget.dart';
import 'package:flutter_application_1/WheatResourceEstimatorScreen.dart';

class PreHomeScreen extends StatelessWidget {
  const PreHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    User? user = FirebaseAuth.instance.currentUser;
    bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    String? userId = user?.uid;

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
                child: Text("Cancel"),
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

    return Scaffold(
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
                    text: "Home".tr(),
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
                    text: "Profile".tr(),
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
                    text: "History".tr(),
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
                    text: "Help".tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Onboarding1()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/feedback_icon.png",
                    text: "Feedback".tr(),
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
                    text: "About Us".tr(),
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
                          text: "Logout".tr(),
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
          /// SafeArea contents (everything else inside)
          Positioned.fill(
            top: screenHeight * 0.02,
            child: SingleChildScrollView(
              child: Container(
                height: screenHeight +
                    80, // Ensures it can scroll beyond screen height
                child: Stack(
                  children: [
                    Positioned(
                      top: screenHeight * 0.10,
                      left: screenWidth * 0.02,
                      child: SizedBox(
                        width: screenWidth * 0.5, // Wide
                        height: screenHeight * 0.2, // Short
                        child: const WeatherWidget(),
                      ),
                    ),

                    Positioned(
                      top: screenHeight * 0.185,
                      left: screenWidth * 0.55,
                      child: SizedBox(
                        width: screenWidth * 0.4, // Wide
                        height: screenHeight * 0.12, // Short
                        child: const TimeWidget(),
                      ),
                    ),

                    /// Feature Selection
                    Positioned(
                      top: screenHeight * 0.33,
                      left: screenWidth * 0.08,
                      right: screenWidth * 0.08,
                      child: Wrap(
                        spacing: screenWidth * 0.04, // horizontal spacing
                        runSpacing: screenHeight * 0.005, // vertical spacing
                        alignment: WrapAlignment.center,
                        children: [
                          _buildFeatureButton(
                            "Upload Image".tr(),
                            "assets/icons/home_upload.png",
                            screenHeight,
                            screenWidth,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()),
                            ),
                          ),
                          _buildFeatureButton(
                            "History".tr(),
                            "assets/icons/home_history.png",
                            screenHeight,
                            screenWidth,
                            () {
                              if (isLoggedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PreviousResultsScreen(),
                                  ),
                                );
                              } else {
                                _showLoginDialog(context);
                              }
                            },
                            disabled: !isLoggedIn, // controls visual only
                          ),
                          _buildFeatureButton(
                            "Feedback".tr(),
                            "assets/icons/home_feedback.png",
                            screenHeight,
                            screenWidth,
                            () {
                              if (isLoggedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FeedbackScreen(),
                                  ),
                                );
                              } else {
                                _showLoginDialog(context);
                              }
                            },
                            disabled: !isLoggedIn, // controls visual only
                          ),
                          _buildFeatureButton(
                            "Help".tr(),
                            "assets/icons/home_help.png",
                            screenHeight,
                            screenWidth,
                            () {
                              if (isLoggedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Onboarding1(),
                                  ),
                                );
                              } else {
                                _showLoginDialog(context);
                              }
                            },
                            disabled: !isLoggedIn, // controls visual only
                          ),
                          _buildFeatureButton(
                            "Edit Profile".tr(),
                            "assets/icons/home_ep.png",
                            screenHeight,
                            screenWidth,
                            () {
                              if (isLoggedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfile(),
                                  ),
                                );
                              } else {
                                _showLoginDialog(context);
                              }
                            },
                            disabled: !isLoggedIn, // controls visual only
                          ),
                          _buildFeatureButton(
                            "Change Password".tr(),
                            "assets/icons/home_cp.png",
                            screenHeight,
                            screenWidth,
                            () {
                              if (!isLoggedIn) {
                                _showLoginDialog(context);
                                return;
                              }

                              final user = FirebaseAuth.instance.currentUser;
                              bool isPasswordUser = false;

                              if (user != null) {
                                for (final info in user.providerData) {
                                  if (info.providerId == 'password') {
                                    isPasswordUser = true;
                                    break;
                                  }
                                }
                              }

                              if (isPasswordUser) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ChangePassword(),
                                  ),
                                );
                              } else {
                                _showChangePasswordRestrictionDialog(
                                    context); // Styled like your login dialog
                              }
                            },

                            disabled: !isLoggedIn, // controls visual only
                          ),
                          _buildFeatureButton(
                            "Compare".tr(),
                            "assets/icons/home_compare.png",
                            screenHeight,
                            screenWidth,
                            () {
                              if (isLoggedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CompareImagesScreen(),
                                  ),
                                );
                              } else {
                                _showLoginDialog(context);
                              }
                            },
                            disabled: !isLoggedIn, // controls visual only
                          ),
                          _buildFeatureButton(
                            "Treatments".tr(),
                            "assets/icons/home_treatment.png",
                            screenHeight,
                            screenWidth,
                            () {
                              if (isLoggedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TreatmentSolutionsScreen(),
                                  ),
                                );
                              } else {
                                _showLoginDialog(context);
                              }
                            },
                            disabled: !isLoggedIn, // controls visual only
                          ),
                          _buildFeatureButton(
                            "Wheat Diary".tr(),
                            "assets/icons/home_diary.png",
                            screenHeight,
                            screenWidth,
                            () {
                              if (isLoggedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CropDiaryScreen(userId: userId!),
                                  ),
                                );
                              } else {
                                _showLoginDialog(context);
                              }
                            },
                            disabled: !isLoggedIn, // controls visual only
                          ),
                          _buildFeatureButton(
                            "Wheat Diary".tr(),
                            "assets/icons/home_land.png",
                            screenHeight,
                            screenWidth,
                            () {
                              if (isLoggedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        WheatResourceEstimatorScreen(),
                                  ),
                                );
                              } else {
                                _showLoginDialog(context);
                              }
                            },
                            disabled: !isLoggedIn, // controls visual only
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                  if (isLoggedIn) {
                    Scaffold.of(context).openDrawer();
                  } else {
                    _showLoginDialog(context);
                  }
                },
                child: Image.asset(
                  "assets/icons/menu.png",
                  height: 62,
                  width: 62,
                ),
              ),
            ),
          ),
        ],
      ),

      /// FAB and Bottom Navigation Bar (unchanged)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 70,
        width: 70,
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
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
        color: const Color(0xFF7B5228),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _bottomIcon(
                Icons.home,
                "Home",
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PreHomeScreen()),
                ),
              ),
              _bottomIcon(
                Icons.history_sharp,
                "History",
                () {
                  if (isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PreviousResultsScreen()),
                    );
                  } else {
                    _showLoginDialog(context);
                  }
                },
                disabled: !isLoggedIn,
              ),
              const SizedBox(width: 40),
              _bottomIcon(
                Icons.help,
                "Help",
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Onboarding1()),
                ),
              ),
              _bottomIcon(
                Icons.person,
                "Profile",
                () {
                  if (isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  } else {
                    _showLoginDialog(context);
                  }
                },
                disabled: !isLoggedIn,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomIcon(IconData icon, String label, VoidCallback onTap,
      {bool disabled = false}) {
    return GestureDetector(
      onTap: onTap, // Always allow tap
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    String title,
    String imagePath,
    double screenHeight,
    double screenWidth,
    VoidCallback onTap, {
    bool disabled = false,
  }) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onTap, // Always handle tap
        child: SizedBox(
          width: screenWidth * 0.253,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5D188),
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
                    color: const Color(0xFF7B5228),
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
              SizedBox(height: screenHeight * 0.005),
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

  void _showLoginDialog(BuildContext context) {
    print("Displaying login dialog...");

    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing by tapping outside the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFE5D188),
          title: Text(
            "Login Required".tr(),
            style: TextStyle(
              color: Color(0xFF7B5228),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Please log in to access this feature.".tr(),
            style: TextStyle(color: Color(0xFF7B5228)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                "Cancel".tr(),
                style: TextStyle(color: Color(0xFF7B5228)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text(
                "Login".tr(),
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        );
      },
    );
  }

  void _showChangePasswordRestrictionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFE5D188),
          title: Text(
            "Access Denied".tr(),
            style: const TextStyle(
              color: Color(0xFF7B5228),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "You cannot change your password because you signed in using Google or Phone."
                .tr(),
            style: const TextStyle(color: Color(0xFF7B5228)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "OK".tr(),
                style: const TextStyle(color: Color(0xFF7B5228)),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        );
      },
    );
  }
}
