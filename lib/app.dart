import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_passwort/features/settings/providers/appearance_provider.dart';
import 'package:k_passwort/features/settings/providers/theme_provider.dart';
import 'package:k_passwort/routing/app_router.dart';
import 'package:k_passwort/ui/theme/app_theme.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/autofill/autofill_entry_selector.dart';

class KPasswortApp extends ConsumerWidget {
  const KPasswortApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final accent = ref.watch(themeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final backgroundColor = ref.watch(backgroundColorProvider);
    final fontFamily = ref.watch(fontFamilyProvider);
    final fontScale = ref.watch(fontScaleProvider);
    final fontColor = ref.watch(fontColorProvider);

    KPasswortColors.configure(
      isLight: themeMode == AppThemeMode.light,
      accent: accent,
      customBackground: backgroundColor,
    );
    AppTypography.configure(
      fontFamily: fontFamily,
      scale: fontScale,
      colorOverride: fontColor,
    );

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          KPasswortColors.isLight ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: KPasswortColors.background,
      systemNavigationBarIconBrightness:
          KPasswortColors.isLight ? Brightness.dark : Brightness.light,
    ));

    // Many widgets read KPasswortColors/AppTypography directly (static
    // fields) instead of through Theme.of(context), so a plain rebuild
    // wouldn't necessarily re-render them. Keying the whole app on the
    // combined appearance state forces Flutter to discard and rebuild the
    // entire widget tree whenever any of it changes, guaranteeing every
    // widget picks up the freshly configured values above.
    final appearanceKey = ValueKey((
      themeMode,
      accent.value,
      backgroundColor?.value,
      fontFamily,
      fontScale,
      fontColor?.value,
    ));

    return MaterialApp.router(
      key: appearanceKey,
      title: 'K-Passwort',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      routerConfig: router,
    );
  }
}

class AutofillPickerApp extends ConsumerWidget {
  const AutofillPickerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(themeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final backgroundColor = ref.watch(backgroundColorProvider);
    final fontFamily = ref.watch(fontFamilyProvider);
    final fontScale = ref.watch(fontScaleProvider);
    final fontColor = ref.watch(fontColorProvider);

    KPasswortColors.configure(
      isLight: themeMode == AppThemeMode.light,
      accent: accent,
      customBackground: backgroundColor,
    );
    AppTypography.configure(
      fontFamily: fontFamily,
      scale: fontScale,
      colorOverride: fontColor,
    );

    return MaterialApp(
      key: ValueKey((
        themeMode,
        accent.value,
        backgroundColor?.value,
        fontFamily,
        fontScale,
        fontColor?.value,
      )),
      title: 'K-Passwort',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const AutofillEntrySelector(),
    );
  }
}
