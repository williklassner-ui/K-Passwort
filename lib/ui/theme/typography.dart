import 'package:flutter/material.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';

abstract class AppTypography {
  static const primaryFont = 'Inter';
  static const monoFont = 'JetBrainsMono';

  // Headings
  static const displayLarge = TextStyle(
    fontFamily: primaryFont, fontSize: 57, fontWeight: FontWeight.w400,
    letterSpacing: -0.25, color: KPasswortColors.onBackground,
  );
  static const displayMedium = TextStyle(
    fontFamily: primaryFont, fontSize: 45, fontWeight: FontWeight.w400,
    color: KPasswortColors.onBackground,
  );
  static const headlineLarge = TextStyle(
    fontFamily: primaryFont, fontSize: 32, fontWeight: FontWeight.w700,
    letterSpacing: -0.5, color: KPasswortColors.onBackground,
  );
  static const headlineMedium = TextStyle(
    fontFamily: primaryFont, fontSize: 28, fontWeight: FontWeight.w600,
    letterSpacing: -0.3, color: KPasswortColors.onBackground,
  );
  static const headlineSmall = TextStyle(
    fontFamily: primaryFont, fontSize: 24, fontWeight: FontWeight.w600,
    color: KPasswortColors.onBackground,
  );

  // Titles
  static const titleLarge = TextStyle(
    fontFamily: primaryFont, fontSize: 22, fontWeight: FontWeight.w600,
    letterSpacing: -0.2, color: KPasswortColors.onBackground,
  );
  static const titleMedium = TextStyle(
    fontFamily: primaryFont, fontSize: 16, fontWeight: FontWeight.w600,
    letterSpacing: 0.1, color: KPasswortColors.onBackground,
  );
  static const titleSmall = TextStyle(
    fontFamily: primaryFont, fontSize: 14, fontWeight: FontWeight.w500,
    letterSpacing: 0.1, color: KPasswortColors.onBackground,
  );

  // Body
  static const bodyLarge = TextStyle(
    fontFamily: primaryFont, fontSize: 16, fontWeight: FontWeight.w400,
    letterSpacing: 0.15, color: KPasswortColors.onBackground,
  );
  static const bodyMedium = TextStyle(
    fontFamily: primaryFont, fontSize: 14, fontWeight: FontWeight.w400,
    letterSpacing: 0.25, color: KPasswortColors.onBackground,
  );
  static const bodySmall = TextStyle(
    fontFamily: primaryFont, fontSize: 12, fontWeight: FontWeight.w400,
    letterSpacing: 0.4, color: KPasswortColors.onSurfaceVariant,
  );

  // Labels
  static const labelLarge = TextStyle(
    fontFamily: primaryFont, fontSize: 14, fontWeight: FontWeight.w600,
    letterSpacing: 0.1, color: KPasswortColors.onBackground,
  );
  static const labelMedium = TextStyle(
    fontFamily: primaryFont, fontSize: 12, fontWeight: FontWeight.w500,
    letterSpacing: 0.5, color: KPasswortColors.onBackground,
  );
  static const labelSmall = TextStyle(
    fontFamily: primaryFont, fontSize: 11, fontWeight: FontWeight.w500,
    letterSpacing: 0.5, color: KPasswortColors.onSurfaceVariant,
  );

  // Monospace — for passwords
  static const passwordLarge = TextStyle(
    fontFamily: monoFont, fontSize: 20, fontWeight: FontWeight.w500,
    letterSpacing: 2.5, color: KPasswortColors.primary,
  );
  static const passwordMedium = TextStyle(
    fontFamily: monoFont, fontSize: 16, fontWeight: FontWeight.w400,
    letterSpacing: 1.5, color: KPasswortColors.primary,
  );
  static const passwordSmall = TextStyle(
    fontFamily: monoFont, fontSize: 13, fontWeight: FontWeight.w400,
    letterSpacing: 1.0, color: KPasswortColors.onSurfaceVariant,
  );

  static const TextTheme textTheme = TextTheme(
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
