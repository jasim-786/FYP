// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  String? temperature;
  String? city;
  String? weatherDescription;
  String? humidity;
  String? weatherIconCode;
  String? advisoryMessage;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    try {
      Location location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      LocationData locationData = await location.getLocation();
      double? latitude = locationData.latitude;
      double? longitude = locationData.longitude;

      if (latitude == null || longitude == null) return;

      const apiKey = '4ab9233283f57f45274343fb85c16583';
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double tempC = double.parse(data['main']['temp'].toString());
        int hum = data['main']['humidity'];

        String? message;
        int month = DateTime.now().month;

        if (month >= 12 || month <= 3) {
          // December to March
          if (tempC > 22) {
            message =
                "⚠️ Warning: Conditions may favor brown rust development.";
          } else if (tempC >= 15 && tempC <= 22) {
            message = "✅ Your wheat crop is safe from brown rust.";
          } else if (tempC > 15) {
            message =
                "⚠️ Warning: Conditions may favor yellow rust development.";
          } else if (tempC >= 10 && tempC <= 15 && hum > 80) {
            message = "✅ Your wheat crop is safe from yellow rust.";
          }
        } else if (month >= 4 && month <= 6) {
          // April to June
          message = "🌾 Happy harvesting!";
        }

        setState(() {
          temperature = "${tempC.toStringAsFixed(1)}°C";
          city = data['name'];
          weatherDescription = data['weather'][0]['main'];
          weatherIconCode = data['weather'][0]['icon'];
          humidity = hum.toString();
          advisoryMessage = message;
        });

        // Show pop-up after widget builds
        if (message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: const Color(0xFFE5D188),
                titlePadding: const EdgeInsets.all(16),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                title: Row(
                  children: [
                    Icon(
                      message!.contains('safe')
                          ? Icons.check_circle_outline
                          : Icons.warning_amber_rounded,
                      color: message.contains('safe')
                          ? Colors.green[800]
                          : Colors.red[800],
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Weather Advisory",
                      style: TextStyle(
                        color: const Color(0xFF7B5228),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  message,
                  style: TextStyle(
                    color: const Color(0xFF7B5228),
                    fontSize: 16,
                  ),
                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF7B5228),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          });
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch weather: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekday = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ][now.weekday % 7];

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: weatherDescription != null
          ? Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(10),
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
                  // Icon
                  Image.network(
                    'https://openweathermap.org/img/wn/$weatherIconCode@2x.png',
                    height: 40,
                    width: 40,
                    color: Colors.white,
                  ),

                  // Day
                  Text(
                    weekday,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 1),

                  // Temperature
                  Text(
                    temperature ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // City and Humidity in a Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          city ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          humidity != null ? 'Humidity: $humidity%' : '',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
