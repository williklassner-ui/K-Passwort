import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:k_passwort/core/constants/crypto_constants.dart';
import 'package:k_passwort/security/keystore/master_key_manager.dart';

enum SessionState { locked, unlocked }

class SessionNotifier extends Notifier<SessionState> with WidgetsBindingObserver {
  Timer? _lockTimer;

  @override
  SessionState build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _lockTimer?.cancel();
    });
    return SessionState.locked;
  }

  void unlock() {
    _lockTimer?.cancel();
    state = SessionState.unlocked;
  }

  void lock() {
    _lockTimer?.cancel();
    ref.read(masterKeyManagerProvider).lock();
    state = SessionState.locked;
  }

  void scheduleLock({int delayMs = CryptoConstants.autoLockDelayMs}) {
    _lockTimer?.cancel();
    _lockTimer = Timer(Duration(milliseconds: delayMs), lock);
  }

  void cancelScheduledLock() => _lockTimer?.cancel();

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    switch (lifecycleState) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        if (state == SessionState.unlocked) scheduleLock();
      case AppLifecycleState.resumed:
        cancelScheduledLock();
      case AppLifecycleState.detached:
        lock();
      case AppLifecycleState.hidden:
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
