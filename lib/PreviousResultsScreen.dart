// ignore_for_file: use_super_parameters, use_build_context_synchronously, file_names
//adding refresh and sorting

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AboutUsScreen.dart';
import 'package:flutter_application_1/HomeScreen.dart';
import 'package:flutter_application_1/LoginScreen.dart';
import 'package:flutter_application_1/Onboarding1.dart';
import 'package:fl_chart/fl_chart.dart';

class PreviousResultsScreen extends StatefulWidget {
  const PreviousResultsScreen({Key? key}) : super(key: key);

  @override
  State<PreviousResultsScreen> createState() => _PreviousResultsScreenState();
}

class _PreviousResultsScreenState extends State<PreviousResultsScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  DateTime? _startDate;
  DateTime? _endDate;
  String _sortOrder = 'Latest';
  List<Map<String, dynamic>> _historyData = [];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    void logout(BuildContext context) async {
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

    Future<void> _refresh() async {
      setState(() {}); // Trigger rebuild
    }

    String _getDayOfWeek(DateTime date) {
      // Get the name of the day (e.g., 'Monday', 'Tuesday', etc.)
      List<String> days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      return days[date.weekday %
          7]; // Date.weekday returns 1 = Monday, 2 = Tuesday, ..., 7 = Sunday
    }

    List<FlSpot> _generateBrownRustSpots() {
      Map<String, int> brownRustCounts =
          {}; // To store counts of Brown Rust per day

      // Loop through the history data
      for (var item in _historyData) {
        DateTime date = item['date'];
        String? prediction = item['prediction'];

        if (prediction == null) continue; // Skip if prediction is null

        // Get the day of the week (Monday = 0, Sunday = 6)
        String dayOfWeek = _getDayOfWeek(date);

        // Increment the count for each prediction type on that day
        if (prediction == 'Brown_Rust') {
          brownRustCounts[dayOfWeek] = (brownRustCounts[dayOfWeek] ?? 0) + 1;
        }
      }

      // Days of the week to display (starting from Sunday to Saturday)
      List<String> daysOfWeek = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];

      // Generate spots for the graph (for Brown Rust)
      List<FlSpot> brownRustSpots = [];
      for (int i = 0; i < daysOfWeek.length; i++) {
        String day = daysOfWeek[i];
        int brownRustCount = brownRustCounts[day] ?? 0;

        // Add spots for Brown Rust
        brownRustSpots.add(FlSpot(
            i.toDouble(), brownRustCount.toDouble())); // Brown Rust count
      }

      return brownRustSpots;
    }

    List<FlSpot> _generateYellowRustSpots() {
      Map<String, int> yellowRustCounts =
          {}; // To store counts of Yellow Rust per day

      // Loop through the history data
      for (var item in _historyData) {
        DateTime date = item['date'];
        String? prediction = item['prediction'];

        if (prediction == null) continue; // Skip if prediction is null

        // Get the day of the week (Monday = 0, Sunday = 6)
        String dayOfWeek = _getDayOfWeek(date);

        // Increment the count for each prediction type on that day
        if (prediction == 'Yellow_Rust') {
          yellowRustCounts[dayOfWeek] = (yellowRustCounts[dayOfWeek] ?? 0) + 1;
        }
      }

      // Days of the week to display (starting from Sunday to Saturday)
      List<String> daysOfWeek = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];

      // Generate spots for the graph (for Yellow Rust)
      List<FlSpot> yellowRustSpots = [];
      for (int i = 0; i < daysOfWeek.length; i++) {
        String day = daysOfWeek[i];
        int yellowRustCount = yellowRustCounts[day] ?? 0;

        // Add spots for Yellow Rust
        yellowRustSpots.add(FlSpot(i.toDouble() + 0.5,
            yellowRustCount.toDouble())); // Yellow Rust count (slightly offset)
      }

      return yellowRustSpots;
    }

    Stream<QuerySnapshot> _filteredResults() {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('disease_detections')
          .where('userId', isEqualTo: user?.uid)
          .orderBy('timestamp', descending: _sortOrder == 'Latest');

      if (_startDate != null) {
        query = query.where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!));
      }

      if (_endDate != null) {
        query = query.where('timestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(_endDate!));
      }

      return query.snapshots();
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
                    text: 'Home'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/profile_icon.png",
                    text: 'Profile'.tr(),
                    onTap: () {
                      // Handle Profile Navigation
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/profile_icon.png",
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
                            logout(context);
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
          // Foreground content
          Positioned.fill(
            top: screenHeight * 0.05,
            bottom: screenHeight * 0.18,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 65, left: 0),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Text(
                          'Previous Results'.tr(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B5228),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Expanded List + Refresh
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                      ),
                      child: RefreshIndicator(
                        onRefresh: _refresh,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _filteredResults(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text('No results found.'),
                              );
                            }
                            // Prepare chart data
                            _historyData = snapshot.data!.docs.map((doc) {
                              final timestamp = doc['timestamp'] as Timestamp;
                              final date = timestamp.toDate();
                              final prediction = doc[
                                  'prediction']; // <-- Fetch prediction too!

                              return {
                                'date':
                                    DateTime(date.year, date.month, date.day),
                                'prediction':
                                    prediction, // <-- Store prediction in map
                              };
                            }).toList();

                            return Column(
                              children: [
                                // History chart
                                if (_historyData.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: SizedBox(
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.25, // Adjust the height based on screen size (30% of the screen height)
                                      width: double
                                          .infinity, // Set the width to occupy the available space
                                      child: LineChart(
                                        LineChartData(
                                          gridData: FlGridData(
                                              show: false), // Hide grid lines
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles:
                                                      false), // Hide left axis labels (y-axis)
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  List<String> days = [
                                                    'Mon',
                                                    'Tue',
                                                    'Wed',
                                                    'Thu',
                                                    'Fri',
                                                    'Sat',
                                                    'Sun'
                                                  ];
                                                  if (value >= 0 &&
                                                      value <= 6 &&
                                                      value == value.toInt()) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8),
                                                      child: Text(
                                                        days[value.toInt()],
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return const SizedBox
                                                      .shrink(); // Empty for others
                                                },
                                              ),
                                            ),
                                          ),
                                          borderData: FlBorderData(
                                              show: false), // Hide the border
                                          lineBarsData: [
                                            // Brown Rust Line
                                            LineChartBarData(
                                              spots:
                                                  _generateBrownRustSpots(), // Brown Rust spots
                                              isCurved: true,
                                              color: Color(
                                                  0xFF7B5228), // Brown color for Brown Rust
                                              barWidth: 3,
                                              belowBarData:
                                                  BarAreaData(show: false),
                                            ),
                                            // Yellow Rust Line
                                            LineChartBarData(
                                              spots:
                                                  _generateYellowRustSpots(), // Yellow Rust spots
                                              isCurved: true,
                                              color: Color(
                                                  0xFFFFD700), // Yellow color for Yellow Rust
                                              barWidth: 3,
                                              belowBarData:
                                                  BarAreaData(show: false),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                Container(
                                  margin: EdgeInsets.only(top: 0, right: 16),
                                  child: DropdownButton<String>(
                                    value: _sortOrder,
                                    dropdownColor: Color(
                                        0xFFE5D188), // Light yellow background inside dropdown
                                    style: TextStyle(
                                      // Text color inside dropdown
                                      color:
                                          Color(0xFF7B5228), // Brown text color
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    iconEnabledColor: Color(
                                        0xFF7B5228), // Brown color for dropdown arrow
                                    items: ['Latest', 'Oldest']
                                        .map((value) => DropdownMenuItem(
                                              value: value,
                                              child: Text(value),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _sortOrder = value!;
                                      });
                                    },
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () async {
                                          DateTime? picked =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2100),
                                          );
                                          if (picked != null) {
                                            setState(() {
                                              _startDate = picked;
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF7B5228),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.calendar_today,
                                                  size: 20,
                                                  color: Colors.white),
                                              SizedBox(width: 8),
                                              Text(
                                                _startDate == null
                                                    ? 'Start Date'
                                                    : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () async {
                                          DateTime? picked =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2100),
                                          );
                                          if (picked != null) {
                                            setState(() {
                                              _endDate = picked.add(Duration(
                                                hours: 23,
                                                minutes: 59,
                                                seconds: 59,
                                              ));
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFE5D188),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.calendar_today,
                                                  size: 20,
                                                  color: Color(0xFF7B5228)),
                                              SizedBox(width: 8),
                                              Text(
                                                _endDate == null
                                                    ? 'End Date'
                                                    : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                                                style: TextStyle(
                                                  color: Color(0xFF7B5228),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Scrollable list
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: snapshot.data!.docs.length,
                                    padding: EdgeInsets.only(bottom: 15),
                                    itemBuilder: (context, index) {
                                      final doc = snapshot.data!.docs[index];
                                      final String disease = doc['prediction'];
                                      final String base64Image =
                                          doc['image_base64'];
                                      final Timestamp timestamp =
                                          doc['timestamp'];
                                      final DateTime dateTime =
                                          timestamp.toDate();

                                      return Card(
                                        elevation: 10,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          side: BorderSide(
                                              color: Color(0xFF7B5228),
                                              width: 1.5),
                                        ),
                                        margin:
                                            EdgeInsets.symmetric(vertical: 10),
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.memory(
                                                  base64Decode(base64Image),
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              SizedBox(width: 15),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Prediction: $disease",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                        color:
                                                            Color(0xFF7B5228),
                                                      ),
                                                    ),
                                                    SizedBox(height: 6),
                                                    Text(
                                                      "Date: ${dateTime.day}/${dateTime.month}/${dateTime.year}  "
                                                      "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.grey[800],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
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

          // Custom back button at top left
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
