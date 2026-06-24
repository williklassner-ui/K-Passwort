import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_passwort/core/constants/route_constants.dart';
import 'package:k_passwort/security/keystore/master_key_manager.dart';
import 'package:k_passwort/security/keystore/session_manager.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/ui/widgets/gradient_scaffold.dart';
import 'package:k_passwort/ui/widgets/secure_text_field.dart';
import 'package:k_passwort/sync/saf_sync_service.dart';
import 'package:k_passwort/features/vault/providers/vault_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    final keyManager = ref.read(masterKeyManagerProvider);
    if (!await keyManager.isBiometricEnabled()) return;

    setState(() { _loading = true; _error = null; });
    try {
      await keyManager.unlockWithBiometric();
      _onUnlocked();
    } catch (e) {
      setState(() { _loading = false; _error = null; }); // Silent on biometric cancel
    }
  }

  Future<void> _unlockWithPassword() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _error = 'Passwort eingeben');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final keyManager = ref.read(masterKeyManagerProvider);
      final repo = ref.read(vaultRepositoryProvider);
      final uri = await SyncStateNotifier.getSavedVaultUri();
      if (uri == null) throw Exception('Kein Tresor konfiguriert');

      await keyManager.unlockWithPassword(password: password);
      await repo.open(vaultUri: uri, masterPassword: password);
      _onUnlocked();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString().contains('Wrong') || e.toString().contains('credentials')
            ? 'Falsches Master-Passwort'
            : 'Fehler beim Öffnen: $e';
      });
    }
  }

  void _onUnlocked() {
    ref.read(vaultRevisionProvider.notifier).update((n) => n + 1);
    ref.read(sessionProvider.notifier).unlock();
    if (mounted) context.go(Routes.vault);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      showGradient: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Lock icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: KPasswortColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: KPasswortColors.primary,
                  size: 40,
                ),
              ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),

              const SizedBox(height: 24),

              Text('K-Passwort', style: AppTypography.headlineSmall)
                  .animate(delay: 150.ms).fadeIn(),

              Text(
                'Gesperrt',
                style: AppTypography.bodyMedium.copyWith(color: KPasswortColors.onSurfaceVariant),
              ).animate(delay: 200.ms).fadeIn(),

              const Spacer(flex: 2),

              // Password field
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
                    style: AppTypography.bodySmall.copyWith(color: KPasswortColors.error),
                  ),
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _unlockWithPassword,
                  child: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Text('Entsperren'),
                ),
              ).animate(delay: 300.ms).fadeIn(),

              const SizedBox(height: 16),

              // Biometric button
              OutlinedButton.icon(
                onPressed: _loading ? null : _tryBiometric,
                icon: const Icon(Icons.fingerprint_rounded, size: 20),
                label: const Text('Biometrik'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: BorderSide(color: KPasswortColors.outline),
                  foregroundColor: KPasswortColors.onBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
