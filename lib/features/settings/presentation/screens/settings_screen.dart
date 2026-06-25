import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:k_passwort/core/constants/crypto_constants.dart';
import 'package:k_passwort/core/constants/route_constants.dart';
import 'package:k_passwort/data/storage/saf_storage.dart';
import 'package:k_passwort/features/settings/providers/theme_provider.dart';
import 'package:k_passwort/features/vault/providers/vault_list_provider.dart';
import 'package:k_passwort/security/biometric/biometric_service.dart';
import 'package:k_passwort/security/keystore/master_key_manager.dart';
import 'package:k_passwort/security/keystore/session_manager.dart';
import 'package:k_passwort/sync/saf_sync_service.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/ui/widgets/gradient_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _State();
}

class _State extends ConsumerState<SettingsScreen> {
  bool _biometricEnabled = false;
  String? _vaultUri;
  final _bioService = BiometricService();
  bool _biometricAvailable = false;
  bool _screenshotBlocked = false;
  int _autoLockMs = CryptoConstants.autoLockDelayMs;
  bool _lockOnScreenOff = false;

  static const _screenshotKey = 'screenshot_blocked';
  static const _secureChannel = MethodChannel(CryptoConstants.secureScreenChannel);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final keyManager = ref.read(masterKeyManagerProvider);
    final bioEnabled = await keyManager.isBiometricEnabled();
    final bioAvail = await _bioService.isAvailable();
    final uri = await SyncStateNotifier.getSavedVaultUri();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricEnabled = bioEnabled;
      _biometricAvailable = bioAvail;
      _vaultUri = uri;
      _screenshotBlocked = prefs.getBool(_screenshotKey) ?? false;
      _autoLockMs = prefs.getInt('auto_lock_ms') ?? CryptoConstants.autoLockDelayMs;
      _lockOnScreenOff = prefs.getBool('lock_on_screen_off') ?? false;
    });
  }

  Future<void> _toggleScreenshotBlock(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_screenshotKey, value);
    await _secureChannel.invokeMethod('setSecureScreen', {'enabled': value});
    setState(() => _screenshotBlocked = value);
  }

  Future<void> _changeSyncPath() async {
    final uri = await SafStorage.pickKdbxFile();
    if (uri == null) return;
    await SyncStateNotifier.saveVaultUri(uri);
    setState(() => _vaultUri = uri);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync-Pfad aktualisiert')),
      );
    }
  }

  Future<void> _openAutofillSettings() async {
    const channel = MethodChannel(CryptoConstants.autofillChannel);
    await channel.invokeMethod('openAutofillSettings');
  }

  Future<void> _showAutoLockPicker() async {
    const options = [
      (-1, 'Nie'),
      (0, 'Sofort'),
      (30000, '30 Sekunden'),
      (60000, '1 Minute'),
      (300000, '5 Minuten'),
      (900000, '15 Minuten'),
      (1800000, '30 Minuten'),
      (3600000, '1 Stunde'),
    ];
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Auto-Sperre',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...options.map((opt) => RadioListTile<int>(
                  title: Text(opt.$2),
                  value: opt.$1,
                  groupValue: _autoLockMs,
                  onChanged: (v) async {
                    Navigator.pop(ctx);
                    final session = ref.read(sessionProvider.notifier);
                    await session.setAutoLockMs(v!);
                    setState(() => _autoLockMs = v);
                  },
                )),
          ],
        ),
      ),
    );
  }

  String _autoLockLabel(int ms) {
    if (ms < 0) return 'Nie';
    if (ms == 0) return 'Sofort';
    if (ms < 60000) return '${ms ~/ 1000} Sekunden';
    if (ms < 3600000) {
      final mins = ms ~/ 60000;
      return '$mins Minute${mins > 1 ? "n" : ""}';
    }
    return '1 Stunde';
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 80, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader('Erscheinungsbild').animate().fadeIn(),

            _ColorPickerTile().animate(delay: 20.ms).fadeIn(),

            const SizedBox(height: 24),
            _SectionHeader('Sicherheit').animate(delay: 40.ms).fadeIn(),

            _SettingsTile(
              icon: Icons.fingerprint_rounded,
              title: 'Biometrisches Entsperren',
              subtitle: _biometricAvailable ? null : 'Auf diesem Gerät nicht verfügbar',
              trailing: _biometricAvailable
                  ? Switch(
                      value: _biometricEnabled,
                      onChanged: (v) async {
                        final keyManager = ref.read(masterKeyManagerProvider);
                        if (v) {
                          await keyManager.enableBiometric();
                        } else {
                          await keyManager.disableBiometric();
                        }
                        setState(() => _biometricEnabled = v);
                      },
                    )
                  : null,
            ).animate(delay: 50.ms).fadeIn(),

            _SettingsTile(
              icon: Icons.no_photography_outlined,
              title: 'Screenshots sperren',
              subtitle: 'Verhindert Screenshots und Screen-Recording',
              trailing: Switch(
                value: _screenshotBlocked,
                onChanged: _toggleScreenshotBlock,
              ),
            ).animate(delay: 80.ms).fadeIn(),

            _SettingsTile(
              icon: Icons.lock_clock_outlined,
              title: 'Auto-Sperre',
              subtitle: _autoLockLabel(_autoLockMs),
              trailing: const Icon(Icons.chevron_right_rounded, size: 18),
              onTap: _showAutoLockPicker,
            ).animate(delay: 100.ms).fadeIn(),

            _SettingsTile(
              icon: Icons.screen_lock_portrait_outlined,
              title: 'Bei Display aus sperren',
              subtitle: 'Sofort sperren wenn Display ausgeht',
              trailing: Switch(
                value: _lockOnScreenOff,
                onChanged: (v) async {
                  await ref.read(sessionProvider.notifier).setLockOnScreenOff(v);
                  setState(() => _lockOnScreenOff = v);
                },
              ),
            ).animate(delay: 120.ms).fadeIn(),

            const SizedBox(height: 24),
            _SectionHeader('Sync').animate(delay: 150.ms).fadeIn(),

            _SettingsTile(
              icon: Icons.folder_outlined,
              title: 'Tresor-Speicherort',
              subtitle: _vaultUri != null
                  ? _vaultUri!.length > 50
                      ? '…${_vaultUri!.substring(_vaultUri!.length - 50)}'
                      : _vaultUri
                  : 'Kein Pfad gesetzt',
              onTap: _changeSyncPath,
            ).animate(delay: 200.ms).fadeIn(),

            _SettingsTile(
              icon: Icons.cloud_sync_outlined,
              title: 'Sync-Anleitung',
              subtitle: 'Datei in Google Drive-Ordner ablegen',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    title: const Text('Google Drive Sync'),
                    content: const Text(
                      '1. Tresor-Speicherort auf einen Google Drive Ordner setzen\n\n'
                      '2. Die Google Drive App synchronisiert die .kdbx-Datei automatisch\n\n'
                      '3. Auf einem zweiten Gerät dieselbe Datei öffnen\n\n'
                      'Kein Account in K-Passwort notwendig — deine Cloud-App übernimmt die Synchronisierung.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ).animate(delay: 250.ms).fadeIn(),

            const SizedBox(height: 24),
            _SectionHeader('Autofill').animate(delay: 300.ms).fadeIn(),

            _SettingsTile(
              icon: Icons.auto_fix_high_rounded,
              title: 'Autofill-Dienst aktivieren',
              subtitle: 'In Android-Einstellungen öffnen',
              onTap: _openAutofillSettings,
              trailing: const Icon(Icons.open_in_new_rounded, size: 16),
            ).animate(delay: 350.ms).fadeIn(),

            const SizedBox(height: 24),
            _SectionHeader('Datenbanken').animate(delay: 360.ms).fadeIn(),

            _VaultListSection().animate(delay: 370.ms).fadeIn(),

            const SizedBox(height: 8),

            _SettingsTile(
              icon: Icons.add_rounded,
              title: 'Neue Datenbank öffnen',
              subtitle: '.kdbx-Datei hinzufügen',
              onTap: () => context.go(Routes.onboardingOpenVault),
            ).animate(delay: 390.ms).fadeIn(),

            _SettingsTile(
              icon: Icons.create_new_folder_outlined,
              title: 'Neue Datenbank erstellen',
              onTap: () => context.go(Routes.onboardingCreateVault),
            ).animate(delay: 395.ms).fadeIn(),

            const SizedBox(height: 24),
            _SectionHeader('Sitzung').animate(delay: 400.ms).fadeIn(),

            _SettingsTile(
              icon: Icons.logout_rounded,
              title: 'Tresor sperren',
              titleColor: KPasswortColors.error,
              onTap: () {
                ref.read(sessionProvider.notifier).lock();
                context.go(Routes.lock);
              },
            ).animate(delay: 450.ms).fadeIn(),

            const SizedBox(height: 32),
            Center(
              child: Text(
                'K-Passwort Beta 0.5 — KDBX 4.x kompatibel',
                style: AppTypography.bodySmall,
              ).animate(delay: 500.ms).fadeIn(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorPickerTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(themeProvider);
    const colors = [
      Color(0xFF00C6A0), // Teal (original)
      Color(0xFFFF9500), // Orange
      Color(0xFF0A84FF), // Blue
      Color(0xFFBF5AF2), // Purple
      Color(0xFFFF453A), // Red
      Color(0xFF32D74B), // Green
      Color(0xFFFFD60A), // Yellow
      Color(0xFFFF2D55), // Pink
      Color(0xFF64D2FF), // Cyan
      Color(0xFF30D158), // Lime green
      Color(0xFF5E5CE6), // Indigo
      Color(0xFFFFBF00), // Amber
      Color(0xFFFF6B00), // Deep Orange
      Color(0xFF50C2C9), // Light Blue
      Color(0xFF00DDB3), // Teal Accent
      Color(0xFFF2F2F7), // White
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: colors.map((c) {
          final selected = accent.value == c.value;
          return GestureDetector(
            onTap: () => ref.read(themeProvider.notifier).setColor(c),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: selected ? Border.all(color: Colors.white, width: 3) : null,
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, size: 20, color: Colors.white)
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _VaultListSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaults = ref.watch(vaultListProvider);
    if (vaults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Text(
          'Noch keine Datenbanken gespeichert.',
          style: AppTypography.bodySmall,
        ),
      );
    }
    final fmt = DateFormat('dd.MM.yyyy');
    return Column(
      children: vaults.map((v) {
        return ListTile(
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: KPasswortColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock_outline_rounded,
                color: KPasswortColors.primary, size: 20),
          ),
          title: Text(v.name, style: AppTypography.bodyMedium),
          subtitle: Text(
            'Zuletzt geöffnet: ${fmt.format(v.lastOpened)}',
            style: AppTypography.bodySmall,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  final uri = Uri(
                    path: Routes.switchVault,
                    queryParameters: {'uri': v.uri, 'name': v.name},
                  );
                  context.go(uri.toString());
                },
                child: const Text('Wechseln'),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded, size: 18),
                color: KPasswortColors.error,
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      title: const Text('Datenbank entfernen?'),
                      content: Text(
                        '"${v.name}" wird aus der Liste entfernt.\nDie Datei selbst wird nicht gelöscht.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx, false),
                          child: const Text('Abbrechen'),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: KPasswortColors.error),
                          onPressed: () => Navigator.pop(dialogCtx, true),
                          child: const Text('Entfernen'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref.read(vaultListProvider.notifier).remove(v.uri);
                  }
                },
              ),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      }).toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall
            .copyWith(color: KPasswortColors.primary, letterSpacing: 1.2),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: KPasswortColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: titleColor ?? KPasswortColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(color: titleColor),
      ),
      subtitle: subtitle != null ? Text(subtitle!, style: AppTypography.bodySmall) : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right_rounded,
                  color: KPasswortColors.onSurfaceVariant, size: 20)
              : null),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
