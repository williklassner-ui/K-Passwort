import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';

/// A softly glowing, pulsing light used in place of a spinner for
/// long-running operations (KDF derivation, KDBX encode/decrypt) where the
/// UI thread can stall for several seconds — a standard [CircularProgressIndicator]
/// would freeze along with it and make the app look hung. This animation is
/// driven independently and keeps pulsing reliably as long as the widget is
/// on screen, so the user can see the app is still working.
class PulsingLight extends StatelessWidget {
  const PulsingLight({
    super.key,
    this.size = 20,
    this.color = KPasswortColors.strengthFair,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.85),
            blurRadius: size * 0.9,
            spreadRadius: size * 0.15,
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.78, 0.78),
          end: const Offset(1.18, 1.18),
          duration: 650.ms,
          curve: Curves.easeInOut,
        )
        .fadeIn(duration: 650.ms, begin: 0.5);
  }
}
