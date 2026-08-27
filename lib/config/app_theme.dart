import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      //  🎨 COLORI --------------------------------------------------------------
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryColor,
        onPrimary: AppColors.primaryTextColor,
        secondary: AppColors.secondaryColor,
        onSecondary: Colors.white,
        error: AppColors.chiusoColor,
        onError: Colors.white,
        background: AppColors.backgroundColor,
        onBackground: AppColors.secondaryTextColor,
        surface: AppColors.cardColor,
        onSurface: AppColors.secondaryTextColor,
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,

      // 🖋️ CARATTERI ------------------------------------------------------------
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryTextColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.secondaryTextColor,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.dividerColor,
        ),
      ),

      //  🧱 CARD ------------------------------------------------------------
      cardTheme: const CardThemeData(
        color: AppColors.cardColor,
        elevation: 1,
        margin: EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          side: BorderSide(
            color: AppColors.dividerColor,
            width: 1,
          ),
        ),
      ),

      // 📝 CAMPI INPUT / FORM  ------------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(),

        // Bordo normale
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.dividerColor,
            width: 1,
          ),
        ),

        // Bordo quando è in focus
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
            width: 2,
          ),
        ),

        // ⭐ Bordo per campi readOnly / disabled
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.dividerColor.withOpacity(0.7),
            width: 1,
          ),
        ),

        // ⭐ Sfondo dei campi normali → bianco
        filled: true,
        fillColor: AppColors.cardColor,

        // Padding
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),

        // Label
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.secondaryTextColor,
        ),

        // Icona
        prefixIconColor: AppColors.secondaryColor,
      ),

      // 🔘 PULSANTI ------------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondaryColor,
          side: const BorderSide(
            color: AppColors.secondaryColor,
            width: 1,
          ),
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),

      // 📌 APPBAR ------------------------------------------------------------
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor,
        ),
        iconTheme: IconThemeData(
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}
