import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_passwort/features/settings/providers/theme_provider.dart';
import 'package:k_passwort/routing/app_router.dart';
import 'package:k_passwort/ui/theme/app_theme.dart';
import 'package:k_passwort/autofill/autofill_entry_selector.dart';

class KPasswortApp extends ConsumerWidget {
  const KPasswortApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final accent = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'K-Passwort',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(accent: accent),
      routerConfig: router,
    );
  }
}

class AutofillPickerApp extends StatelessWidget {
  const AutofillPickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'K-Passwort',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const AutofillEntrySelector(),
    );
  }
}
