import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_passwort/core/constants/route_constants.dart';
import 'package:k_passwort/security/biometric/biometric_service.dart';
import 'package:k_passwort/security/keystore/master_key_manager.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/ui/widgets/gradient_scaffold.dart';

class BiometricSetupScreen extends ConsumerStatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  ConsumerState<BiometricSetupScreen> createState() => _State();
}

class _State extends ConsumerState<BiometricSetupScreen> {
  final _bioService = BiometricService();
  bool _loading = false;
  String? _error;

  Future<void> _enable() async {
    setState(() { _loading = true; _error = null; });
    try {
      final keyManager = ref.read(masterKeyManagerProvider);
      await keyManager.enableBiometric();
      if (mounted) context.go(Routes.vault);
    } catch (e) {
      setState(() { _loading = false; _error = 'Biometrik konnte nicht aktiviert werden: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('Biometrisches Entsperren')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: KPasswortColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: KPasswortColors.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  color: KPasswortColors.primary,
                  size: 52,
                ),
              )
                  .animate()
                  .scale(begin: const Offset(0.7, 0.7), duration: 600.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 32),

              Text(
                'Schneller entsperren',
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
              ).animate(delay: 200.ms).fadeIn(),

              const SizedBox(height: 12),

              Text(
                'Verwende Fingerabdruck oder Gesicht\nstatt dem Master-Passwort.',
                style: AppTypography.bodyMedium.copyWith(
                  color: KPasswortColors.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 300.ms).fadeIn(),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _error!,
                    style: AppTypography.bodySmall.copyWith(color: KPasswortColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),

              const Spacer(flex: 3),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _enable,
                  icon: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.fingerprint_rounded),
                  label: const Text('Biometrik aktivieren'),
                ),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1),

              const SizedBox(height: 14),

              TextButton(
                onPressed: () => context.go(Routes.vault),
                child: const Text('Überspringen'),
              ).animate(delay: 480.ms).fadeIn(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
