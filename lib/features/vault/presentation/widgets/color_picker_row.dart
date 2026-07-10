import 'package:flutter/material.dart';
import 'package:k_passwort/features/vault/providers/color_providers.dart';

class ColorPickerRow extends StatelessWidget {
  const ColorPickerRow({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final int selectedColor;
  final ValueChanged<int> onColorSelected;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _swatch(
          context,
          color: 0,
          primary: primary,
          child: Icon(Icons.block_rounded, size: 14, color: Colors.grey.shade400),
        ),
        ...kPresetColors.map(
          (c) => _swatch(context, color: c, primary: primary),
        ),
      ],
    );
  }

  Widget _swatch(BuildContext context, {required int color, required Color primary, Widget? child}) {
    final isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () => onColorSelected(color),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color == 0 ? null : Color(color),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? primary : (color == 0 ? Colors.grey.shade400 : Colors.transparent),
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: child ??
            (isSelected
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : null),
      ),
    );
  }
}
