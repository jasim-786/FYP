import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Onboarding1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPVerificationScreen({
    required this.verificationId,
    required this.phoneNumber,
    super.key,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResendEnabled = false; // To control the resend button's state
  late String _verificationId;
  late String _phoneNumber;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _phoneNumber = widget.phoneNumber;
    _isResendEnabled = false; // Start with resend disabled
  }

  void _verifyOTP() async {
    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator while verifying OTP
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      String uid = userCredential.user!.uid;

// Show a dialog or a bottom sheet to enter full name
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final TextEditingController _nameController = TextEditingController();
          return AlertDialog(
            backgroundColor: const Color(0xFFE5D188),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Enter Full Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B5228),
              ),
            ),
            content: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: "Full Name",
                hintStyle: TextStyle(color: Colors.black54),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF7B5228)),
                ),
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF7B5228),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  String fullName = _nameController.text.trim();

                  // Validate: not empty and only alphabets/spaces
                  if (fullName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Full name cannot be empty')),
                    );
                    return;
                  } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(fullName)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Only alphabets are allowed in name')),
                    );
                    return;
                  }

                  final uid = FirebaseAuth.instance.currentUser!.uid;

                  await FirebaseFirestore.instance
                      .collection('user_details')
                      .doc(uid)
                      .set({
                    'userId': uid,
                    'full_name': fullName,
                    'phone_number': widget.phoneNumber,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  Navigator.of(context).pop(); // Close the dialog

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => Onboarding1()),
                  );
                },
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator after verification attempt
      });
    }
  }

  // Resend OTP method
  void _resendOTP() async {
    setState(() {
      _isResendEnabled = false; // Disable resend button while requesting OTP
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Verification failed')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });

        // Enable resend after a delay (e.g., 30 seconds)
        Future.delayed(Duration(seconds: 30), () {
          setState(() {
            _isResendEnabled = true; // Enable the resend button
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully!')),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          // Dismiss the keyboard when tapping outside the TextField
          FocusScope.of(context).unfocus();
        },
        child: Stack(
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
              top: screenHeight * 0.2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  children: [
                    Text(
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6, // Limit input to 6 digits
                      decoration: InputDecoration(
                        hintText: 'Enter 6-digit OTP',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        counterText: "", // Hide the counter text
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    SizedBox(
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.07,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : _verifyOTP, // Disable while loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B5228),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Verify OTP',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Resend OTP button
                    _isResendEnabled
                        ? TextButton(
                            onPressed: _resendOTP,
                            child: const Text(
                              'Resend OTP',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF7B5228),
                              ),
                            ),
                          )
                        : const Text(
                            'Please wait 30 seconds before resending OTP.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
