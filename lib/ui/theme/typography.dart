import 'package:flutter/material.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';

/// Text styles used throughout the app. Font family/size/color are
/// user-configurable (Settings → Erscheinungsbild), so these are mutable
/// getters rather than `const` fields — [configure] updates the underlying
/// state and `app.dart` forces a full app-tree remount afterwards so every
/// widget re-reads the fresh values.
abstract class AppTypography {
  static const defaultFont = 'Inter';
  static const monoFont = 'JetBrainsMono';

  /// `null` means "use the platform default font" (Settings: "System").
  static String? primaryFont = defaultFont;
  static double _scale = 1.0;
  static Color? _colorOverride;

  /// Updates font family/scale/color. [fontFamily] of `null` uses the
  /// platform default font. [scale] multiplies every style's base font
  /// size (e.g. 1.15 = 15% larger everywhere). [colorOverride] replaces
  /// the default neutral text color; `null` restores the theme-driven
  /// default.
  static void configure({
    String? fontFamily = defaultFont,
    double scale = 1.0,
    Color? colorOverride,
  }) {
    primaryFont = fontFamily;
    _scale = scale;
    _colorOverride = colorOverride;
  }

  static Color get _onBackground => _colorOverride ?? KPasswortColors.onBackground;
  static Color get _onSurfaceVariant =>
      _colorOverride?.withOpacity(0.7) ?? KPasswortColors.onSurfaceVariant;

  static double _s(double base) => base * _scale;

  // Headings
  static TextStyle get displayLarge => TextStyle(
        fontFamily: primaryFont, fontSize: _s(57), fontWeight: FontWeight.w400,
        letterSpacing: -0.25, color: _onBackground,
      );
  static TextStyle get displayMedium => TextStyle(
        fontFamily: primaryFont, fontSize: _s(45), fontWeight: FontWeight.w400,
        color: _onBackground,
      );
  static TextStyle get headlineLarge => TextStyle(
        fontFamily: primaryFont, fontSize: _s(32), fontWeight: FontWeight.w700,
        letterSpacing: -0.5, color: _onBackground,
      );
  static TextStyle get headlineMedium => TextStyle(
        fontFamily: primaryFont, fontSize: _s(28), fontWeight: FontWeight.w600,
        letterSpacing: -0.3, color: _onBackground,
      );
  static TextStyle get headlineSmall => TextStyle(
        fontFamily: primaryFont, fontSize: _s(24), fontWeight: FontWeight.w600,
        color: _onBackground,
      );

  // Titles
  static TextStyle get titleLarge => TextStyle(
        fontFamily: primaryFont, fontSize: _s(22), fontWeight: FontWeight.w600,
        letterSpacing: -0.2, color: _onBackground,
      );
  static TextStyle get titleMedium => TextStyle(
        fontFamily: primaryFont, fontSize: _s(16), fontWeight: FontWeight.w600,
        letterSpacing: 0.1, color: _onBackground,
      );
  static TextStyle get titleSmall => TextStyle(
        fontFamily: primaryFont, fontSize: _s(14), fontWeight: FontWeight.w500,
        letterSpacing: 0.1, color: _onBackground,
      );

  // Body
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: primaryFont, fontSize: _s(16), fontWeight: FontWeight.w400,
        letterSpacing: 0.15, color: _onBackground,
      );
  static TextStyle get bodyMedium => TextStyle(
        fontFamily: primaryFont, fontSize: _s(14), fontWeight: FontWeight.w400,
        letterSpacing: 0.25, color: _onBackground,
      );
  static TextStyle get bodySmall => TextStyle(
        fontFamily: primaryFont, fontSize: _s(12), fontWeight: FontWeight.w400,
        letterSpacing: 0.4, color: _onSurfaceVariant,
      );

  // Labels
  static TextStyle get labelLarge => TextStyle(
        fontFamily: primaryFont, fontSize: _s(14), fontWeight: FontWeight.w600,
        letterSpacing: 0.1, color: _onBackground,
      );
  static TextStyle get labelMedium => TextStyle(
        fontFamily: primaryFont, fontSize: _s(12), fontWeight: FontWeight.w500,
        letterSpacing: 0.5, color: _onBackground,
      );
  static TextStyle get labelSmall => TextStyle(
        fontFamily: primaryFont, fontSize: _s(11), fontWeight: FontWeight.w500,
        letterSpacing: 0.5, color: _onSurfaceVariant,
      );

  // Monospace — for passwords. Intentionally NOT affected by the custom
  // font-color override (accent/muted color carries meaning here).
  static TextStyle get passwordLarge => TextStyle(
        fontFamily: monoFont, fontSize: _s(20), fontWeight: FontWeight.w500,
        letterSpacing: 2.5, color: KPasswortColors.primary,
      );
  static TextStyle get passwordMedium => TextStyle(
        fontFamily: monoFont, fontSize: _s(16), fontWeight: FontWeight.w400,
        letterSpacing: 1.5, color: KPasswortColors.primary,
      );
  static TextStyle get passwordSmall => TextStyle(
        fontFamily: monoFont, fontSize: _s(13), fontWeight: FontWeight.w400,
        letterSpacing: 1.0, color: KPasswortColors.onSurfaceVariant,
      );

  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
