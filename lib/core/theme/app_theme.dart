import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildAppTheme() {
  const primary = Color(0xFF1A73E8);
  const textPrimary = Color(0xFF202124);
  const textSecondary = Color(0xFF5F6368);
  const surface = Colors.white;

  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: base.colorScheme.copyWith(
      primary: primary,
      surface: surface,
      onSurface: textPrimary,
      onPrimary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    textTheme: GoogleFonts.robotoTextTheme(base.textTheme).copyWith(
      titleLarge: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyLarge: const TextStyle(fontSize: 16, color: textPrimary),
      bodyMedium: const TextStyle(fontSize: 14, color: textPrimary),
      bodySmall: const TextStyle(fontSize: 12, color: textSecondary),
    ),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFE8EAED),
    checkboxTheme: _checkboxTheme(primary),
  );
}

ThemeData buildDarkAppTheme() {
  const primary = Color(0xFF1A73E8);
  const textPrimary = Color(0xFFE8EAED);
  const textSecondary = Color(0xFFBDC1C6);
  const background = Color(0xFF202124);
  const surface = Color(0xFF2D2E30);

  final base = ThemeData.dark(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: background,
    colorScheme: base.colorScheme.copyWith(
      primary: primary,
      surface: surface,
      onSurface: textPrimary,
      onPrimary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    textTheme: GoogleFonts.robotoTextTheme(base.textTheme).copyWith(
      titleLarge: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyLarge: const TextStyle(fontSize: 16, color: textPrimary),
      bodyMedium: const TextStyle(fontSize: 14, color: textPrimary),
      bodySmall: const TextStyle(fontSize: 12, color: textSecondary),
    ),
    cardColor: surface,
    dividerColor: const Color(0xFF3C4043),
    checkboxTheme: _checkboxTheme(primary),
  );
}

CheckboxThemeData _checkboxTheme(Color primary) {
  return CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return primary;
      }
      return Colors.transparent;
    }),
    side: const BorderSide(color: Color(0xFFBDC1C6), width: 1.2),
  );
}

