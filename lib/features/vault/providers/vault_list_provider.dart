import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VaultDescriptor {
  VaultDescriptor({
    required this.name,
    required this.uri,
    required this.lastOpened,
  });

  final String name;
  final String uri;
  final DateTime lastOpened;

  Map<String, dynamic> toJson() => {
        'name': name,
        'uri': uri,
        'lastOpened': lastOpened.toIso8601String(),
      };

  factory VaultDescriptor.fromJson(Map<String, dynamic> json) => VaultDescriptor(
        name: json['name'] as String,
        uri: json['uri'] as String,
        lastOpened: DateTime.parse(json['lastOpened'] as String),
      );
}

class VaultListNotifier extends Notifier<List<VaultDescriptor>> {
  static const _key = 'kpasswort_vault_list';

  @override
  List<VaultDescriptor> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => VaultDescriptor.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.map((v) => v.toJson()).toList()));
  }

  Future<void> add(VaultDescriptor vault) async {
    state = [
      ...state.where((v) => v.uri != vault.uri),
      vault,
    ];
    await _save();
  }

  Future<void> remove(String uri) async {
    state = state.where((v) => v.uri != uri).toList();
    await _save();
  }

  Future<void> updateName(String uri, String name) async {
    state = state.map((v) => v.uri == uri
        ? VaultDescriptor(name: name, uri: v.uri, lastOpened: v.lastOpened)
        : v).toList();
    await _save();
  }

  Future<void> setLastOpened(String uri) async {
    state = state.map((v) => v.uri == uri
        ? VaultDescriptor(name: v.name, uri: v.uri, lastOpened: DateTime.now())
        : v).toList();
    await _save();
  }
}

final vaultListProvider =
    NotifierProvider<VaultListNotifier, List<VaultDescriptor>>(
  VaultListNotifier.new,
);
