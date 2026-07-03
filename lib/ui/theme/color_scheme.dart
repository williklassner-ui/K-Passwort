import 'package:flutter/material.dart';

/// Design-token palette used throughout the app. Most widgets reference
/// these fields directly (e.g. `KPasswortColors.onSurface`) instead of
/// `Theme.of(context)`, so they're mutable static fields rather than
/// `const` — [configure] rewrites them when the user changes theme mode /
/// accent / background color, and `app.dart` forces a full app-tree
/// remount afterwards so every widget picks up the fresh values.
abstract class KPasswortColors {
  // === Core surfaces — defaults to the original AMOLED dark palette ===
  static Color background = const Color(0xFF000000);
  static Color surface = const Color(0xFF0D0D0D);
  static Color surfaceVariant = const Color(0xFF1A1A1A);
  static Color outline = const Color(0xFF2C2C2E);
  static Color outlineVariant = const Color(0xFF1E1E1E);

  // === Text ===
  static Color onBackground = const Color(0xFFF2F2F7);
  static Color onSurface = const Color(0xFFF2F2F7);
  static Color onSurfaceVariant = const Color(0xFF8E8E93);

  // === Brand accent — user-configurable, teal-emerald by default ===
  static Color primary = const Color(0xFF00C6A0);
  static Color primaryDim = const Color(0xFF009E80);
  static Color onPrimary = const Color(0xFF000000);

  // === Semantic (kept consistent across light/dark) ===
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

  static bool isLight = false;

  /// Rewrites the mutable palette fields above based on the current theme
  /// settings. Must be followed by a full app-tree remount (see app.dart)
  /// so widgets that read these fields directly re-render.
  static void configure({
    required bool isLight,
    required Color accent,
    Color? customBackground,
  }) {
    KPasswortColors.isLight = isLight;
    if (isLight) {
      background = customBackground ?? const Color(0xFFFFFFFF);
      surface = customBackground != null
          ? Color.lerp(customBackground, Colors.black, 0.03)!
          : const Color(0xFFF7F7F8);
      surfaceVariant = customBackground != null
          ? Color.lerp(customBackground, Colors.black, 0.06)!
          : const Color(0xFFEFEFF2);
      outline = const Color(0xFFD1D1D6);
      outlineVariant = const Color(0xFFE5E5EA);
      onBackground = const Color(0xFF1C1C1E);
      onSurface = const Color(0xFF1C1C1E);
      onSurfaceVariant = const Color(0xFF6E6E73);
      onPrimary = const Color(0xFFFFFFFF);
    } else {
      background = customBackground ?? const Color(0xFF000000);
      surface = customBackground != null
          ? Color.lerp(customBackground, Colors.white, 0.06)!
          : const Color(0xFF0D0D0D);
      surfaceVariant = customBackground != null
          ? Color.lerp(customBackground, Colors.white, 0.12)!
          : const Color(0xFF1A1A1A);
      outline = const Color(0xFF2C2C2E);
      outlineVariant = const Color(0xFF1E1E1E);
      onBackground = const Color(0xFFF2F2F7);
      onSurface = const Color(0xFFF2F2F7);
      onSurfaceVariant = const Color(0xFF8E8E93);
      onPrimary = const Color(0xFF000000);
    }
    primary = accent;
    primaryDim = Color.lerp(accent, Colors.black, 0.2)!;
  }

  /// Builds a Material [ColorScheme] snapshot from the current palette.
  static ColorScheme scheme() => ColorScheme(
        brightness: isLight ? Brightness.light : Brightness.dark,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer:
            isLight ? Color.lerp(primary, Colors.white, 0.85)! : Color.lerp(primary, Colors.black, 0.8)!,
        onPrimaryContainer: primary,
        secondary: const Color(0xFF64D2FF),
        onSecondary: const Color(0xFF000000),
        secondaryContainer: isLight ? const Color(0xFFD6F0FF) : const Color(0xFF003A4D),
        onSecondaryContainer: const Color(0xFF0A84FF),
        tertiary: const Color(0xFFBF5AF2),
        onTertiary: Colors.white,
        tertiaryContainer: isLight ? const Color(0xFFF2E0FF) : const Color(0xFF2D0A47),
        onTertiaryContainer: const Color(0xFFBF5AF2),
        error: error,
        onError: onError,
        errorContainer: isLight ? const Color(0xFFFFDAD9) : const Color(0xFF3D0000),
        onErrorContainer: error,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceVariant,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: isLight ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
        onInverseSurface: isLight ? const Color(0xFFF2F2F7) : const Color(0xFF000000),
        inversePrimary: isLight ? Color.lerp(primary, Colors.black, 0.3)! : const Color(0xFF006651),
      );
}
