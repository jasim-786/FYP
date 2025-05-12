// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, file_names, prefer_final_fields, sort_child_properties_last, non_constant_identifier_names, avoid_print, prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Onboarding1.dart';

class UserDetailScreen extends StatefulWidget {
  final String? phoneNumber;
  final bool isGoogleLogin;

  const UserDetailScreen({
    super.key,
    this.phoneNumber,
    required this.isGoogleLogin,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _name = TextEditingController();
  TextEditingController _phone = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    User? user = FirebaseAuth.instance.currentUser;
    if (widget.isGoogleLogin && user != null) {
      _name.text = user.displayName ?? ''; // Pre-fill name from Google
    } else if (!widget.isGoogleLogin && widget.phoneNumber != null) {
      _phone.text =
          widget.phoneNumber!; // Pre-fill phone number from phone login
    }
  }

  Future<void> _saveUserDetails(String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('users_details')
          .doc(uid)
          .set({
        'userId': uid,
        'Full_name': _name.text.trim(),
        'Phone Number':
            widget.isGoogleLogin ? _phone.text.trim() : widget.phoneNumber,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Details saved successfully!'.tr())),
      );

      _name.clear();
      _phone.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Onboarding1()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
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
              top: screenHeight * 0.145,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -30,
                          right: 100,
                          child: Image.asset(
                            "assets/icons/user_info.png",
                            height: screenHeight * 0.15,
                            width: screenHeight * 0.15,
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(8, 30),
                          child: Text(
                            'Complete\nProfile'.tr(),
                            style: TextStyle(
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          height: widget.isGoogleLogin
                              ? screenHeight * 0.26
                              : screenHeight * 0.32,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Color(0xFF7B5228),
                                width: 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 20),
                                  Form(
                                    key: _key,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: _name,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[a-zA-Z\s]')),
                                          ],
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.person),
                                            hintText: 'Enter Full Name'.tr(),
                                            filled: true,
                                            fillColor: Colors.transparent,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Color(0xFF7B5228),
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Color(0xFF7B5228),
                                                width: 2,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Full name cannot be empty';
                                            } else if (!RegExp(r'^[a-zA-Z\s]+$')
                                                .hasMatch(value.trim())) {
                                              return 'Only alphabets are allowed';
                                            }
                                            return null;
                                          },
                                        ),
                                        if (widget.isGoogleLogin) ...[
                                          SizedBox(height: 20),
                                          TextFormField(
                                            controller: _phone,
                                            keyboardType: TextInputType.phone,
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.phone),
                                              hintText: 'Phone Number'.tr(),
                                              filled: true,
                                              fillColor: Colors.transparent,
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(32),
                                                borderSide: BorderSide(
                                                  color: Color(0xFF7B5228),
                                                  width: 1.5,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(32),
                                                borderSide: BorderSide(
                                                  color: Color(0xFF7B5228),
                                                  width: 2,
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(32),
                                                borderSide: BorderSide(
                                                  color: Colors.red,
                                                  width: 1.5,
                                                ),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(32),
                                                borderSide: BorderSide(
                                                  color: Colors.red,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Phone number cannot be empty';
                                              } else if (value.length != 11) {
                                                return 'Enter a valid 11-digit phone number';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -25,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SizedBox(
                              width: screenWidth * 0.5,
                              height: screenHeight * 0.06,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_key.currentState!.validate()) {
                                    User? user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      await _saveUserDetails(user.uid);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'No user logged in. Please log in again.'
                                                  .tr()),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0xFF7B5228),
                                ),
                                child: Text(
                                  'Save'.tr(),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }
}
