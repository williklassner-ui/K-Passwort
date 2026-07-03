import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_passwort/core/constants/route_constants.dart';
import 'package:k_passwort/features/settings/providers/appearance_provider.dart';
import 'package:k_passwort/features/settings/providers/theme_provider.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/ui/widgets/gradient_scaffold.dart';

class DesignScreen extends ConsumerWidget {
  const DesignScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 16;
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Design'),
        leading: BackButton(onPressed: () => context.go(Routes.settings)),
      ),
      body: FocusTraversalGroup(
        policy: ReadingOrderTraversalPolicy(),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, topPadding, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader('Erscheinungsbild').animate().fadeIn(),
              _ThemeModeSelector().animate(delay: 10.ms).fadeIn(),

              _SectionHeader('Akzentfarbe').animate(delay: 15.ms).fadeIn(),
              _AccentColorPicker().animate(delay: 20.ms).fadeIn(),

              _SectionHeader('Hintergrundfarbe').animate(delay: 25.ms).fadeIn(),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: Text(
                  'Optional — überschreibt das Standard-Hintergrundfarbe des Themes',
                  style: AppTypography.bodySmall,
                ),
              ).animate(delay: 28.ms).fadeIn(),
              _OptionalColorPickerTile(
                current: ref.watch(backgroundColorProvider),
                onChanged: (c) => ref.read(backgroundColorProvider.notifier).setColor(c),
              ).animate(delay: 30.ms).fadeIn(),

              _SectionHeader('Schriftart').animate(delay: 35.ms).fadeIn(),
              _FontFamilyPicker().animate(delay: 40.ms).fadeIn(),

              _SectionHeader('Schriftgröße').animate(delay: 45.ms).fadeIn(),
              _FontScalePicker().animate(delay: 50.ms).fadeIn(),

              _SectionHeader('Schriftfarbe').animate(delay: 55.ms).fadeIn(),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: Text(
                  'Optional — überschreibt die Standard-Textfarbe',
                  style: AppTypography.bodySmall,
                ),
              ).animate(delay: 58.ms).fadeIn(),
              _OptionalColorPickerTile(
                current: ref.watch(fontColorProvider),
                onChanged: (c) => ref.read(fontColorProvider.notifier).setColor(c),
              ).animate(delay: 60.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall
            .copyWith(color: KPasswortColors.primary, letterSpacing: 1.2),
      ),
    );
  }
}

class _ThemeModeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SegmentedButton<AppThemeMode>(
        segments: const [
          ButtonSegment(
            value: AppThemeMode.dark,
            label: Text('Dunkel'),
            icon: Icon(Icons.dark_mode_outlined, size: 18),
          ),
          ButtonSegment(
            value: AppThemeMode.light,
            label: Text('Hell'),
            icon: Icon(Icons.light_mode_outlined, size: 18),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (selection) {
          ref.read(themeModeProvider.notifier).setMode(selection.first);
        },
      ),
    );
  }
}

class _AccentColorPicker extends ConsumerWidget {
  static const _colors = [
    // Original palette
    Color(0xFF00C6A0), // Teal
    Color(0xFFFF9500), // Orange
    Color(0xFF0A84FF), // Blue
    Color(0xFFBF5AF2), // Purple
    Color(0xFFFF453A), // Red
    Color(0xFF32D74B), // Green
    Color(0xFFFFD60A), // Yellow
    Color(0xFFFF2D55), // Pink
    Color(0xFF64D2FF), // Cyan
    Color(0xFF30D158), // Lime Green
    Color(0xFF5E5CE6), // Indigo
    Color(0xFFFFBF00), // Amber
    Color(0xFFFF6B00), // Deep Orange
    Color(0xFF50C2C9), // Light Blue
    Color(0xFF00DDB3), // Teal Accent
    Color(0xFFF2F2F7), // White
    // Neue Farben
    Color(0xFFFFD700), // Gold
    Color(0xFF00E5CC), // Mint
    Color(0xFFFF6B6B), // Coral
    Color(0xFFFF00FF), // Magenta
    Color(0xFF003087), // Navy
    Color(0xFF6B8E23), // Olive
    Color(0xFFCD5C5C), // Terracotta
    Color(0xFF4682B4), // Steel Blue
    Color(0xFFFF1493), // Deep Pink
    Color(0xFF7FFF00), // Chartreuse
    Color(0xFF8B0000), // Dark Red
    Color(0xFF20B2AA), // Light Sea Green
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(themeProvider);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _colors.map((c) {
        final selected = accent.value == c.value;
        return GestureDetector(
          onTap: () => ref.read(themeProvider.notifier).setColor(c),
          child: Focus(
            child: Builder(builder: (ctx) {
              final focused = Focus.of(ctx).hasFocus;
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? Colors.white
                        : focused
                            ? KPasswortColors.primary
                            : Colors.transparent,
                    width: selected || focused ? 3 : 0,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded, size: 20, color: Colors.white)
                    : null,
              );
            }),
          ),
        );
      }).toList(),
    );
  }
}

