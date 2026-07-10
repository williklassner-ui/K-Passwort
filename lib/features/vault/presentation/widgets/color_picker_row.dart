import 'package:flutter/material.dart';
import 'package:k_passwort/features/vault/providers/color_providers.dart';

class ColorPickerRow extends StatelessWidget {
  const ColorPickerRow({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _swatch(
          context,
          color: 0,
          primary: primary,
          child: Icon(Icons.block_rounded, size: 14, color: Colors.grey.shade400),
        ),
        ...kPresetColors.map((c) => _swatch(context, color: c, primary: primary)),
      ],
    );
  }

  Widget _swatch(
    BuildContext context, {
    required int color,
    required Color primary,
    Widget? child,
  }) {
    final isSelected = selected == color;
    return GestureDetector(
      onTap: () => onChanged(color),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color == 0
              ? Theme.of(context).colorScheme.surfaceVariant
              : Color(color),
          border: Border.all(
            color: isSelected ? primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: isSelected && child == null
            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
            : child,
      ),
    );
  }
}
