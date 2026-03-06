import 'package:flutter/material.dart';

/// Основной бренд-цвет GogoMarket: #FF5001 (оранжевый)
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color accent  = Color(0xFFFF5001); // основной
  static const Color accentLight = Color(0xFFFF7433); // светлее для hover
  static const Color accentDark  = Color(0xFFCC4000); // темнее для pressed
  static const Color accentBg    = Color(0x1AFF5001); // 10% для фонов

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color green  = Color(0xFF00C566);
  static const Color red    = Color(0xFFFF3B5C);
  static const Color blue   = Color(0xFF0288D1);
  static const Color gold   = Color(0xFFFFC107);
  static const Color purple = Color(0xFF7C4DFF);

  // ── Dark theme ─────────────────────────────────────────────────────────────
  static const Color darkBg       = Color(0xFF0D0D0D);
  static const Color darkBgCard   = Color(0xFF1A1A1A);
  static const Color darkBgSurface= Color(0xFF252525);
  static const Color darkBorder   = Color(0xFF2E2E2E);
  static const Color darkTextPrimary   = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFAAAAAA);
  static const Color darkTextMuted     = Color(0xFF666666);

  // ── Light theme ────────────────────────────────────────────────────────────
  static const Color lightBg       = Color(0xFFF2F2F2);
  static const Color lightBgCard   = Color(0xFFFFFFFF);
  static const Color lightBgSurface= Color(0xFFE8E8E8);
  static const Color lightBorder   = Color(0xFFDDDDDD);
  static const Color lightTextPrimary   = Color(0xFF111111);
  static const Color lightTextSecondary = Color(0xFF555555);
  static const Color lightTextMuted     = Color(0xFF999999);

  // ── Legacy aliases (backward compat с существующими экранами) ──────────────
  static const Color bgDark      = darkBg;
  static const Color bgCard      = darkBgCard;
  static const Color bgSurface   = darkBgSurface;
  static const Color bgLight     = lightBg;
  static const Color bgCardLight = lightBgCard;
  static const Color border      = darkBorder;
  static const Color textPrimary    = darkTextPrimary;
  static const Color textSecondary  = darkTextSecondary;
  static const Color textMuted      = darkTextMuted;
  static const Color orange = accent;
  static const Color accent2 = accentLight;
}
