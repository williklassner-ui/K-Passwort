import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_passwort/core/constants/route_constants.dart';
import 'package:k_passwort/features/auth/presentation/screens/lock_screen.dart';
import 'package:k_passwort/features/generator/presentation/screens/generator_screen.dart';
import 'package:k_passwort/features/onboarding/presentation/screens/biometric_setup_screen.dart';
import 'package:k_passwort/features/onboarding/presentation/screens/master_password_setup_screen.dart';
import 'package:k_passwort/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:k_passwort/features/settings/presentation/screens/settings_screen.dart';
import 'package:k_passwort/features/vault/presentation/screens/entry_detail_screen.dart';
import 'package:k_passwort/features/vault/presentation/screens/entry_edit_screen.dart';
import 'package:k_passwort/features/vault/presentation/screens/vault_home_screen.dart';
import 'package:k_passwort/routing/route_guards.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final guard = ref.watch(routeGuardProvider);

  return GoRouter(
    initialLocation: Routes.lock,
    redirect: guard.redirect,
    refreshListenable: guard,
    routes: [
      GoRoute(
        path: Routes.onboardingWelcome,
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.onboardingCreateVault,
        builder: (_, __) => const MasterPasswordSetupScreen(isCreating: true),
      ),
      GoRoute(
        path: Routes.onboardingOpenVault,
        builder: (_, state) => MasterPasswordSetupScreen(
          isCreating: false,
          prefillUri: state.uri.queryParameters['uri'],
          vaultName: state.uri.queryParameters['name'],
        ),
      ),
      GoRoute(
        path: Routes.onboardingBiometric,
        builder: (_, __) => const BiometricSetupScreen(),
      ),
      GoRoute(
        path: Routes.lock,
        builder: (_, __) => const LockScreen(),
      ),
      GoRoute(
        path: Routes.switchVault,
        builder: (_, state) => MasterPasswordSetupScreen(
          isCreating: false,
          isSwitching: true,
          prefillUri: state.uri.queryParameters['uri'],
          vaultName: state.uri.queryParameters['name'],
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => VaultShell(child: child),
        routes: [
          GoRoute(
            path: Routes.vault,
            builder: (_, __) => const VaultHomeScreen(),
            routes: [
              GoRoute(
                path: 'entry/new',
                builder: (_, __) => const EntryEditScreen(entryId: null),
              ),
              GoRoute(
                path: 'entry/:id',
                builder: (_, state) =>
                    EntryDetailScreen(entryId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, state) =>
                        EntryEditScreen(entryId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: Routes.generator,
            builder: (_, __) => const GeneratorScreen(),
          ),
          GoRoute(
            path: Routes.settings,
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Seite nicht gefunden: ${state.error}')),
    ),
  );
});
