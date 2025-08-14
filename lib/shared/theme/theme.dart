import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

ThemeData getDefaultTheme() {
  // Ganti warna utama menjadi warna ungu yang Anda inginkan
  const primaryColor = Color(0xFF9027E9); // <-- PERUBAHAN DI SINI

  return ThemeData(
    // --- Warna Dasar ---
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xfff5f5f5),
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),

    // --- Font / Tipografi ---
    textTheme: GoogleFonts.poppinsTextTheme(),

    // --- AppBar ---
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xfff5f5f5),
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
      ),
      iconTheme: const IconThemeData(
        color: Colors.black87,
      ),
    ),

    // --- Tombol ---
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14.0),
      ),
    ),

    // --- Text Field ---
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(
          color: primaryColor,
        ),
      ),
    ),

    // --- Bottom Navigation Bar ---
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      unselectedItemColor: Colors.grey,
      selectedItemColor: primaryColor,
    ),
  );
}