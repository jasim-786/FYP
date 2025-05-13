import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,

  // 🌾 Primary earthy colors
  primaryColor: const Color(0xFF7B5228), // Rich soil brown
  scaffoldBackgroundColor: const Color(0xFFFFFAF0), // Wheat paper-like tone
  // 🌿 AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF7B5228),
    foregroundColor: Colors.white,
    elevation: 2,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  // 🌱 Elevated Button
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF7B5228), // Brown
      foregroundColor: Colors.white,
      elevation: 4,
      shadowColor: Colors.green.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: 0.5,
      ),
    ),
  ),

  // 🍃 Icon Theme
  iconTheme: const IconThemeData(
    color: Color(0xFF9CAF88), // Faded leaf green
    size: 26,
  ),

  // 🃏 Card Theme
  cardTheme: CardTheme(
    color: const Color(0xFFF1E6C1), // Soft wheat yellow
    shadowColor: Colors.green.shade100,
    elevation: 5,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  // 🧾 Text Theme
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      color: Color(0xFF5A3B1A), // Deep bark brown
      fontSize: 24,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(
      color: Color(0xFF5A3B1A),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(color: Color(0xFF3E3E3E), fontSize: 16, height: 1.5),
    bodyMedium: TextStyle(
      color: Color(0xFF5A4D2E), // Olive green-brown
      fontSize: 15,
    ),
  ),

  // ✅ Input Theme (for forms)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFFCF7E8), // Pale wheat
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF7B5228)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFBCA17F)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF7B5228), width: 2),
    ),
  ),

  // 🍂 Floating Action Button
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF7B5228),
    foregroundColor: Colors.white,
    elevation: 6,
  ),

  // 🍀 Divider
  dividerTheme: DividerThemeData(color: Colors.brown.shade200, thickness: 1.2),

  // 🧩 Color scheme
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: const Color(0xFF7B5228),
    secondary: const Color(0xFFA2C28B), // Sage green
    surface: const Color(0xFFF1E6C1),
    onPrimary: Colors.white,
    onSecondary: Colors.black87,
  ),
);
