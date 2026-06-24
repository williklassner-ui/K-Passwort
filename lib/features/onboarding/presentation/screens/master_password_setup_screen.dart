import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_passwort/core/constants/app_constants.dart';
import 'package:k_passwort/core/constants/route_constants.dart';
import 'package:k_passwort/data/repositories/vault_repository.dart';
import 'package:k_passwort/data/storage/saf_storage.dart';
import 'package:k_passwort/features/onboarding/presentation/widgets/password_strength_indicator.dart';
import 'package:k_passwort/features/vault/providers/vault_provider.dart';
import 'package:k_passwort/security/keystore/master_key_manager.dart';
import 'package:k_passwort/security/keystore/session_manager.dart';
import 'package:k_passwort/sync/saf_sync_service.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/ui/widgets/gradient_scaffold.dart';
import 'package:k_passwort/ui/widgets/secure_text_field.dart';

class MasterPasswordSetupScreen extends ConsumerStatefulWidget {
  const MasterPasswordSetupScreen({super.key, required this.isCreating});
  final bool isCreating;

  @override
  ConsumerState<MasterPasswordSetupScreen> createState() => _State();
}

class _State extends ConsumerState<MasterPasswordSetupScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _proceed() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _error = 'Bitte Master-Passwort eingeben');
      return;
    }
    if (widget.isCreating && password != _confirmController.text) {
      setState(() => _error = 'Passwörter stimmen nicht überein');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final repo = ref.read(vaultRepositoryProvider);
      final keyManager = ref.read(masterKeyManagerProvider);

      if (widget.isCreating) {
        // Pick save location
        final uri = await SafStorage.createKdbxFile(AppConstants.defaultVaultName);
        if (uri == null) {
          setState(() { _loading = false; _error = 'Kein Speicherort gewählt'; });
          return;
        }
        await SyncStateNotifier.saveVaultUri(uri);

        await repo.create(vaultUri: uri, masterPassword: password);
        await keyManager.unlockWithPassword(password: password);
      } else {
        // Pick existing file
        final uri = await SafStorage.pickKdbxFile();
        if (uri == null) {
          setState(() { _loading = false; _error = 'Keine Datei gewählt'; });
          return;
        }
        await SyncStateNotifier.saveVaultUri(uri);

        await repo.open(vaultUri: uri, masterPassword: password);
        await keyManager.unlockWithPassword(password: password);
      }

      ref.read(sessionProvider.notifier).unlock();

      if (mounted) context.go(Routes.onboardingBiometric);
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isCreating ? 'Tresor erstellen' : 'Tresor öffnen';

    return GradientScaffold(
      appBar: AppBar(
        title: Text(title),
        leading: BackButton(onPressed: () => context.go(Routes.onboardingWelcome)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isCreating
                    ? 'Master-Passwort wählen'
                    : 'Master-Passwort eingeben',
                style: AppTypography.headlineMedium,
              ).animate().fadeIn().slideY(begin: 0.1),

              const SizedBox(height: 8),

              Text(
                widget.isCreating
                    ? 'Dieses Passwort verschlüsselt deinen Tresor.\nVergiss es nicht — es kann nicht zurückgesetzt werden.'
                    : 'Gib dein Master-Passwort für die .kdbx-Datei ein.',
                style: AppTypography.bodyMedium.copyWith(
                  color: KPasswortColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ).animate(delay: 100.ms).fadeIn(),

              const SizedBox(height: 36),

              SecureTextField(
                controller: _passwordController,
                label: 'Master-Passwort',
                isPassword: true,
                autofocus: true,
                onChanged: (_) => setState(() {}),
              ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.08),

              if (widget.isCreating) ...[
                const SizedBox(height: 16),
                PasswordStrengthIndicator(
                  password: _passwordController.text,
                ).animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 16),
                SecureTextField(
                  controller: _confirmController,
                  label: 'Passwort bestätigen',
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _proceed(),
                ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.08),
              ],

              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: KPasswortColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: KPasswortColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: KPasswortColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: AppTypography.bodySmall.copyWith(color: KPasswortColors.error))),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _proceed,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(widget.isCreating ? 'Tresor erstellen' : 'Öffnen'),
                ),
              ).animate(delay: 300.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
