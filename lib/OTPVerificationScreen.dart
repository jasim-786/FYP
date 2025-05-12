import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Onboarding1.dart';
import 'UserDetailScreen.dart'; // Import UserDetailScreen

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
  bool _isResendEnabled = false;
  late String _verificationId;
  late String _phoneNumber;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _phoneNumber = widget.phoneNumber;
    _isResendEnabled = false;
  }

  void _verifyOTP() async {
    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      String uid = userCredential.user!.uid;

      // Check if user details exist in Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users_details')
          .doc(uid)
          .get();

      if (!doc.exists) {
        // Navigate to UserDetailScreen if details don't exist
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UserDetailScreen(
              phoneNumber: _phoneNumber,
              isGoogleLogin: false,
            ),
          ),
        );
      } else {
        // Navigate to Onboarding1 if details already exist
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Onboarding1()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resendOTP() async {
    setState(() {
      _isResendEnabled = false;
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

        Future.delayed(Duration(seconds: 30), () {
          setState(() {
            _isResendEnabled = true;
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
                      maxLength: 6,
                      decoration: InputDecoration(
                        hintText: 'Enter 6-digit OTP',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        counterText: "",
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    SizedBox(
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.07,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyOTP,
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
