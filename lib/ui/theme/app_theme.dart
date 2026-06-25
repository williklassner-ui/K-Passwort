import 'package:flutter/material.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark({Color accent = const Color(0xFF00C6A0)}) {
    final accentDim = Color.lerp(accent, Colors.black, 0.2)!;
    final colors = KPasswortColors.scheme.copyWith(
      primary: accent,
      primaryContainer: Color.lerp(accent, Colors.black, 0.8)!,
      onPrimaryContainer: accent,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      fontFamily: AppTypography.primaryFont,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: KPasswortColors.background,
      cardColor: KPasswortColors.surface,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: KPasswortColors.background,
        foregroundColor: KPasswortColors.onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge,
        iconTheme: const IconThemeData(color: KPasswortColors.onBackground),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: const Color(0xFF1C1C1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: KPasswortColors.outline, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KPasswortColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: KPasswortColors.outline, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: KPasswortColors.outline, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KPasswortColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.bodyMedium.copyWith(color: KPasswortColors.onSurfaceVariant),
        labelStyle: AppTypography.bodyMedium.copyWith(color: KPasswortColors.onSurfaceVariant),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: KPasswortColors.onPrimary,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: AppTypography.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: KPasswortColors.onPrimary,
        elevation: 2,
        shape: const CircleBorder(),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: KPasswortColors.surfaceVariant,
        selectedColor: accent.withOpacity(0.15),
        labelStyle: AppTypography.labelMedium,
        side: BorderSide(color: KPasswortColors.outline, width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // List Tiles
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        iconColor: accent,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: KPasswortColors.outline,
        thickness: 0.5,
        space: 0,
      ),

      // Bottom navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: KPasswortColors.surface,
        indicatorColor: accent.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(color: accent);
          }
          return AppTypography.labelSmall.copyWith(color: KPasswortColors.onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: accent, size: 22);
          }
          return IconThemeData(color: KPasswortColors.onSurfaceVariant, size: 22);
        }),
        elevation: 0,
        height: 64,
      ),

      // Sliders
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: KPasswortColors.outline,
        thumbColor: accent,
        overlayColor: accent.withOpacity(0.1),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? accent : KPasswortColors.onSurfaceVariant),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? accent.withOpacity(0.4)
                : KPasswortColors.outline),
      ),

      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: KPasswortColors.surface,
        modalBackgroundColor: KPasswortColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: KPasswortColors.outline,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: KPasswortColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: AppTypography.titleLarge,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: KPasswortColors.surfaceVariant,
        contentTextStyle: AppTypography.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),

      textTheme: AppTypography.textTheme,
    );
  }
}
