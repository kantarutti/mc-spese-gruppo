import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colori personalizzati
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color backgroundColor = Color(0xFFFAFAFA);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: surfaceColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white,
      ),
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 32,
        color: Colors.black87,
      ),
      displayMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 28,
        color: Colors.black87,
      ),
      displaySmall: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: Colors.black87,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.black87,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: Colors.black87,
      ),
      titleLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.black87,
      ),
      titleMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: Colors.black87,
      ),
      titleSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: Colors.black87,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.normal,
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.normal,
        fontSize: 14,
        color: Colors.black87,
      ),
      bodySmall: GoogleFonts.poppins(
        fontWeight: FontWeight.normal,
        fontSize: 12,
        color: Colors.black54,
      ),
      labelLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.black87,
      ),
      labelMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: Colors.black87,
      ),
      labelSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 10,
        color: Colors.black87,
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: GoogleFonts.poppins(
        color: Colors.grey[700],
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.poppins(
        color: Colors.grey[500],
        fontSize: 14,
      ),
    ),

    // Dialog Theme
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
    ),

    // FAB Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: Color(0xFF1E1E1E),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white,
      ),
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: const Color(0xFF2C2C2C),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Text Theme (simile al light theme)
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 32,
        color: Colors.white,
      ),
      displayMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 28,
        color: Colors.white,
      ),
      displaySmall: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.normal,
        fontSize: 16,
        color: Colors.white70,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.normal,
        fontSize: 14,
        color: Colors.white70,
      ),
    ),
  );
}