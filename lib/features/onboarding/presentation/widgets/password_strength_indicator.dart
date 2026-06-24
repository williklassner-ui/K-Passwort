import 'package:flutter/material.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:zxcvbn/zxcvbn.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final result = Zxcvbn().evaluate(password);
    final score = (result.score ?? 0).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: i < score ? _color(score) : KPasswortColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          _label(score),
          style: AppTypography.labelSmall.copyWith(color: _color(score)),
        ),
      ],
    );
  }

  Color _color(int score) {
    switch (score) {
      case 0: return KPasswortColors.strengthWeak;
      case 1: return KPasswortColors.strengthFair;
      case 2: return KPasswortColors.strengthGood;
      case 3: return KPasswortColors.strengthStrong;
      default: return KPasswortColors.strengthVeryStrong;
    }
  }

  String _label(int score) {
    switch (score) {
      case 0: return 'Sehr schwach';
      case 1: return 'Schwach';
      case 2: return 'Mittel';
      case 3: return 'Stark';
      default: return 'Sehr stark';
    }
  }
}
