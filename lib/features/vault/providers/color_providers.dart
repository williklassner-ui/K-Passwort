import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kPresetColors = <int>[
  0xFFEF5350,
  0xFFFF9800,
  0xFFFFEB3B,
  0xFF4CAF50,
  0xFF009688,
  0xFF2196F3,
  0xFF9C27B0,
  0xFFE91E63,
];

class TagColorsNotifier extends Notifier<Map<String, int>> {
  static const _key = 'kpasswort_tag_colors';

  @override
  Map<String, int> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return;
    final map = (jsonDecode(json) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v as int));
    state = map;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state));
  }

  Future<void> setColor(String tagName, int colorValue) async {
    final next = Map<String, int>.from(state);
    if (colorValue == 0) {
      next.remove(tagName);
    } else {
      next[tagName] = colorValue;
    }
    state = next;
    await _save();
  }
}

class GroupColorsNotifier extends Notifier<Map<String, int>> {
  static const _key = 'kpasswort_group_colors';

  @override
  Map<String, int> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return;
    final map = (jsonDecode(json) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v as int));
    state = map;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state));
  }

  Future<void> setColor(String groupId, int colorValue) async {
    final next = Map<String, int>.from(state);
    if (colorValue == 0) {
      next.remove(groupId);
    } else {
      next[groupId] = colorValue;
    }
    state = next;
    await _save();
  }
}

final tagColorsProvider =
    NotifierProvider<TagColorsNotifier, Map<String, int>>(TagColorsNotifier.new);

final groupColorsProvider =
    NotifierProvider<GroupColorsNotifier, Map<String, int>>(
        GroupColorsNotifier.new);
