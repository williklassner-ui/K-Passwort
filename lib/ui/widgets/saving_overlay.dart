import 'package:flutter/material.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/ui/widgets/pulsing_light.dart';

/// Full-screen backdrop shown while a vault write (encode + SAF write) is
/// in flight, so slow saves don't look like a frozen app. The encode/write
/// itself runs off the main isolate (see KdbxVault._runOffMainIsolate), so
/// this animation keeps pulsing smoothly for the whole duration instead of
/// freezing along with a blocked UI thread.
class SavingOverlay extends StatelessWidget {
  const SavingOverlay({super.key, this.label = 'Wird gespeichert…'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withOpacity(0.55),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PulsingLight(size: 48),
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
