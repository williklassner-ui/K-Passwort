import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_passwort/core/constants/route_constants.dart';
import 'package:k_passwort/data/storage/saf_storage.dart';
import 'package:k_passwort/features/settings/providers/trash_retention_provider.dart';
import 'package:k_passwort/features/vault/providers/vault_list_provider.dart';
import 'package:k_passwort/features/vault/providers/vault_provider.dart';
import 'package:k_passwort/security/keystore/master_key_manager.dart';
import 'package:k_passwort/security/keystore/session_manager.dart';
import 'package:k_passwort/sync/saf_sync_service.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/ui/widgets/gradient_scaffold.dart';
import 'package:k_passwort/ui/widgets/pulsing_light.dart';
import 'package:k_passwort/ui/widgets/secure_text_field.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _storedUri;

  @override
  void initState() {
    super.initState();
    _checkStoredVault();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkStoredVault() async {
    final uri = await SyncStateNotifier.getSavedVaultUri();
    if (!mounted) return;
    if (uri == null) {
      // No vault ever configured → go to onboarding
      context.go(Routes.onboardingWelcome);
      return;
    }
    setState(() => _storedUri = uri);
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    final keyManager = ref.read(masterKeyManagerProvider);
    if (!await keyManager.isBiometricEnabled()) return;
    if (_storedUri == null) return;

    setState(() { _loading = true; _error = null; });
    try {
      final password = await keyManager.unlockWithBiometric();
      if (password == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final repo = ref.read(vaultRepositoryProvider);
      if (!repo.isOpen) {
        await repo.open(vaultUri: _storedUri!, masterPassword: password);
      }
      if (repo.isOpen) {
        await _openVault(_storedUri!);
      } else {
        if (mounted) setState(() { _loading = false; });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Entsperren fehlgeschlagen — bitte erneut versuchen';
        });
      }
    }
  }

  Future<void> _unlockWithPassword() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _error = 'Passwort eingeben');
      return;
    }
    final uri = _storedUri;
    if (uri == null) {
      context.go(Routes.onboardingWelcome);
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final keyManager = ref.read(masterKeyManagerProvider);
      await keyManager.unlockWithPassword(password: password);
      await _openVault(uri);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().contains('Wrong') ||
                  e.toString().contains('credentials') ||
                  e.toString().contains('Invalid')
              ? 'Falsches Master-Passwort'
              : 'Fehler beim Öffnen: $e';
        });
      }
    }
  }

  Future<void> _openVault(String uri) async {
    final repo = ref.read(vaultRepositoryProvider);

    // Only open with password if not already opened (e.g. via biometric)
    if (!repo.isOpen) {
      final password = _passwordController.text;
      await repo.open(vaultUri: uri, masterPassword: password);
    }

    final retentionDays = ref.read(trashRetentionDaysProvider);
    if (retentionDays != null) {
      await repo.purgeExpiredTrash(retentionDays);
    }

    // Keep vault list up to date
    final info = await _vaultName(uri);
    await ref.read(vaultListProvider.notifier).add(VaultDescriptor(
      name: info,
      uri: uri,
      lastOpened: DateTime.now(),
    ));
    ref.read(currentVaultUriProvider.notifier).state = uri;

    _onUnlocked();
  }

  Future<String> _vaultName(String uri) async {
    try {
      final info = await SafStorage.getFileInfo(uri);
      return (info?['name'] as String?) ?? 'vault.kdbx';
    } catch (_) {
      return 'vault.kdbx';
    }
  }

  void _onUnlocked() {
    ref.read(vaultRevisionProvider.notifier).update((n) => n + 1);
    ref.read(sessionProvider.notifier).unlock();
    if (mounted) context.go(Routes.vault);
  }

  @override
  Widget build(BuildContext context) {
    // While checking stored vault, show loading
    if (_storedUri == null && _error == null) {
      return Scaffold(
        backgroundColor: KPasswortColors.background,
        body: const Center(child: PulsingLight(size: 32)),
      );
    }

    final accent = Theme.of(context).colorScheme.primary;

    return GradientScaffold(
      showGradient: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: accent,
                  size: 40,
                ),
              ).animate().scale(
                  begin: const Offset(0.8, 0.8),
                  curve: Curves.easeOutBack),

              const SizedBox(height: 24),

              Text('K-Passwort', style: AppTypography.headlineSmall)
                  .animate(delay: 150.ms).fadeIn(),

              Text(
                'Gesperrt',
                style: AppTypography.bodyMedium
                    .copyWith(color: KPasswortColors.onSurfaceVariant),
              ).animate(delay: 200.ms).fadeIn(),

              const Spacer(flex: 2),

              SecureTextField(
                controller: _passwordController,
                label: 'Master-Passwort',
                hint: 'Passwort eingeben',
                isPassword: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _unlockWithPassword(),
              ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.08),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: AppTypography.bodySmall
                        .copyWith(color: KPasswortColors.error),
                  ),
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _unlockWithPassword,
                  child: _loading
                      ? const PulsingLight(size: 18)
                      : const Text('Entsperren'),
                ),
              ).animate(delay: 300.ms).fadeIn(),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _loading ? null : _tryBiometric,
                icon: const Icon(Icons.fingerprint_rounded, size: 20),
                label: const Text('Biometrik'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: BorderSide(color: KPasswortColors.outline),
                  foregroundColor: KPasswortColors.onBackground,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ).animate(delay: 380.ms).fadeIn(),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
