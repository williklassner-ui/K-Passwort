import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:k_passwort/core/constants/route_constants.dart';
import 'package:k_passwort/core/utils/vault_open_flow.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/ui/widgets/glass_card.dart';
import 'package:k_passwort/ui/widgets/gradient_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // Logo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: KPasswortColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: KPasswortColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: KPasswortColors.primary,
                  size: 36,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 32),

              Text('K-Passwort', style: AppTypography.headlineLarge)
                  .animate(delay: 150.ms)
                  .fadeIn()
                  .slideY(begin: 0.1),

              const SizedBox(height: 12),

              Text(
                'Dein sicherer, privater Passwort-Tresor.\nKeePass-kompatibel, kein Cloud-Account.',
                style: AppTypography.bodyLarge.copyWith(
                  color: KPasswortColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.1),

              const Spacer(flex: 2),

              // Feature list
              ..._features.asMap().entries.map((e) =>
                _FeatureTile(icon: e.value.$1, label: e.value.$2)
                    .animate(delay: (350 + e.key * 80).ms)
                    .fadeIn()
                    .slideX(begin: -0.05)
              ),

              const Spacer(flex: 3),

              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(Routes.onboardingCreateVault),
                  child: const Text('Neuen Tresor erstellen'),
                ),
              )
                  .animate(delay: 700.ms)
                  .fadeIn()
                  .slideY(begin: 0.1),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => pickAndOpenExistingVault(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    side: BorderSide(color: KPasswortColors.outline),
                    foregroundColor: KPasswortColors.onBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Vorhandene .kdbx öffnen'),
                ),
              )
                  .animate(delay: 780.ms)
                  .fadeIn()
                  .slideY(begin: 0.1),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  static const _features = [
    (Icons.lock_outline_rounded, 'AES-256 + Argon2id Verschlüsselung'),
    (Icons.sync_rounded, 'Sync via Google Drive — kein Account'),
    (Icons.fingerprint_rounded, 'Biometrisches Entsperren'),
    (Icons.auto_fix_high_outlined, 'Android Autofill'),
  ];
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: KPasswortColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: KPasswortColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Text(label, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
