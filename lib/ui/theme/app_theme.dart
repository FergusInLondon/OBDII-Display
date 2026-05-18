import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFF00E5FF);
  static const backgroundColor = Color(0xFF0A0A0F);
  static const surfaceColor = Color(0xFF13131A);
  static const errorColor = Color(0xFFFF2D55);
  static const warningColor = Color(0xFFFF6B00);
  static const textColor = Color(0xFFF0F0F0);
  static const mutedTextColor = Color(0x4DFFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.syneTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
        ),
      ).copyWith(
        labelSmall: GoogleFonts.dmMono(color: mutedTextColor),
        displayMedium: GoogleFonts.dmMono(color: textColor, fontWeight: FontWeight.w300),
      ),
    );
  }
}
