import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_passwort/core/constants/crypto_constants.dart';
import 'package:k_passwort/features/generator/providers/generator_provider.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/ui/widgets/gradient_scaffold.dart';

class GeneratorScreen extends ConsumerStatefulWidget {
  const GeneratorScreen({super.key});

  @override
  ConsumerState<GeneratorScreen> createState() => _State();
}

class _State extends ConsumerState<GeneratorScreen> {
  bool _usePassphrase = false;

  Future<void> _copySecure(String text) async {
    const channel = MethodChannel(CryptoConstants.clipboardChannel);
    await channel.invokeMethod('copySecure', {
      'text': text,
      'clearAfterMs': CryptoConstants.clipboardClearDelayMs,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwort kopiert — wird in 30s geleert')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(generatorConfigProvider);
    final password = ref.watch(generatedPasswordProvider);

    return GradientScaffold(
      appBar: AppBar(title: const Text('Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Generated password display
            _PasswordDisplay(
              password: password,
              onCopy: () => _copySecure(password),
              onRefresh: () => ref.read(generatorConfigProvider.notifier).update(config),
            ).animate().fadeIn().scale(begin: const Offset(0.97, 0.97)),

            const SizedBox(height: 28),

            // Mode toggle
            Row(
              children: [
                Expanded(child: _ModeButton(
                  label: 'Passwort',
                  selected: !_usePassphrase,
                  onTap: () => setState(() => _usePassphrase = false),
                )),
                const SizedBox(width: 10),
                Expanded(child: _ModeButton(
                  label: 'Passphrase',
                  selected: _usePassphrase,
                  onTap: () => setState(() => _usePassphrase = true),
                )),
              ],
            ).animate(delay: 100.ms).fadeIn(),

            const SizedBox(height: 24),

            if (!_usePassphrase) ...[
              // Length slider
              Text('Länge: ${config.length}', style: AppTypography.labelMedium)
                  .animate(delay: 150.ms).fadeIn(),
              Slider(
                value: config.length.toDouble(),
                min: 8,
                max: 64,
                divisions: 56,
                onChanged: (v) => ref.read(generatorConfigProvider.notifier)
                    .update(config.copyWith(length: v.toInt())),
              ).animate(delay: 180.ms).fadeIn(),

              // Options
              _SwitchTile('Großbuchstaben (A-Z)', config.useUppercase,
                  (v) => ref.read(generatorConfigProvider.notifier)
                      .update(config.copyWith(useUppercase: v)))
                  .animate(delay: 220.ms).fadeIn(),
              _SwitchTile('Kleinbuchstaben (a-z)', config.useLowercase,
                  (v) => ref.read(generatorConfigProvider.notifier)
                      .update(config.copyWith(useLowercase: v)))
                  .animate(delay: 260.ms).fadeIn(),
              _SwitchTile('Zahlen (0-9)', config.useNumbers,
                  (v) => ref.read(generatorConfigProvider.notifier)
                      .update(config.copyWith(useNumbers: v)))
                  .animate(delay: 300.ms).fadeIn(),
              _SwitchTile('Sonderzeichen (!@#...)', config.useSymbols,
                  (v) => ref.read(generatorConfigProvider.notifier)
                      .update(config.copyWith(useSymbols: v)))
                  .animate(delay: 340.ms).fadeIn(),
              _SwitchTile('Mehrdeutige Zeichen ausschließen', config.excludeAmbiguous,
                  (v) => ref.read(generatorConfigProvider.notifier)
                      .update(config.copyWith(excludeAmbiguous: v)))
                  .animate(delay: 380.ms).fadeIn(),
            ],

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _copySecure(password),
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Passwort kopieren'),
              ),
            ).animate(delay: 420.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}

class _PasswordDisplay extends StatelessWidget {
  const _PasswordDisplay({
    required this.password,
    required this.onCopy,
    required this.onRefresh,
  });

  final String password;
  final VoidCallback onCopy;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KPasswortColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KPasswortColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          SelectableText(
            password,
            style: AppTypography.passwordLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                color: KPasswortColors.onSurfaceVariant,
                onPressed: onRefresh,
                tooltip: 'Neu generieren',
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                color: KPasswortColors.primary,
                onPressed: onCopy,
                tooltip: 'Kopieren',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? KPasswortColors.primary.withOpacity(0.15) : KPasswortColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? KPasswortColors.primary : KPasswortColors.outline,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: selected ? KPasswortColors.primary : KPasswortColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile(this.label, this.value, this.onChanged);

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label, style: AppTypography.bodyMedium),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
