import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark }

/// Hell/Dunkel theme mode. Defaults to dark (the app's original look).
class ThemeModeNotifier extends Notifier<AppThemeMode> {
  static const _key = 'app_theme_mode';

  @override
  AppThemeMode build() {
    _load();
    return AppThemeMode.dark;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value != null) {
      state = AppThemeMode.values.firstWhere(
        (m) => m.name == value,
        orElse: () => AppThemeMode.dark,
      );
    }
  }

  Future<void> setMode(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, AppThemeMode>(ThemeModeNotifier.new);

/// Custom background color override. `null` = use the theme mode's default.
class BackgroundColorNotifier extends Notifier<Color?> {
  static const _key = 'background_color';

  @override
  Color? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_key);
    if (value != null) state = Color(value);
  }

  Future<void> setColor(Color? color) async {
    state = color;
    final prefs = await SharedPreferences.getInstance();
    if (color == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setInt(_key, color.value);
    }
  }
}

final backgroundColorProvider =
    NotifierProvider<BackgroundColorNotifier, Color?>(BackgroundColorNotifier.new);

/// Font family override. `null` = platform default font ("System").
class FontFamilyNotifier extends Notifier<String?> {
  static const _key = 'font_family';
  static const defaultValue = 'Inter';

  @override
  String? build() {
    _load();
    return defaultValue;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_key)) return;
    final stored = prefs.getString(_key);
    state = (stored == null || stored.isEmpty) ? null : stored;
  }

  Future<void> setFamily(String? family) async {
    state = family;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, family ?? '');
  }
}

final fontFamilyProvider = NotifierProvider<FontFamilyNotifier, String?>(FontFamilyNotifier.new);

/// Font size scale multiplier (1.0 = default).
class FontScaleNotifier extends Notifier<double> {
  static const _key = 'font_scale';

  @override
  double build() {
    _load();
    return 1.0;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getDouble(_key);
    if (value != null) state = value;
  }

  Future<void> setScale(double scale) async {
    state = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, scale);
  }
}

final fontScaleProvider = NotifierProvider<FontScaleNotifier, double>(FontScaleNotifier.new);

/// Custom text color override. `null` = use the theme-driven default.
class FontColorNotifier extends Notifier<Color?> {
  static const _key = 'font_color';

  @override
  Color? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_key);
    if (value != null) state = Color(value);
  }

  Future<void> setColor(Color? color) async {
    state = color;
    final prefs = await SharedPreferences.getInstance();
    if (color == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setInt(_key, color.value);
    }
  }
}

final fontColorProvider = NotifierProvider<FontColorNotifier, Color?>(FontColorNotifier.new);
