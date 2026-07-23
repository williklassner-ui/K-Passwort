import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:k_passwort/core/constants/app_constants.dart';
import 'package:k_passwort/core/errors/failures.dart';
import 'package:k_passwort/security/crypto/secure_key.dart';
import 'package:k_passwort/security/keystore/android_keystore.dart';

/// Owns the in-memory master password used to open the KDBX vault.
///
/// The password is never persisted in plaintext. For biometric unlock it is
/// wrapped with a hardware-backed, user-authentication-required key in the
/// Android Keystore (see [AndroidKeystore]) — so it can only be recovered
/// after a successful BIOMETRIC_STRONG authentication. On lock the in-memory
/// copy is dropped.
class MasterKeyManager {
  MasterKeyManager(this._storage);

  final FlutterSecureStorage _storage;
  String? _rawPassword;

  bool get isUnlocked => _rawPassword != null;

  /// Remembers the password used to unlock the vault. The (already opened)
  /// KdbxFile retains its own credentials internally, so a key file — if any
  /// — is only required at open time and need not be kept here.
  Future<void> unlockWithPassword({
    required String password,
    Uint8List? keyFileBytes,
  }) async {
    _rawPassword = password;
  }

  /// Unlock via biometric: unwraps the master password from the Android
  /// Keystore (requires biometric auth). Returns the password so the caller
  /// can (re-)open the KDBX file.
  Future<String?> unlockWithBiometric() async {
    final wrappedKey = await _storage.read(key: AppConstants.wrappedKeyStorageKey);
    final iv = await _storage.read(key: AppConstants.wrappedKeyIvStorageKey);

    if (wrappedKey == null || iv == null) {
      throw const BiometricFailure('Kein biometrischer Schlüssel gespeichert');
    }

    final key = await AndroidKeystore.unwrapKey(wrappedKey: wrappedKey, iv: iv);
    try {
      final password = utf8.decode(key.bytes);
      _rawPassword = password;
      return password;
    } finally {
      key.dispose();
    }
  }

  /// Enable biometric unlock: wraps the current master password with the
  /// Android Keystore (hardware TEE, user-authentication required). The
  /// plaintext password is never written to storage — only its
  /// biometric-gated ciphertext.
  Future<void> enableBiometric() async {
    final password = _rawPassword;
    if (password == null) {
      throw StateError('Must be unlocked first');
    }

    await AndroidKeystore.generateKey();
    final passwordKey = SecureKey(Uint8List.fromList(utf8.encode(password)));
    try {
      final wrapped = await AndroidKeystore.wrapKey(passwordKey);
      await _storage.write(
          key: AppConstants.wrappedKeyStorageKey, value: wrapped['wrappedKey']);
      await _storage.write(
          key: AppConstants.wrappedKeyIvStorageKey, value: wrapped['iv']);
    } finally {
      passwordKey.dispose();
    }
  }

  Future<void> disableBiometric() async {
    await AndroidKeystore.deleteKey();
    await _storage.delete(key: AppConstants.wrappedKeyStorageKey);
    await _storage.delete(key: AppConstants.wrappedKeyIvStorageKey);
  }

  Future<bool> isBiometricEnabled() async {
    final key = await _storage.read(key: AppConstants.wrappedKeyStorageKey);
    return key != null;
  }

  void lock() {
    _rawPassword = null;
  }
}
