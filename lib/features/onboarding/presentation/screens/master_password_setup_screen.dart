import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_passwort/core/constants/app_constants.dart';
import 'package:k_passwort/core/constants/route_constants.dart';
import 'package:k_passwort/data/storage/saf_storage.dart';
import 'package:k_passwort/features/onboarding/presentation/widgets/password_strength_indicator.dart';
import 'package:k_passwort/features/vault/providers/vault_list_provider.dart';
import 'package:k_passwort/features/vault/providers/vault_provider.dart';
import 'package:k_passwort/security/keystore/master_key_manager.dart';
import 'package:k_passwort/security/keystore/session_manager.dart';
import 'package:k_passwort/sync/saf_sync_service.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/ui/widgets/gradient_scaffold.dart';
import 'package:k_passwort/ui/widgets/secure_text_field.dart';

class MasterPasswordSetupScreen extends ConsumerStatefulWidget {
  const MasterPasswordSetupScreen({
    super.key,
    required this.isCreating,
    this.isSwitching = false,
    this.prefillUri,
    this.vaultName,
  });

  final bool isCreating;
  /// True only for the "switch vault while already unlocked" flow — controls
  /// back-button behavior and post-success navigation.
  final bool isSwitching;
  /// When set, skips the file picker and opens this URI directly.
  final String? prefillUri;
  final String? vaultName;

  @override
  ConsumerState<MasterPasswordSetupScreen> createState() => _State();
}

class _State extends ConsumerState<MasterPasswordSetupScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  // For the open-vault flow: file must be picked before password is entered.
  String? _selectedUri;
  String _selectedName = '';

  bool get _isSwitching => widget.isSwitching;
  // True when we need the user to pick a file first (i.e. no file was
  // pre-selected by the caller before navigating here).
  bool get _needsFilePick => !widget.isCreating && widget.prefillUri == null;

  @override
  void initState() {
    super.initState();
    if (widget.prefillUri != null) {
      _selectedUri = widget.prefillUri;
      _selectedName = widget.vaultName ?? 'Tresor';
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() { _loading = true; _error = null; });
    try {
      final uri = await SafStorage.pickKdbxFile();
      if (uri == null) {
        if (mounted) setState(() { _loading = false; _error = 'Keine Datei gewählt'; });
        return;
      }
      final info = await SafStorage.getFileInfo(uri);
      final name = (info?['name'] as String?) ?? 'vault.kdbx';
      if (mounted) {
        setState(() {
          _loading = false;
          _selectedUri = uri;
          _selectedName = name;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = 'Fehler: $e'; });
    }
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

      String vaultUri;
      String vaultName;

      if (widget.isCreating) {
        final uri = await SafStorage.createKdbxFile(AppConstants.defaultVaultName);
        if (uri == null) {
          setState(() { _loading = false; _error = 'Kein Speicherort gewählt'; });
          return;
        }
        vaultUri = uri;
        vaultName = AppConstants.defaultVaultName;
        await SyncStateNotifier.saveVaultUri(uri);
        await repo.create(vaultUri: uri, masterPassword: password);
        await keyManager.unlockWithPassword(password: password);
      } else {
        // Both switch and normal open: URI already selected
        vaultUri = _selectedUri!;
        vaultName = _selectedName;
        await SyncStateNotifier.saveVaultUri(vaultUri);
        await repo.open(vaultUri: vaultUri, masterPassword: password);
        await keyManager.unlockWithPassword(password: password);
      }

      await ref.read(vaultListProvider.notifier).add(VaultDescriptor(
        name: vaultName,
        uri: vaultUri,
        lastOpened: DateTime.now(),
      ));

      ref.read(vaultRevisionProvider.notifier).update((n) => n + 1);
      ref.read(sessionProvider.notifier).unlock();

      if (mounted) {
        // Switching vaults → skip biometric setup, go straight to vault
        context.go(_isSwitching ? Routes.vault : Routes.onboardingBiometric);
      }
    } catch (e) {
      debugPrint('Vault öffnen/erstellen fehlgeschlagen: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().contains('Wrong') ||
                  e.toString().contains('credentials') ||
                  e.toString().contains('Invalid')
              ? 'Falsches Master-Passwort'
              : e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isCreating
        ? 'Tresor erstellen'
        : (_isSwitching ? 'Tresor wechseln' : 'Tresor öffnen');

    return GradientScaffold(
      appBar: AppBar(
        title: Text(title),
        leading: BackButton(
          onPressed: () => _isSwitching
              ? context.pop()
              : context.go(Routes.onboardingWelcome),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
          child: _needsFilePick && _selectedUri == null
              ? _FilePickStep(
                  loading: _loading,
                  error: _error,
                  onPick: _pickFile,
                )
              : _PasswordStep(
                  isCreating: widget.isCreating,
                  isSwitching: _isSwitching,
                  vaultName: _selectedName,
                  passwordController: _passwordController,
                  confirmController: _confirmController,
                  loading: _loading,
                  error: _error,
                  onProceed: _proceed,
                  onPasswordChanged: () => setState(() {}),
                ),
        ),
      ),
    );
  }
}

class _FilePickStep extends StatelessWidget {
  const _FilePickStep({
    required this.loading,
    required this.error,
    required this.onPick,
  });

  final bool loading;
  final String? error;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tresor-Datei wählen', style: AppTypography.headlineMedium)
            .animate().fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 8),
        Text(
          'Wähle deine .kdbx-Datei aus. Das Passwort wird im nächsten Schritt abgefragt.',
          style: AppTypography.bodyMedium
              .copyWith(color: KPasswortColors.onSurfaceVariant, height: 1.5),
        ).animate(delay: 80.ms).fadeIn(),

        const SizedBox(height: 48),

        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: KPasswortColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: KPasswortColors.primary.withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.folder_open_outlined,
              color: KPasswortColors.primary,
              size: 48,
            ),
          ).animate(delay: 100.ms).scale(
              begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack),
        ),

        const SizedBox(height: 48),

        if (error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KPasswortColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: KPasswortColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: KPasswortColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(error!,
                      style: AppTypography.bodySmall
                          .copyWith(color: KPasswortColors.error)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: loading ? null : onPick,
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Icon(Icons.folder_open_outlined),
            label: Text(loading ? 'Wird geöffnet…' : '.kdbx-Datei auswählen'),
          ),
        ).animate(delay: 180.ms).fadeIn(),
      ],
    );
  }
}

