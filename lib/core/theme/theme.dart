// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // 컬러 정의
  static const Color primaryColor = Color(0xFF3266FF);
  static const Color primaryDark = Color(0xFF1E4AE5);
  static const Color primaryLight = Color(0xFF5B86FF);

  // 보조 컬러들
  static const Color backgroundColor = Color(0xFFF8F9FA);

  // 텍스트 컬러
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF718096);
  static const Color textOnPrimary = Colors.white;

  // 자주 사용하는 사이즈들
  static const double appBarFontSize = 16.0;
  static const double bodyFontSize = 14.0;
  static const double captionFontSize = 12.0;
  static const double titleFontSize = 20.0;

  // 라이트 테마
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Paperlogy',

    // 컬러 스킴
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryLight,
      secondary: primaryDark,
      secondaryContainer: primaryLight,
      onPrimary: textOnPrimary,
      onSecondary: textOnPrimary,
      onSurface: textPrimary,
      onError: textOnPrimary,
    ),

    // 앱바 테마
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: textOnPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Paperlogy',
        fontSize: appBarFontSize,
        fontWeight: FontWeight.w600,
        color: textOnPrimary,
      ),
      iconTheme: IconThemeData(color: textOnPrimary, size: 24),
    ),
  );
}
