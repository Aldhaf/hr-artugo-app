import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr_artugo_app/core.dart';

ThemeData getDarkTheme() {
  // Definisikan warna primer baru Anda di sini
  const Color primaryColor = Color(0xFFA27BFF);

  final textTheme = GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);

  return ThemeData.dark().copyWith(
    colorScheme: ThemeData.dark().colorScheme.copyWith(
          primary: primaryColor,
          secondary: primaryColor, // Biasanya diatur sama dengan primary
          brightness: Brightness.dark,
        ),

    // 2. Atur warna utama secara eksplisit
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212), // Warna latar belakang dark mode standar
    textTheme: textTheme,

    // 3. Pertahankan kustomisasi Anda yang sudah ada
    appBarTheme: AppBarTheme(
      elevation: 0.6,
      titleTextStyle: GoogleFonts.lato(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      unselectedItemColor: Colors.grey[400],
      selectedItemColor: primaryColor, // Terapkan warna primer pada item yang aktif
    ),
    tabBarTheme: const TabBarThemeData(
      unselectedLabelColor: Colors.grey,
      labelColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: primaryColor), // Gunakan primaryColor saat aktif
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    ),

    // 4. Tambahkan tema untuk widget umum lainnya agar konsisten
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor, // Tombol akan menggunakan warna primer
        foregroundColor: Colors.white, // Teks pada tombol akan berwarna putih
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}