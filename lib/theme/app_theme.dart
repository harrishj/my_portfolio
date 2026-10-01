import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // NIKI Studio Deep Charcoal Canvas & Surfaces
  static const Color bgDark = Color(0xFF141312); // Deep Charcoal Canvas
  static const Color bgSurface = Color(0xFF1A1918); // Elevated Surface
  static const Color bgCard = Color(0xFF1F1E1C); // Secondary Surface
  static const Color bgCardHover = Color(0xFF262523); // Active / Hover Surface
  static const Color bgStage = Color(0xFF181716); // Device Frame Stage

  // NIKI Studio Palette Tokens
  static const Color amber = Color(0xFFBA7924); // Dominant Brand / Active Accent
  static const Color sand = Color(0xFFE9C28F); // Inverted Surface
  static const Color ink = Color(0xFF54240C); // Deep Brown Ink (Text on Sand)
  static const Color greyAccent = Color(0xFF7C7F80); // Architectural Muted Grey
  static const Color lightGrey = Color(0xFFC0C4C4); // Detail / Highlight Grey

  // Text Hierarchy
  static const Color textPrimary = Color(0xFFF2F1EE); // High-contrast White/Bone
  static const Color textSecondary = Color(0xFFA8A6A1); // Warm Muted Body
  static const Color textMuted = Color(0xFF7C7F80); // Architecture Meta

  // Hairlines & Dividers
  static const Color hairline = Color(0x337C7F80); // 1px Hairline Divider
  static const Color hairlineStrong = Color(0x557C7F80);
  static const Color cardBorder = Color(0xFF2A2826);
  static const Color amberBorder = Color(0x66BA7924);

  // Backward compatibility alias constants
  static const Color accentBlue = amber;
  static const Color accentPurple = Color(0xFF8C5820);
  static const Color accentPink = sand;
  static const Color accentGreen = Color(0xFF5A9E6F);
  static const Color bgMedium = bgSurface;
  static const Color bgElevated = bgCard;
  static const Color glassBorder = hairline;
  static const Color glassBorderHover = amber;
  static const Color glassBackground = Color(0x1A1F1E1C);

  // Subtle Atmospheric Gradients
  static const LinearGradient amberGlow = LinearGradient(
    colors: [Color(0x33BA7924), Colors.transparent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFBA7924), Color(0xFFE9C28F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x22BA7924), Colors.transparent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static const double baseSpacing = 16.0;
  static const double radius = 2.0; // Minimalist architectural radius

  static TextStyle displayFont({
    double fontSize = 48,
    FontWeight fontWeight = FontWeight.w800,
    Color color = AppColors.textPrimary,
    double height = 0.9,
    double letterSpacing = -0.5,
  }) {
    return GoogleFonts.unbounded(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle bodyFont({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textSecondary,
    double height = 1.6,
    double letterSpacing = 0.0,
  }) {
    return GoogleFonts.interTight(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle metaFont({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.textMuted,
    double letterSpacing = 1.5,
  }) {
    return GoogleFonts.interTight(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static ThemeData get darkTheme {
    final baseText = GoogleFonts.interTightTextTheme();
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.amber,
        secondary: AppColors.sand,
        surface: AppColors.bgSurface,
      ),
      textTheme: baseText.copyWith(
        displayLarge: GoogleFonts.unbounded(
          fontSize: 96,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: -2.0,
          height: 0.85,
        ),
        displayMedium: GoogleFonts.unbounded(
          fontSize: 56,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -1.2,
          height: 0.9,
        ),
        headlineLarge: GoogleFonts.unbounded(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.8,
          height: 1.0,
        ),
        headlineMedium: GoogleFonts.unbounded(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.4,
          height: 1.1,
        ),
        titleLarge: GoogleFonts.interTight(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.interTight(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.interTight(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.65,
        ),
        bodyMedium: GoogleFonts.interTight(
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
        labelLarge: GoogleFonts.interTight(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 1.2,
        ),
        labelSmall: GoogleFonts.interTight(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 1.4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          borderSide: const BorderSide(color: AppColors.amber, width: 1.5),
        ),
        labelStyle: GoogleFonts.interTight(color: AppColors.textSecondary, fontSize: 13),
        hintStyle: GoogleFonts.interTight(color: AppColors.textMuted, fontSize: 13),
      ),
    );
  }
}
