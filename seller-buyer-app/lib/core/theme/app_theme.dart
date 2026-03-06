import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static const _fontFamily = 'Inter';
  static const _accent = AppColors.accent;
  static const _radius = Radius.circular(14);

  // ──────────────────────────────────────────────────────────────────────────
  // DARK
  // ──────────────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const bg      = AppColors.darkBg;
    const card    = AppColors.darkBgCard;
    const surface = AppColors.darkBgSurface;
    const brd     = AppColors.darkBorder;
    const tPrimary   = AppColors.darkTextPrimary;
    const tSecondary = AppColors.darkTextSecondary;
    const tMuted     = AppColors.darkTextMuted;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: bg,

      colorScheme: const ColorScheme.dark(
        primary:   _accent,
        secondary: AppColors.accentLight,
        surface:   card,
        error:     AppColors.red,
        onPrimary: Colors.white,
        onSurface: tPrimary,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: tPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: bg,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily, fontSize: 18,
          fontWeight: FontWeight.w700, color: tPrimary,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(_radius)),
        textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
        elevation: 0,
        splashFactory: InkRipple.splashFactory,
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        foregroundColor: _accent,
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: _accent, width: 1.5),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(_radius)),
        textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
      )),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(
        foregroundColor: _accent,
        textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
      )),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(
        foregroundColor: tPrimary,
      )),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.all(_radius), borderSide: const BorderSide(color: brd)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(_radius), borderSide: const BorderSide(color: brd)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(_radius), borderSide: const BorderSide(color: _accent, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.all(_radius), borderSide: const BorderSide(color: AppColors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.all(_radius), borderSide: const BorderSide(color: AppColors.red, width: 1.5)),
        labelStyle: const TextStyle(color: tMuted, fontFamily: _fontFamily),
        hintStyle: const TextStyle(color: tMuted, fontFamily: _fontFamily),
      ),

      // Card
      cardTheme: CardTheme(
        color: card, elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(_radius)),
        margin: EdgeInsets.zero,
      ),

      // BottomNav
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: _accent,
        unselectedItemColor: tMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Tab
      tabBarTheme: const TabBarTheme(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: _accent, width: 2),
        ),
        labelColor: _accent,
        unselectedLabelColor: tMuted,
        labelStyle: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w400, fontSize: 14),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((s) =>
          s.contains(MaterialState.selected) ? _accent : tMuted),
        trackColor: MaterialStateProperty.resolveWith((s) =>
          s.contains(MaterialState.selected) ? AppColors.accentBg : brd),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((s) =>
          s.contains(MaterialState.selected) ? _accent : Colors.transparent),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(color: brd, width: 1.5),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      ),

      // Divider
      dividerTheme: const DividerThemeData(color: brd, thickness: 1, space: 1),

      // SnackBar
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: TextStyle(color: tPrimary, fontFamily: _fontFamily),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(_radius)),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        labelStyle: const TextStyle(color: tPrimary, fontFamily: _fontFamily, fontSize: 12),
        side: const BorderSide(color: brd),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ProgressIndicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: _accent),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      textTheme: const TextTheme(
        headlineLarge:  TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w800, color: tPrimary),
        headlineMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700, color: tPrimary),
        headlineSmall:  TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700, color: tPrimary),
        titleLarge:     TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700, color: tPrimary),
        titleMedium:    TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600, color: tPrimary),
        titleSmall:     TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600, color: tPrimary),
        bodyLarge:      TextStyle(fontFamily: _fontFamily, color: tPrimary),
        bodyMedium:     TextStyle(fontFamily: _fontFamily, color: tSecondary),
        bodySmall:      TextStyle(fontFamily: _fontFamily, color: tMuted),
        labelLarge:     TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600, color: tPrimary),
        labelMedium:    TextStyle(fontFamily: _fontFamily, color: tSecondary),
        labelSmall:     TextStyle(fontFamily: _fontFamily, color: tMuted),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // LIGHT
  // ──────────────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const bg      = AppColors.lightBg;
    const card    = AppColors.lightBgCard;
    const surface = AppColors.lightBgSurface;
    const brd     = AppColors.lightBorder;
    const tPrimary   = AppColors.lightTextPrimary;
    const tSecondary = AppColors.lightTextSecondary;
    const tMuted     = AppColors.lightTextMuted;

    return darkTheme.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,

      colorScheme: const ColorScheme.light(
        primary:   _accent,
        secondary: AppColors.accentLight,
        surface:   card,
        error:     AppColors.red,
        onPrimary: Colors.white,
        onSurface: tPrimary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: card,
        foregroundColor: tPrimary,
        elevation: 0,
        shadowColor: Color(0x18000000),
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: card,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily, fontSize: 18,
          fontWeight: FontWeight.w700, color: tPrimary,
        ),
      ),

      cardTheme: CardTheme(
        color: card, elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(_radius)),
        margin: EdgeInsets.zero,
        shadowColor: const Color(0x14000000),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.all(_radius), borderSide: const BorderSide(color: brd)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(_radius), borderSide: const BorderSide(color: brd)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(_radius), borderSide: const BorderSide(color: _accent, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.all(_radius), borderSide: const BorderSide(color: AppColors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.all(_radius), borderSide: const BorderSide(color: AppColors.red, width: 1.5)),
        labelStyle: const TextStyle(color: tMuted, fontFamily: _fontFamily),
        hintStyle: const TextStyle(color: tMuted, fontFamily: _fontFamily),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: _accent,
        unselectedItemColor: tMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      dividerTheme: const DividerThemeData(color: brd, thickness: 1, space: 1),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: card,
        contentTextStyle: TextStyle(color: tPrimary, fontFamily: _fontFamily),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(_radius)),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surface,
        labelStyle: const TextStyle(color: tPrimary, fontFamily: _fontFamily, fontSize: 12),
        side: const BorderSide(color: brd),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      textTheme: const TextTheme(
        headlineLarge:  TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w800, color: tPrimary),
        headlineMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700, color: tPrimary),
        headlineSmall:  TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700, color: tPrimary),
        titleLarge:     TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700, color: tPrimary),
        titleMedium:    TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600, color: tPrimary),
        titleSmall:     TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600, color: tPrimary),
        bodyLarge:      TextStyle(fontFamily: _fontFamily, color: tPrimary),
        bodyMedium:     TextStyle(fontFamily: _fontFamily, color: tSecondary),
        bodySmall:      TextStyle(fontFamily: _fontFamily, color: tMuted),
        labelLarge:     TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600, color: tPrimary),
        labelMedium:    TextStyle(fontFamily: _fontFamily, color: tSecondary),
        labelSmall:     TextStyle(fontFamily: _fontFamily, color: tMuted),
      ),
    );
  }
}
