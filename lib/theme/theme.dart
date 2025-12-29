// lib/theme.dart
import 'package:flutter/material.dart';

const Color kNavy = Color(0xFF0A2A43);
const Color kYellow = Color(0xFFF2C94C);
const Color kAccentYellow = Color(0xFFFFC947);
const Color kSurface = Color(0xFFFFFFFF);
const Color kMuted = Color(0xFF9AA6B2);

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kNavy,
  scaffoldBackgroundColor: kSurface,
  splashColor: kYellow.withOpacity(0.12),

  // AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: kSurface,
    elevation: 0,
    iconTheme: IconThemeData(color: kNavy),
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: kNavy,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
  ),

  // Text theme (Material 3 style names)
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: kNavy,
    ),
    displayMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: kNavy,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
    bodySmall: TextStyle(fontSize: 12, color: kMuted),
  ),

  // Elevated button / yellow CTAs
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kYellow,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 6,
    ),
  ),

  // Outlined button (navy outline)
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: kNavy,
      side: const BorderSide(color: kNavy, width: 2),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),

  // Input field
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[200],
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    labelStyle: const TextStyle(color: kNavy),
  ),

  // Bottom nav
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: kSurface,
    selectedItemColor: kNavy,
    unselectedItemColor: kMuted,
    showUnselectedLabels: true,
  ),
);
