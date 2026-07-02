import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Retention period (in days) for trashed entries before they're purged
/// automatically on unlock. `null` = keep forever (default).
class TrashRetentionNotifier extends Notifier<int?> {
  static const _key = 'trash_retention_days';

  @override
  int? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_key);
    if (value != null && value > 0) state = value;
  }

  /// Sets the retention period in days, or `null` for unlimited.
  Future<void> setDays(int? days) async {
    state = days;
    final prefs = await SharedPreferences.getInstance();
    if (days == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setInt(_key, days);
    }
  }
}

final trashRetentionDaysProvider =
    NotifierProvider<TrashRetentionNotifier, int?>(TrashRetentionNotifier.new);
