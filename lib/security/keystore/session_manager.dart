import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:k_passwort/core/constants/crypto_constants.dart';
import 'package:k_passwort/security/keystore/master_key_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SessionState { locked, unlocked }

class SessionNotifier extends Notifier<SessionState> with WidgetsBindingObserver {
  Timer? _lockTimer;
  int _autoLockMs = CryptoConstants.autoLockDelayMs;
  bool _lockOnScreenOff = false;

  static const _autoLockKey = 'auto_lock_ms';
  static const _screenOffKey = 'lock_on_screen_off';

  @override
  SessionState build() {
    WidgetsBinding.instance.addObserver(this);
    _loadPrefs();
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _lockTimer?.cancel();
    });
    return SessionState.locked;
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _autoLockMs = prefs.getInt(_autoLockKey) ?? CryptoConstants.autoLockDelayMs;
    _lockOnScreenOff = prefs.getBool(_screenOffKey) ?? false;
  }

  Future<void> setAutoLockMs(int ms) async {
    _autoLockMs = ms;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoLockKey, ms);
  }

  Future<void> setLockOnScreenOff(bool value) async {
    _lockOnScreenOff = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_screenOffKey, value);
  }

  int get autoLockMs => _autoLockMs;
  bool get lockOnScreenOff => _lockOnScreenOff;

  void unlock() {
    _lockTimer?.cancel();
    state = SessionState.unlocked;
  }

  void lock() {
    _lockTimer?.cancel();
    ref.read(masterKeyManagerProvider).lock();
    state = SessionState.locked;
  }

  void scheduleLock() {
    _lockTimer?.cancel();
    if (_autoLockMs < 0) return; // never
    if (_autoLockMs == 0) {
      lock();
      return;
    }
    _lockTimer = Timer(Duration(milliseconds: _autoLockMs), lock);
  }

  void cancelScheduledLock() => _lockTimer?.cancel();

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    switch (lifecycleState) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        if (state == SessionState.unlocked) {
          if (_lockOnScreenOff) {
            lock();
          } else {
            scheduleLock();
          }
        }
      case AppLifecycleState.resumed:
        cancelScheduledLock();
      case AppLifecycleState.detached:
        lock();
      case AppLifecycleState.inactive:
        // Ignored: also fires for in-app overlays, dialogs and biometric prompts.
        break;
    }
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);

// Providers — declared here to avoid circular imports
final masterKeyManagerProvider = Provider<MasterKeyManager>((ref) {
  return MasterKeyManager(const FlutterSecureStorage());
});
