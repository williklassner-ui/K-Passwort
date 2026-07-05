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

              const Spacer(flex: 3),

              // Actions — größer, vertikal mittig
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () => context.go(Routes.onboardingCreateVault),
                  style: ElevatedButton.styleFrom(
                    textStyle: AppTypography.labelLarge.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Neuen Tresor erstellen'),
                ),
              )
                  .animate(delay: 700.ms)
                  .fadeIn()
                  .slideY(begin: 0.1),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 64,
                child: OutlinedButton(
                  onPressed: () => pickAndOpenExistingVault(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: KPasswortColors.outline),
                    foregroundColor: KPasswortColors.onBackground,
                    textStyle: AppTypography.labelLarge.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
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

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
