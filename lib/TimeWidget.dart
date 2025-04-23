import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class TimeWidget extends StatefulWidget {
  const TimeWidget({super.key});

  @override
  State<TimeWidget> createState() => _TimeWidgetState();
}

class _TimeWidgetState extends State<TimeWidget> {
  late String _currentTime;
  late String _greeting;

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime();
    _greeting = _getGreeting();
    _startTimer();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return DateFormat('hh:mm a').format(now); // AM/PM format
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {
        _currentTime = _getCurrentTime();
        _greeting = _getGreeting();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE5D188), Color(0xFF7B5228)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time
          Text(
            _currentTime,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          // Greeting below the time
          Text(
            _greeting,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
