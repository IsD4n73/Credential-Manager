import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF0A0A10);
  static const surface = Color(0xFF12121C);
  static const surfaceAlt = Color(0xFF1A1A28);
  static const surfaceElevated = Color(0xFF222234);
  static const border = Color(0xFF2A2A3A);
  static const borderStrong = Color(0xFF3A3A50);

  static const textPrimary = Color(0xFFE8E8F0);
  static const textSecondary = Color(0xFFA0A0B8);
  static const textMuted = Color(0xFF6B6B82);

  // Bright accents
  static const accentCyan = Color(0xFF00E5FF);
  static const accentMagenta = Color(0xFFFF2E97);
  static const accentLime = Color(0xFFB5FF3D);
  static const accentViolet = Color(0xFF9F5BFF);
  static const accentOrange = Color(0xFFFF8A3D);
  static const accentYellow = Color(0xFFFFE03D);
  static const accentRed = Color(0xFFFF4D6D);

  static const primary = accentCyan;

  /// Bright neon palette for project color tagging.
  static const projectPalette = <Color>[
    Color(0xFF00E5FF), // cyan
    Color(0xFFFF2E97), // magenta
    Color(0xFFB5FF3D), // lime
    Color(0xFF9F5BFF), // violet
    Color(0xFFFF8A3D), // orange
    Color(0xFFFFE03D), // yellow
    Color(0xFFFF4D6D), // red
    Color(0xFF3DFFB5), // mint
    Color(0xFF3DA0FF), // azure
    Color(0xFFFF6BD6), // pink
    Color(0xFF6BFFE0), // aqua
    Color(0xFFFFB23D), // amber
  ];

  static Color projectColorFromKey(String key) {
    if (key.isEmpty) return projectPalette.first;
    var h = 0;
    for (final code in key.codeUnits) {
      h = (h * 31 + code) & 0x7fffffff;
    }
    return projectPalette[h % projectPalette.length];
  }
}

/// Predefined environments with bright accent colors.
class EnvPresets {
  static const defaults = <String, Color>{
    'local': Color(0xFF3DA0FF),
    'dev': Color(0xFFB5FF3D),
    'staging': Color(0xFFFFB23D),
    'qa': Color(0xFF9F5BFF),
    'test': Color(0xFF6BFFE0),
    'preprod': Color(0xFFFF8A3D),
    'prod': Color(0xFFFF4D6D),
  };

  static Color colorFor(String name) {
    final key = name.toLowerCase().trim();
    if (defaults.containsKey(key)) return defaults[key]!;
    // Fallback: derive from string
    return AppColors.projectColorFromKey(key);
  }
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      bodyLarge: GoogleFonts.inter(color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.inter(color: AppColors.textPrimary),
      bodySmall: GoogleFonts.inter(color: AppColors.textSecondary),
      titleLarge: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleMedium: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );

    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.accentCyan,
        onPrimary: Color(0xFF001318),
        secondary: AppColors.accentMagenta,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.accentRed,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 20),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accentCyan, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentCyan,
          foregroundColor: const Color(0xFF001318),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderStrong),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentCyan,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: GoogleFonts.inter(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        textStyle: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 12),
      ),
    );
  }

  static TextStyle mono({double size = 13, Color? color, FontWeight? weight}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      color: color ?? AppColors.textPrimary,
      fontWeight: weight ?? FontWeight.w500,
      height: 1.4,
    );
  }
}
