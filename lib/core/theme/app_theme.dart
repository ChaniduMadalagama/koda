// filepath: /Users/developer/Desktop/flutter/koda/lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A service provider class for managing the theme of the application.
class ThemeServiceProvider with ChangeNotifier {
  ThemeServiceProvider({bool isDark = false}) : _isDark = isDark;

  bool _isDark = false;
  bool get isDark => _isDark;

  ThemeData get lightTheme => _lightThemeData();
  ThemeData get darkTheme => _darkThemeData();
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDark = !_isDark;
    Hive.box<bool>('themeMode').put('isDark', _isDark);
    setSystemUIOverlayStyle(isDark: _isDark);
    notifyListeners();
  }

  // --- Mindful Warmth Color Palette ---
  static const Color _primary = Color(0xFF7E5700);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _primaryContainer = Color(0xFFFFB82B);
  static const Color _onPrimaryContainer = Color(0xFF6D4B00);

  static const Color _secondary = Color(0xFF71585B);
  static const Color _onSecondary = Color(0xFFFFFFFF);
  static const Color _secondaryContainer = Color(0xFFF9D8DB);
  static const Color _onSecondaryContainer = Color(0xFF755C5F);

  static const Color _tertiary = Color(0xFF605A7A);
  static const Color _onTertiary = Color(0xFFFFFFFF);
  static const Color _tertiaryContainer = Color(0xFFC8C0E5);
  static const Color _onTertiaryContainer = Color(0xFF534D6C);

  static const Color _background = Color(0xFFFEF8FC);
  static const Color _surface = Color(0xFFFEF8FC);
  static const Color _onSurface = Color(0xFF1D1B1E);
  static const Color _surfaceVariant = Color(0xFFE7E1E5);
  static const Color _onSurfaceVariant = Color(0xFF514534);

  static const Color _outline = Color(0xFF837561);
  static const Color _error = Color(0xFFBA1A1A);

  ThemeData _lightThemeData() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: _primary,
        onPrimary: _onPrimary,
        primaryContainer: _primaryContainer,
        onPrimaryContainer: _onPrimaryContainer,
        secondary: _secondary,
        onSecondary: _onSecondary,
        secondaryContainer: _secondaryContainer,
        onSecondaryContainer: _onSecondaryContainer,
        tertiary: _tertiary,
        onTertiary: _onTertiary,
        tertiaryContainer: _tertiaryContainer,
        onTertiaryContainer: _onTertiaryContainer,
        error: _error,
        onError: Colors.white,
        surface: _surface,
        onSurface: _onSurface,
        onSurfaceVariant: _onSurfaceVariant,
        outline: _outline,
      ),
      textTheme: _textTheme(),
      elevatedButtonTheme: _elevatedButtonTheme(),
      appBarTheme: _appBarTheme(isDark: false),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        color: _surfaceVariant,
      ),
    );
  }

  ThemeData _darkThemeData() {
    // Mirroring light theme for now as specific dark mappings weren't provided,
    // but using Inverse Surface as a base.
    return _lightThemeData().copyWith(brightness: Brightness.dark);
  }

  TextTheme _textTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.64,
        height: 40 / 32,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.14,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
      ),
    );
  }

  ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: _onPrimary,
        elevation: 0,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  AppBarTheme _appBarTheme({required bool isDark}) {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: _onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: _onSurface),
    );
  }

  static void setSystemUIOverlayStyle({bool isDark = false}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? Colors.black : _background,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }
}
