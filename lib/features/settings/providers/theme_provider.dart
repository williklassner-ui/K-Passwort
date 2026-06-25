import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends Notifier<Color> {
  static const _key = 'accent_color';
  static const defaultColor = Color(0xFF00C6A0); // Teal (original brand)

  @override
  Color build() {
    _load();
    return defaultColor;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_key);
    if (value != null) state = Color(value);
  }

  Future<void> setColor(Color color) async {
    state = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, color.value);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, Color>(ThemeNotifier.new);
