import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Aether Light Color Palette
  static const Color primaryColor = Color(0xFF2979FF); // Electric Blue
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF82B1FF);
  static const Color secondaryColor = Color(0xFF00BCD4); // Bright Cyan
  static const Color accentColor = Color(
    0xFFFF6B6B,
  ); // Coral (keeping for alerts)
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color errorColor = Color(0xFFEF4444);

  // Aether Light Backgrounds
  static const Color backgroundColor = Color(0xFFF2F5FB); // Soft Blue-Gray
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure White
  static const Color inputFillColor = Color(0xFFEAF1FF); // Light Blue Tint
  static const Color chipBackgroundColor = Color(0xFFEAF1FF); // Light Blue Tint

  // Text Colors
  static const Color textPrimaryColor = Color(0xFF0F172A);
  static const Color textSecondaryColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  // Category Tint Colors
  static const Color categoryPhonesTint = Color(0xFFFFE8D6); // Soft Peach
  static const Color categoryElectronicsTint = Color(0xFFD8F3DC); // Soft Mint
  static const Color categoryAccessoriesTint = Color(
    0xFFE8E8FD,
  ); // Soft Lavender
  static const Color categoryComputersTint = Color(0xFFE0F2FE); // Soft Sky Blue
  static const Color categoryOthersTint = Color(0xFFF0F3F6); // Soft Grey

  // Dark theme colors
  static const Color darkPrimaryColor = Color(0xFF818CF8);
  static const Color darkBackgroundColor = Color(0xFF000000); // OLED Black
  static const Color darkSurfaceColor = Color(0xFF0F172A);
  static const Color darkTextPrimaryColor = Color(0xFFF1F5F9);
  static const Color darkTextSecondaryColor = Color(0xFF94A3B8);
  static const Color darkBorderColor = Color(0xFF1E293B);

  // Gradients for Aether Light
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2979FF), Color(0xFF1E88E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00BCD4), Color(0xFF00ACC1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFAA5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aetherGradient = LinearGradient(
    colors: [Color(0xFFF2F5FB), Color(0xFFEAF1FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Helper method to get category tint color
  static Color getCategoryTint(String category) {
    switch (category.toLowerCase()) {
      case 'phones':
      case 'phone':
      case 'mobile':
      case 'devices':
        return categoryPhonesTint;
      case 'electronics':
      case 'cameras':
      case 'camera':
      case 'audio':
        return categoryElectronicsTint;
      case 'accessories':
      case 'accessory':
      case 'fashion':
        return categoryAccessoriesTint;
      case 'computers':
      case 'computer':
      case 'laptop':
      case 'laptops':
        return categoryComputersTint;
      default:
        return categoryOthersTint;
    }
  }

  // Light Theme - Aether Light Edition
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        iconTheme: const IconThemeData(color: textPrimaryColor),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimaryColor,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimaryColor,
        ),
        displaySmall: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimaryColor,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimaryColor,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondaryColor,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondaryColor,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        surface: surfaceColor,
        background: backgroundColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: primaryColor.withOpacity(0.3),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: textSecondaryColor),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ─── Dark Theme — "Aether Dark" ────────────────────────────────────────────
  static const Color darkBg       = Color(0xFF0D1117);
  static const Color darkSurface  = Color(0xFF161B22);
  static const Color darkCard     = Color(0xFF1C2333);
  static const Color darkBorder2  = Color(0xFF30363D);
  static const Color darkPrimary2 = Color(0xFF4A9EFF);
  static const Color darkText1    = Color(0xFFE6EDF3);
  static const Color darkText2    = Color(0xFF8B949E);
  static const Color darkInput    = Color(0xFF1C2333);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkPrimary2,
      scaffoldBackgroundColor: darkBg,
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkText1,
        ),
        iconTheme: const IconThemeData(color: darkText1),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: darkText1),
        displayMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: darkText1),
        displaySmall: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: darkText1),
        headlineLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: darkText1),
        headlineMedium: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: darkText1),
        headlineSmall: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: darkText1),
        titleLarge: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: darkText1),
        titleMedium: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: darkText1),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: darkText1),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: darkText2),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: darkText2),
      ),
      colorScheme: ColorScheme.dark(
        primary: darkPrimary2,
        secondary: const Color(0xFF4A9EFF),
        error: errorColor,
        surface: darkSurface,
        background: darkBg,
        onPrimary: Colors.white,
        onSurface: darkText1,
        onBackground: darkText1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary2,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder2, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder2, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkPrimary2, width: 2),
        ),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: darkText2),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: darkPrimary2,
        unselectedItemColor: darkText2,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCard,
        contentTextStyle: GoogleFonts.inter(color: darkText1, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