class _OptionalColorPickerTile extends StatelessWidget {
  const _OptionalColorPickerTile({required this.current, required this.onChanged});

  final Color? current;
  final ValueChanged<Color?> onChanged;

  static const _colors = [
    Color(0xFF00C6A0),
    Color(0xFFFF9500),
    Color(0xFF0A84FF),
    Color(0xFFBF5AF2),
    Color(0xFFFF453A),
    Color(0xFF32D74B),
    Color(0xFFFFD60A),
    Color(0xFF64D2FF),
    Color(0xFF1C1C1E),
    Color(0xFFFFFFFF),
    Color(0xFFFFD700),
    Color(0xFF003087),
    Color(0xFF4682B4),
    Color(0xFF8B4513),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _swatch(
          color: KPasswortColors.surfaceVariant,
          selected: current == null,
          onTap: () => onChanged(null),
          child: Icon(Icons.not_interested_rounded,
              size: 18, color: KPasswortColors.onSurfaceVariant),
        ),
        ..._colors.map((c) => _swatch(
              color: c,
              selected: current?.value == c.value,
              onTap: () => onChanged(c),
            )),
      ],
    );
  }

  Widget _swatch({
    required Color color,
    required bool selected,
    required VoidCallback onTap,
    Widget? child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? KPasswortColors.onSurface : KPasswortColors.outline,
            width: selected ? 3 : 1,
          ),
        ),
        child: selected
            ? Icon(Icons.check_rounded,
                size: 18,
                color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white)
            : child,
      ),
    );
  }
}

class _FontFamilyPicker extends ConsumerWidget {
  static const _fonts = <(String?, String, String)>[
    ('Inter', 'Inter', 'Standard — sauber & modern'),
    ('JetBrainsMono', 'JetBrains Mono', 'Monospace — ideal für Codes'),
    ('sans-serif', 'Roboto', 'Android Standard-Schrift'),
    ('sans-serif-light', 'Roboto Light', 'Leicht & luftig'),
    ('sans-serif-condensed', 'Roboto Condensed', 'Kompakt & platzsparend'),
    ('serif', 'Serif', 'Klassische Serifenschrift'),
    ('monospace', 'Monospace', 'Systemweite Festbreitenschrift'),
    ('cursive', 'Kursiv', 'Handschrift-Stil'),
    (null, 'System', 'Standard-Systemschrift'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(fontFamilyProvider);
    return Column(
      children: _fonts.map((opt) {
        final selected = current == opt.$1;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: Text(
            opt.$2,
            style: TextStyle(
              fontFamily: opt.$1,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? KPasswortColors.primary : KPasswortColors.onSurface,
            ),
          ),
          subtitle: Text(opt.$3, style: AppTypography.bodySmall),
          trailing: selected
              ? Icon(Icons.check_circle_rounded, color: KPasswortColors.primary)
              : null,
          onTap: () => ref.read(fontFamilyProvider.notifier).setFamily(opt.$1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tileColor: selected ? KPasswortColors.primary.withOpacity(0.08) : null,
        );
      }).toList(),
    );
  }
}

class _FontScalePicker extends ConsumerWidget {
  static const _scales = <(double, String)>[
    (0.85, '85% — Klein'),
    (0.9, '90% — Etwas kleiner'),
    (1.0, '100% — Standard'),
    (1.1, '110% — Etwas größer'),
    (1.15, '115% — Größer'),
    (1.2, '120% — Deutlich größer'),
    (1.3, '130% — Sehr groß'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(fontScaleProvider);
    return Column(
      children: _scales.map((opt) {
        final selected = (current - opt.$1).abs() < 0.001;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: Text(
            opt.$2,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 14 * opt.$1,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? KPasswortColors.primary : KPasswortColors.onSurface,
            ),
          ),
          trailing: selected
              ? Icon(Icons.check_circle_rounded, color: KPasswortColors.primary)
              : null,
          onTap: () => ref.read(fontScaleProvider.notifier).setScale(opt.$1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tileColor: selected ? KPasswortColors.primary.withOpacity(0.08) : null,
        );
      }).toList(),
    );
  }
}
