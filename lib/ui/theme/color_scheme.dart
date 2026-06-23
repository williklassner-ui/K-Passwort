import 'package:flutter/material.dart';

abstract class KPasswortColors {
  // === Core surfaces (AMOLED-optimized) ===
  static const background = Color(0xFF000000);      // Pure black
  static const surface = Color(0xFF0D0D0D);          // Near-black cards
  static const surfaceVariant = Color(0xFF1A1A1A);   // Elevated surfaces
  static const outline = Color(0xFF2C2C2E);           // Borders, dividers
  static const outlineVariant = Color(0xFF1E1E1E);

  // === Text ===
  static const onBackground = Color(0xFFF2F2F7);
  static const onSurface = Color(0xFFF2F2F7);
  static const onSurfaceVariant = Color(0xFF8E8E93);  // Secondary text

  // === Brand accent — teal-emerald ===
  static const primary = Color(0xFF00C6A0);
  static const primaryDim = Color(0xFF009E80);
  static const onPrimary = Color(0xFF000000);

  // === Semantic ===
  static const error = Color(0xFFFF453A);
  static const onError = Color(0xFFFFFFFF);
  static const warning = Color(0xFFFFBF00);
  static const success = Color(0xFF32D74B);

  // === Password strength colors ===
  static const strengthWeak = Color(0xFFFF453A);
  static const strengthFair = Color(0xFFFF9500);
  static const strengthGood = Color(0xFFFFBF00);
  static const strengthStrong = Color(0xFF32D74B);
  static const strengthVeryStrong = Color(0xFF00C6A0);

  // === Category colors ===
  static const categoryLogin = Color(0xFF0A84FF);
  static const categoryCard = Color(0xFFFF9F0A);
  static const categoryNote = Color(0xFF32D74B);
  static const categoryIdentity = Color(0xFFBF5AF2);
  static const categorySSH = Color(0xFFFF453A);
  static const categoryWifi = Color(0xFF64D2FF);

  static const ColorScheme scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: Color(0xFF003D33),
    onPrimaryContainer: Color(0xFF00C6A0),
    secondary: Color(0xFF64D2FF),
    onSecondary: Color(0xFF000000),
    secondaryContainer: Color(0xFF003A4D),
    onSecondaryContainer: Color(0xFF64D2FF),
    tertiary: Color(0xFFBF5AF2),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFF2D0A47),
    onTertiaryContainer: Color(0xFFBF5AF2),
    error: error,
    onError: onError,
    errorContainer: Color(0xFF3D0000),
    onErrorContainer: Color(0xFFFF453A),
    surface: surface,
    onSurface: onSurface,
    surfaceContainerHighest: surfaceVariant,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFF2F2F7),
    onInverseSurface: Color(0xFF000000),
    inversePrimary: Color(0xFF006651),
  );
}
