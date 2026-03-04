import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color accent     = Color(0xFFFF3B5C);
  static const Color accentDark = Color(0xFFE02040);
  static const Color accent2    = Color(0xFFFF8C42);

  // Backgrounds — dark theme
  static const Color bgDark     = Color(0xFF0D0D15);
  static const Color bgCard     = Color(0xFF1A1A2E);
  static const Color bgCardMid  = Color(0xFF16213E);
  static const Color bgSurface  = Color(0xFF232340);

  // Backgrounds — light theme
  static const Color bgLight     = Color(0xFFF8F8FC);
  static const Color bgCardLight = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color textMuted     = Color(0xFF6B6B80);
  static const Color textDark      = Color(0xFF1A1A2E);

  // Status
  static const Color green   = Color(0xFF00A86B);
  static const Color blue    = Color(0xFF0288D1);
  static const Color purple  = Color(0xFF7C4DFF);
  static const Color gold    = Color(0xFFF9A825);
  static const Color orange  = Color(0xFFFF6B35);
  static const Color red     = Color(0xFFFF3B5C);

  // Borders
  static const Color border      = Color(0xFF2A2A3E);
  static const Color borderLight = Color(0xFFE0E0EE);

  // Gradients
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accent2],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [bgDark, bgCard],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF9A825), Color(0xFFFF8C42)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