class _PasswordStep extends StatelessWidget {
  const _PasswordStep({
    required this.isCreating,
    required this.isSwitching,
    required this.vaultName,
    required this.passwordController,
    required this.confirmController,
    required this.loading,
    required this.error,
    required this.onProceed,
    required this.onPasswordChanged,
  });

  final bool isCreating;
  final bool isSwitching;
  final String vaultName;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool loading;
  final String? error;
  final VoidCallback onProceed;
  final VoidCallback onPasswordChanged;

  @override
  Widget build(BuildContext context) {
    final headline = isCreating ? 'Master-Passwort wählen' : 'Master-Passwort eingeben';
    final subtitle = isCreating
        ? 'Dieses Passwort verschlüsselt deinen Tresor.\nVergiss es nicht — es kann nicht zurückgesetzt werden.'
        : 'Gib dein Master-Passwort für "$vaultName" ein.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isCreating && vaultName.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: KPasswortColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KPasswortColors.outline, width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded,
                    color: KPasswortColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(vaultName,
                      style: AppTypography.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 24),
        ],

        Text(headline, style: AppTypography.headlineMedium)
            .animate(delay: 50.ms).fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 8),
        Text(subtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: KPasswortColors.onSurfaceVariant,
              height: 1.5,
            )).animate(delay: 100.ms).fadeIn(),

        const SizedBox(height: 36),

        SecureTextField(
          controller: passwordController,
          label: 'Master-Passwort',
          isPassword: true,
          autofocus: true,
          onChanged: (_) => onPasswordChanged(),
        ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.08),

        if (isCreating) ...[
          const SizedBox(height: 16),
          PasswordStrengthIndicator(
            password: passwordController.text,
          ).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 16),
          SecureTextField(
            controller: confirmController,
            label: 'Passwort bestätigen',
            isPassword: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onProceed(),
          ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.08),
        ],

        if (error != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KPasswortColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: KPasswortColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: KPasswortColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(error!,
                      style: AppTypography.bodySmall
                          .copyWith(color: KPasswortColors.error)),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: loading ? null : onProceed,
            child: loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(isCreating ? 'Tresor erstellen' : 'Öffnen'),
          ),
        ).animate(delay: 300.ms).fadeIn(),
      ],
    );
  }
}
