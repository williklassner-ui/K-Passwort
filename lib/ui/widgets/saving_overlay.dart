import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';

/// Full-screen backdrop shown while a vault write (encode + SAF write) is
/// in flight, so slow saves don't look like a frozen app.
class SavingOverlay extends StatelessWidget {
  const SavingOverlay({super.key, this.label = 'Wird gespeichert…'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withOpacity(0.55),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent, width: 2.5),
                ),
                child: Icon(Icons.lock_rounded, color: accent, size: 28),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1.05, 1.05),
                    duration: 700.ms,
                    curve: Curves.easeInOut,
                  )
                  .fadeIn(duration: 700.ms),
              const SizedBox(height: 20),
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: KPasswortColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
